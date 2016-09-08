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
	\../../table-list                           : TableListView
	\../../table-item                           : TableItemView
	\../../list                                 : ListView
}


class ItemView extends TableItemView
	template: 'pages/list-item'


class CompositeListView extends TableListView
	template: 'pages/list'
	child-view: ItemView


class PagesListView extends ListView
	
	initialize: !->
		super ...
		
		options =
			model: StaticPageListItemModel
			action: \get_pages_list
		
		@init-table-list \
			CompositeListView,
			options,
			OrderingElementsListCollection
		
		@listen-to @table-list, 'sync reset', @show-table-view
	
	on-show: !->
		super ...
		@table-list.fetch!
	
	show-table-view: !->
		@get-region \main .show @table-view


module.exports = PagesListView
