import sys

class CollectHandlersException(Exception):
	def __repr__(self, e, list):
		return "{0}, {1}".format(e, list)

def collect_handlers(*args):
	routes  = []
	for item in args:
		routes += item
	routeslist = [x[0] for x in routes]
	duplicated = { x for x in routeslist if routeslist.count(x) > 1 }
	if len(duplicated) > 0:
		raise CollectHandlersException("Duplicate routes! {0}".format(duplicated))

	return routes


def error_log(error):
	print("An error occured! \n{0}".format(error))
	sys.exit(1)