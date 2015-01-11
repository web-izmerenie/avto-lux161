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
from sqlalchemy.orm import relationship
from .dbconnect import Base, dbprefix
from .mixins import PageMixin, IdMixin
	

class StaticPageModel(Base, PageMixin, IdMixin):
	__tablename__ = dbprefix + 'pages'

	content = Column(String(80192))	
	show_h1 = Column(Boolean)
	is_main_page = Column(Boolean)



class UrlMapping(Base, IdMixin):
	__tablename__ = dbprefix + 'oldurls'

	old_url = Column(String(8192))
	new_url = Column(String(8192))