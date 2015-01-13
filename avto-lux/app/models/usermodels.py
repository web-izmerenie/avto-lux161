from sqlalchemy import (
	Column,
	String,
	Integer,
	Boolean,
	DateTime
	)
import json
from app.configparser import config
from .dbconnect import Base, dbprefix, engine, session
from .pagemodels import IdMixin
from .init_models import init_models
from app.mixins import AuthMixin



class User(Base, IdMixin):
	__tablename__ = dbprefix + 'users'

	login = Column(String(128))
	password = Column(String(4096))
	last_login = Column(DateTime(timezone=False))
	is_active = Column(Boolean)

	def __repr__(self):
		return self.login


def create_init_user():
	try:
		usr = session.query(User).filter_by(login='admin').one()
		print("Superuser exists")
		return False
	except Exception as e:
		init_models()
		newusr = User(
			login='admin',
			password=AuthMixin().create_password('admin'),
			is_active=True)
		session.add(newusr)
		session.commit()


