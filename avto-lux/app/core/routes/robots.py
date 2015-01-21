from .base import BaseHandler
from app.configparser import config


class RobotsTxtRoute(BaseHandler):
	def get(self):
		data = {'is_debug': config('DEBUG')}
		self.set_header('Content-Type', 'text/plain; charset="utf-8"')
		return self.render('client/robots.jade', **data)
