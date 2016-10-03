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
	\app/view/list                      : ListView
	\app/view/elements-table/list/index : TableListView
	\app/view/elements-table/item/index : TableItemView
	
	# view mixins
	\app/view/elements-table/list/drag-row-mixin : {
		drag-row-table-list-view-mixin
	}
	\app/view/elements-table/list/drop-custom-ordering-mixin : {
		drop-custom-ordering-table-list-view-mixin
	}
	\app/view/elements-table/list/by-column-ordering-mixin : {
		by-column-ordering-table-list-view-mixin
	}
	\app/view/elements-table/item/drag-row-mixin : {
		drag-row-table-item-view-mixin
	}
	
	# helpers
	\app/utils/mixins : { call-class-mixins, extend-class-mixins }
	\app/utils/dashes : { camelize }
}


[ drag-row-table-item-view-mixin ]
	call-class = call-class-mixins ..
	extend-class = extend-class-mixins ..

class ItemView
extends TableItemView
implements drag-row-table-item-view-mixin
	
	template   : \pages/list-item
	
	ui         : extend-class super::, \ui
	events     : extend-class super::, \events
	
	initialize : !-> (call-class super::, \initialize) ...


[
	drag-row-table-list-view-mixin
	drop-custom-ordering-table-list-view-mixin
	by-column-ordering-table-list-view-mixin
]
	call-class = call-class-mixins ..
	extend-class = extend-class-mixins ..

class CompositeListView
extends TableListView
implements \
drag-row-table-list-view-mixin, \
drop-custom-ordering-table-list-view-mixin, \
by-column-ordering-table-list-view-mixin
	
	template   : \pages/list
	child-view : ItemView
	
	ui         : extend-class super::, \ui
	events     : extend-class super::, \events
	
	initialize : !-> (call-class super::, \initialize) ...
	on-render  : !-> (call-class super::, camelize \on-render) ...


class PagesListView extends ListView
	initialize: !->
		super? ...
		@init-table-list do
			CompositeListView
			null
			Collection: StaticPagesListCollection


module.exports = PagesListView
