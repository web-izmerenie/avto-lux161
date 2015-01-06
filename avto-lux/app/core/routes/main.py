import tornado.template
from .base import BaseHandler
from app.mixins.routes_mixin import Custom404Mixin
from pyjade.ext.tornado import patch_tornado
patch_tornado()


class MainRoute(BaseHandler, Custom404Mixin):
	def get(self):
		# self.render('layout.jade')
		return self.render("sdfds.jade")


class PageRoute(BaseHandler, Custom404Mixin):
	def get(self, alias):
		self.render('xxx.jade')

class ItemRoute(BaseHandler, Custom404Mixin):
	def get(self, category, item):
		return self.render('yyy.jade')