# -*- coding: utf-8 -*-

__all__ = ['base', 'catalog', 'decorators', 'main', 'robots', 'sitemap']

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
from .robots import RobotsTxtRoute
from .sitemap import SiteMapRoute

routes = [
	('/', MainRoute),
	('/uploaded-files/(.*)',
		StaticFileHandler,
		{"path": os.path.join(os.getcwd(), config('UPLOAD_FILES_PATH'))}),
	('/api/forms/', FormsHandler),
	
	('/catalog/(.*?)/(.*?)\.html', CatalogItemRoute),
	('/catalog/(.*?)\.html', CatalogSectionRoute),
	
	('/robots\.txt', RobotsTxtRoute),
	('/sitemap.xml', SiteMapRoute),
	
	('/(.*?)(\.html)', StaticPageRoute),
	('/(.*?)()', StaticPageRoute)
]
