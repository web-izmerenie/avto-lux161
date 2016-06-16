# -*- coding: utf-8 -*-

import sys
from sqlalchemy import create_engine
from app.configparser import config
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import OperationalError
from sqlalchemy import inspect

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
		print('Connect to PostgreSQL database error:\n', e, file=sys.stderr)
	else:
		raise e

Session = sessionmaker(bind=engine)
