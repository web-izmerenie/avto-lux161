from app.app import run_instance
from app.configparser import config

if __name__ == '__main__':
	run_instance(config('PORT'), host=config('HOST'))

