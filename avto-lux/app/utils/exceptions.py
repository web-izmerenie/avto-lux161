# -*- coding: utf-8 -*-

class CollectHandlersException(Exception):
	def __repr__(self, e, list):
		return "{0}, {1}".format(e, list)
