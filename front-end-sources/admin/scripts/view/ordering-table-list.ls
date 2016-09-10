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
	
	initialize: !->
		super ...
		@listen-to @collection, 'sort sync reset', @actualize-order-column
	
	ui: {
		\ordering-column : \.js-ordering-column
		\ordering-column-text : '.js-ordering-column span'
	} <<< super::ui
	
	events: {
		'click @ui.ordering-column-text': 'on-ordering-column-click'
	} <<< super::events
	
	on-render: !->
		for item in @ui.'ordering-column'
			@$ item .find \>span .css \cursor, \pointer
		@actualize-order-column!
	
	actualize-order-column: !->
		
		{ ordering-field, ordering-method } = @collection
		
		for item in @ui.'ordering-column'
			@$ item
				if (..data \field) is ordering-field
					switch ordering-method
					| \asc  =>
						..remove-class \ordering-column--desc
						..add-class \ordering-column--asc
					| \desc =>
						..remove-class \ordering-column--asc
						..add-class \ordering-column--desc
					| _     => ...
				else
					..remove-class \ordering-column--asc
					..remove-class \ordering-column--desc
	
	\on-ordering-column-click : (e)!->
		e.prevent-default!
		@collection.trigger \order-by (@$ e.target .parent! .data \field)


module.exports = OrderingTableListView
