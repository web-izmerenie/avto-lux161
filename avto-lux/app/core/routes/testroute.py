import tornado.template
from .base import BaseHandler
from pyjade.ext.tornado import patch_tornado
patch_tornado()


class TestRoute(BaseHandler):
	def get(self, file):
		return self.render(str(file) + '.jade', show_h1=1)
