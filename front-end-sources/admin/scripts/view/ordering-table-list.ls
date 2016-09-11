/**
 * Table List View that supports ordering
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\./table-list : TableListView
}


class OrderingTableListView extends TableListView
	
	ui: {
		\ordering-column      : \.js-ordering-column
		\ordering-column-text : '.js-ordering-column span'
		\row                  : 'tbody tr'
	} <<< super::ui
	
	events: {
		'click @ui.ordering-column-text' : \on-ordering-column-click
		
		'dragstart @ui.row'              : \on-row-drag-start
		'dragover  @ui.row'              : \on-row-drag-over
		'dragleave @ui.row'              : \on-row-drag-leave
		'drop      @ui.row'              : \on-row-drop
	} <<< super::events
	
	collection-events:
		\sort  : \actualize-order-column
		\sync  : \actualize-order-column
		\reset : \actualize-order-column
	
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
		@collection.trigger \order-by (@$ e.target .parent! .data \field)
	
	
	\on-row-drag-start : (e)!->
		
		@$ e.current-target .css \opacity, 0.3
		id = @$ e.current-target .find \.js-model-id .data \model-id |> Number
		
		e.original-event.data-transfer
			..effect-allowed = \copy
			..set-data \drag-id, id
	
	\on-row-drag-over : (e)!->
		e.prevent-default!
		e.original-event.data-transfer.drop-effect = \copy
		@$ e.current-target .add-class \ordering-drag-over
	
	\on-row-drag-leave : (e)!->
		@$ e.current-target .remove-class \ordering-drag-over
	
	\on-row-drop : (e)!->
		
		e.prevent-default!
		e.stop-propagation!
		
		@$ e.current-target .remove-class \ordering-drag-over
		
		drag-id = e.original-event.data-transfer.get-data \drag-id |> Number
		at-id = @$ e.current-target
			.find \.js-model-id
			.data \model-id
			|> Number
		
		drag-model = @collection.get drag-id
		at-model   = @collection.get at-id
		
		drag-model.trigger \view:ordering-drag-off
		
		drag-model.put-at at-model


module.exports = OrderingTableListView
