import os, sys
import getopt
from app.configparser import config
from app.app import run_instance
from app.models.init_models import init_models



def run():
	run_instance(config('PORT'), host=config('HOST'))


def dbsync():
	pass

if __name__ == '__main__':
	try:
		action = sys.argv[1]
		opts = sys.argv[2:]
	except IndexError:
		raise Exception("Missed required argument")

	actions = {
		'run': run,
		'dbsync': dbsync,
	}

	actions[action]()
