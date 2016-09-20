# -*- coding: utf-8 -*-

import os
import hashlib
import time
import sys
from app.configparser import config
from app.utils import get_json_localization

from app.mixins import AuthMixin

from app.mixins.routes_mixin import (
	JsonResponseMixin
)

from app.models.dbconnect import Session
from app.models.usermodels import User
import datetime


def request_except_handler(fn):
	def wrap(*args, **kwargs):
		self = args[0]
		try:
			return fn(*args, **kwargs)
		except NoArgumentFound as e:
			print(
				'adm/request_except_handler(): NoArgumentFound:\n',
				e, file=sys.stderr
			)
			return self.json_response({
				'status': 'error',
				'error_code': 'Too less arguments was send'
			})
		except Exception as e:
			print(
				'adm/request_except_handler(): error:\n',
				e, file=sys.stderr
			)
			return self.json_response({
				'status': 'error',
				'error_code': 'system_fail'
			})
	wrap.__name__ = fn.__name__
	return wrap


class AdminMainRoute(JsonResponseMixin):
	
	def get(self, *args):
		lang = config('LOCALIZATION')['LANG']
		localization = get_json_localization('ADMIN')[lang]
		kwrgs = {
			'page_title': localization['page_title'],
			'lang': lang,
			'local': localization,
			'is_auth': 1 if self.get_current_user() else 0,
			'is_debug': 1 if self.application.settings.get('debug') else 0
		}
		return self.render('admin/layout.jade', **kwrgs)
	
	def get_current_user(self):
		return self.get_secure_cookie('user')


class AuthHandler(AuthMixin, JsonResponseMixin):
	
	def post(self):
		
		if self.get_current_user():
			return self.json_response({'status': 'success'})
		
		session = Session()
		try:
			usr = (
				session
					.query(User)
					.filter_by(login=self.get_argument('user'))
					.one()
			)
		except Exception as e:
			print(
				'adm/AuthHandler.post(): user not found:\n',
				e, file=sys.stderr
			)
			return self.json_response({
				'status': 'error',
				'error_code': 'user_not_found'
			})
		finally:
			session.close()
		
		compared = self.compare_password(
			hpasswd=usr.password,
			password=self.get_argument('pass')
		)
		
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
			'error_code': 'incorrect_password'
		})
	
	def get_current_user(self):
		return self.get_secure_cookie('user')


class LogoutHandler(JsonResponseMixin):
	def post(self):
		self.clear_all_cookies()
		return self.json_response({'status': 'logout'})


class CreateUser(AuthMixin, JsonResponseMixin):
	
	def post(self):
		
		login = self.get_argument('login')
		passwd = self.get_argument('password')
		
		session = Session()
		
		try:
			olds = [x[0] for x in session.query(User.login).all()]
		except Exception as e:
			session.close()
			print(
				'adm/CreateUser.post(): cannot get users logins:\n',
				e, file=sys.stderr
			)
			raise e
		
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
		
		is_active = True
		try:
			self.get_argument('is_active')
		except:
			is_active = False
		
		usr = User(
			login=login,
			password=self.create_password(passwd),
			last_login=datetime.datetime.utcnow(),
			is_active=is_active
		)
		
		try:
			session.add(usr)
			session.commit()
		except Exception as e:
			print(
				'adm/CreateUser.post(): cannot add user:\n',
				e, file=sys.stderr
			)
			raise e
		finally:
			session.close()
		
		return self.json_response({'status': 'success'})


class UpdateUser(AuthMixin, JsonResponseMixin):
	
	def post(self):
		
		kwargs = {}
		passwrd = self.get_argument('password')
		login = self.get_argument('login')
		id = self.get_argument('id')
		
		is_active = True
		try:
			self.get_argument('is_active')
		except:
			is_active = False
		
		session = Session()
		try:
			usr = session.query(User).filter_by(id=id).one()
		except Exception as e:
			session.close()
			print(
				'adm/UpdateUser.post(): cannot get user'+
				' by #%s id:\n' % str(id),
				e, file=sys.stderr
			)
			raise e
		
		try:
			olds = [x[0] for x in session.query(User.login).all()]
		except Exception as e:
			session.close()
			print(
				'adm/UpdateUser.post(): cannot get users logins:\n',
				e, file=sys.stderr
			)
			raise e
		
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
		
		kwargs.update({
			'login': login,
			'is_active': is_active
		})
		if passwrd != '':
			kwargs.update({'password': self.create_password(passwrd)})
		
		try:
			session.query(User).filter_by(id=id).update(kwargs)
			session.commit()
		except Exception as e:
			print('adm/UpdateUser.post(): cannot update '+\
				'user #%s data:\n' % str(id),\
				e, file=sys.stderr)
			raise e
		finally:
			session.close()
		
		return self.json_response({'status': 'success'})


class FileUpload(JsonResponseMixin):
	
	@request_except_handler
	def post(self):
		
		if not self.get_current_user():
			self.set_status(403)
			return self.json_response({'status': 'unauthorized'})
		
		file_path = config('UPLOAD_FILES_PATH')
		hashes = []
		for f in self.request.files.items():
			_file = f[1][0]
			
			_filename = hashlib.sha512(
				str(time.time()).encode('utf-8')
			).hexdigest()[0:35]
			fname = _filename + '.' + _file['content_type'].split('/')[1]
			
			f = open(os.path.join(file_path, fname), 'wb')
			f.write(_file['body'])
			f.close()
			hashes.append({'name': fname})
		
		return self.json_response({
			'status': 'success',
			'files': hashes
		})
	
	def get_current_user(self):
		return self.get_secure_cookie('user')


class FileSave(JsonResponseMixin):
	pass
