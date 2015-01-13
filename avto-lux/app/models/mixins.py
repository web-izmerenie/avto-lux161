from .dbconnect import Base
from sqlalchemy.ext.declarative import declarative_base, declared_attr
from sqlalchemy import (
	Column,
	String,
	Integer,
	Boolean,
	DateTime
)
from sqlalchemy.dialects.postgresql import JSON

class PageMixin:

	@declared_attr
	def title(cls):
		return Column(String(4096))

	@declared_attr
	def is_active(cls):
		return Column(Boolean)

	@declared_attr
	def alias(cls):
		return Column(String(8192))

	@declared_attr
	def has_footer_slogan(cls):
		return Column(Boolean)

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
	def seo_meta_descrtption(cls):
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

class IdMixin:
	@declared_attr
	def id(cls):
		return Column(Integer, primary_key=True)
