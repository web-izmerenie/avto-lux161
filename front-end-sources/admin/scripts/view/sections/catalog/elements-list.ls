/**
 * Catalog Elements List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone.marionette : { LayoutView }
	
	# models
	\app/model/basic : { BasicModel }
	
	# views
	\app/view/list                      : ListView
	\app/view/elements-table/list/index : TableListView
	\app/view/elements-table/item/index : TableItemView
}


class ItemView extends TableItemView
	template: \catalog/elements-list-item


class CompositeListView extends TableListView
	template: \catalog/elements-list
	child-view: ItemView
	child-view-options: (model, index)~>
		model.set \local, @model.get \local


class PageView extends LayoutView
	model: new BasicModel!
	template: \catalog/elements-list-main
	regions:
		header : \.header
		main   : \.main


class HeaderView extends LayoutView
	model: new BasicModel!
	template: \catalog/elements-list-header


class CatalogElementsListView extends ListView
	
	initialize: !->
		
		super? ...
		
		section-id = @get-option \section-id
		
		@init-table-list do
			CompositeListView
			model: new BasicModel section_id: section-id
		
		@page-view = new PageView! .render!
		@header-view = new HeaderView do
			model: new BasicModel do
				section_name: null
				section_id: section-id
		@header-view.render!
	
	on-show: !->
		super? ...
		@update-list !~>
			@get-region \main .show @page-view
			@page-view.get-region \header .show @header-view
			@page-view.get-region \main .show @table-view
	
	show-table-view: !-> void
	
	update-list: (cb)!->
		
		(data-arr, json)<~! @get-list do
			action: \get_catalog_elements
			args: JSON.stringify do
				id: @get-option \section-id
		
		new-data-list = []
		for item in data-arr
			new-data-list.push do
				is_active: item.is_active
				id: item.id
				ref: "
					\#panel/catalog/section_#{@get-option \section-id}
					/edit_#{item.id}.html
				"
				name: item.title
				count: item.count
		
		@table-list.reset new-data-list
		@header-view.model.set \section_name, json.section_title
		@header-view.render!
		
		cb! if cb?


module.exports = CatalogElementsListView
