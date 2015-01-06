from tornado.web import RequestHandler
import json

class JsonResponseMixin(RequestHandler):
	def json_response(self, data):
		return self.write(json.dumps(data))


class Custom404Mixin(RequestHandler):
	def write_error(self, status_code, **kwargs):
		print(kwargs["exc_info"])
	try:
		self.set_status(404)
		return self.write("Not not not!")