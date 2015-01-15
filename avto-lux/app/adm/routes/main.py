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

from app.models.dbconnect import Session
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
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql import func
import datetime
patch_tornado()


def request_except_handler(fn):
	def wrap(*args, **kwargs):
		self = args[0]
		try:
			return fn(*args, **kwargs)
		except NoArgumentFound as n:
			print(n)
			return self.json_response({
				'status': 'error',
				'error_code': 'Too less arguments was send'})
		except Exception as e:
			print(e)
			return self.json_response({
				'status': 'error',
				'error_code': 'system_fail'})
	wrap.__name__ = fn.__name__
	return wrap



def query_except_handler(fn):
	def wrap(*args, **kwargs):
		self = args[0]
		try:
			return fn(*args, **kwargs)
		except NoResultFound as n:
			print(n)
			return self.json_response({'status': 'not_found'})
		except Exception as e:
			print(e)
			return self.json_response({
				'status': 'error',
				'error_code': 'system_fail'})
	wrap.__name__ = fn.__name__
	return wrap


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
		session = Session()
		if self.get_current_user():
			return self.json_response({'status': 'success'}) ## TODO : Change status to already auth
		try:
			usr = session.query(User).filter_by(login=self.get_argument('user')).one()
		except Exception as e:
			print(e)
			return self.json_response({
				'status': 'error',
				'error_code': 'user_not_found'})
		print(usr)
		compared = self.compare_password(
			hpasswd=usr.password,
			password=self.get_argument('pass'))
		print(compared)
		if compared:
			self.set_secure_cookie('user', usr.login)
			return self.json_response({'status': 'success'})
		return self.json_response({
			'status': 'error',
			'error_code': 'incorrect_password'})


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
	def post(self):
		if not self.get_current_user():
			self.set_status(403)
			return self.json_response({'status': 'unauthorized'})

		action = self.get_argument('action')
		kwrgs = {}
		actions = {
			'get_pages_list': self.get_pages_list,
			'get_static_page': self.get_static_page,
			'get_catalog_sections': self.get_catalog_sections,
			'get_catalog_list': self.get_catalog_list
		}

		if action not in actions.keys():
			return self.json_response({'status': 'lol'})
		func = actions[action]
		return func(**kwrgs)


	def get_current_user(self):
		return self.get_secure_cookie('user')

	@query_except_handler
	def get_pages_list(self):
		session = Session()
		data = session.query(
			StaticPageModel.title,
			StaticPageModel.id,
			StaticPageModel.alias
			).all()
		return self.json_response({
			'status': 'success',
			'data_list': [{
				'title': x.title,
				'id': x.id,
				'alias': x.alias
				} for x in data ]
			})

	@query_except_handler
	def get_static_page(self, id=None):
		print(id)
		if not id:
			return self.json_response({'status': 'error'})
		session = Session()
		data = session.query(
			StaticPageModel
			).filter_by(id=id)


	@query_except_handler
	def get_catalog_sections(self):
		session = Session()
		counts = session.query(
			func.count(CatalogItemModel.section_id)
			).group_by(CatalogItemModel.section_id).all()
		data = session.query(
			CatalogSectionModel.title,
			CatalogSectionModel.id
			).all()
		return self.json_response({
			'status': 'success',
			'data_list': [{
				'id': x[1][1],
				'title': x[1][0],
				'count': x[0][0]
			} for x in list(zip(counts, data))]
		})

	@query_except_handler
	def get_catalog_list(self):
		session=Session()
		data = session.query(
			CatalogItemModel.id,
			CatalogItemModel.title,
			CatalogItemModel.alias
			).all()

		return self.json_response({
			'status': 'success',
			'data_list': [{
				'title': x.title,
				'id': x.id,
				'alias': x.alias
				} for x in data ]
			})


		return self.json_response({'status':'test'})

class ImageLoadHandler(AdminBaseHandler, JsonResponseMixin):
	def post(self):
		files = (x for x in request.files)

		return self.json_response()
