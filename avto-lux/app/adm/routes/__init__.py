__all__ = ['base', 'main']

from .main import (
	AdminMainRoute,
	AuthHandler,
	LogoutHandler,
	CreateUser,
	UpdateUser,
	FileUpload
)
from .actions import AdminMainHandler

routes = [
	('/adm/', AdminMainRoute),

	('/adm/auth', AuthHandler),
	('/adm/logout', LogoutHandler),
	('/adm/data.json', AdminMainHandler),
	('/adm/create.account', CreateUser),
	('/adm/update.account', UpdateUser),
	('/adm/upload.json', FileUpload),
]
