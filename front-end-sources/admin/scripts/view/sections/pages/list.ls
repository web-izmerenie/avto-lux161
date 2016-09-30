/**
 * Pages List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	# models
	\app/collection/sections/static-pages-list : { StaticPagesListCollection }
	
	# views
	\app/view/ordering-table-list              : OrderingTableListView
	\app/view/ordering-table-item              : OrderingTableItemView
	\app/view/list                             : ListView
}


class ItemView extends OrderingTableItemView
	template: \pages/list-item


class CompositeListView extends OrderingTableListView
	template: \pages/list
	child-view: ItemView


class PagesListView extends ListView
	initialize: !->
		super ...
		@init-table-list do
			CompositeListView
			null
			Collection: StaticPagesListCollection


module.exports = PagesListView
