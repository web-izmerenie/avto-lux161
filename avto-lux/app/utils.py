

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
		raise CollectHandlersException("Duplicate routes!", duplicated)

	return routes