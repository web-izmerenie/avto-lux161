import yaml
import os
import Types


class Config:
	def __init__(self):
		conf_path = os.path.join(os.getcwd(), 'config.yaml')
		if os.environ.get('CONFIG_PATH'):
			conf_path = os.environ.get('CONFIG_PATH')

		fd = open(conf_path, 'r')
		config = yaml.load(''.join(fd.readlines()))
		fd.close()

		if os.environ.get('PORT'):
			config['PORT'] = os.environ.get('PORT')
		if os.environ.get('HOST'):
			config['HOST'] = os.environ.get('HOST')

		if os.environ.get('DATABASE_PORT'):
			config['DATABASE']['PORT'] = os.environ.get('DATABASE_PORT')
		if os.environ.get('DATABASE_HOST'):
			config['DATABASE']['HOST'] = os.environ.get('DATABASE_HOST')
		if os.environ.get('DATABASE_DBNAME'):
			config['DATABASE']['DBNAME'] = os.environ.get('DATABASE_DBNAME')
		if os.environ.get('DATABASE_USER'):
			config['DATABASE']['USER'] = os.environ.get('DATABASE_USER')
		if os.environ.get('DATABASE_PASS'):
			config['DATABASE']['PASS'] = os.environ.get('DATABASE_PASS')

		if os.environ.get('TEMPLATES_PATH'):
			config['TEMPLATES_PATH'] = os.environ.get('TEMPLATES_PATH')
		if os.environ.get('STATIC_PATH'):
			config['STATIC_PATH'] = os.environ.get('STATIC_PATH')
		if os.environ.get('NUBMER_OF_INSTANCES'):
			config['NUBMER_OF_INSTANCES'] = os.environ.get('NUBMER_OF_INSTANCES')


		self.config = config

	# def check_environ(self, element):
	# 	if 

	def __call__(self, key):
		return self.config[key]


config = Config()
