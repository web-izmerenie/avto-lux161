# -*- coding: utf-8 -*-

from tornado.web import RequestHandler


class UnicodeRedirectHandler(RequestHandler):
	
	def initialize(self, url, status=302):
		self._url = url
		self._status = status
	
	def get(self):
		if self._headers_written:
			raise Exception("Cannot redirect after headers have been written")
		assert isinstance(self._status, int) and 300 <= self._status <= 399
		
		self.set_status(self._status)
		self.set_header('Location', self._url)
		self.finish()


def collect_handlers(*args):
	
	from urllib.parse import quote
	from app.models.pagemodels import UrlMapping
	from app.models.dbconnect import Session
	
	routes = []
	for item in args:
		routes += item
	duplicated = {x for x in routes if routes.count(x) > 1}
	if len(duplicated) > 0:
		raise CollectHandlersException("Duplicate routes! {0}".format(duplicated))
	
	redirect_routes = []
	session = Session()
	try:
		_rr = session.query(UrlMapping).all()
	except Exception as e:
		session.close()
		print('collect_handlers(): cannot get data from UrlMapping model:\n',\
			e, file=sys.stderr)
		raise e
	for redirect in _rr:
		old_url = quote(redirect.old_url, encoding='utf-8')
		redirect_routes.append((old_url, UnicodeRedirectHandler, {
			'url': redirect.new_url,
			'status': int(redirect.status)
		}))
	session.close()
	return redirect_routes + routes
