import hashlib
from tornado.web import RequestHandler

class AmdinBaseHandler(RequestHandler):
	def validate_password(self, symbols):
		return True


def AuthMixin:
	def create_password(self, symbols):
		return str(hashlib.sha512(symbols.encode('utf-8')).hexdigest())

	def compare_password(self, hpasswd=None, password=None):
		return hpasswd == hashlib.sha512(password.encode('utf-8')).hexdigest()