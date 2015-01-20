from .base import BaseHandler
from .menu import MenuProvider
from .decorators import route_except_handler
from app.models.dbconnect import Session
from app.mixins.routes_mixin import Custom404Mixin

from app.models.catalogmodels import(
	CatalogSectionModel,
	CatalogItemModel
)

session = Session()


class CatalogSectionRoute(BaseHandler, MenuProvider, Custom404Mixin):
	@route_except_handler
	def get(self, alias):
		if alias.endswith(".html"):
			alias = alias.replace('.html', '').replace('/', '')
		page = session.query(CatalogSectionModel).filter_by(alias=alias).one()
		items = session.query(CatalogItemModel).filter_by(section_id=page.id).all()

		data = page.to_frontend
		data.update({
			'is_catalog': True,
			'is_main_page': False,
			'items': [x.to_frontend for x in items]
		})

		self.render('client/catalog_sections.html', **data)
