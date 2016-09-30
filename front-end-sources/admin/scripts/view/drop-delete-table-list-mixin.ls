/**
 * Drag'n'drop detele mixin for TableListView
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */


# required to be used with drag-row-table-list-view-mixin
export drop-delete-table-list-view-mixin =
	
	ui:
		\drop-delete-zone : \.js-drop-delete-zone
	
	events:
		'drop @ui.drop-delete-zone' : \on-delete-drop
	
	\on-delete-drop : !-> @on-delete-drop ...
	on-delete-drop: !-> void
