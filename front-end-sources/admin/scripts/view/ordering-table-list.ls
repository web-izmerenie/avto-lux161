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
		\ordering-row         : 'tbody tr'
	} <<< super::ui
	
	events: {
		'click @ui.ordering-column-text' : \on-ordering-column-click
		
		'dragstart @ui.ordering-row'     : \on-ordering-row-drag-start
		'dragover  @ui.ordering-row'     : \on-ordering-row-drag-over
		'dragleave @ui.ordering-row'     : \on-ordering-row-drag-leave
		'dragend   @ui.ordering-row'     : \on-ordering-row-drag-end
		'drop      @ui.ordering-row'     : \on-ordering-row-drop
	} <<< super::events
	
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
	
	
	\on-ordering-row-drag-start : (e)!->
		
		@$ e.current-target .css \opacity, 0.3
		id = @$ e.current-target .find \.js-model-id .data \model-id |> Number
		
		e.original-event.data-transfer
			..effect-allowed = \copy
			..set-data \ordering-drag-collection, \
				@get-ordering-collection-unique-id!
			..set-data \ordering-drag-model-id, id
	
	\on-ordering-row-drag-over : (e)!->
		e.prevent-default!
		e.original-event.data-transfer.drop-effect = \copy
		@$ e.current-target .add-class \ordering-drag-over
	
	\on-ordering-row-drag-leave : (e)!->
		@$ e.current-target .remove-class \ordering-drag-over
	
	\on-ordering-row-drop : (e)!->
		
		try { model-id } = @ordering-prepare-transfer-data e
		catch then if e instanceof @@OrderingBreak then return else throw e
		
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
	
	\on-ordering-row-drag-end : (e)!->
		
		try { model-id } = @ordering-prepare-transfer-data e
		catch then if e instanceof @@OrderingBreak then return else throw e
		
		@collection.get model-id .trigger \view:ordering-drag-off
	
	get-ordering-collection-unique-id: -> [..cid for @collection.models] * \,
	
	ordering-prepare-transfer-data: (e)->
		
		e.original-event.data-transfer
			collection-id = ..get-data \ordering-drag-collection
			model-id = ..get-data \ordering-drag-model-id
		
		if '' in [collection-id, model-id]
		or collection-id isnt @get-ordering-collection-unique-id!
			throw new @@OrderingBreak
		
		{ collection-id, model-id: Number model-id }
	
	class @OrderingBreak extends Error then !-> super '---break---'


module.exports = OrderingTableListView
