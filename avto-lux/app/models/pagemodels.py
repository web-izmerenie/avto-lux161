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
	is_h1_show = Column(Boolean, default=True)
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



class UrlMapping(Base, IdMixin):
	__tablename__ = dbprefix + 'oldurls'

	old_url = Column(String(8192))
	new_url = Column(String(8192))
	status = Column(Integer, default=301)

	@property
	def item(self):
		print(vars(self))
		return vars(self)
