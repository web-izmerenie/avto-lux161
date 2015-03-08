# -*- coding: utf-8 -*-

from .base import BaseHandler
from app.configparser import config
from .decorators import route_except_handler


class RobotsTxtRoute(BaseHandler):
	@route_except_handler
	def get(self):
		data = {'is_debug': config('DEBUG')}
		self.set_header('Content-Type', 'text/plain; charset="utf-8"')
		data.update(self.get_nonrel_handlers())
		return self.render('client/robots.jade', **data)

	def head(self):
		return self.get()
