# -*- coding: utf-8 -*-

import os, json, sys
import datetime
import time
import tornado.template
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql import func
from tornado.web import RedirectHandler, URLSpec


from app.configparser import config

from app.utils import get_json_localization

from app.mixins import AuthMixin
from app.mixins.routes_mixin import JsonResponseMixin

from app.models.dbconnect import Session, db_inspector
from app.models.usermodels import User
from app.models.pagemodels import (StaticPageModel, UrlMapping)
from app.models.non_relation_data import NonRelationData
from app.models.catalogmodels import (CatalogSectionModel, CatalogItemModel)


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
				print(
					'adm/query_except_handler(): IntegrityError:\n',
					e, file=sys.stderr
				)
				return self.json_response({
					'status': 'error',
					'error_code': 'unique_key_exist',
				})
			elif e.__class__.__name__ == 'DataError':
				print(
					'adm/query_except_handler(): DataError:\n',
					e, file=sys.stderr
				)
				return self.json_response({
					'status': 'error',
					'error_code': 'incorrect_data',
				})
			print('adm/query_except_handler(): error:\n', e, file=sys.stderr)
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
			return self.json_response({ 'status': 'unauthorized' })
		
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
			'get_data_list': self.get_data_list,
			'get_fields': self.get_fields,
			'add': self.create,
			'update': self.update_page,
			'delete': self.delete_smth
		}
		
		if action not in actions.keys():
			return self.json_response({
				'status': 'error',
				'error_code': 'non_existent_action'
			})
		func = actions[action]
		
		return func(**kwrgs)
	
	
	def get_current_user(self):
		return self.get_secure_cookie('user')
	
	
	@query_except_handler
	def get_pages_list(self):
		session = Session()
		
		try:
			result = session.execute(
				StaticPageModel.get_ordered_list_query().done()
			)
			data = session.query(StaticPageModel).instances(result)
		except Exception as e:
			session.close()
			print(
				'adm/AdminMainHandler.get_pages_list(): ' +
				'cannot get static pages:\n',
				e, file=sys.stderr
			)
			raise e
		
		pages_list = [x.static_list for x in data]
		for idx, page in enumerate(pages_list):
			page['sort'] = idx + 1
		
		session.close()
		return self.json_response({
			'status': 'success',
			'data_list': pages_list
		})
	
	
	## TODO : Optimize and using join ¯\(°_o)/¯
	@query_except_handler
	def get_catalog_sections(self):
		session = Session()
		
		try:
			cats = session.query(CatalogSectionModel.id).all()
		except Exception as e:
			session.close()
			print(
				'adm/AdminMainHandler.get_catalog_sections(): ' +
				'cannot get catalog sections:\n',
				e, file=sys.stderr
			)
			raise e
		
		counts = []
		for i in cats:
			try:
				count = (
					session
						.query(CatalogItemModel.id)
						.filter_by(section_id=i[0])
						.all()
				)
			except Exception as e:
				session.close()
				print(
					'adm/AdminMainHandler.get_catalog_sections(): ' +
					'cannot get catalog items by section id #%s:\n' % str(i[0]),
					e, file=sys.stderr
				)
				raise e
			counts.append((len(count),))
		
		try:
			data = session.query(
				CatalogSectionModel.title,
				CatalogSectionModel.id,
				CatalogSectionModel.is_active
			).all()
		except Exception as e:
			session.close()
			print(
				'adm/AdminMainHandler.get_catalog_sections(): ' +
				'cannot get catalog sections:\n',
				e, file=sys.stderr
			)
			raise e
		
		session.close()
		return self.json_response({
			'status': 'success',
			'data_list': [
				{
					'is_active': bool(x[1][2]),
					'id': x[1][1],
					'title': x[1][0],
					'count': x[0][0]
				} for x in list(zip(counts, data))
			]
		})
	
	
	@query_except_handler
	def get_catalog_elements(self, id=None):
		session = Session()
		
		try:
			data = session.query(
				CatalogItemModel.id,
				CatalogItemModel.title,
				CatalogItemModel.is_active
			).filter_by(section_id=id).all()
		except Exception as e:
			session.close()
			print(
				'adm/AdminMainHandler.get_catalog_elements(): ' +
				'cannot get catalog items by section id #%s:\n' % str(id),
				e, file=sys.stderr
			)
			raise e
		
		try:
			title = session.query(
				CatalogSectionModel.title
			).filter_by(id=id).one()
		except Exception as e:
			session.close()
			print(
				'adm/AdminMainHandler.get_catalog_elements(): ' +
				'cannot get catalog section by id #%s:\n' % str(id),
				e, file=sys.stderr
			)
			raise e
		
		session.close()
		
		return self.json_response({
			'status': 'success',
			'section_title': title[0],
			'data_list': [
				{
					'is_active': bool(x.is_active),
					'title': x.title,
					'id': x.id
				} for x in data
			]
		})
	
	@query_except_handler
	def get_redirect_list(self):
		session = Session()
		
		try:
			data = session.query(UrlMapping).all()
		except Exception as e:
			session.close()
			print(
				'adm/AdminMainHandler.get_redirect_list(): ' +
				'cannot get data from UrlMapping model:\n',
				e, file=sys.stderr
			)
			raise e
		
		session.close()
		
		return self.json_response({
			'status': 'success',
			'data_list': [x.item for x in data]
		})
	
	
	@query_except_handler
	def get_accounts_list(self):
		session = Session()
		
		try:
			data = session.query(User).all()
		except Exception as e:
			session.close()
			print(
				'adm/AdminMainHandler.get_accounts_list(): ' +
				'cannot get users:\n',
				e, file=sys.stderr
			)
			raise e
		
		session.close()
		
		return self.json_response({
			'status': 'success',
			'data_list': [
				{
					'id': x.id,
					'login': x.login,
					'is_active': x.is_active
				} for x in data
			]
		})
	
	
	@query_except_handler
	def get_static_page(self, id=None):
		session = Session()
		
		try:
			data = session.query(StaticPageModel).filter_by(id=id).one()
		except Exception as e:
			session.close()
			print(
				'adm/AdminMainHandler.get_static_page(): ' +
				'cannot get static page by id #%s:\n' % str(id),
				e, file=sys.stderr
			)
			raise e
		
		session.close()
		
		return self.json_response({
			'status': 'success',
			'data': data.item
		})
	
	
	@query_except_handler
	def create(self, **kwargs):
		section = kwargs['section']
		del kwargs['section']
		
		for item in (
			x for x in kwargs.keys()
			if x.startswith('is_') or x.startswith('has_')
		):
			kwargs[item] = True
		
		section_map = {
			'pages': StaticPageModel,
			'redirect': UrlMapping,
			'catalog_section': CatalogSectionModel,
			'catalog_element': CatalogItemModel,
			'data': NonRelationData
		}
		
		session = Session()
		
		page = section_map[section](**kwargs)
		
		try:
			session.add(page)
		except Exception as e:
			session.close()
			print(
				'adm/AdminMainHandler.create(): ' +
				'cannot create page by "%s" section:\n' % str(section),
				e, file=sys.stderr
			)
			raise e
		
		if section == 'redirect':
			permanent = 'status' in kwargs and kwargs['status'] == '301'
			from app.app import application
			
			application().handlers[0][1][:0] = [
				URLSpec(
					kwargs['old_url'] + '$',
					RedirectHandler,
					kwargs={
						'url': kwargs['new_url'],
						'permanent': permanent
					},
					name=None
				)
			]
		
		try:
			session.commit()
		except Exception as e:
			session.close()
			print(
				'adm/AdminMainHandler.create(): ' +
				'cannot commit create page by "%s" section:\n' % str(section),
				e, file=sys.stderr
			)
			raise e
			
		session.close()
		
		return self.json_response({'status': 'success'})
	
	##TODO :: Clear shitcode
	@query_except_handler
	def update_page(self, **kwargs):
		
		id = kwargs['id']
		section = kwargs['section']
		
		del kwargs['id']
		del kwargs['section']
		
		section_map = {
			'pages': StaticPageModel,
			'redirect': UrlMapping,
			'catalog_section': CatalogSectionModel,
			'catalog_element': CatalogItemModel,
			'data': NonRelationData
		}
		
		fields = db_inspector.get_columns(
			section_map[section].__tablename__
		)
		
		for item in (
			x for x in fields
			if x['name'].startswith('is_')
			or x['name'].startswith('has_')
			or x['name'].startswith('inherit_seo_')
		):
			if item['name'] not in kwargs.keys():
				kwargs.update({ item['name']: False })
			else:
				kwargs[item['name']] = True
		
		session = Session()
		
		try:
			data = session.query(section_map[section]).filter_by(id=id)
		except Exception as e:
			session.close()
			print(
				'adm/AdminMainHandler.update_page(): ' +
				'cannot update page by "%s" section:\n' % str(section),
				e, file=sys.stderr
			)
			raise e
		
		if section == 'redirect':
			permanent = 'status' in kwargs and kwargs['status'] == '301'
			from app.app import application
			counter = 0
			hndlr = application().handlers[0][1]
			for item in range(len(hndlr)):
				try:
					if hndlr[item].__dict__['kwargs']['url'] == data.one().new_url:
						hndlr[item] = URLSpec(
							kwargs['old_url'] + '$',
							RedirectHandler,
							kwargs={
								'url': kwargs['new_url'],
								'permanent': permanent
							},
							name=None
						)
				except KeyError:
					continue
		data.update(kwargs)
		
		try:
			session.commit()
		except Exception as e:
			session.close()
			print(
				'adm/AdminMainHandler.update_page(): ' +
				'cannot commit update page by "%s" section:\n' % str(section),
				e, file=sys.stderr
			)
			raise e
		
		session.close()
		
		return self.json_response({'status': 'success'})
	
	
	@query_except_handler
	def delete_smth(self, model=None, id=None): # smth - something
		session = Session()
		models = {
			'pages': StaticPageModel,
			'redirect': UrlMapping,
			'catalog_section': CatalogSectionModel,
			'catalog_element': CatalogItemModel,
			'accounts': User
		}
		
		try:
			session \
				.query(models[model]) \
				.filter_by(id=id) \
				.delete(synchronize_session=True)
			session.commit()
		except Exception as e:
			session.close()
			print(
				'adm/AdminMainHandler.delete_smth(): ' +
				'cannot delete page by id #%s:\n' % str(id),
				e, file=sys.stderr
			)
			return self.json_response({
				'status': 'error',
				'error_code': 'system_fail'
			})
		
		session.close()
		
		return self.json_response({'status': 'success'})
	
	
	@query_except_handler
	def get_data_list(self):
		session = Session()
		
		try:
			data = session.query(NonRelationData).all()
		except Exception as e:
			session.close()
			print(
				'adm/AdminMainHandler.get_data_list(): ' +
				'cannot get non-relation data elements:\n',
				e, file=sys.stderr
			)
			raise e
		
		session.close()
		return self.json_response({
			'status': 'success',
			'data_list': [x.item for x in data]
		})
	
	
	@query_except_handler
	def get_fields(self, model=None, edit=False, id=None):
		session = Session()
		
		models = {
			'pages': StaticPageModel,
			'redirect': UrlMapping,
			'catalog_section': CatalogSectionModel,
			'catalog_element': CatalogItemModel,
			'accounts': User,
			'data': NonRelationData
		}
		
		fields = db_inspector.get_columns(
			models[model].__tablename__
		)
		
		# TODO :: refactoring
		types_map = {
			'BOOLEAN': 'checkbox',
			'TEXT': 'html',
			'VARCHAR(4096)': 'text',
			'VARCHAR(8192)': 'text',
			'VARCHAR(1024)': 'text',
			'VARCHAR(5000)': 'password',
			'JSON': 'data_fields' if model == 'data' else 'files',
			'INTEGER': 'text'
		}
		vidgets = []
		
		for field in fields:
			try:
				if 'id' in field['name'] or 'prev_elem' in field['name']:
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
			try:
				data = session.query(models[model]).filter_by(id=id).one()
			except Exception as e:
				session.close()
				print(
					'adm/AdminMainHandler.get_fields(): ' +
					'cannot get fields by "%s" model and id #%s:\n' % (model, id),
					e, file=sys.stderr
				)
				raise e
			values = data.item
			
			if model == 'catalog_element':
				values.update({'section_id': data.section_id})
		
		if model == 'catalog_element':
			try:
				sections = session.query(CatalogSectionModel).all()
			except Exception as e:
				session.close()
				print(
					'adm/AdminMainHandler.get_fields(): ' +
					'cannot get catalog sections list:\n',
					e, file=sys.stderr
				)
				raise e
			
			vidgets.append({
				'name': 'section_id',
				'type': 'select',
				'default_val': None,
				'list_values': [
					{ 'title': x.title, 'value': x.id } for x in sections
				]
			})
		
		session.close()
		
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
