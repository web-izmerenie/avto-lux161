# -*- coding: utf-8 -*-

class LazyMemoizeWrapper:
	def __init__(self, f):
		self._getter = f
	def __call__(self):
		try:
			return self._value
		except AttributeError:
			self._value = self._getter()
			del self._getter
			return self._value
