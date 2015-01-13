import os, json
from app.configparser import config
from app.utils import get_json_localization
import tornado.template
from .base import (
	AdminBaseHandler,
)
from app.mixins import AuthMixin

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
import datetime
patch_tornado()



class AdminMainRoute(AdminBaseHandler, JsonResponseMixin):
	def get(self, *args):

		lang = config('LOCALIZATION')['LANG']
		localization = get_json_localization('ADMIN')[lang]
		print()
		kwrgs = {
			'page_title' : localization['page_title'],
			'lang': lang,
			'local': localization,
			'is_auth': (lambda: 1 if self.get_current_user() else 0)(),
			'is_debug': (lambda: 1 if self.application.settings.get('debug') else 0)()
			}
		return self.render('admin/layout.jade', **kwrgs)


	def get_current_user(self):
		return self.get_secure_cookie('user')



class EmptyHandler(AdminBaseHandler):
	def get(self):
		self.write("Lolka")
	def post(self):
		return self.write("Hello!")



class AuthHandler(AdminBaseHandler, AuthMixin, JsonResponseMixin):
	def post(self):
		if self.get_current_user():
			return self.json_response({'status': 'success'}) ## TODO : Change status to already auth
		try:
			usr = session.query(User).filter_by(login=self.get_argument('user')).one()
		except Exception as e:
			print(e)
			return self.json_response({'status': 'error', 'error_code': 'user_not_found'})
		print(usr)
		compared = self.compare_password(hpasswd=usr.password, password=self.get_argument('pass'))
		print(compared)
		if compared:
			self.set_secure_cookie('user', usr.login)
			return self.json_response({'status': 'success'})
		return self.json_response({'status': 'error', 'error_code': 'incorrect_password'})


	def get_current_user(self):
		return self.get_secure_cookie('user')



class LogoutHandler(AdminBaseHandler, JsonResponseMixin):
	def get(self):
		self.clear_all_cookies()
		return self.json_response({'status': 'logout'})



class CreateUser(AdminBaseHandler, AuthMixin):
	def post(self):
		login = self.get_argument('user')
		passwd = self.get_argument('pass')
		usr = User(
			login=login,
			password=passwrd,
			last_login=datetime.datetime.utcnow(),
			is_active=True
			)
		session.add(usr)
		session.commit()
		return self.json_response({'status': 'created'})



class AdminMainHandler(AdminBaseHandler, JsonResponseMixin):
	actions = {
		# 'name': {
		# 	'func': 'func',
		# 	'args': 'args',
		# 	'kwargs': {}
		# }
	}

	def post(self):
		if not self.get_current_user():
			self.set_status(403)
			return self.json_response({'status': 'unauthorized'})

		print(self.request)
		return self.json_response({'status': 'lol'})

	def get_current_user(self):
		return self.get_secure_cookie('user')



class ImageLoadHandler(AdminBaseHandler, JsonResponseMixin):
	def post(self):
		files = (x for x in request.files)

		return self.json_response()
