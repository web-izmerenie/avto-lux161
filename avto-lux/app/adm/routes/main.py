import tornado.template
from .base import (
	AmdinBaseHandler, 
	AuthMixin
)

from app.mixins.routes_mixin import (
	Custom404Mixin, 
	JsonResponseMixin
)

from pyjade.ext.tornado import patch_tornado

from app.models.dbconnect import session
## Debug
from app.models.usermodels import User
from app.models.pagemodels import (
	StaticPageModel,
	UrlMapping
)
from app.models.catalogmodels import(
	CatalogSectionModel,
	CatalogItemModel
)
patch_tornado()


class AdminMainRoute(AmdinBaseHandler):
	def get(self):
		return self.render('admin/layout.jade')


class EmptyHandler(AmdinBaseHandler):
	def get(self):
		self.write("Lolka")
	def post(self):
		return self.write("Hello!")


class AuthHandler(AmdinBaseHandler, AuthMixin):
	def post(self):
		pass