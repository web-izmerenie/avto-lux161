/**
 * Catalog Elements List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\marionette : M

	'../../../model/basic' : BasicModel

	# views
	'../../table-list' : TableListView
	'../../table-item' : TableItemView
	'../../list' : ListView
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

class CatalogElementsListView extends ListView
	initialize: !->
		ListView.prototype.initialize ...

		@init-table-list CompositeListView

		@page-view = (new PageView!).render!
		@header-view = new HeaderView {
			model: new BasicModel { section_name: null }
		}
		@header-view.render!

	on-show: !->
		ListView.prototype.on-show ...

		@update-list !~>
			@get-region \main .show @page-view
			@page-view.get-region \header .show @header-view
			@page-view.get-region \main .show @table-view

	update-list: (cb)!->
		(data-arr, json)<~! @get-list {
			action: \get_catalog_elements
			args: JSON.stringify {
				id: @get-option \section-id
			}
		}

		new-data-list = []
		for item in data-arr
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

module.exports = CatalogElementsListView
