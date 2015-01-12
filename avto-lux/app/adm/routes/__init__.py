__all__ = ['base', 'main']

from .main import (
	AdminMainRoute,
	EmptyHandler,
	AuthHandler
)

routes = [
	('/adm/?', AdminMainRoute),
	('/adm/auth/', AuthHandler),
	('adm/data.json', EmptyHandler),
]
