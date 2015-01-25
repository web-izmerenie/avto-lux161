# -*- coding: utf-8 -*-

import sys
from sqlalchemy.orm.exc import NoResultFound
from app.models.dbconnect import Session
from app.configparser import config

from app.models.pagemodels import (
	StaticPageModel
)

from app.mixins.routes_mixin import (
	NonRelationDataProvider
)


def route_except_handler(fn):
	def wrap(*args, **kwargs):
		self = args[0]
		try:
			return fn(*args, **kwargs)
		except NoResultFound as e:
			print(e, file=sys.stderr)
			self.set_status(404)
			session = Session()
			page = session.query(StaticPageModel).filter_by(alias='/404.html').one()
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
			return self.render('client/error-404.jade', **data)
		except Exception as e:
			print(e, file=sys.stderr)
			self.set_status(500)
			return self.write('500: Internal server error')
	wrap.__name__ = fn.__name__
	return wrap
