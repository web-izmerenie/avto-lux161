from .base import BaseHandler
from .menu import MenuProvider
from .decorators import route_except_handler
from app.models.dbconnect import Session
from app.mixins.routes_mixin import Custom404Mixin

from app.models.catalogmodels import CatalogItemModel

session = Session()


class CatalogItemRoute(BaseHandler, MenuProvider, Custom404Mixin):
	@route_except_handler
	def get(self, category, item):
		if item.endswith(".html"):
			item = item.replace('.html', '').replace('/', '')
		page = session.query(CatalogItemModel).filter_by(alias=item).one()
		data = page.to_frontend
		data.update({'is_catalog': True, 'is_main_page': False})
		return self.render('client/catalog-detail.jade', **data)
