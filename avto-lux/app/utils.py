# -*- coding: utf-8 -*-

import os, sys, json
import smtplib
from app.configparser import config
import decimal, datetime
from app.models.dbconnect import Session
from tornado.web import RedirectHandler
from app.models.pagemodels import UrlMapping


class CollectHandlersException(Exception):
	def __repr__(self, e, list):
		return "{0}, {1}".format(e, list)


def collect_handlers(*args):
	routes = []
	for item in args:
		routes += item
	duplicated = {x for x in routes if routes.count(x) > 1}
	if len(duplicated) > 0:
		raise CollectHandlersException("Duplicate routes! {0}".format(duplicated))

	redirect_routes = []
	session = Session()
	_rr = session.query(UrlMapping).all()
	for redirect in _rr:
		redirect_routes.append((redirect.old_url, RedirectHandler, {
			'url': redirect.new_url,
			'permanent': (lambda: True if int(redirect.status) == 302 else False)()
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
		"From: %s\r\n" % from_addr +
		"To: %s\r\n" % to +
		"Subject: %s\r\n" % theme +
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
