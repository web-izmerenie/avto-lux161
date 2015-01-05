from sqlalchemy import create_engine
from app.configparser import config
from sqlalchemy.ext.declarative import declarative_base
Base = declarative_base()

dbc = config('DATABASE')
engine = create_engine("postgresql://%s:%s@%s/%s" % (dbc['USER'], dbc['PASS'], dbc['HOST'], dbc['DBNAME']))


