from tornado.web import RequestHandler
import json

class JsonResponseMixin(RequestHandler):
	def json_response(self, data):
		return self.write(json.dumps(data))


class ForbiddenPostPutHeadDeleteMixin(RequestHandler):
	def post(self):
		return self.send_error(status_code=403)

	def put(self):
		return self.send_error(status_code=403)

	def head(self):
		return self.send_error(status_code=403)

	def delete(self):
		return self.send_error(status_code=403)