/**
 * Catalog Elements List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone : B
	\marionette : M
	\backbone.wreqr : W
	'../../../ajax-req'

	'../../../model/basic' : BasicModel

	# views
	'../../smooth' : SmoothView
	'../../loader' : LoaderView
	'../../table-list' : TableListView
	'../../table-item' : TableItemView
}

class ItemView extends TableItemView
	template: 'catalog/elements-list-item'

class CompositeListView extends TableListView
	template: 'catalog/elements-list'
	child-view: ItemView

class PageView extends M.LayoutView
	model: new BasicModel!
	template: 'catalog/elements-list-main'
	regions:
		\header : \.header
		\main : \.main

class HeaderView extends M.LayoutView
	model: new BasicModel!
	template: 'catalog/elements-list-header'

class CatalogElementsListView extends SmoothView
	initialize: !->
		SmoothView.prototype.initialize ...

		@loader-view = (new LoaderView!).render!

		@table-list = new B.Collection []
		@table-view = new CompositeListView collection: @table-list
		@table-view.render!

		@table-view.on \refresh:list, !~> @get-list!

		@page-view = (new PageView!).render!
		@header-view = new HeaderView {
			model: new BasicModel { section_name: null }
		}
		@header-view.render!

	on-show: !->
		@get-region \main .show @loader-view
		@get-list !~>
			@get-region \main .show @page-view
			@page-view.get-region \header .show @header-view
			@page-view.get-region \main .show @table-view

	get-list: (cb)!->
		@ajax = ajax-req {
			data:
				action: \get_catalog_elements
				args: JSON.stringify {
					id: @get-option \section-id
				}
			success: (json)!~>
				if json.status is not \success or not json.data_list?
					W.radio.commands .execute \police, \panic,
						new Error 'Incorrect server data'

				new-data-list = []
				for item in json.data_list
					ref = '#panel/catalog/section_'
					ref += @get-option \section-id
					ref += '/edit_' + item.id + '.html'
					new-data-list.push {
						id: item.id
						ref: ref
						name: item.title
						count: item.count
					}

				@table-list.reset new-data-list
				@header-view.model.set \section_name, json.section_title
				@header-view.render!
				cb! if cb?
		}

	regions:
		\main : '.main'

	class-name: 'catalog-elements-list v-stretchy'
	template: 'main'

	on-destroy: !->
		@ajax.abort! if @ajax?

module.exports = CatalogElementsListView
