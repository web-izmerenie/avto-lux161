# -*- coding: utf-8 -*-

import sys
import re
import os.path
import tornado.httpserver, tornado.ioloop, tornado.web
from tornado.options import define, options
import hashlib
from .core.routes import routes as core_routes
from .adm.routes import routes as admin_routes
import tornado

from .configparser import config
from .models.init_models import init_models
from .utils import collect_handlers, error_log, get_json_localization
from tornado.web import StaticFileHandler, _RequestDispatcher


handlers = []
try:
	#TODO Add sort routes function
	handlers = collect_handlers(admin_routes, core_routes)
except Exception as e:
	error_log(e)


settings = dict(
	template_path=os.path.join(os.getcwd(), config('TEMPLATES_PATH')),
	static_path=os.path.join(os.getcwd(), config('STATIC_PATH')),
	debug=(lambda: True if config('DEBUG') else False),
	autoreload=config('AUTO_RELOAD'),
	xsrf_cookies = config('XSRF'),
	cookie_secret = str(hashlib.sha512(os.urandom(300)).hexdigest()))

if not config('DEBUG'):
	settings['log_function'] = (lambda arg: None)


# for dirty hack of cyrillic redirects
_encoded_url_reg = re.compile('%[a-fA-F0-9]{2}')
def _reg_to_upper(matchobj):
	return matchobj.group(0).upper()


class _CustomRequestDispatcher(_RequestDispatcher):
	def set_request(self, request):
		request.uri = re.sub(_encoded_url_reg, _reg_to_upper, request.uri)
		request.path = re.sub(_encoded_url_reg, _reg_to_upper, request.path)
		_RequestDispatcher.set_request(self, request)


class Application(tornado.web.Application):
	def __init__(self, handlers=None, **kwargs):
		""" hack for dynamic robots.txt """

		tornado.web.Application.__init__(self, handlers, **kwargs)
		new_handlers = []
		for item in self.handlers[0][1]:
			if 'robots' in item.regex.pattern \
			and item.handler_class is StaticFileHandler:
				continue
			new_handlers.append(item)

		new_tuple = []
		for i in range(len(self.handlers[0])):
			if i == 1:
				new_tuple.append(new_handlers)
				continue
			new_tuple.append(self.handlers[0][i])

		self.handlers[0] = tuple(new_tuple)

	def start_request(self, connection):
		""" cutsom dispatcher for fixing request uri
		dirty hack (need to create issue about cyrillic redirects)
		see also: utils.py -> collect_handlers and UnicodeRedirectHandler """
		return _CustomRequestDispatcher(self, connection)

	def __call__(self, request):
		raise Exception('use "start_request" instead of __call__')


application = Application(handlers, **settings)
def run_instance(port, host):
	tornado.options.parse_command_line()
	application.listen(port, address=host)
	print("Server run on %s:%s" % (host, port))
	tornado.ioloop.IOLoop.instance().start()
