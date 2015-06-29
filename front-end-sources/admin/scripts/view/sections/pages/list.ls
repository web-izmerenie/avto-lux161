/**
 * Pages List View
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
	template: 'pages/list-item'

class CompositeListView extends TableListView
	template: 'pages/list'
	child-view: ItemView
	child-view-options: (model, index)~>
		model.set \local , @model.get \local

class PagesListView extends ListView
	initialize: !->
		ListView.prototype.initialize ...
		@init-table-list CompositeListView
	
	on-show: !->
		ListView.prototype.on-show ...
		@update-list !~> @get-region \main .show @table-view
	
	update-list: (cb)!->
		(data-arr)<~! @get-list { action: \get_pages_list }
		
		new-data-list = []
		for item in data-arr
			new-data-list.push do
				is_active: item.is_active
				id: item.id
				ref: "\#panel/pages/edit_#{item.id}.html"
				name: item.title
				url: item.alias
		
		@table-list.reset new-data-list
		cb! if cb?

module.exports = PagesListView
