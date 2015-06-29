# -*- coding: utf-8 -*-

from sqlalchemy import (
	Column,
	String,
	Integer
)
from sqlalchemy.dialects.postgresql import JSON
from .dbconnect import Base, dbprefix
from .mixins import IdMixin


class NonRelationData(Base, IdMixin):
	__tablename__ = dbprefix + 'non_relation_data'
	
	name = Column(String(1024))
	code = Column(String(1024), unique=True)
	sort = Column(Integer)
	data_json = Column(JSON)
	
	def __repr__(self):
		return self.data_json
	
	@property
	def item(self):
		return vars(self).copy()
	
	@property
	def to_frontend(self):
		vals = vars(self).copy()
		
		deprecated = ['_sa_instance_state', 'data_json']
		for item in deprecated:
			if item in vals:
				del vals[item]
		
		return vals
