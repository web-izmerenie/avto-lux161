# -*- coding: utf-8 -*-

from .dbconnect import Base
from app.configparser import config
from sqlalchemy.ext.declarative import declarative_base, declared_attr
from sqlalchemy import (
	Column,
	String,
	Integer,
	Boolean,
	DateTime,
)
from sqlalchemy.schema import ColumnDefault
from sqlalchemy.dialects.postgresql import JSON
import warnings
import json
from os import path


class IdMixin:
	@declared_attr
	def id(cls):
		return Column(Integer, primary_key=True)


class PageMixin(IdMixin):
	
	@declared_attr
	def title(cls):
		return Column(String(4096))
	
	@declared_attr
	def is_active(cls):
		return Column(Boolean, default=False)
	
	@declared_attr
	def alias(cls):
		return Column(String(8192), unique=True)
	
	@declared_attr
	def has_footer_slogan(cls):
		return Column(Boolean, default=False)
	
	@declared_attr
	def footer_slogan(cls):
		return Column(String(8192))
	
	@declared_attr
	def seo_meta_title(cls):
		return Column(String(4096))
	
	@declared_attr
	def seo_meta_keywords(cls):
		return Column(String(4096))
	
	@declared_attr
	def seo_meta_description(cls):
		return Column(String(8192))
	
	@declared_attr
	def seo_title(cls):
		return Column(String(4096))
	
	@declared_attr
	def create_date(cls):
		return Column(DateTime)
	
	@declared_attr
	def last_change(cls):
		return Column(DateTime)
	
	
	
	
	@declared_attr
	def files(cls):
		return Column(JSON)
	
	def _get_files_list(self):
		files_list = []
		try:
			files_list = json.loads(self.files)
			assert type(files_list) is list, "'files' must be a list"
			for item in files_list:
				assert type(item) is dict, "'files' list item must be a dictionary"
				assert 'filename' in item, "'files' list item must have 'filename' property"
				assert type(item['filename']) is str, "'filename' property of 'files' list item must be a string"
				assert item['filename'] == path.basename(item['filename']), ''
		except Exception as e:
			files_list = []
			warnings.warn(
				"PageMixin._get_files_list(): parse JSON error " + \
				"(id: %d)\nException: %s" % (self.id, e)
			)
		return files_list
	
	@property
	def frontend_files_list(self):
		return list(map(
			lambda x: (x, x.update(filepath='/uploaded-files/%s' % x['filename']))[0],
			self._get_files_list()
		))
	
	@property
	def system_files_list(self):
		return list(map(
			lambda x: (x, x.update(filepath=path.join(config('UPLOAD_FILES_PATH'), x['filename'])))[0],
			self._get_files_list()
		))
