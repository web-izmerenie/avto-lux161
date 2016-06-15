# -*- coding: utf-8 -*-

import yaml
import os
from copy import deepcopy
import warnings

from .utils.lazy_memoize_wrapper import LazyMemoizeWrapper

class Config:
	
	def __init__(self):
		
		self._read_configs()
		self._deep_check_required_config_keys(
			self._default_config, self._config
		)
		self._deep_warning_about_unknown_config_keys(
			self._default_config, self._config
		)
		
		config = deepcopy(self._config)
		
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
	
	def _read_configs(self):
		self._default_config = self._read_config(
			os.path.join(os.getcwd(), 'config.yaml.example')
		)
		self._config = self._read_config(self._get_config_path())
	
	@staticmethod
	def _deep_check_required_config_keys(default_branch, branch, branch_path=''):
		for key in default_branch:
			new_branch_path = branch_path + '.' + key
			if key not in branch:
				raise AttributeError(
					"Required config branch '%s' doesn't exists" % new_branch_path[1:]
				)
			if type(default_branch[key]) is dict:
				if type(branch[key]) is not dict:
					raise AttributeError("Branch '%s' should be a dictionary" % new_branch_path[1:])
				Config._deep_check_required_config_keys(
					default_branch[key], branch[key], new_branch_path
				)
	
	@staticmethod
	def _deep_warning_about_unknown_config_keys(default_branch, branch, branch_path=''):
		for key in branch:
			new_branch_path = branch_path + '.' + key
			if key not in default_branch:
				warnings.warn("Found unknown config branch: '%s'" % new_branch_path[1:])
				continue
			if type(branch[key]) is dict:
				Config._deep_warning_about_unknown_config_keys(
					default_branch[key], branch[key], new_branch_path
				)

	@staticmethod
	def _read_config(config_path):
		fd = open(config_path, 'r')
		config = yaml.load(''.join(fd.readlines()))
		fd.close()
		return config

	_get_config_path = LazyMemoizeWrapper(
		lambda:
			os.environ.get('CONFIG_PATH')
			if os.environ.get('CONFIG_PATH')
			else os.path.join(os.getcwd(), 'config.yaml')
	)

	def __call__(self, key):
		return self.config[key]



config = Config()
