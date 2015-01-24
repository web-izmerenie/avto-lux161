# -*- coding: utf-8 -*-

from tornado.web import RequestHandler
import json
from app.utils import is_date
from app.models.pagemodels import StaticPageModel
from app.models.dbconnect import Session
from app.models.catalogmodels import CatalogSectionModel
from app.models.non_relation_data import NonRelationData
import sys


class MenuProviderMixin():
	def getmenu(
		self,
		page_alias=None,
		catalog_section_alias=None,
		catalog_item_alias=None
	):
		menu = {
			'main': [],
			'catalog': []
		}

		session = Session()

		static_pages = session.query(StaticPageModel)\
			.filter_by(is_main_menu_item=True)\
			.order_by("id asc").all()
		for page in [x.item for x in static_pages]:
			item = {
				'active': False,
				'link': page['alias'],
				'title': page['title']
			}
			if page_alias is not None:
				if page['alias'] == page_alias:
					item['active'] = True
			menu['main'].append(item)

		sections = session.query(CatalogSectionModel).order_by("id asc").all()
		for section in [x.item for x in sections]:
			item = {
				'active': False,
				'current': False,
				'link': '/catalog/' + section['alias'] + '.html',
				'title': section['title']
			}
			if catalog_section_alias is not None:
				if section['alias'] == catalog_section_alias:
					item['active'] = True
					item['current'] = True
					if catalog_item_alias is not None:
						item['current'] = False
			menu['catalog'].append(item)

		session.close()
		return menu


class NonRelationDataProvider():
	def get_nonrel_arr(self, code1, code2):
		res = []
		level1 = None

		if code1 not in self.nonrel_list:
			print('data code "%s" not found' % code1, file=sys.stderr)
			return tuple(res)

		level1 = self.nonrel_list[code1]

		for item in level1:
			if 'code' not in item.keys():
				continue
			if item['code'] == code2:
				values = item['values']
				for val in values:
					res.append(val['value'])

		return tuple(res)

	def get_nonrel_val(self, code1, code2):
		res = ''

		arr = self.get_nonrel_arr(code1, code2)
		if len(arr) > 0:
			res = arr[0]

		return res

	def get_nonrel_handlers(self):
		session = Session()
		data = session.query(NonRelationData).all()
		session.close()

		export = {}
		for item in [x.item for x in data]:
			data_list = tuple()
			try:
				data_list = json.loads(item['data_json'])
				if type(data_list) is not list and type(data_list) is not tuple:
					raise Exception('"data_json" must be a json-array')
			except Exception as e:
				print(e, file=sys.stderr)
				data_list = tuple()
			export[item['code']] = data_list
		self.nonrel_list = export

		res = {
			'get_nonrel_arr': self.get_nonrel_arr,
			'get_nonrel_val': self.get_nonrel_val
		}

		return res


class JsonResponseMixin(RequestHandler):
	def json_response(self, data):
		return self.write(json.dumps(data, default=is_date))


class ErrorHandlerMixin(RequestHandler):
	def write_error(self, status_code, **kwargs):
		error_class_name = kwargs["exc_info"][1].__class__.__name__
		errors = {
			'FileNotFoundError': 500
		}
		status = errors[error_class_name]
		self.set_status(status)

		return self.write('500: Internal server error')


class JResponse(RequestHandler):
	def __init__(self, status='success', status_code=200):
		self.status = status
		self.s_code = status_code

	def __call__(self, response_data):
		if self.self.s_code is not 200:
			self.set_status(self.self.s_code)
			data = {'status': self.status}.update(response_data)
		return self.self.write(json.dumps(data, default=is_date))


success_response = JResponse()
error_response = JResponse(status='error', status_code=500)
not_found_response = JResponse(status='not_found', status_code=404)
