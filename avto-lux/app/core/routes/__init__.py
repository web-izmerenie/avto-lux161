__all__ = ['base', 'main']


from .main import (
	MainRoute,
	PageRoute,
	ItemRoute,
	UrlToRedirect,
	FormsHandler
)

from .testroute import TestRoute

routes = [
	('/', MainRoute),
	('/api/forms/', FormsHandler),

	('/test/(.*?).html', TestRoute), ## Only for testing slised pages
	('/test/(.*?)', TestRoute),

	('/([-0-9])+(.html)', UrlToRedirect),
	('/(.*?)/item/(.*?).html', UrlToRedirect),

	('/(.*?).html', PageRoute),
	('/(.*?)', PageRoute),
	('/(.*?)/(.*?).html', ItemRoute),
	('/(.*?)/(.*?)', ItemRoute)
]
