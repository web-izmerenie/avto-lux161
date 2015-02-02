# -*- coding: utf-8 -*-

import sys
from sqlalchemy.orm.exc import NoResultFound
from app.models.dbconnect import Session
from app.configparser import config

from app.models.pagemodels import StaticPageModel


_404_page_alias = '/404.html'


def route_except_handler(fn):
	def wrap(*args, **kwargs):
		self = args[0]
		try:
			return fn(*args, **kwargs)
		except NoResultFound as e:
			print('route_except_handler(): NoResultFound exception:\n',\
				e, file=sys.stderr)
			self.set_status(404)
			session = Session()
			try:
				page = session.query(StaticPageModel)\
					.filter_by(alias=_404_page_alias).one()
			except Exception as e:
				session.close()
				print('route_except_handler(): cannot get 404 page'+\
					' by "%s" alias:\n' % str(_404_page_alias),\
					e, file=sys.stderr)
				self.set_status(500)
				return self.write('500: Internal server error')
			session.close()
			menu = self.getmenu()
			data = page.to_frontend
			data.update({
				'is_catalog': False,
				'is_catalog_item': False,
				'menu': menu,
				'is_debug': config('DEBUG')
			})
			data.update(self.get_nonrel_handlers())
			data.update(self.get_helpers())
			return self.render('client/error-404.jade', **data)
		except Exception as e:
			print(e, file=sys.stderr)
			self.set_status(500)
			return self.write('500: Internal server error')
	wrap.__name__ = fn.__name__
	return wrap
