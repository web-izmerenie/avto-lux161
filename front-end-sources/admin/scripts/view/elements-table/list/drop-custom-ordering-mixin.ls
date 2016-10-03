/**
 * Drag'n'drop custom reordering mixin for TableListView
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\./drag-row-mixin : { DragBreak }
}


# required to be used with drag-row-table-list-view-mixin
export drop-custom-ordering-table-list-view-mixin =
	
	ui:
		\drop-custom-ordering-row : 'tbody tr'
	
	events:
		'dragover  @ui.drop-custom-ordering-row' : \on-custom-ordering-row-drag-over
		'dragleave @ui.drop-custom-ordering-row' : \on-custom-ordering-row-drag-leave
		'drop      @ui.drop-custom-ordering-row' : \on-custom-ordering-row-drop
	
	\on-custom-ordering-row-drag-over : (e)!->
		
		try @extract-drag-data e
		catch then if e instanceof DragBreak then return else throw e
		
		e.prevent-default!
		e.original-event.data-transfer.drop-effect = \copy
		@$ e.current-target .add-class \ordering-drag-over
	
	\on-custom-ordering-row-drag-leave : (e)!->
		
		try @extract-drag-data e
		catch then if e instanceof DragBreak then return else throw e
		
		@$ e.current-target .remove-class \ordering-drag-over
	
	\on-custom-ordering-row-drop : (e)!->
		
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
