/**
 * Data List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone : B
	
	# views
	'../../table-list' : TableListView
	'../../table-item' : TableItemView
	'../../list' : ListView
}

class ItemView extends TableItemView
	template: 'data/list-item'

class CompositeListView extends TableListView
	template: 'data/list'
	child-view: ItemView

class Collection extends B.Collection
	comparator: (v) -> if v.get \sort then v.get \sort else 0

class DataListView extends ListView
	initialize: !->
		ListView.prototype.initialize ...
		@init-table-list CompositeListView, null, Collection
	
	on-show: !->
		ListView.prototype.on-show ...
		@update-list !~> @get-region \main .show @table-view
	
	update-list: (cb)!->
		(data-arr)<~! @get-list { action: \get_data_list }
		
		new-data-list = []
		for item in data-arr
			new-data-list.push {
				id: item.id
				ref: '#panel/data/edit_' + item.id + '.html'
				name: item.name
				code: item.code
				sort: item.sort
			}
		
		@table-list.reset new-data-list
		cb! if cb?

module.exports = DataListView
