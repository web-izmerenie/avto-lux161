# -*- coding: utf-8 -*-

from warnings import warn
from sqlalchemy.orm.exc import NoResultFound


# decorator to catch exceptions
# supposed to be used with JsonResponseMixin
def query_except_handler(fn):
	def wrap(*args, **kwargs):
		self = args[0]
		try:
			return fn(*args, **kwargs)
		except NoResultFound as n:
			self.set_status(404)
			return self.json_response({
				'status': 'data_not_found'
			})
		except Exception as e:
			# TODO FIXME instance of exception
			if e.__class__.__name__ == 'IntegrityError':
				warn('adm/query_except_handler(): IntegrityError:\n%s' % e)
				return self.json_response({
					'status': 'error',
					'error_code': 'unique_key_exist',
				})
			# TODO FIXME instance of exception
			elif e.__class__.__name__ == 'DataError':
				warn('adm/query_except_handler(): DataError:\n%s' % e)
				return self.json_response({
					'status': 'error',
					'error_code': 'incorrect_data',
				})
			warn('adm/query_except_handler(): error:\n%s' % e)
			self.set_status(500)
			return self.json_response({
				'status': 'error',
				'error_code': 'system_fail'
			})
	wrap.__name__ = fn.__name__
	return wrap


# decorator to catch exceptions
# supposed to be used with JsonResponseMixin
def request_except_handler(fn):
	def wrap(*args, **kwargs):
		self = args[0]
		try:
			return fn(*args, **kwargs)
		except NoArgumentFound as e:
			warn('adm/request_except_handler(): NoArgumentFound:\n%s' % e)
			return self.json_response({
				'status': 'error',
				'error_code': 'not_enough_arguments'
			})
		except Exception as e:
			warn('adm/request_except_handler(): error:\n%s' % e)
			return self.json_response({
				'status': 'error',
				'error_code': 'system_fail'
			})
	wrap.__name__ = fn.__name__
	return wrap


# decorator to mark that authentication is required
# supposed to be used with JsonResponseMixin
# see also http://stackoverflow.com/a/15337710/774228
def require_auth(fn):
	def wrap(*args, **kwargs):
		self = args[0]
		if self.get_secure_cookie('user'):
			return fn(*args, **kwargs)
		else:
			self.set_status(403)
			return self.json_response({'status': 'unauthorized'})
	wrap.__name__ = fn.__name__
	return wrap
