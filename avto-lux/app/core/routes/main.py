import json
import tornado.template
from tornado.web import HTTPError, MissingArgumentError
from .base import BaseHandler

from app.mixins.routes_mixin import Custom404Mixin, JsonResponseMixin
from pyjade.ext.tornado import patch_tornado

from app.models.dbconnect import session
from sqlalchemy import select, func

## Debug
from app.models.usermodels import User
from app.models.pagemodels import (
	StaticPageModel,
	UrlMapping
)
from app.models.catalogmodels import(
	CatalogSectionModel,
	CatalogItemModel
)

from app.models.utilmodels import (
	CallModel,
	OrderModel
)
from sqlalchemy.orm.exc import MultipleResultsFound, NoResultFound
import time
import datetime

patch_tornado()


class MainRoute(BaseHandler, Custom404Mixin):
	def get(self):
		# return self.render('sdfs.jade')
		q = session.query(User).all()
		self.write(json.dumps(str(q)))


class UrlToRedirect(BaseHandler):
	def get(self, first, second):
		old_url = self.request.uri
		new_url = session.query(UrlMapping.new_url).filter_by(old_url=str(old_url))
		return self.redirect(str(new_url[0][0]), permanent=False, status=None)


class PageRoute(BaseHandler, Custom404Mixin):
	def get(self, alias):
		self.render('xxx.jade') ## TODO Replace to page.jade


class ItemRoute(BaseHandler, Custom404Mixin):
	def get(self, category, item):
		return self.render('yyy.jade') #Replace to catalog.jade


class FormsHandler(JsonResponseMixin):
	def post(self):
		actions = {
			'call' : {
				'fn': self.save_call,
			},
			'order' : {
				'fn': self.save_order,
			}
		}
		is_ajax = None
		try:
			is_ajax = self.get_argument('json')
		except MissingArgumentError:
			pass

		body = str(self.request.body)
		action = self.get_argument('action')

		if action not in actions.keys():
			if is_ajax:
				self.set_status(500)
				return self.json_response({'status': 'systemfail'})
			return self.write("Lol, request isn't correct")

		fn = actions[action]['fn']
		args = dict([ x.split('=') for x in body.split('&') if 'action' not in x ])

		if self.validate_fields(args):
			try:
				fn(args)
			except Exception as e:
				print(e)
				self.set_status(500)
				return self.json_response({'status': 'systemfail'})\
					if is_ajax\
					else self.write('Here should be a 500 page')

			if is_ajax:
				return self.json_response({'status': 'success'})
			self.write('Lol, it is not ajax. Loosers.')


	def validate_fields(self, fields):
		print(fields)
		required_fields = ['name', 'phone', '']
		err_stack = []

		for key in fields:
			if key in required_fields and fields[key] is '':
				err_stack.append(key)

		if len(err_stack) > 0:
			self.json_response({
				'status': 'error',
				'errorlist': [{x: 'reuqired' for x in err_stack}]
				})
			return False
		return True


	def save_call(self, d):
		call = CallModel(
			name = d['name'],
			phone = d['phone'],
			date = datetime.datetime.now()
			)
		session.add(call)
		session.commit()


	def save_order(self, d):
		car = session.query(CatalogItemModel).filter_by(id=d['id'])
		order = OrderModel(
			name=d['name'],
			email=d['email'],
			phone=d['phone'],
			# date = datetime.combine(call_date, call_time)
			date=datetime.datetime.now()
			)
		car.orders.append(order)

		session.add(car)
		session.add(order)
		session.commit()
