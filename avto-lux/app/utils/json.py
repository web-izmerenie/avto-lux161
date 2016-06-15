# -*- coding: utf-8 -*-

def to_json(obj):
	import json
	from .date import is_date
	return json.dumps([dict(x) for x in obj], default=is_date)
