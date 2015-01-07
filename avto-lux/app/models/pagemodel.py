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
from .dbconnect import Base
from .catalogmodels import CatalogModel
from .usermodels import User
from sqlalchemy.orm import relationship
	
dbprefix = config('DATABASE')['TABLE_NAME_PREFIX']

class StaticPageModel(Base):
	__tablename__ = dbprefix + '_pages'

	page_id = Column(Integer, primary_key=True)
	title = Column(String(4096))
	content = Column(Text)
	footer_text = Column(Text)
	is_visible = Column(Boolean)
	is_catalog_page = Column(Boolean)
	alias = Column(String(8192))
	catalog = relationship('CatalogModel', uselist=False)
	is_footer_slogan = Column(Boolan)
	footer_slogan = Column(String(8192))

	seo_meta_title = Column(String(4096))
	seo_meta_keywords = Column(String(4096))
	seo_meta_descrtption = Column(String(8192))
	seo_title = Column(String(4096))

	create_date = Column(DateTime)
	last_change = Column(DateTime)


class UrlMapping(Base):
	__tablename__ = dbprefix + '_oldurls'
	url_id = Column(Integer, primary_key=True)
	old_url = Column(String(8192))
	new_url = Column(String(8192))