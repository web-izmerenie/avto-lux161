from sqlalchemy import (
	Column, 
	String, 
	Integer, 
	Boolean,
	DateTime
	)
import json
from app.configparser import config
from .dbconnect import Base, dbprefix, engine
from .pagemodels import IdMixin


class User(Base, IdMixin):
	__tablename__ = dbprefix + 'users'

	login = Column(String(128))
	password = Column(String(4096))
	last_login = Column(DateTime(timezone=False))
	is_active = Column(Boolean)

	def __repr__(self):
		return self.login

