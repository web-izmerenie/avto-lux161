# -*- coding: utf-8 -*-

import sys
from urllib.parse import quote

from .base import BaseHandler
from app.configparser import config
from app.models.dbconnect import Session
from app.models.pagemodels import StaticPageModel
from app.models.catalogmodels import (CatalogSectionModel, CatalogItemModel)
from .decorators import route_except_handler


class SiteMapRoute(BaseHandler):
	@route_except_handler
	def get(self):
		data = {'is_debug': config('DEBUG')}
		urls = []

		session = Session()

		try:
			pages = session.query(StaticPageModel)\
				.filter_by(is_active=True)\
				.order_by(StaticPageModel.id.asc()).all()
			sections = session.query(CatalogSectionModel)\
				.filter_by(is_active=True)\
				.order_by(CatalogSectionModel.id.asc()).all()
			items = session.query(CatalogItemModel)\
				.filter_by(is_active=True)\
				.order_by(CatalogItemModel.id.asc()).all()
		except Exception as e:
			session.close()
			print('SiteMapRoute.get(): cannot get data from DB:\n',\
				e, file=sys.stderr)
			raise e

		session.close()

		for page in [x.item for x in pages]:
			if '404' in page['alias']:
				continue
			urls.append({
				'alias': quote(page['alias'], encoding='utf-8'),
				'lastmod': page['last_change']
			})

		for section in [x.item for x in sections]:
			url = '/catalog/{0}.html'.format(section['alias'])
			url = quote(url, encoding='utf-8')
			urls.append({
				'alias': url,
				'lastmod': section['last_change']
			})

		for item in [x.item for x in items]:
			section_alias = None
			for section in [x.item for x in sections]:
				if section['id'] == item['section_id']:
					section_alias = section['alias']
			if section_alias is None:
				e = Exception('SiteMapRoute: '+\
					'cannot find section for element #%d' % item['id'])
				print(e, file=sys.stderr)
				continue
			url = '/catalog/{0}/{1}.html'.format(section_alias, item['alias'])
			url = quote(url, encoding='utf-8')
			urls.append({
				'alias': url,
				'lastmod': section['last_change']
			})

		data.update({'urls': tuple(urls)})
		self.set_header('Content-Type', 'text/xml; charset="utf-8"')
		return self.render('client/sitemap.jade', **data)

	def head(self):
		return self.get()
