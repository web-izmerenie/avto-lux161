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
			'is_active' : self.is_active and True or False,
			'title'     : self.title,
			'id'        : self.id,
			'alias'     : self.alias
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
	
	@classmethod
	def get_ordered_list_query(cls, **filters):
		return text('''
			WITH ordering AS (
				SELECT *, ROW_NUMBER() OVER (ORDER BY id ASC) AS pos FROM {0}
			)
			SELECT {1}
			FROM {0}
			INNER JOIN ordering AS cur ON ({0}.id = cur.id)
			LEFT JOIN ordering AS next ON (next.prev_elem = {0}.id)
			{2}
			ORDER BY (
				CASE WHEN cur.prev_elem IS NULL THEN 0 ELSE next.pos END
			) ASC
		'''.format(
			
			cls.__table__.name,
			
			', '.join([
				'cur.{0} AS {0}'.format(x)
				for x in cls.__table__.columns.keys()
			]),
			
			'' if len(filters) == 0 else 'WHERE ' + ' AND '.join([
				'cur.%s = %s' % (key, val)
				for key, val in filters.items()
			])
		))


class UrlMapping(Base, IdMixin):
	__tablename__ = dbprefix + 'oldurls'
	
	old_url = Column(String(8192))
	new_url = Column(String(8192))
	status = Column(Integer)
	
	@property
	def item(self):
		return vars(self).copy()
