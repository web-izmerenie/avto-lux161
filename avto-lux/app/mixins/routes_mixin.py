from tornado.web import RequestHandler
import json
from app.utils import get_json_localization, is_date
from app.configparser import config

class JsonResponseMixin(RequestHandler):
	def json_response(self, data):
		return self.write(json.dumps(data, default=is_date))


class Custom404Mixin(RequestHandler):
	def write_error(self, status_code, **kwargs):
		lang = config('LOCALIZATION')['LANG']
		localization = get_json_localization('CLIENT')[lang]['titles']
		print(kwargs["exc_info"])
		self.set_status(404)
		kwrgs = {
			'page_title':localization['error_404'],
			'show_h1': 1,
			'page_content': '',
			'error_msg_list': '',
			'success_msg_list': ''
		}
		return self.render('client/error-404.jade', **kwrgs)
