import yaml
import os, sys


class Config:
	ENV_VARS = ('PORT', 'HOST')

	def __init__(self):
		conf_path = os.path.join(os.getcwd(), 'config.yaml')
		if os.environ.get('CONFIG_PATH'):
			conf_path = os.environ.get('CONFIG_PATH')

		fd = open(conf_path, 'r')
		config = yaml.load(''.join(fd.readlines()))
		fd.close()

		for key in self.ENV_VARS:
			if os.environ.get(key):
				config[key] = os.environ.get(key)
		self.config = config

	def __call__(self, key):
		return self.config[key]


config = Config()