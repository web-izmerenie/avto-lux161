/**
 * Table List View that supports ordering
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\./table-list                : TableListView
	\./drag-row-table-list-mixin : { drag-row-table-list-view-mixin, DragBreak }
}


class OrderingTableListView
extends TableListView
implements drag-row-table-list-view-mixin
	
	ui: {
		\ordering-column      : \.js-ordering-column
		\ordering-column-text : '.js-ordering-column span'
		\ordering-row         : 'tbody tr'
	} <<< super::ui <<< drag-row-table-list-view-mixin.ui
	
	events: {
		'click @ui.ordering-column-text' : \on-ordering-column-click
		
		'dragover  @ui.ordering-row'     : \on-ordering-row-drag-over
		'dragleave @ui.ordering-row'     : \on-ordering-row-drag-leave
		'drop      @ui.ordering-row'     : \on-ordering-row-drop
	} <<< super::events <<< drag-row-table-list-view-mixin.events
	
	collection-events: {
		sort  : \actualize-order-column
		sync  : \actualize-order-column
		reset : \actualize-order-column
	} <<< super::collection-events
	
	on-render: !->
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
	
	
	\on-ordering-row-drag-over : (e)!->
		
		try @extract-drag-data e
		catch then if e instanceof DragBreak then return else throw e
		
		e.prevent-default!
		e.original-event.data-transfer.drop-effect = \copy
		@$ e.current-target .add-class \ordering-drag-over
	
	\on-ordering-row-drag-leave : (e)!->
		
		try @extract-drag-data e
		catch then if e instanceof DragBreak then return else throw e
		
		@$ e.current-target .remove-class \ordering-drag-over
	
	\on-ordering-row-drop : (e)!->
		
		try { model-id } = @extract-drag-data e
		catch then if e instanceof DragBreak then return else throw e
		
		e.prevent-default!
		e.stop-propagation!
		
		at-id = @$ e.current-target
			.find \.js-model-id
			.data \model-id
			|> Number
		
		@$ e.current-target .remove-class \ordering-drag-over
		
		drag-model = @collection.get model-id
		at-model   = @collection.get at-id
		
		drag-model.put-at at-model


module.exports = OrderingTableListView
