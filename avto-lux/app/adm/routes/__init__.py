__all__ = ['base', 'main']

from .main import (
	AdminMainRoute,
	EmptyHandler,
	AuthHandler,
	LogoutHandler,
	CreateUser
)

routes = [
	('/adm/?', AdminMainRoute),
	('/adm/auth/', AuthHandler),
	('/adm/logout/', LogoutHandler),
	('adm/data.json', EmptyHandler),
	('/adm/create.user', CreateUser)
]
