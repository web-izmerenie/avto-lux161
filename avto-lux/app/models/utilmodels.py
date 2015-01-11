from sqlalchemy import (
	Column,
	String,
	Integer,
	Boolean,
	DateTime,
	ForeignKey
	)
from app.configparser import config
from .dbconnect import Base, dbprefix
from sqlalchemy.dialects.postgresql import *
from .pagemodels import IdMixin
from .catalogmodels import CatalogItemModel


class CallModel(Base, IdMixin):
	__tablename__ = dbprefix + 'calls'

	name = Column(String(4096))
	phone = Column(String(4096))
	date  = Column(DateTime)


class OrderModel(Base, IdMixin):
	__tablename__ = dbprefix + 'orders'

	name = Column(String(4096))
	email = Column(String(8192))
	phone = Column(String(4096))
	date = Column(DateTime)
	orders = Column(Integer, ForeignKey(dbprefix + 'catalog_items.id'))


class PhoneModel(Base, IdMixin):
	__tablename__ = dbprefix + 'phones'

	title = Column(String(4096))
	phone = Column(String(4096))


	def __repr__(self):
		return self.phone


class UploadedFiles(Base, IdMixin):
	__tablename__ = dbprefix + 'files'

	filetype = Column(String(200))
	path = Column(String(4000))
	alt = Column(String(8196))


