# -*- coding: utf-8 -*-

def get_json_localization(side):
	
	import os
	import json
	from app.configparser import config
	
	pathc = config('LOCALIZATION')['SOURCES']
	if side is None and not pathc[side]:
		raise Exception("Incorrect localization source")
	
	f = open(os.path.join(os.getcwd(), pathc[side]), 'r')
	jn = json.loads(''.join([line for line in f]))
	f.close()
	return jn
