from sqlalchemy import (
	Column, 
	String, 
	Integer, 
	ForeignKey, 
	Boolean,
	DateTime
	)
from sqlalchemy.orm import relationship, backref
from sqlalchemy.ext.declarative import declarative_base

from app.configparser import config

Base = declarative_base()
dbprefix = config('DATABASE')['TABLE_NAME_PREFIX']


class User(Base):
	__tablename__ = dbprefix + '_users'

	user_id = Column(Integer, primary_key=True)
	name = Column(String(50))
	login = Column(String(50))
	password = Column(String(100))
	last_login = Column(DateTime(timezone=False))
	is_active = Column(Boolean)

	def __repr__(self):
		return self.name

