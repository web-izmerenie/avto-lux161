from sqlalchemy import create_engine
from app.configparser import config
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy import inspect

Base = declarative_base()

dbprefix = config('DATABASE')['TABLE_NAME_PREFIX']

dbc = config('DATABASE')
engine = create_engine("postgresql://%s:%s@%s/%s" % (
	dbc['USER'], dbc['PASS'], dbc['HOST'], dbc['DBNAME']))
db_inspector = inspect(engine)

Session = sessionmaker(bind=engine)
