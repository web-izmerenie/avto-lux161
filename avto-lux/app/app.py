import os.path, re, tornado.httpserver, tornado.ioloop, tornado.web
from tornado.options import define, options
import hashlib
from .core.routes import routes as core_routes

from .core.routes.testroute import TestRoute
from .configparser import config
from .models.init_models import init_models
from .utils import collect_handlers



class AvtoLuxApplication(tornado.web.Application):
	def __init__(self):
		handlers = collect_handlers(core_routes)
		settings = dict(
			template_path=os.path.join(os.getcwd(), config('TEMPLATES_PATH')),
			static_path=os.path.join(os.getcwd(), config('STATIC_PATH')),
			debug=True,
			xsrf_cookies = False,
			cookie_secret = str(hashlib.sha224(os.urandom(100)).hexdigest()))

		tornado.web.Application.__init__(self, handlers, **settings)

def run_instance(port, host=''):
	# init_models()
	tornado.options.parse_command_line()
	http_server = tornado.httpserver.HTTPServer(AvtoLuxApplication())
	http_server.listen(port, address=host)
	print("Server run on %s:%s" % (host, port))
	tornado.ioloop.IOLoop.instance().start()