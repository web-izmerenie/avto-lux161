#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os, sys
import warnings
import getopt
from app.configparser import config
from app.app import run_instance
from app.models.init_models import init_models
from app.models.usermodels import create_init_user
from app.models.migrate import migrate
import multiprocessing


devserver = config('DEV_SERVER')
prserver = config('PRODUCTION_SERVER')

def error_handler(fn):
	pass

def devserver(port=devserver['PORT'], host=devserver['HOST']):
	run_instance(port, host)


def server(instances=prserver['INSTANCES']):
	port = prserver['MAIN_PORT']
	host = prserver['HOST']
	for ins in range(prserver['INSTANCES']):
		process = multiprocessing.Process(target=run_instance, args=(port + ins, host))
		process.start()

def dbsync():
	try:
		print('Models syncronization...')
		init_models()
	except Exception as e:
		warnings.warn(e)


def createadmin():
	return create_init_user()



if __name__ == '__main__':
	
	try:
		action = sys.argv[1]
		# opts = sys.argv[2:]
		# if len(opts) > 0:
		# 	try:
		# 		opts, args = getopt.getopt(sys.argv[2:], "p", ["help", "output="])
		# 	except Exception as e:
		# 		raise Exception("Unknown option key")
		# print(opts)
	
	except IndexError:
		raise Exception("Missed required argument")
	
	actions = {
		'run': {
			'fn': server,
			'kwrgs': {},
			'options': []
		},
		'dev-server': {
			'fn': devserver,
			'kwrgs': {},
			'options': []
		},
		'dbsync': {
			'fn': dbsync,
			'kwrgs': {},
			'options': []
		},
		'create-admin': {
			'fn': createadmin,
			'kwrgs': {},
			'options': []
		},
		'dbmigrate': {
			'fn': migrate,
			'kwrgs': {},
			'options': []
		}
	}
	
	if action not in actions:
		raise Exception("Invalid option")
	
	ac = actions[action]
	ac['fn'](**ac['kwrgs'])
