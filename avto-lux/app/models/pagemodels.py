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
import base64


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
		escaped = ['footer_slogan']
		try:
			for item in deprecated:
				del vals[item]
		except:
			pass
		# for item in escaped:
		# 	print(vals[item])
		# 	vals[item] = base64.b64encode(vals[item])

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
