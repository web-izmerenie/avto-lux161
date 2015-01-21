# -*- coding: utf-8 -*-

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

	@property
	def item(self):
		return vars(self).copy()


class OrderModel(Base, IdMixin):
	__tablename__ = dbprefix + 'orders'

	name = Column(String(4096))
	callback = Column(String(8192))
	date = Column(DateTime)
	item_id = Column(Integer, ForeignKey(dbprefix + 'catalog_items.id'))

	@property
	def item(self):
		return vars(self).copy()


class PhoneModel(Base, IdMixin):
	__tablename__ = dbprefix + 'phones'

	title = Column(String(4096))
	phone = Column(String(4096))


	def __repr__(self):
		return self.phone

	@property
	def item(self):
		return vars(self).copy()
