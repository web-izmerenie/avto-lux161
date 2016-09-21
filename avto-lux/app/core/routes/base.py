# -*- coding: utf-8 -*-

from tornado.web import RequestHandler
from app.mixins.routes import (
	MenuProviderMixin,
	NonRelationDataProvider,
	HelpersProviderMixin
)


class BaseHandler(
	RequestHandler,
	MenuProviderMixin,
	NonRelationDataProvider,
	HelpersProviderMixin
):
	def remove_html(self, arg):
		if arg.endswith('.html'):
			return arg.replace('.html', '')
		return arg
