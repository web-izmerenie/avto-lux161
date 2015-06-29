/**
 * Catalog Sections List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	# views
	'../../table-list' : TableListView
	'../../table-item' : TableItemView
	'../../list' : ListView
}

class ItemView extends TableItemView
	template: 'catalog/sections-list-item'

class CompositeListView extends TableListView
	template: 'catalog/sections-list'
	child-view: ItemView
	child-view-options: (model, index)~>
		model.set \local , @model.get \local

class CatalogSectionsListView extends ListView
	initialize: !->
		ListView.prototype.initialize ...
		@init-table-list CompositeListView
	
	on-show: !->
		ListView.prototype.on-show ...
		@update-list !~> @get-region \main .show @table-view
	
	update-list: (cb)!->
		(data-arr)<~! @get-list { action: \get_catalog_sections }
		
		new-data-list = []
		for item in data-arr
			new-data-list.push do
				is_active: item.is_active
				id: item.id
				ref: "\#panel/catalog/section_#{item.id}/"
				name: item.title
				count: item.count
		
		@table-list.reset new-data-list
		cb! if cb?

module.exports = CatalogSectionsListView
