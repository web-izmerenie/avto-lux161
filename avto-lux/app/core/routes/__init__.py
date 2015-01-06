__all__ = ['base', 'main']


from .main import (
	MainRoute, 
	PageRoute,
	ItemRoute,
	CallHandler,
	OrderHandler
)

from .testroute import TestRoute

routes = [
	('/', MainRoute),
	('/test/(.*).html', TestRoute), ## Only for testing slised pages
	('/test/(.*)', TestRoute),
	('/api/calls', CallHandler),
	('/api/orders', OrderHandler),
	
	('/(.*).html', PageRoute),
	('/(.*)', PageRoute),
	('/(.*)/(.*).html', ItemRoute),
	('/(.*)/(.*)', ItemRoute)
]