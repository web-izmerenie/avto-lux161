# -*- coding: utf-8 -*-

def is_date(obj):
	import datetime
	if isinstance(obj, datetime.date):
		return obj.isoformat()
