import json
import sys
import tornado.template
from tornado.web import HTTPError, MissingArgumentError
from .base import BaseHandler

from app.mixins.routes_mixin import Custom404Mixin, JsonResponseMixin
from pyjade.ext.tornado import patch_tornado

from app.models.dbconnect import Session
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
from sqlalchemy.orm.exc import NoResultFound
session = Session()
# patch_tornado()

def route_except_handler(fn):
	def wrap(*args, **kwargs):
		self = args[0]
		try:
			return fn(*args, **kwargs)
		except NoResultFound as e:
			print(e, file=sys.stderr)
			self.set_status(404)
			page = session.query(StaticPageModel).filter_by(alias='/404.html').one()
			page.to_frontend.update({'is_catalog': False})
			return self.render('client/error_404.html', **page.to_frontend)
		except Exception as e:
			print(e, file=sys.stderr)
			self.set_status(500)
			return self.write('500: Internal server error')
	wrap.__name__ = fn.__name__
	return wrap


class MainRoute(BaseHandler, Custom404Mixin):
	@route_except_handler
	def get(self):
		page = session.query(StaticPageModel).filter_by(alias='/').one()
		page.to_frontend.update({'is_catalog': False})
		return self.render('client/content_page.html', **page.to_frontend)


class UrlToRedirect(BaseHandler):
	@route_except_handler
	def get(self, first, second):
		old_url = self.request.uri
		new_url = session.query(UrlMapping.new_url).filter_by(old_url=str(old_url)).one()
		return self.redirect(str(new_url[0][0]), permanent=False, status=None)


class StaticPageRoute(BaseHandler, Custom404Mixin):
	@route_except_handler
	def get(self, alias):
		if not alias.endswith(".html"):
			alias = '/' + alias + '.html'
		page = session.query(StaticPageModel).filter_by(alias=alias).one()
		page.to_frontend.update({'is_catalog': False})
		return self.render('client/content_page.html', **page.to_frontend)


class CatalogSectionRoute(BaseHandler, Custom404Mixin):
	@route_except_handler
	def get(self, alias):
		if alias.endswith(".html"):
			alias = alias.replace('.html', '').replace('/', '')
		page = session.query(CatalogSectionModel).filter_by(alias=alias).one()
		items = session.query(CatalogItemModel).filter_by(section_id=page.id).all()

		page.to_frontend.update({'is_catalog': True, 'is_main_page': False})
		page.to_frontend.update({'items': [x.to_frontend for x in items]})

		self.render('client/catalog_sections.html', **page.to_frontend)


class CatalogItemRoute(BaseHandler, Custom404Mixin):
	@route_except_handler
	def get(self, category, item):
		if item.endswith(".html"):
			item = item.replace('.html', '').replace('/', '')
		page = session.query(CatalogItemModel).filter_by(alias=item).one()
		data = page.to_frontend
		data.update({'is_catalog': True, 'is_main_page': False})
		return self.render('client/catalog_detail.html', **data)


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
				print(e, file=sys.stderr)
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
			date = datetime.combine(
				date(int(dt[2]), int(dt[1]), int(dt[0])),
				time(int(d['hours']), int(d['minutes']))),
				item_id=item.id
			)

		session.add(order)
		session.commit()
		send_mail('Order sent')
