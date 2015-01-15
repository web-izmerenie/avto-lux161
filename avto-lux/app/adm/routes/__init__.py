__all__ = ['base', 'main']

from .main import (
	AdminMainRoute,
	EmptyHandler,
	AuthHandler,
	LogoutHandler,
	CreateUser,
)
from .actions import AdminMainHandler

routes = [
	('/adm/', AdminMainRoute),

	('/adm/auth', AuthHandler),
	('/adm/logout', LogoutHandler),
	('/adm/data.json', AdminMainHandler),
	('/adm/create.user', CreateUser)
]
