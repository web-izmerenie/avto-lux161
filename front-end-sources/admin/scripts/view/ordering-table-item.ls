/**
 * Table Item View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\./table-item : TableItemView
}


class OrderingTableItemView extends TableItemView
	
	attributes:
		draggable: true
	
	model-events: {
		\view:ordering-drag-off : \on-ordering-drag-off
	} <<< super::model-events
	
	\on-ordering-drag-off : !-> @$el.css \opacity, ''


module.exports = OrderingTableItemView
