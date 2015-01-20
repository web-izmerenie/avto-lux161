__all__ = ['base', 'menu', 'main']

from pyjade.ext.tornado import patch_tornado
patch_tornado()

from tornado.web import StaticFileHandler
import os
from app.configparser import config
from .main import (
	MainRoute,
	StaticPageRoute,
	UrlToRedirect,
	FormsHandler
)
from .catalogitem import CatalogItemRoute
from .catalogsection import CatalogSectionRoute

from .testroute import TestRoute

routes = [
	('/', MainRoute),
	('/uploaded-files/(.*)',
		StaticFileHandler,
		{"path": os.path.join(os.getcwd(), config('UPLOAD_FILES_PATH'))}),
	('/api/forms/', FormsHandler),

	# TODO :: remove test routes for production (only for development)
	# Only for testing slised pages
	('/test/(.*?).html', TestRoute),
	('/test/(.*?)', TestRoute),

	('/([-0-9])+(.html)', UrlToRedirect),
	('/(.*?)/item/(.*?).html', UrlToRedirect),

	('/catalog/(.*?)/(.*?).html', CatalogItemRoute),
	('/catalog/(.*?)/(.*?)', CatalogItemRoute),
	('/catalog/(.*?)', CatalogSectionRoute),
	('/catalog/(.*?).html', CatalogSectionRoute),
	('/(.*?).html', StaticPageRoute),
	('/(.*?)', StaticPageRoute)
]
