/**
 * Table List View that supports ordering
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\./table-list                            : TableListView
	\./drag-row-table-list-mixin             : { drag-row-table-list-view-mixin }
	\./drop-custom-ordering-table-list-mixin : {
		drop-custom-ordering-table-list-view-mixin
	}
}


class OrderingTableListView
extends TableListView
implements \
	drag-row-table-list-view-mixin, \
	drop-custom-ordering-table-list-view-mixin
	
	ui: {
		\ordering-column      : \.js-ordering-column
		\ordering-column-text : '.js-ordering-column span'
	}
		<<< (super::ui ? {})
		<<< (drag-row-table-list-view-mixin.ui ? {})
		<<< (drop-custom-ordering-table-list-view-mixin.ui ? {})
	
	events: {
		'click @ui.ordering-column-text' : \on-ordering-column-click
	}
		<<< (super::events ? {})
		<<< (drag-row-table-list-view-mixin.events ? {})
		<<< (drop-custom-ordering-table-list-view-mixin.events ? {})
	
	collection-events: {
		sort  : \actualize-order-column
		sync  : \actualize-order-column
		reset : \actualize-order-column
	} <<< (super::collection-events ? {})
	
	on-render: !->
		super? ...
		for item in @ui.\ordering-column
			@$ item .find \>span .css \cursor, \pointer
		@actualize-order-column!
	
	\actualize-order-column : !-> @actualize-order-column ...
	actualize-order-column: !->
		
		{ ordering-field, ordering-method } = @collection
		
		for item in @ui.\ordering-column
			@$ item
				if (..data \field) is ordering-field
					switch ordering-method
					| \asc =>
						..remove-class \ordering-column--desc
						..add-class \ordering-column--asc
					| \desc =>
						..remove-class \ordering-column--asc
						..add-class \ordering-column--desc
					| _ => ...
				else
					..remove-class \ordering-column--asc
					..remove-class \ordering-column--desc
	
	\on-ordering-column-click : (e)!->
		e.prevent-default!
		@collection.trigger \order-by _ <| @$ e.target .parent! .data \field


module.exports = OrderingTableListView
