from tornado.web import RequestHandler
import json

class JsonResponseMixin(RequestHandler):
	def json_response(self, data):
		return self.write(json.dumps(data))

class ErrorResponseMixin(RequestHandler):
	def response_403(self):
		return self.send_error(status_code=403)


class ForbiddenPostPutHeadDeleteMixin(RequestHandler):
	def post(self):
		return self.response_403()

	def put(self):
		return self.response_403()

	def head(self):
		return self.response_403()

	def delete(self):
		return self.response_403()