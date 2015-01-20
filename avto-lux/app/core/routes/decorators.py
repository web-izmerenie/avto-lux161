import sys
from sqlalchemy.orm.exc import NoResultFound
from app.models.dbconnect import Session

from app.models.pagemodels import (
	StaticPageModel
)

session = Session()

def route_except_handler(fn):
	def wrap(*args, **kwargs):
		self = args[0]
		try:
			return fn(*args, **kwargs)
		except NoResultFound as e:
			print(e, file=sys.stderr)
			self.set_status(404)
			page = session.query(StaticPageModel).filter_by(alias='/404.html').one()
			menu = self.getmenu()
			data = page.to_frontend
			data.update({'menu': menu})
			data.update({ 'is_catalog': False })
			return self.render('client/error-404.jade', **data)
		except Exception as e:
			print(e, file=sys.stderr)
			self.set_status(500)
			return self.write('500: Internal server error')
	wrap.__name__ = fn.__name__
	return wrap
