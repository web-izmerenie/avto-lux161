__all__ = ['base', 'main']


from .main import (
	MainRoute, 
	PageRoute,
	ItemRoute,
	CallHandler,
	OrderHandler,
	UrlToRedirect
)

from .testroute import TestRoute

routes = [
	('/', MainRoute),

	('/test/(.*).html', TestRoute), ## Only for testing slised pages
	('/test/(.*)', TestRoute),
	('/api/calls', CallHandler),
	('/api/orders', OrderHandler),

	('/([-0-9])+(.html)', UrlToRedirect),
	('/(.*)/item/(.*).html', UrlToRedirect),

	('/(.*).html', PageRoute),
	('/(.*)', PageRoute),
	('/(.*)/(.*).html', ItemRoute),
	('/(.*)/(.*)', ItemRoute)
]