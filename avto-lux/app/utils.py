import sys

class CollectHandlersException(Exception):
	def __repr__(self, e, list):
		return "{0}, {1}".format(e, list)



def collect_handlers(*args):
	## TODO: implement sort
	# def sort_func(x):
	# 	val = x[0]
	# 	max_of_positions = 0
	# 	if val.endwith('/'):
	# 		nums = val.count - 1
	# 	else:
	# 		nums = val.count('/')
	# 	return val

	routes  = []
	for item in args:
		routes += item
	routeslist = [x[0] for x in routes]
	duplicated = { x for x in routeslist if routeslist.count(x) > 1 }
	if len(duplicated) > 0:
		raise CollectHandlersException("Duplicate routes! {0}".format(duplicated))

	# print("Sorted: {0}".format(sorted(routes, key=sort_func, reverse=False)))

	# return sorted(routes, key=lambda x: x[0], reverse=True)
	return routes




def error_log(error):
	print("An error occured! \n{0}".format(error))
	sys.exit(1)