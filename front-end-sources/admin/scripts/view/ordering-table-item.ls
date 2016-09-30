/**
 * Table Item View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\./table-item                : TableItemView
	\./drag-row-table-item-mixin : { drag-row-table-item-view-mixin }
}


class OrderingTableItemView
extends TableItemView
implements drag-row-table-item-view-mixin
	
	model-events: {}
		<<< super::model-events
		<<< drag-row-table-item-view-mixin.model-events


module.exports = OrderingTableItemView
