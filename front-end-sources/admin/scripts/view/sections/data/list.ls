/**
 * Data List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	# models
	\app/collection/basic : { BasicCollection }
	
	# views
	\app/view/list                      : ListView
	\app/view/elements-table/list/index : TableListView
	\app/view/elements-table/item/index : TableItemView
}


class ItemView extends TableItemView
	template: \data/list-item


class CompositeListView extends TableListView
	template: \data/list
	child-view: ItemView


class Collection extends BasicCollection
	comparator: -> (it.get \sort) ? 0


class DataListView extends ListView
	
	initialize: !->
		super? ...
		@init-table-list CompositeListView, null, { Collection }
	
	on-show: !->
		super? ...
		@update-list !~> @get-region \main .show @table-view
	
	update-list: (cb)!->
		
		(data-arr)<~! @get-list action: \get_data_list
		
		new-data-list = []
		for item in data-arr
			new-data-list.push do
				id: item.id
				ref: "\#panel/data/edit_#{item.id}.html"
				name: item.name
				code: item.code
				sort: item.sort
		
		@table-list.reset new-data-list
		cb! if cb?


module.exports = DataListView
