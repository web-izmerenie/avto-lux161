/**
 * Table Item View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\./table-item                : TableItemView
	\./drag-row-table-item-mixin : { drag-row-table-item-view-mixin }
	
	\app/utils/mixins : { call-class-mixins, extend-class-mixins }
}


item-mixins =
	* drag-row-table-item-view-mixin
	...

call-class = call-class-mixins item-mixins
extend-class = extend-class-mixins item-mixins

class OrderingTableItemView
extends TableItemView
implements drag-row-table-item-view-mixin
	
	initialize: !-> (call-class super::, \initialize) ...
	
	ui     : extend-class super::, \ui
	events : extend-class super::, \events


module.exports = OrderingTableItemView
