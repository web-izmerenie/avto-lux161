# -*- coding: utf-8 -*-

from sqlalchemy import (
	Column,
	String,
	Integer,
	Boolean,
	Text,
	ForeignKey
)
from sqlalchemy.sql import text
from collections import Iterable
from copy import deepcopy

from .dbconnect import Base, dbprefix
from .mixins import PageMixin, IdMixin


class StaticPageModel(Base, PageMixin, IdMixin):
	
	__tablename__ = dbprefix + 'pages'
	
	content_text = Column(Text)
	is_h1_show = Column(Boolean, default=False)
	is_main_page = Column(Boolean, default=False)
	is_main_menu_item = Column(Boolean, default=False)
	
	# for custom ordering
	prev_elem = Column(Integer, ForeignKey(dbprefix + 'pages.id'))
	
	@property
	def static_list(self):
		return {
			'is_active'         : bool(self.is_active),
			'title'             : self.title,
			'id'                : self.id,
			'alias'             : self.alias,
			'is_main_menu_item' : self.is_main_menu_item
		}
	
	@property
	def item(self):
		return vars(self).copy()
	
	@property
	def to_frontend(self):
		
		vals = vars(self).copy()
		
		deprecated = [
			'_sa_instance_state',
			'id',
			'create_date',
			'files',
			'last_change',
			'alias'
		]
		for item in deprecated:
			if item in vals:
				del vals[item]
		
		vals.update({'success_msg_list': '', 'error_msg_list': ''})
		return vals
	
	
	@staticmethod
	class _GetOrderedListQueryChain:
		
		def __init__(
			self,
			table_name,
			table_columns,
			filters={}
		):
			self._table_name = table_name
			self._table_columns = table_columns
			self._filters = filters
		
		@classmethod
		def copy(cls, self):
			return cls(
				table_name=str(self._table_name),
				table_columns=[str(x) for x in self._table_columns],
				filters=deepcopy(self._filters)
			)
		
		def filter(self, replace_filters=False, **filters):
			cloned = self.copy(self)
			filters = deepcopy(filters)
			if replace_filters:
				cloned._filters = filters
			else:
				cloned._filters.update(filters)
			return cloned
		
		def done(self):
			return text('''
				WITH RECURSIVE recursetree AS (
					SELECT {fields} FROM {table_name} WHERE prev_elem IS NULL
					UNION ALL
					SELECT {t_fields} FROM {table_name} t
					INNER JOIN recursetree rt ON rt.id = t.prev_elem
				)
				SELECT {fields} FROM recursetree
				{filters}
			'''.format(
				
				table_name=self._table_name,
				
				fields=', '.join(self._table_columns),
				t_fields=', '.join([
					't.{0} AS {0}'.format(x)
					for x in self._table_columns
				]),
				
				filters='' if len(self._filters) == 0 else 'WHERE ' + ' AND '.join([
					'%s = %s' % (key, (
						'"{0}"'.format(val.replace('"', '\\"', 999999))
							if type(val) is str else val
					))
					for key, val in self._filters.items()
				])
			))
	
	@classmethod
	def get_ordered_list_query(cls):
		return cls._GetOrderedListQueryChain(
			table_name=cls.__table__.name,
			table_columns=cls.__table__.columns.keys()
		)
	
	
	@staticmethod
	class _GetReorderPageQueryChain:
		
		def __init__(self, table_name, page_id=None, before_id=None):
			self._table_name = table_name
			self._page_id = page_id
			self._before_id = before_id
		
		@classmethod
		def copy(cls, self, **kwargs):
			init_kwargs = {
				'table_name': self._table_name,
				'page_id': self._page_id,
				'before_id': self._before_id
			}
			init_kwargs.update(kwargs)
			return cls(**init_kwargs)
		
		def page(self, page_id):
			return self.copy(self, page_id=page_id)
			
		def place_before(self, before_id):
			return self.copy(self, before_id=before_id)
		
		def done(self):
			if self._page_id is None or self._before_id is None:
				raise Exception('Not enough data to reorder static page')
			if self._page_id == self._before_id:
				raise Exception('Page id and new place id cannot be the same')
			return text('''
				
				WITH old_prev_of_target AS (
					SELECT prev_elem FROM {table_name}
					WHERE id = {page_id} LIMIT 1
				)
				UPDATE {table_name}
				SET prev_elem = old_prev_of_target.prev_elem
				FROM old_prev_of_target
				WHERE {table_name}.prev_elem = {page_id}
				
				;
				
				WITH place_at_page AS (
					SELECT prev_elem FROM {table_name}
					WHERE id = {before_id} LIMIT 1
				)
				UPDATE {table_name}
				SET prev_elem = place_at_page.prev_elem
				FROM place_at_page
				WHERE {table_name}.id = {page_id}
				
				;
				
				UPDATE {table_name}
				SET prev_elem = {page_id}
				WHERE id = {before_id}
				
			'''.format(
				table_name=self._table_name,
				page_id=self._page_id,
				before_id=self._before_id
			))
	
	@classmethod
	def get_reorder_page_query(cls):
		return cls._GetReorderPageQueryChain(cls.__table__.name)


class UrlMapping(Base, IdMixin):
	
	__tablename__ = dbprefix + 'oldurls'
	
	old_url = Column(String(8192))
	new_url = Column(String(8192))
	status = Column(Integer)
	
	@property
	def item(self):
		return vars(self).copy()
