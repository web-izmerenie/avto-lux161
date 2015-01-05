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
from sqlalchemy.dialects.postgresql import *
from sqlalchemy.orm import relationship
	
dbprefix = config('DATABASE')['TABLE_NAME_PREFIX']


class CatalogModel(Base):
	__tablename__ = dbprefix + '_catalog'

	section_id = Column(Integer, primary_key=True)
	items = relationship('CatalogItemModel')
	is_visible = Column(Boolean)

	inherit_seo_meta_title = Column(Boolean)
	inherit_seo_meta_keywords = Column(Boolean)
	inherit_seo_meta_descrtption = Column(Boolean)
	inherit_seo_title = Column(Boolean)


class CatalogItemModel(Base):
	__tablename__ = dbprefix + '_catalog_items'

	item_id = Column(Integer, primary_key=True)
	item_title = Column(String(4096))
	item_description = Column(Text)
	main_image = Column(String(8192))
	images = Column(ARRAY(String))
	is_visible = Column(Boolean)

	## Inheritance from catalog

	inherit_seo_meta_title = Column(Boolean)
	inherit_seo_meta_keywords = Column(Boolean)
	inherit_seo_meta_descrtption = Column(Boolean)
	inherit_seo_title = Column(Boolean)

	seo_meta_title = Column(String(4096))
	seo_meta_keywords = Column(String(4096))
	seo_meta_descrtption = Column(String(8192))
	seo_title = Column(String(4096))

