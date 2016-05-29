# -*- coding: utf-8 -*-

import os
import sys
import json
import smtplib
from app.configparser import config
import datetime
from app.models.dbconnect import Session
from tornado.web import RequestHandler
from app.models.pagemodels import UrlMapping
from urllib.parse import quote



class LazyMemoizeWrapper:
	def __init__(self, f):
		self._getter = f
	def __call__(self):
		try:
			return self._value
		except AttributeError:
			self._value = self._getter();
			return self._value


class CollectHandlersException(Exception):
	def __repr__(self, e, list):
		return "{0}, {1}".format(e, list)


class UnicodeRedirectHandler(RequestHandler):
	def initialize(self, url, status=302):
		self._url = url
		self._status = status
	
	def get(self):
		if self._headers_written:
			raise Exception("Cannot redirect after headers have been written")
		assert isinstance(self._status, int) and 300 <= self._status <= 399
		
		self.set_status(self._status)
		self.set_header('Location', self._url)
		self.finish()


def collect_handlers(*args):
	routes = []
	for item in args:
		routes += item
	duplicated = {x for x in routes if routes.count(x) > 1}
	if len(duplicated) > 0:
		raise CollectHandlersException("Duplicate routes! {0}".format(duplicated))
	
	redirect_routes = []
	session = Session()
	try:
		_rr = session.query(UrlMapping).all()
	except Exception as e:
		session.close()
		print('collect_handlers(): cannot get data from UrlMapping model:\n',\
			e, file=sys.stderr)
		raise e
	for redirect in _rr:
		old_url = quote(redirect.old_url, encoding='utf-8')
		redirect_routes.append((old_url, UnicodeRedirectHandler, {
			'url': redirect.new_url,
			'status': int(redirect.status)
		}))
	session.close()
	return redirect_routes + routes


def error_log(error):
	print("An error occured! \n{0}".format(error))
	sys.exit(1)


def get_json_localization(side):
	pathc = config('LOCALIZATION')['SOURCES']
	if side is None and not pathc[side]:
		raise Exception("Incorrect localization source")
	
	f = open(os.path.join(os.getcwd(), pathc[side]), 'r')
	jn = json.loads(''.join([line for line in f]))
	f.close()
	return jn


def send_mail(msg=None, theme=None):
	mailc = config('MAIL')
	from_addr = mailc['FROM_ADDRESS']
	to = mailc['MAIN_RECIPIENT']
	user = mailc['USER']
	pwd = mailc['PASS']
	
	smtpserver = smtplib.SMTP(
		mailc['SMTP_PROVIDER']['HOST'], mailc['SMTP_PROVIDER']['PORT'])
	smtpserver.ehlo()
	smtpserver.starttls()
	smtpserver.login(user, pwd)
	body = ''.join(
		"Content-Type: text/html; charset=utf-8\r\n" +
		("From: %s\r\n" % from_addr) +
		("To: %s\r\n" % to) +
		("Subject: %s\r\n" % theme) +
		"\r\n" +
		msg +
		"\r\n"
	)
	smtpserver.sendmail(user, to, body.encode('utf-8'))
	smtpserver.close()


def is_date(obj):
	if isinstance(obj, datetime.date):
		return obj.isoformat()


def to_json(obj):
	return json.dumps([dict(x) for x in obj], default=is_date)
