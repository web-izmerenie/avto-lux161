__all__ = ['base', 'main']

from .main import (
	AdminMainRoute,
	AuthHandler,
	LogoutHandler,
	CreateUser,
	FileUpload
)
from .actions import AdminMainHandler

routes = [
	('/adm/', AdminMainRoute),

	('/adm/auth', AuthHandler),
	('/adm/logout', LogoutHandler),
	('/adm/data.json', AdminMainHandler),
	('/adm/create.user', CreateUser),
	('/adm/upload.json', FileUpload)
]
