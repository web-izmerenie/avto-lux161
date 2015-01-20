# -*- coding: utf-8 -*-

from sqlalchemy import (
	Column,
	Table,
	String,
	Integer,
	Boolean,
	DateTime,
	Text,
	ForeignKey
	)
from app.configparser import config
from sqlalchemy.orm import relationship
from .dbconnect import Base, dbprefix
from .mixins import PageMixin, IdMixin


class StaticPageModel(Base, PageMixin, IdMixin):
	__tablename__ = dbprefix + 'pages'

	content_text = Column(Text)
	is_h1_show = Column(Boolean, default=False)
	is_main_page = Column(Boolean, default=False)

	@property
	def static_list(self):
		return {
			'title': self.title,
			'id': self.id,
			'alias': self.alias
			}

	@property
	def item(self):
		return vars(self)

	@property
	def to_frontend(self):
		vals = vars(self)

		deprecated = ['_sa_instance_state', 'id', 'create_date', 'files', 'last_change', 'alias']
		for item in deprecated:
			if item in vals:
				del vals[item]

		vals.update({'success_msg_list': '', 'error_msg_list': ''})
		return vals


class UrlMapping(Base, IdMixin):
	__tablename__ = dbprefix + 'oldurls'

	old_url = Column(String(8192))
	new_url = Column(String(8192))
	status = Column(Integer)

	@property
	def item(self):
		return vars(self)
