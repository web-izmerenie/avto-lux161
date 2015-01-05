import tornado.template
from .base import BaseHandler

from pyjade.ext.tornado import patch_tornado
patch_tornado()


class MainHandler(BaseHandler):
	def get(self):

		self.write("Hello!")