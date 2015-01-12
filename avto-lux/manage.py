import os, sys
import getopt
from app.configparser import config
from app.app import run_instance
from app.models.init_models import init_models


def run(port=0, host=0):
	run_instance(config('PORT'), host=config('HOST'))


def dbsync():
	try:
		print('Models syncronization...')
		init_models()
	except Exception as e:
		print(e)


actions = {
	'run': run,
	'dbsync': dbsync,
}


if __name__ == '__main__':
	try:
		action = sys.argv[1]
		opts = sys.argv[2:]
		if len(opts) > 0:
			try:
				opts, args = getopt.getopt(sys.argv[2:], "ho:v", ["help", "output="])
			except Exception as e:
				raise Exception("Unknown option key")
		print(opts)

	except IndexError:
		raise Exception("Missed required argument")
	if action not in actions:
		raise Exception("Invalid option")

	actions[action]()
