# -*- coding: utf-8 -*-

import os, sys, json
import smtplib
from app.configparser import config
import decimal, datetime

class CollectHandlersException(Exception):
	def __repr__(self, e, list):
		return "{0}, {1}".format(e, list)



def collect_handlers(*args):
	def sort_func():
		pass

	routes  = []
	for item in args:
		routes += item
	routeslist = [(lambda y: y + '/' if not y.endswith('/') else y)(x[0]) for x in routes]
	duplicated = { x for x in routeslist if routeslist.count(x) > 1 }
	if len(duplicated) > 0:
		raise CollectHandlersException("Duplicate routes! {0}".format(duplicated))

	# print("Sorted: {0}".format(sorted(routes, key=sort_func, reverse=False)))
	# return sorted(routes, key=lambda x: x[0], reverse=True)
	return routes


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


def send_mail(msg=None):
	mailc = config('MAIL')
	to = mailc['MAIN_RECIPIENT']
	gmail_user = mailc['USER']
	gmail_pwd = mailc['PASS']

	smtpserver = smtplib.SMTP(mailc['SMTP_PROVIDER']['HOST'], mailc['SMTP_PROVIDER']['PORT'])
	smtpserver.ehlo()
	smtpserver.starttls()
	smtpserver.ehlo
	smtpserver.login(gmail_user, gmail_pwd)
	header = 'To:' + to + '\n' + 'From: WEBSITE:: avto-lux.ru\n' + 'Subject:testing \n'
	msg = msg or ''
	smtpserver.sendmail(gmail_user, to, msg)
	smtpserver.close()



def is_date(obj):
	if isinstance(obj, datetime.date):
		return obj.isoformat()

def to_json(obj):
	return json.dumps([dict(x) for x in obj], default=is_date)
