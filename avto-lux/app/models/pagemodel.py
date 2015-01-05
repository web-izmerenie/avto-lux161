from sqlalchemy import (
	Column, 
	String, 
	Integer, 
	Boolean,
	DateTime,
	Text
	)
from app.configparser import config
from .dbconnect import Base
from .catalogmodels import CatalogModel
from sqlalchemy.orm import relationship
	
dbprefix = config('DATABASE')['TABLE_NAME_PREFIX']

class StaticPageModel(Base):
	__tablename__ = dbprefix + '_pages'

	page_id = Column(Integer, primary_key=True)
	title = Column(String(4096))
	content = Column(Text)
	is_visible = Column(Boolean)
	is_catalog_page = Column(Boolean)
	catalog_page = relationship('CatalogModel')

	seo_meta_title = Column(String(4096))
	seo_meta_keywords = Column(String(4096))
	seo_meta_descrtption = Column(String(8192))
	seo_title = Column(String(4096))