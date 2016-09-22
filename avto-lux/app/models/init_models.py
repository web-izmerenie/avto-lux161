# -*- coding: utf-8 -*-

from .pagemodels import *
from .catalogmodels import *
from .utilmodels import *
from .usermodels import *
from .dbconnect import Base, engine
from .migrate import init_migrate


def init_models():
	Base.metadata.create_all(engine)
	init_migrate()
	print('Models are initialized.')
