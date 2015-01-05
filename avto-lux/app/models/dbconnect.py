from sqlalchemy import create_engine
from app.configparser import config
from app.models.usermodels import Base

dbc = config('DATABASE')
engine = create_engine("postgresql://%s:%s@%s/%s" % (dbc['USER'], dbc['PASS'], dbc['HOST'], dbc['DBNAME']))

def db_init():
	Base.metadata.create_all(engine)

