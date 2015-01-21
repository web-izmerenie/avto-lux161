# -*- coding: utf-8 -*-

__all__ = ['base', 'menu', 'main']

from pyjade.ext.tornado import patch_tornado
patch_tornado()

from tornado.web import StaticFileHandler
import os
from app.configparser import config
from .main import (
	MainRoute,
	StaticPageRoute,
	FormsHandler
)
from .catalog import (CatalogItemRoute, CatalogSectionRoute)

routes = [
	('/', MainRoute),
	('/uploaded-files/(.*)',
		StaticFileHandler,
		{"path": os.path.join(os.getcwd(), config('UPLOAD_FILES_PATH'))}),
	('/api/forms/', FormsHandler),

	('/catalog/(.*?)/(.*?).html', CatalogItemRoute),
	('/catalog/(.*?)/(.*?)', CatalogItemRoute),
	('/catalog/(.*?)', CatalogSectionRoute),
	('/catalog/(.*?).html', CatalogSectionRoute),

	('/(.*?).html', StaticPageRoute),
	('/(.*?)', StaticPageRoute)
]
