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
from datetime import date, time, datetime
from app.utils import (
	get_json_localization,
	send_mail
)
from app.configparser import config

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
		is_ajax = False
		lang = config('LOCALIZATION')['LANG']
		localization = get_json_localization('CLIENT')[lang]['forms']
		actions = {
			'call' : {
				'fn': self.save_call,
			},
			'order' : {
				'fn': self.save_order,
			}
		}

		try:
			is_ajax = self.get_argument('ajax')
		except MissingArgumentError:
			pass

		body = str(self.request.body)
		action = self.get_argument('action')


		if action not in actions.keys():
			if is_ajax:
				self.set_status(400)
				return self.json_response({'status': 'unknown_form'})
			return self.write("Lol, request isn't correct")

		p_title = localization['response_page'][action]
		fn = actions[action]['fn']
		args = dict([ x.split('=') for x in body.split('&') if 'action' not in x ])

		errors = self.validate_fields(args)
		if len(errors) == 0:
			try:
				fn(args)
			except Exception as e:
				print(e)
				self.set_status(500)
				return self.json_response({'status': 'system_fail'})\
					if is_ajax\
					else self.write('Internal server Error')

			if is_ajax:
				return self.json_response({'status': 'success'})

			kwrgs = self.set_kwargs(
				success_msg_list=['lol', 'you','are', 'nigga'],
				title=p_title)
			return self.render('client/content-page.jade', **kwargs)

		else:
			if is_ajax:
				self.set_status(400)
				self.json_response({
					'status': 'error',
					'error_fields': { x: 'required' for x in errors }
					})
			else:
				err_list = [localization['err']['required_page'].format(localization['fields'][x]) \
					for x in errors ]
				kwrgs = self.set_kwargs(
					error_msg_list=err_list,
					title=p_title)
				self.render('client/content-page.jade', **kwrgs)


	def set_kwargs(self, success_msg_list=[], error_msg_list=[], title=''):
		return {
				'page_content':'',
				'show_h1': 1,
				'page_title': title,
				'success_msg_list': success_msg_list,
				'error_msg_list':error_msg_list
			}

	def validate_fields(self, fields):
		err_stack = []
		all_required_fields = ['name', 'phone', 'callback']

		for key in fields:
			if key in all_required_fields and fields[key] is '':
				err_stack.append(key)

		return err_stack


	def save_call(self, d):
		call = CallModel(
			name = d['name'],
			phone = d['phone'],
			date = datetime.utcnow()
			)
		session.add(call)
		session.commit()
		send_mail(msg="Call sent")


	def save_order(self, d):
		print(d['date'], d['hours'], d['minutes'])
		dt = d['date'].split('.')
		item = session.query(CatalogItemModel.id).filter_by(id=d['id']).one()
		order = OrderModel(
			name=d['name'],
			callback=d['callback'],
			date = datetime.combine(date(int(dt[2]), int(dt[1]), int(dt[0])), time(int(d['hours']), int(d['minutes']))),
			item_id=item.id
			)

		session.add(order)
		session.commit()
		send_mail('Order sent')
