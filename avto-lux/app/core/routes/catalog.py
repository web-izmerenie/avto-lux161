# -*- coding: utf-8 -*-

from .base import BaseHandler
from .decorators import route_except_handler
from app.models.dbconnect import Session
from app.mixins.routes_mixin import ErrorHandlerMixin

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
		page = session.query(CatalogSectionModel).filter_by(alias=alias).one()
		items = session.query(CatalogItemModel).filter_by(section_id=page.id)\
			.order_by(CatalogItemModel.id.asc()).all()
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


class CatalogItemRoute(BaseHandler, ErrorHandlerMixin):
	@route_except_handler
	def get(self, category, item):
		session = Session()
		if item.endswith(".html"):
			item = item.replace('.html', '').replace('/', '')
		page = session.query(CatalogItemModel).filter_by(alias=item).one()
		session.close()
		menu = self.getmenu(
			catalog_section_alias=category,
			catalog_item_alias=item)
		data = page.to_frontend
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
