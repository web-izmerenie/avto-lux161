# -*- coding: utf-8 -*-

from sqlalchemy import (
	Column,
	String,
	Integer,
	Boolean,
	DateTime,
	Text,
	ForeignKey,
)
from app.configparser import config
from sqlalchemy.dialects.postgresql import *
from sqlalchemy.orm import relationship
from .dbconnect import Base, dbprefix
from .pagemodels import PageMixin, IdMixin
from sqlalchemy.dialects.postgresql import JSON
from app.models.dbconnect import Session
from os import path
import json
import sys
import warnings


class CatalogSectionModel(Base, PageMixin):
	__tablename__ = dbprefix + 'catalog'
	
	delegate_seo_meta_title = Column(Boolean)
	delegate_seo_meta_keywords = Column(Boolean)
	delegate_seo_meta_descrtption = Column(Boolean)
	delegate_seo_title = Column(Boolean)
	
	page_seo_text = Column(Text)
	
	items = relationship('CatalogItemModel')
	
	@property
	def item(self):
		return vars(self).copy()
	
	@property
	def to_frontend(self):
		vals = vars(self).copy()
		
		deprecated = [
			'_sa_instance_state',
			'create_date',
			'files',
			'last_change',
			'alias'
		]
		for item in deprecated:
			if item in vals:
				del vals[item]
		
		return vals


class CatalogItemModel(Base, PageMixin):
	__tablename__ = dbprefix + 'catalog_items'
	
	description_text = Column(Text)
	main_image = Column(JSON)
	images = Column(JSON)
	
	section_id = Column(Integer, ForeignKey(dbprefix + 'catalog.id'))
	orders = relationship('OrderModel')
	
	inherit_seo_meta_title = Column(Boolean)
	inherit_seo_meta_keywords = Column(Boolean)
	inherit_seo_meta_descrtption = Column(Boolean)
	inherit_seo_title = Column(Boolean)
	
	
	def _get_main_image(self):
		
		main_image = None
		
		try:
			main_image = json.loads(self.main_image)
			msg = "'main_image' must be a list with single element or just empty list"
			assert type(main_image) is list, msg
			assert 0 <= len(main_image) <= 1, msg
			if len(main_image) > 0:
				assert 'filename' in main_image[0], \
					"'main_image' list item must contain 'filename' key"
				assert main_image[0]['filename'] == path.basename(main_image[0]['filename']), \
					"'images' list item 'filename' property is unsafe"
		except Exception as e:
			main_image = None
			warnings.warn(
				"CatalogItemModel._get_main_image(): get 'main_image' error " + \
				"(catalog item id: %d)\nException: %s" % (self.id, e)
			)
		
		if main_image is not None and len(main_image) == 0:
			return None
		else:
			return main_image[0]
	
	@property
	def frontend_main_image(self):
		main_image = self._get_main_image()
		if main_image is None:
			return None
		else:
			main_image['filepath'] = '/uploaded-files/%s' % main_image['filename']
			return main_image
	
	@property
	def system_main_image(self):
		main_image = self._get_main_image()
		if main_image is None:
			return None
		else:
			main_image['filepath'] = path.join(config('UPLOAD_FILES_PATH'), main_image['filename'])
			return main_image
	
	
	def _get_images(self):
		
		images = []
		
		try:
			images = json.loads(self.images)
			assert type(images) is list, "'images' must be a list"
			for item in images:
				assert type(item) is dict, \
					"'images' list item must be a dictionary"
				assert 'filename' in item, \
					"'images' list item must have 'filename' property"
				assert type(item['filename']) is str, \
					"'images' property of 'files' list item must be a string"
				assert item['filename'] == path.basename(item['filename']), \
					"'images' list item 'filename' property is unsafe"
		except Exception as e:
			images = []
			warnings.warn(
				"CatalogItemModel._get_images(): get 'images' error " + \
				"(catalog item id: %d)\nException: %s" % (self.id, e)
			)
		
		return images
	
	@property
	def frontend_images(self):
		return list(map(
			lambda x: (x, x.update(filepath='/uploaded-files/%s' % x['filename']))[0],
			self._get_images()
		))
	
	@property
	def system_images(self):
		return list(map(
			lambda x: (x, x.update(filepath=path.join(config('UPLOAD_FILES_PATH'), x['filename'])))[0],
			self._get_images()
		))
	
	
	@property
	def item(self):
		return vars(self).copy()
	
	@property
	def to_frontend(self):
		vals = vars(self).copy()
		
		deprecated = [
			'_sa_instance_state',
			'create_date',
			'files',
			'last_change'
		]
		for item in deprecated:
			if item in vals:
				del vals[item]
		
		# get section alias
		session = Session()
		try:
			section_alias = session.query(CatalogSectionModel.alias) \
				.filter_by(id=vals['section_id']) \
				.one()
		except Exception as e:
			warnings.warn(
				'CatalogItemModel.to_frontend():' + \
				' cannot find section by "section_id"' + \
				' (catalog item id: %d)\nException: %s' % (self.id, e)
			)
			raise e
		finally:
			session.close()
		
		vals['main_image']  = self.frontend_main_image
		vals['images']      = self.frontend_images
		
		vals['detail_link'] = '/catalog/%s/%s.html' % (section_alias[0], vals['alias'])
		
		return vals
