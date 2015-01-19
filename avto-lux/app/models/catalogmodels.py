from sqlalchemy import (
	Column,
	String,
	Integer,
	Boolean,
	DateTime,
	Text,
	ForeignKey
	)
from app.configparser import config
from sqlalchemy.dialects.postgresql import *
from sqlalchemy.orm import relationship
from .dbconnect import Base, dbprefix
from .pagemodels import PageMixin, IdMixin
from sqlalchemy.dialects.postgresql import JSON
from app.models.dbconnect import Session
import json
session = Session()

class CatalogSectionModel(Base, PageMixin, IdMixin):
	__tablename__ = dbprefix + 'catalog'

	delegate_seo_meta_title = Column(Boolean)
	delegate_seo_meta_keywords = Column(Boolean)
	delegate_seo_meta_descrtption = Column(Boolean)
	delegate_seo_title = Column(Boolean)

	items = relationship('CatalogItemModel')

	@property
	def item(self):
		return vars(self)

	@property
	def to_frontend(self):
		vals = vars(self)
		deprecated = ['_sa_instance_state', 'id', 'create_date', 'files', 'last_change', 'alias']
		escaped = ['footer_slogan']
		try:
			for item in deprecated:
				del vals[item]
		except:
			pass
		return vals



class CatalogItemModel(Base, PageMixin, IdMixin):
	__tablename__ = dbprefix + 'catalog_items'

	desctiption_text = Column(Text)
	main_image = Column(JSON)
	images = Column(JSON)

	section_id = Column(Integer, ForeignKey(dbprefix + 'catalog.id'))
	orders = relationship('OrderModel')

	inherit_seo_meta_title = Column(Boolean)
	inherit_seo_meta_keywords = Column(Boolean)
	inherit_seo_meta_descrtption = Column(Boolean)
	inherit_seo_title = Column(Boolean)

	@property
	def item(self):
		return vars(self)

	@property
	def to_frontend(self):
		vals = vars(self)
		deprecated = ['_sa_instance_state', 'id','create_date', 'files', 'last_change']
		try:
			for item in deprecated:
				del vals[item]
		except:
			pass

		s = session.query(CatalogSectionModel.alias).filter_by(id=vals['section_id']).one()

		# if vals['main_image'] == '':
		# 	main_img = ''
		# else:
		# 	main_img = vals['main_image']
		# 	if len(main_img) == 0:
		# 		main_img = ''
		# 	else:
		# 		main_img = main_img
		# print(main_img)

		vals.update({'detail_link': '/catalog/{0}/{1}.html'.format(s[0], vals['alias'])})

		return vals

