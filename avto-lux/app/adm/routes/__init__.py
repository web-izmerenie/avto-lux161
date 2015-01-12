__all__ = ['base', 'main']

from .main import (
	AdminMainRoute,
	EmptyHandler
)

routes = [
	('/adm/?', AdminMainRoute),
	('/adm/auth', EmptyHandler),
	('adm/data.json', EmptyHandler),
]
