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
import sys
session = Session()


def parse_main_image():
	pass

def parse_images():
	pass


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
		vals = vars(self).copy()

		deprecated = ['_sa_instance_state', 'id', 'create_date', 'files', 'last_change', 'alias']
		for item in deprecated:
			if item in vals:
				del vals[item]

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
		vals = vars(self).copy()

		deprecated = ['_sa_instance_state', 'id', 'create_date', 'files', 'last_change']
		for item in deprecated:
			if item in vals:
				del vals[item]

		# get section alias
		s = session.query(CatalogSectionModel.alias).filter_by(id=vals['section_id']).one()

		# main image parse {{{

		main_image = None

		try:
			main_image = json.loads(vals['main_image'])
			if type(main_image) is not list:
				raise Exception('Must be an array')
		except Exception as e:
			main_image = None
			print(e, file=sys.stderr)

		if main_image and len(main_image) > 0 and 'filename' in main_image[0]:
			main_image = main_image[0]
			main_image['filename'] = '/uploaded-files/%s' % main_image['filename']

		vals['main_image'] = main_image

		# }}}

		# images parse {{{

		images = []

		try:
			images = json.loads(vals['images'])
			if type(images) is not list:
				raise Exception('Must be an array')
		except Exception as e:
			images = []
			print(e, file=sys.stderr)

		for item in images:
			if 'filename' not in item:
				continue
			item['filename'] = '/uploaded-files/%s' % item['filename']

		vals['images'] = images

		# }}}

		vals['detail_link'] = '/catalog/{0}/{1}.html'.format(s[0], vals['alias'])

		return vals

