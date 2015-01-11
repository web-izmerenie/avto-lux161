import json
import tornado.template
from .base import BaseHandler
from app.mixins.routes_mixin import Custom404Mixin, JsonResponseMixin
from pyjade.ext.tornado import patch_tornado

from app.models.dbconnect import session
from sqlalchemy import select, func

## Debug
from app.models.usermodels import User
from app.models.pagemodels import (
	StaticPageModel,
	UrlMapping
)
from app.models.catalogmodels import(
	CatalogSectionModel,
	CatalogItemModel
)
from sqlalchemy.orm.exc import MultipleResultsFound, NoResultFound

patch_tornado()


class MainRoute(BaseHandler, Custom404Mixin):
	def get(self):
		# return self.render('sdfs.jade')
		q = session.query(User).all()
		self.write(json.dumps(str(q)))


class UrlToRedirect(BaseHandler):
	def get(self, first, second):
		old_url = self.request.uri
		new_url = session.query(UrlMapping.new_url).filter_by(old_url=str(old_url))
		return self.redirect(str(new_url[0][0]), permanent=False, status=None)


class PageRoute(BaseHandler, Custom404Mixin):
	def get(self, alias):
		self.render('xxx.jade') ## TODO Replace to page.jade


class ItemRoute(BaseHandler, Custom404Mixin):
	def get(self, category, item):
		return self.render('yyy.jade') #Replace to catalog.jade

class FormHandler(BaseHandler, JsonResponseMixin):
	def post(self):
		action = request.body
		return json_response({})
