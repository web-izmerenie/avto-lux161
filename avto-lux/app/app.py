import sys, re, os.path
import tornado.httpserver, tornado.ioloop, tornado.web
from tornado.options import define, options
import hashlib
from .core.routes import routes as core_routes
from .adm.routes import routes as admin_routes

from .configparser import config
from .models.init_models import init_models
from .utils import collect_handlers, error_log, get_json_localization


handlers = []
try:
	#TODO Add sort routes function
	handlers = collect_handlers(admin_routes, core_routes)
except Exception as e:
	error_log(e)

settings = dict(
	template_path=os.path.join(os.getcwd(), config('TEMPLATES_PATH')),
	static_path=os.path.join(os.getcwd(), config('STATIC_PATH')),
	debug=True,
	autoreload=config('AUTO_RELOAD'),
	xsrf_cookies = config('XSRF'),
	cookie_secret = str(hashlib.sha512(os.urandom(300)).hexdigest()))


def run_instance(port, host):
	tornado.options.parse_command_line()
	srv = tornado.httpserver.HTTPServer(tornado.web.Application(handlers, **settings))
	srv.listen(port, address=host)
	print("Server run on %s:%s" % (host, port))
	tornado.ioloop.IOLoop.instance().start()
