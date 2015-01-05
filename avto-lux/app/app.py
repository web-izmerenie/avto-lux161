import os.path, re, tornado.httpserver, tornado.ioloop, tornado.web
from tornado.options import define, options
import hashlib


class AvtoLuxApplication(tornado.web.Application):
    def __init__(self):
        handlers = []
        settings = dict(
            template_path=os.path.join(os.path.dirname(__file__), "templates"),
            static_path=os.path.join(os.path.dirname(__file__), "static"),
            debug=True,
            xsrf_cookies = False,
            cookie_secret = str(hashlib.sha224(os.urandom(100)).hexdigest()))

        tornado.web.Application.__init__(self, handlers, **settings)

def run_instance(host, port):
    tornado.options.parse_command_line()
    http_server = tornado.httpserver.HTTPServer(AvtoLuxApplication())
    http_server.listen(port)
    print("Server run on %s:%s" % (host, port))
    tornado.ioloop.IOLoop.instance().start()

