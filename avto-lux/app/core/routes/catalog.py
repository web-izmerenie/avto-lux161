# -*- coding: utf-8 -*-

import sys

from .base import BaseHandler
from .decorators import route_except_handler
from app.models.dbconnect import Session
from app.mixins.routes_mixin import ErrorHandlerMixin
from sqlalchemy.orm.exc import NoResultFound

from app.models.catalogmodels import(
	CatalogSectionModel,
	CatalogItemModel
)
from app.configparser import config


class CatalogSectionRoute(BaseHandler, ErrorHandlerMixin):
	@route_except_handler
	def get(self, alias):
		session = Session()
		if alias.endswith(".html"):
			alias = alias.replace('.html', '').replace('/', '')
		try:
			page = session.query(CatalogSectionModel)\
				.filter_by(alias=alias, is_active=True)\
				.one()
		except Exception as e:
			session.close()
			print('CatalogSectionRoute.get(): cannot get catalog section or section is not active'+\
				' by "%s" code:\n' % str(alias),\
				e, file=sys.stderr)
			raise e
		try:
			items = session.query(CatalogItemModel)\
				.filter_by(section_id=page.id, is_active=True)\
				.order_by(CatalogItemModel.id.asc()).all()
		except Exception as e:
			session.close()
			print('CatalogSectionRoute.get(): cannot get catalog items'+\
				' by section #%d:\n' % int(page.id),\
				e, file=sys.stderr)
			raise e
		session.close()
		menu = self.getmenu(catalog_section_alias=alias)
		data = page.to_frontend
		data.update({
			'is_catalog': True,
			'is_catalog_item': False,
			'is_main_page': False,
			'items': [x.to_frontend for x in items],
			'menu': menu,
			'is_debug': config('DEBUG')
		})
		data.update(self.get_nonrel_handlers())
		data.update(self.get_helpers())
		return self.render('client/catalog-sections.jade', **data)
	
	def head(self, alias):
		return self.get(alias)


class CatalogItemRoute(BaseHandler, ErrorHandlerMixin):
	@route_except_handler
	def get(self, category, item):
		session = Session()
		
		# check for active element section
		try:
			section = session.query(CatalogSectionModel)\
				.filter_by(alias=category, is_active=True)\
				.one()
		except Exception as e:
			session.close()
			print('CatalogItemRoute.get(): cannot get catalog section or section is not active'+\
				' by "%s" code:\n' % str(category),\
				e, file=sys.stderr)
			raise e
		
		if item.endswith(".html"):
			item = item.replace('.html', '').replace('/', '')
		
		# get item
		try:
			page = session\
				.query(CatalogItemModel)\
				.filter_by(alias=item, is_active=True)\
				.one()
		except Exception as e:
			session.close()
			print('CatalogItemRoute.get(): cannot get catalog item or item is not active'+\
				' by "%s" code:\n' % str(item),\
				e, file=sys.stderr)
			raise e
		
		session.close()
		data = page.to_frontend
		
		# check for category
		if data['section_id'] != section.to_frontend['id']:
			e = NoResultFound()
			print('CatalogItemRoute.get(): mismatch catalog category of element and category in URL'+\
				' by "%s" code:\n' % str(item),\
				e, file=sys.stderr)
			raise e
		
		menu = self.getmenu(
			catalog_section_alias=category,
			catalog_item_alias=item)
		data.update({
			'is_catalog': True,
			'is_catalog_item': True,
			'catalog_item_id': data['id'],
			'is_main_page': False,
			'menu': menu,
			'is_debug': config('DEBUG')
		})
		data.update(self.get_nonrel_handlers())
		data.update(self.get_helpers())
		return self.render('client/catalog-detail.jade', **data)
	
	def head(self, category, item):
		return self.get(category, item)
