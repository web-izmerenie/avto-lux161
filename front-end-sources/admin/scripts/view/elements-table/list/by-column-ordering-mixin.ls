/**
 * TableListView mixin that adds column ordering
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */


export by-column-ordering-table-list-view-mixin =
	
	initialize: !->
		@listen-to @collection, 'sort sync reset', @\actualize-order-column
	
	ui:
		\ordering-column      : \.js-ordering-column
		\ordering-column-text : '.js-ordering-column span'
	
	events:
		'click @ui.ordering-column-text' : \on-ordering-column-click
	
	on-render: !->
		for @ui.\ordering-column
			@$ (..) .find \>span .css \cursor, \pointer
		@actualize-order-column!
	
	\actualize-order-column : !-> @actualize-order-column ...
	actualize-order-column: !->
		
		{ ordering-field, ordering-method } = @collection
		
		for @ui.\ordering-column
			@$ ..
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
