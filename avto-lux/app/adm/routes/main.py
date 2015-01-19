import os, json
import hashlib
import time
from app.configparser import config
from app.utils import get_json_localization
import tornado.template

from app.mixins import AuthMixin

from app.mixins.routes_mixin import (
	JsonResponseMixin
)

from pyjade.ext.tornado import patch_tornado

from app.models.dbconnect import Session
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



class AdminMainRoute(JsonResponseMixin):
	def get(self, *args):

		lang = config('LOCALIZATION')['LANG']
		localization = get_json_localization('ADMIN')[lang]
		kwrgs = {
			'page_title' : localization['page_title'],
			'lang': lang,
			'local': localization,
			'is_auth': (
				lambda: 1 if self.get_current_user() else 0)(),
			'is_debug': (
				lambda: 1 \
					if self.application.settings.get('debug') \
					else 0)()
			}
		return self.render('admin/layout.jade', **kwrgs)


	def get_current_user(self):
		return self.get_secure_cookie('user')


class AuthHandler(AuthMixin, JsonResponseMixin):
	def post(self):
		session = Session()
		if self.get_current_user():
			return self.json_response({'status': 'success'}) ## TODO : Change status to already auth
		try:
			usr = session.query(User).filter_by(
				login=self.get_argument('user')
				).one()
		except Exception as e:
			print(e)
			return self.json_response({
				'status': 'error',
				'error_code': 'user_not_found'})

		compared = self.compare_password(
			hpasswd=usr.password,
			password=self.get_argument('pass'))

		if compared and usr.is_active:
			self.set_secure_cookie('user', usr.login)
			return self.json_response({'status': 'success'})
		elif not usr.is_active:
			return self.json_response({
				'status': 'error',
				'error_code': 'user_inactive'
				})
		return self.json_response({
			'status': 'error',
			'error_code': 'incorrect_password'})


	def get_current_user(self):
		return self.get_secure_cookie('user')



class LogoutHandler(JsonResponseMixin):
	def post(self):
		self.clear_all_cookies()
		return self.json_response({'status': 'logout'})



class CreateUser(AuthMixin, JsonResponseMixin):
	def post(self):
		session = Session()
		login = self.get_argument('login')
		passwd = self.get_argument('password')
		is_active = True
		olds = [x[0] for x in session.query(User.login).all()]

		if login == '':
			return self.json_response({
				'status': 'error',
				'error_code': 'unique_key_exist'
				})
		elif login in olds:
			return self.json_response({
				'status': 'error',
				'error_code': 'incorrect_data'
				})
		try:
			self.get_argument('is_active')
		except:
			is_active = False

		print(login, passwd)
		usr = User(
			login=login,
			password=self.create_password(passwd),
			last_login=datetime.datetime.utcnow(),
			is_active=is_active
			)
		session.add(usr)
		session.commit()
		return self.json_response({'status': 'success'})


class UpdateUser(AuthMixin, JsonResponseMixin):
	def post(self):
		session = Session()
		kwargs = {}
		passwrd = self.get_argument('password')
		login = self.get_argument('login')
		id = self.get_argument('id')
		is_active = True
		try:
			self.get_argument('is_active')
		except:
			is_active = False
		usr = session.query(User).filter_by(id=id).one()

		olds = [x[0] for x in session.query(User.login).all()]
		if login == '':
			return self.json_response({
				'status': 'error',
				'error_code': 'unique_key_exist'
				})
		elif usr.login != login and login in olds:
			return self.json_response({
				'status': 'error',
				'error_code': 'incorrect_data'
				})

		kwargs.update({'login': login, 'is_active': is_active})
		if passwrd != '':
			kwargs.update({'password': self.create_password(passwrd)})

		session.query(User).filter_by(id=id).update(kwargs)
		session.commit()
		return self.json_response({'status': 'success'})




class FileUpload(JsonResponseMixin):
	@request_except_handler
	def post(self):
		if not self.get_current_user():
			self.set_status(403)
			return self.json_response({
				'status': 'unauthorized'
				})

		print(self.request.headers)
		file_path = config('UPLOAD_FILES_PATH')
		hashes = []
		for f in self.request.files.items():
			_file = f[1][0]
			print(_file['content_type'])


			_filename = hashlib.sha512(str(time.time()).encode('utf-8')).hexdigest()[0:35]
			fname = _filename + '.' + _file['content_type'].split('/')[1]

			f = open(os.path.join(file_path, fname), 'wb')
			f.write(_file['body'])
			f.close()
			hashes.append({ 'name': fname })


			print("File: %s was uploaded" % _file['filename'])
		return self.json_response({
			'status': 'success',
			'files': hashes
			})

	def get_current_user(self):
		return self.get_secure_cookie('user')



class FileSave(JsonResponseMixin):
	pass
