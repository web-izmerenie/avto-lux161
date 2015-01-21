# -*- coding: utf-8 -*-

from .pagemodels import *
from .catalogmodels import *
from .utilmodels import *
from .usermodels import *
from .dbconnect import Base, engine

def init_models():
	Base.metadata.create_all(engine)
