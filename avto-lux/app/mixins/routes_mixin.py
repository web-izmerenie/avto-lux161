from tornado.web import RequestHandler
import json
from app.utils import get_json_localization, is_date
from app.configparser import config
from app.models.pagemodels import (
	StaticPageModel,
	UrlMapping
)
from app.models.dbconnect import Session


class JsonResponseMixin(RequestHandler):
	def json_response(self, data):
		return self.write(json.dumps(data, default=is_date))


class Custom404Mixin(RequestHandler):
	def write_error(self, status_code, **kwargs):
		session = Session()
		lang = config('LOCALIZATION')['LANG']
		localization = get_json_localization('CLIENT')[lang]['titles']
		error_class_name = kwargs["exc_info"][1].__class__.__name__
		errors = {
			'FileNotFoundError': 404
		}
		status = errors[error_class_name]
		self.set_status(status)
		page = session.query(StaticPageModel).filter_by(alias='/404.html').one()
		page.to_frontend.update({'is_catalog': False})
		return self.render('client/error-404.jade', **page.to_frontend) ## TODO: rename to error_page.jade



class JResponse(RequestHandler):
	def __init__(self, status='success', status_code=200):
		self.status = status
		self.s_code = status_code

	def __call__(self, response_data):
		if self.self.s_code is not 200:
			self.set_status(self.self.s_code)
			data = {'status': self.status }.update(response_data)
		return self.self.write(json.dumps(data, default=is_date))


success_response = JResponse()
error_response = JResponse(status='error', status_code=500)
not_found_response = JResponse(status='not_found', status_code=404)
