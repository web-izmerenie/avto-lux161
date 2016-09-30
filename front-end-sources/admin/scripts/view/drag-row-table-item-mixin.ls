/**
 * Drag'n'drop row support for TableItemView mixin
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */


export drag-row-table-item-view-mixin =
	
	attributes:
		draggable: true
	
	model-events:
		\view:drag-row-drag-start : \on-drag-row-drag-start
		\view:drag-row-drag-end   : \on-drag-row-drag-end
	
	\on-drag-row-drag-start : !-> @$el.css \opacity, 0.3
	\on-drag-row-drag-end   : !-> @$el.css \opacity, ''
