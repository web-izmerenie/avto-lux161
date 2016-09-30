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
	
	\app/utils/mixins : { call-class-mixins, extend-class-mixins }
	\app/utils/dashes : { camelize }
}


list-mixins =
	* drag-row-table-list-view-mixin
	* drop-custom-ordering-table-list-view-mixin

call-class = call-class-mixins list-mixins
extend-class = extend-class-mixins list-mixins

class OrderingTableListView
extends TableListView
implements \
	drag-row-table-list-view-mixin, \
	drop-custom-ordering-table-list-view-mixin
	
	initialize: !->
		(call-class super::, \initialize) ...
		@listen-to @collection, 'sort sync reset', @\actualize-order-column
	
	ui: {
		\ordering-column      : \.js-ordering-column
		\ordering-column-text : '.js-ordering-column span'
	} <<< (extend-class super::, \ui)
	
	events: {
		'click @ui.ordering-column-text' : \on-ordering-column-click
	} <<< (extend-class super::, \events)
	
	on-render: !->
		(call-class super::, camelize \on-render) ...
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


module.exports = OrderingTableListView
