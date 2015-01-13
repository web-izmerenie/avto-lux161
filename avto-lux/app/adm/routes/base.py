import hashlib
from tornado.web import RequestHandler

class AdminBaseHandler(RequestHandler):
	def validate_password(self, symbols):
		return True


