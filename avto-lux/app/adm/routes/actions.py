# -*- coding: utf-8 -*-

import os, json, sys
from app.configparser import config
from app.utils import get_json_localization
import tornado.template

from app.mixins import AuthMixin

from app.mixins.routes_mixin import (
	JsonResponseMixin
)

from app.models.dbconnect import Session, db_inspector
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
import time

from tornado.web import RedirectHandler, URLSpec


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
			if e.__class__.__name__ == 'IntegrityError':
				print(e, file=sys.stderr)
				return self.json_response({
					'status': 'error',
					'error_code': 'unique_key_exist',
					})
			elif e.__class__.__name__ == 'DataError':
				print(e, file=sys.stderr)
				return self.json_response({
					'status': 'error',
					'error_code': 'incorrect_data',
					})
			print(e, file=sys.stderr)
			self.set_status(500)
			return self.json_response({
				'status': 'error',
				'error_code': 'system_fail'
				})
	wrap.__name__ = fn.__name__
	return wrap


class AdminMainHandler(JsonResponseMixin):
	def post(self):
		if not self.get_current_user():
			self.set_status(403)
			return self.json_response({
				'status': 'unauthorized'
				})

		action = self.get_argument('action')
		kwrgs = {}
		try:
			kwrgs = json.loads(self.get_argument('args'))
		except:
			kwrgs = {}

		actions = {
			'get_pages_list': self.get_pages_list,
			'get_catalog_sections': self.get_catalog_sections,
			'get_catalog_elements': self.get_catalog_elements,
			'get_redirect_list': self.get_redirect_list,
			'get_accounts_list': self.get_accounts_list,
			'get_fields': self.get_fields,
			'add': self.create_page,
			'update': self.update_page
		}

		if action not in actions.keys():
			return self.json_response({
				'status': 'error',
				'error_code': 'non_existent_action'})
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

	## TODO : Optimize and using join ¯\(°_o)/¯
	@query_except_handler
	def get_catalog_sections(self):
		session = Session()
		cats = session.query(CatalogSectionModel.id).all()
		counts = []
		for i in cats:
			count = session.query(
				CatalogItemModel.id).filter_by(section_id=i[0]).all()
			counts.append((len(count),))

		data = session.query(
			CatalogSectionModel.title,
			CatalogSectionModel.id,
			CatalogSectionModel.is_active
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
	def get_catalog_elements(self, id=None):
		session=Session()
		data = session.query(
			CatalogItemModel.id,
			CatalogItemModel.title,
			CatalogItemModel.is_active
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
	def get_static_page(self, id=None):
		session = Session()
		data = session.query(StaticPageModel).filter_by(id=id).one()
		return self.json_response({
			'status': 'success',
			'data': data.item
			})


	@query_except_handler
	def create_page(self, **kwargs):
		section = kwargs['section']
		del kwargs['section']

		for item in (x for x
			in kwargs.keys()
				if x.startswith('is_')
					or x.startswith('has_')):
			kwargs[item] = True

		section_map = {
			'pages': StaticPageModel,
			'redirect': UrlMapping,
			'catalog_section': CatalogSectionModel,
			'catalog_element': CatalogItemModel,
		}
		session = Session()

		page = section_map[section](**kwargs)
		session.add(page)

		if section == 'redirect':
			permanent = (lambda: True if kwargs['status'] == '301' else False)()
			from app.app import application

			application.handlers[0][1][:0] = [
				URLSpec(
					kwargs['old_url'] + '$',
					RedirectHandler,
					kwargs={
						'url': kwargs['new_url'],
						'permanent': permanent
						},
					name=None)
			]
		session.commit()
		session.close()

		return self.json_response({'status': 'success'})

	##TODO :: Clear shitcode
	@query_except_handler
	def update_page(self, **kwargs):
		section = kwargs['section']
		del kwargs['section']
		id = kwargs['id']
		del kwargs['id']

		section_map = {
			'pages': StaticPageModel,
			'redirect': UrlMapping,
			'catalog_section': CatalogSectionModel,
			'catalog_element': CatalogItemModel,
		}

		fields = db_inspector.get_columns(
			section_map[section].__tablename__
			)

		for item in (x for x
			in fields
				if x['name'].startswith('is_')
					or x['name'].startswith('has_')
						or x['name'].startswith('inherit_seo_')):
			if item['name'] not in kwargs.keys():
				kwargs.update({ item['name']: False })
			else:
				kwargs[item['name']] = True

		session = Session()
		data = session.query(
			section_map[section]
				).filter_by(id=id)

		if section == 'redirect':
			permanent = (lambda: True if kwargs['status'] == '301' else False)()
			from app.app import application
			counter = 0
			hndlr = application.handlers[0][1]
			for item in range(len(hndlr)):
				try:
					if(hndlr[item].__dict__['kwargs']['url'] == data.one().new_url):
						hndlr[item] = URLSpec(
							kwargs['old_url'] + '$',
							RedirectHandler,
							kwargs={
								'url': kwargs['new_url'],
								'permanent': permanent
								},
							name=None)
				except KeyError:
					continue
		data.update(kwargs)
		session.commit()
		return self.json_response({'status': 'success'})


	@query_except_handler
	def get_fields(self, model=None, edit=False, id=None):
		session = Session()
		models = {
			'pages': StaticPageModel,
			'redirect': UrlMapping,
			'catalog_section': CatalogSectionModel,
			'catalog_element': CatalogItemModel,
			'accounts': User
		}

		fields = db_inspector.get_columns(
			models[model].__tablename__
			)

		# TODO :: this shit really needs refactoring
		types_map = {
			'BOOLEAN': 'checkbox',
			'TEXT': 'html',
			'VARCHAR(4096)': 'text',
			'VARCHAR(8192)': 'text',
			'VARCHAR(5000)': 'password',
			'JSON': 'files',
			'INTEGER': 'text'
		}
		vidgets = []

		for field in fields:
			try:
				if 'id' in field['name']:
					continue
				vidget = {
					'name': field['name'],
					'type': types_map[str(field['type'])],
					'default_val': field['default']
				}
				vidgets.append(vidget)
			except KeyError:
				continue

		values = None
		if edit and id is not None:
			data = session.query(models[model]).filter_by(id=id).one()
			values = data.item

			if model == 'catalog_element':
				print("SID:: %s" % data.section_id)
				values.update({'section_id': data.section_id})

		if model == 'catalog_element':
			sections = session.query(CatalogSectionModel).all()

			vidgets.append({
				'name': 'section_id',
				'type': 'select',
				'default_val': None,
				'list_values': [{
					'title': x.title,
					'value': x.id} for x in sections]
				})

		try:
			del values['create_date']
			del values['last_change']
			del values['_sa_instance_state']
			del values['password']
		except Exception:
			pass

		return self.json_response({
			'status': 'success',
			'fields_list': vidgets,
			'values_list': values
			})
