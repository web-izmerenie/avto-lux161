# -*- coding: utf-8 -*-

from .base import BaseHandler
from .decorators import route_except_handler
from app.models.dbconnect import Session
from app.mixins.routes_mixin import (ErrorHandlerMixin, MenuProviderMixin)

from app.models.catalogmodels import(
	CatalogSectionModel,
	CatalogItemModel
)

session = Session()


class CatalogSectionRoute(BaseHandler, MenuProviderMixin, ErrorHandlerMixin):
	@route_except_handler
	def get(self, alias):
		if alias.endswith(".html"):
			alias = alias.replace('.html', '').replace('/', '')
		page = session.query(CatalogSectionModel).filter_by(alias=alias).one()
		items = session.query(CatalogItemModel).filter_by(section_id=page.id)\
			.order_by('id asc').all()
		menu = self.getmenu(catalog_section_alias=alias)
		data = page.to_frontend
		data.update({
			'is_catalog': True,
			'is_catalog_item': False,
			'is_main_page': False,
			'items': [x.to_frontend for x in items],
			'menu': menu
		})

		self.render('client/catalog-sections.jade', **data)


class CatalogItemRoute(BaseHandler, MenuProviderMixin, ErrorHandlerMixin):
	@route_except_handler
	def get(self, category, item):
		if item.endswith(".html"):
			item = item.replace('.html', '').replace('/', '')
		page = session.query(CatalogItemModel).filter_by(alias=item).one()
		menu = self.getmenu(
			catalog_section_alias=category,
			catalog_item_alias=item)
		data = page.to_frontend
		data.update({
			'is_catalog': True,
			'is_catalog_item': True,
			'catalog_item_id': data['id'],
			'is_main_page': False,
			'menu': menu
		})
		return self.render('client/catalog-detail.jade', **data)
