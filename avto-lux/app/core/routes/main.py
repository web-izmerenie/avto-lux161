import tornado.template
from .base import BaseHandler
from app.mixins.routes_mixin import ForbiddenPostPutHeadDeleteMixin
from pyjade.ext.tornado import patch_tornado
patch_tornado()


class MainRoute(BaseHandler, ForbiddenPostPutHeadDeleteMixin):
	def get(self):
		# self.render('index.jade')
		self.write("Hello!")


class StaticPageRoute(BaseHandler, ForbiddenPostPutHeadDeleteMixin):
	def get(self, alias):
		self.render('xxx.jade')

