from tornado.web import RequestHandler
import json
from app.utils import get_json_localization

class JsonResponseMixin(RequestHandler):
	def json_response(self, data):
		return self.write(json.dumps(data))


class Custom404Mixin(RequestHandler):
	def write_error(self, status_code, **kwargs):
		localization = get_json_localization('CLIENT')['ru']['titles']
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
