import tornado.template
from .base import (
	AmdinBaseHandler, 
	AuthMixin
)

from app.mixins.routes_mixin import (
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


class AuthHandler(AmdinBaseHandler, AuthMixin, JsonResponseMixin):
	def post(self):
		self.set_secure_cookie('user', 'lolka')
		return self.json_response({'status': 'success'})

	def get_current_user(self):
		return self.get_secure_cookie('user')


class AdminMainHandler(AmdinBaseHandler, JsonResponseMixin):
	def post(self):
		print(self.request)
		return json_response({'status': 'lol'})