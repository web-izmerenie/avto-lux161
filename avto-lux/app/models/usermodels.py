from sqlalchemy import (
	Column, 
	String, 
	Integer, 
	Boolean,
	DateTime
	)
from app.configparser import config
from .dbconnect import Base, engine
	
dbprefix = config('DATABASE')['TABLE_NAME_PREFIX']


class User(Base):
	__tablename__ = dbprefix + '_users'

	user_id = Column(Integer, primary_key=True)
	login = Column(String(128))
	password = Column(String(4096))
	last_login = Column(DateTime(timezone=False))
	is_active = Column(Boolean)

	def __repr__(self):
		return self.login

