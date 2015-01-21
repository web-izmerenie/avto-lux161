# -*- coding: utf-8 -*-

from .base import BaseHandler


class TestRoute(BaseHandler):
	def get(self, file):
		return self.render(str(file) + '.jade', show_h1=1)
