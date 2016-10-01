/**
 * Table List View that supports ordering
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\./table-list : TableListView
	\./drag-row-table-list-mixin : {
		drag-row-table-list-view-mixin
	}
	\./drop-custom-ordering-table-list-mixin : {
		drop-custom-ordering-table-list-view-mixin
	}
	\./by-column-ordering-table-list-mixin : {
		by-column-ordering-table-list-view-mixin
	}
	
	\app/utils/mixins : { call-class-mixins, extend-class-mixins }
	\app/utils/dashes : { camelize }
}


list-mixins =
	* drag-row-table-list-view-mixin
	* drop-custom-ordering-table-list-view-mixin
	* by-column-ordering-table-list-view-mixin

call-class = call-class-mixins list-mixins
extend-class = extend-class-mixins list-mixins

class OrderingTableListView
extends TableListView
implements \
	drag-row-table-list-view-mixin, \
	drop-custom-ordering-table-list-view-mixin, \
	by-column-ordering-table-list-view-mixin
	
	initialize: !-> (call-class super::, \initialize) ...
	
	ui     : (extend-class super::, \ui)
	events : (extend-class super::, \events)
	
	on-render: !-> (call-class super::, camelize \on-render) ...


module.exports = OrderingTableListView
