__all__ = ['base', 'main']

from tornado.web import StaticFileHandler
import os
from app.configparser import config
from .main import (
	MainRoute,
	StaticPageRoute,
	ItemRoute,
	UrlToRedirect,
	FormsHandler,
	CatalogPageRoute
)

from .testroute import TestRoute

routes = [
	('/', MainRoute),
	('/uploaded-files/(.*)', StaticFileHandler, {"path": os.path.join(os.getcwd(), config('UPLOAD_FILES_PATH'))}),
	('/api/forms/', FormsHandler),

	('/test/(.*?).html', TestRoute), ## Only for testing slised pages
	('/test/(.*?)', TestRoute),

	('/([-0-9])+(.html)', UrlToRedirect),
	('/(.*?)/item/(.*?).html', UrlToRedirect),

	('/catalog/(.*?)/(.*?).html', ItemRoute),
	('/catalog/(.*?)/(.*?)', ItemRoute),
	('/catalog/(.*?)', CatalogPageRoute),
	('/catalog/(.*?).html', CatalogPageRoute),
	('/(.*?).html', StaticPageRoute),
	('/(.*?)', StaticPageRoute)
]
