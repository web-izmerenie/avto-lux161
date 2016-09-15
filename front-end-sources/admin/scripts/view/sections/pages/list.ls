/**
 * Pages List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone                                   : B
	
	# models
	\../../../collection/ordering-elements-list : OrderingElementsListCollection
	\../../../model/static-page-list-item       : StaticPageListItemModel
	
	# views
	\../../ordering-table-list                  : OrderingTableListView
	\../../ordering-table-item                  : OrderingTableItemView
	\../../list                                 : ListView
}


class ItemView extends OrderingTableItemView
	template: \pages/list-item


class CompositeListView extends OrderingTableListView
	template: \pages/list
	child-view: ItemView


class PagesListView extends ListView
	
	initialize: !->
		super ...
		
		options =
			model: StaticPageListItemModel
			action: \get_pages_list
		
		@init-table-list do
			CompositeListView
			null
			do
				Collection: OrderingElementsListCollection
				collection-options: options
		
		@listen-to @table-list, 'sync reset', @show-table-view
	
	on-show: !->
		super ...
		@table-list.fetch!
	
	update-list: !->
		@table-list.fetch!
	
	show-table-view: !->
		@get-region \main .show @table-view


module.exports = PagesListView
