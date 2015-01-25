# -*- coding: utf-8 -*-

import json
import sys
import tornado.template
from tornado.web import HTTPError, MissingArgumentError
from .base import BaseHandler

from app.mixins.routes_mixin import (
	ErrorHandlerMixin,
	JsonResponseMixin,
	MenuProviderMixin,
	NonRelationDataProvider
)

from app.models.dbconnect import Session
from sqlalchemy import select, func

from app.models.pagemodels import (
	StaticPageModel,
	UrlMapping
)
from app.models.catalogmodels import CatalogItemModel

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

from .decorators import route_except_handler


class MainRoute(
	BaseHandler, MenuProviderMixin, NonRelationDataProvider,
	ErrorHandlerMixin
):
	@route_except_handler
	def get(self):
		session = Session()
		page = session.query(StaticPageModel).filter_by(alias='/').one()
		session.close()
		menu = self.getmenu(page_alias='/')
		data = page.to_frontend
		data.update({
			'is_catalog': False,
			'is_catalog_item': False,
			'menu': menu,
			'is_debug': config('DEBUG')
		})
		data.update(self.get_nonrel_handlers())
		return self.render('client/content-page.jade', **data)


class StaticPageRoute(
	BaseHandler, MenuProviderMixin, NonRelationDataProvider,
	ErrorHandlerMixin
):
	@route_except_handler
	def get(self, alias):
		if not alias.endswith(".html"):
			alias = '/' + alias + '.html'
		session = Session()
		page = session.query(StaticPageModel).filter_by(alias=alias).one()
		session.close()
		menu = self.getmenu(page_alias=alias)
		data = page.to_frontend
		data.update({
			'is_catalog': False,
			'is_catalog_item': False,
			'menu': menu,
			'is_debug': config('DEBUG')
		})
		data.update(self.get_nonrel_handlers())
		return self.render('client/content-page.jade', **data)


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

		args = dict([ x.split('=') for x
			in str(self.request.body).split('&')
				if 'action' not in x ])
		for key in args:
			args[key] = self.get_argument(key)

		action = self.get_argument('action')

		if action not in actions.keys():
			if is_ajax:
				self.set_status(400)
				return self.json_response({'status': 'unknown_form'})
			return self.write("Lol, request isn't correct")

		p_title = localization['response_page'][action]
		fn = actions[action]['fn']

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
				success_msg_list=['lol', 'you', 'are', 'nigga'],
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
			'error_msg_list': error_msg_list
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
		session = Session()
		session.add(call)
		session.commit()
		session.close()

		send_mail(
			msg='<h1>Заказ звонка</h1>' +
				'<dl><dt>Имя:</dt><dd>%s</dd>' % d['name'] +
				'<dt>Телефон:</dt><dd>%s</dd></dl>' % d['phone'],
			theme='АвтоЛюкс: заказ звонка'
		)


	def save_order(self, d):
		dt = d['date'].split('.')
		session = Session()
		item = session.query(CatalogItemModel).filter_by(id=d['id']).one()
		session.close()
		full_date = datetime.combine(
				date(int(dt[2]), int(dt[1]), int(dt[0])),
				time(int(d['hours']), int(d['minutes']))),
		order = OrderModel(
			name=d['name'],
			callback=d['callback'],
			date=full_date,
			item_id=item.id
		)

		session = Session()
		session.add(order)
		session.commit()
		session.close()
		send_mail(
			msg='<h1>Заказ "%s"</h1>' % item.title +
				'<dl><dt>Имя:</dt><dd>%s</dd>' % d['name'] +
				'<dt>Контакты:</dt><dd>%s</dd>' % d['callback'] +
				'<dt>Дата заказа:</dt><dd>%s</dd></dl>' % (
					full_date[0].strftime('%d.%m.%Y %H:%M')),
			theme='АвтоЛюкс: заказ "%s"' % item.title
		)
