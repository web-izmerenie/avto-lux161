import os, sys
import getopt
from app.configparser import config
from app.app import run_instance
from app.models.init_models import init_models
import multiprocessing

devserver = config('DEVSERVER')
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
		print(e)



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
		'run':{
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
	}

	if action not in actions:
		raise Exception("Invalid option")

	ac = actions[action]
	ac['fn'](**ac['kwrgs'])
