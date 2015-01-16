import os, json
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


def query_except_handler(fn):
	def wrap(*args, **kwargs):
		self = args[0]
		try:
			return fn(*args, **kwargs)
		except NoResultFound as n:
			print(n)
			self.set_status(404)
			return self.json_response({'status': 'data_not_found'})
		except Exception as e:
			print(e)
			self.set_status(500)
			return self.json_response({
				'status': 'error',
				'error_code': 'system_fail'})
	wrap.__name__ = fn.__name__
	return wrap


class AdminMainHandler(JsonResponseMixin):
	def post(self):
		if not self.get_current_user():
			self.set_status(403)
			return self.json_response({'status': 'unauthorized'})

		action = self.get_argument('action')
		kwrgs = {}
		try:
			kwrgs = json.loads(self.get_argument('args'))
		except:
			kwrgs = {}
		print(kwrgs)

		actions = {
			'get_pages_list': self.get_pages_list,
			'get_catalog_sections': self.get_catalog_sections,
			'get_catalog_elements': self.get_catalog_elements,
			'get_redirect_list': self.get_redirect_list,
			'get_accounts_list': self.get_accounts_list,
			'get_fields': self.get_fields
		}

		if action not in actions.keys():
			return self.json_response({'status': 'error'})
		func = actions[action]
		return func(**kwrgs)


	def get_current_user(self):
		return self.get_secure_cookie('user')


	@query_except_handler
	def get_pages_list(self):
		session = Session()
		data = session.query(StaticPageModel).all()
		return self.json_response({
			'status': 'success',
			'data_list': [ x.static_list for x in data ]
			})

	## TODO : Optimize and using join
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
	def get_catalog_elements(self, id=id):
		session=Session()
		data = session.query(
			CatalogItemModel.id,
			CatalogItemModel.title,
			).filter_by(section_id=id).all()
		title = session.query(
			CatalogSectionModel.title
			).filter_by(id=id).one()

		return self.json_response({
			'status': 'success',
			'section_title': title[0],
			'data_list': [{
				'title': x.title,
				'id': x.id
				} for x in data ]
			})

	@query_except_handler
	def get_redirect_list(self):
		session = Session()
		data = session.query(UrlMapping).all()
		return self.json_response({
			'status':'success',
			'data_list': [x.item for x in data]
			})
		# return self.json_response({
		# 	'status': 'success',
		# 	'data_list': [{
		# 		'new_url': x.new_url,
		# 		'old_url': x.old_url,
		# 		'id': x.id,
		# 		'status': 301 ## TODO :: Change model
 	# 			} for x in data ]
		# 	})

	@query_except_handler
	def get_accounts_list(self):
		session = Session()
		data = session.query(User).all()
		return self.json_response({
			'status': 'success',
			'data_list': [{
				'id': x.id,
				'login': x.login,
				'is_active': x.is_active
				} for x in data ]
			})


	@query_except_handler
	def get_static_page(self, id):
		session = Session()
		data = session.query(StaticPageModel).filter_by(id=id).one()
		print(data.one_record)
		return self.json_response({
			'status': 'success',
			'data': data.item
			})

	@query_except_handler
	def update_static_page(self):
		pass

	@query_except_handler
	def create_static_page(self):
		pass

	@query_except_handler
	def get_fields(self, model):
		session = Session()
		models = {
			'static_page': StaticPageModel
		}
		return self.json_response({
			'status': 'success',
			'fields_list': session.query(models[model]).first().fields
			})

class ImageLoadHandler(JsonResponseMixin):
	def post(self):
		files = (x for x in request.files)

		return self.json_response()
