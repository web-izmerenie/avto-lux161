/**
 * Drag'n'drop row mixin TableListView
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */


export class DragBreak extends Error
	!-> super '---break---'


# @collection must be instance of BasicCollection
export drag-row-table-list-view-mixin =
	
	ui:
		\drag-row : 'tbody tr'
	
	events:
		'dragstart @ui.drag-row' : \on-drag-row-drag-start
		'dragend   @ui.drag-row' : \on-drag-row-drag-end
	
	# extract drag data from event data-transfer
	extract-drag-data: (e)->
		
		e.original-event.data-transfer
			collection-id = ..get-data \drag-collection
			model-id = ..get-data \drag-model-id
		
		if '' in [ collection-id, model-id ]
		or collection-id isnt @collection.cid
			throw new DragBreak
		
		{ collection-id, model-id: Number model-id }
	
	\on-drag-row-drag-start : !-> @on-drag-row-drag-start ...
	on-drag-row-drag-start: (e)!->
		
		@$ e.current-target .find \th
			throw new Error "Cannot find <th>" if ..length < 1
			..eq 0 .data \model-id
				if (String ..) is (String Number ..)
					id = Number ..
				else
					throw new Error "Cannot get model-id for drag'n'drop"
		
		@collection.get id .trigger \view:drag-row-drag-start
		
		e.original-event.data-transfer
			..effect-allowed = \copy
			..set-data \drag-collection, @collection.cid
			..set-data \drag-model-id, id
	
	\on-drag-row-drag-end : !-> @on-drag-row-drag-end ...
	on-drag-row-drag-end: (e)!->
		
		try { model-id } = @extract-drag-data e
		catch then if e instanceof DragBreak then return else throw e
		
		@collection.get model-id .trigger \view:drag-row-drag-end
