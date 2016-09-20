# -*- coding: utf-8 -*-

from sqlalchemy import (
	Column,
	String,
	Integer,
	Boolean,
	DateTime
)
import json
import sys

from app.configparser import config
from .dbconnect import Base, dbprefix, engine, Session
from .pagemodels import IdMixin
from .init_models import init_models
from app.mixins import AuthMixin


class User(Base, IdMixin):
	
	__tablename__ = dbprefix + 'users'
	
	login = Column(String(4096))
	password = Column(String(5000))
	last_login = Column(DateTime(timezone=False))
	is_active = Column(Boolean)
	
	def __repr__(self):
		return self.login
	
	@property
	def item(self):
		return vars(self).copy()


_default_superuser_login = 'admin'
_default_superuser_password = 'admin'


def create_init_user():
	session = Session()
	try:
		session.query(User).filter_by(login=_default_superuser_login).one()
		print(
			Exception(
				'create_init_user(): Superuser "%s" '+
				'already exists' % _default_superuser_login
			),
			file=sys.stderr
		)
		return False
	except:
		init_models()
		try:
			newusr = User(
				login=_default_superuser_login,
				password=AuthMixin().create_password(_default_superuser_password),
				is_active=True
			)
		except Exception as e:
			session.close()
			print(
				'create_init_user(): cannot create superuser:\n',\
				e, file=sys.stderr
			)
			raise e
		session.add(newusr)
		session.commit()
	session.close()
