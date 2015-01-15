import hashlib
from tornado.web import RequestHandler
from app.mixins.routes_mixin import (
	success_response,
	error_response,
	not_found_response
	)


class TemplateView(RequestHandler):
	template = ''
	kwargs = {}
	def get(self, *args):

		return self.render(template, **kwargs)
