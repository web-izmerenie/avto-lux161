# -*- coding: utf-8 -*-

import warnings
import sys
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import OperationalError
from sqlalchemy import inspect

from app.configparser import config


Base = declarative_base()

dbprefix = config('DATABASE')['TABLE_NAME_PREFIX']

dbc = config('DATABASE')
engine = create_engine('postgresql://%s:%s@%s/%s' % (
	dbc['USER'], dbc['PASS'], dbc['HOST'], dbc['DBNAME']
))

try:
	db_inspector = inspect(engine)
except OperationalError as e:
	if 'Connection refused' in str(e):
		warnings.warn('Connect to PostgreSQL database error:\nException: %s' % e)
		sys.exit(1)
	else:
		raise e

Session = sessionmaker(bind=engine)
