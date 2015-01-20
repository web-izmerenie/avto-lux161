from tornado.web import RequestHandler


class BaseHandler(RequestHandler):
	def remove_html(self, arg):
		if arg.endswith('.html'):
			return arg.replace('.html', '')
		return arg
