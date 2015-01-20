from tornado.web import RequestHandler
from tornado.template import Loader

import os


class BaseHandler(RequestHandler):
	def remove_html(self, arg):
		if arg.endswith('.html'):
			return arg.replace('.html', '')
		return arg
