from sqlalchemy import (
	Column, 
	String, 
	Integer, 
	Boolean,
	DateTime
	)
from app.configparser import config
from .dbconnect import Base
from sqlalchemy.dialects.postgresql import *
	
dbprefix = config('DATABASE')['TABLE_NAME_PREFIX']



class CallModel(Base):
	__tablename__ = dbprefix + '_calls'

	call_id = Column(Integer, primary_key=True)
	name = Column(String(4096))
	phone = Column(String(4096))



class OrderModel(Base):
	__tablename__ = dbprefix + '_orders'

	order_id = Column(Integer, primary_key=True)
	name = Column(String(4096))
	email = Column(String(8192))
	date = Column(DateTime)
	phone = Column(String(4096))

