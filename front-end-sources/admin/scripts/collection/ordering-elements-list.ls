/**
 * Ordering elements list collection
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone        : B
	
	\./elements-list : ElementsListCollection
}


class OrderingElementsListCollection extends ElementsListCollection
	
	initialize: !->
		super ...
		@on \order-by, @on-order-by
		@on \reordered, @fetch
	
	ordering-field: \sort # default ordering field
	ordering-method: \asc # default ordering method
	
	comparator: (a, b)->
		a .= get @ordering-field
		b .= get @ordering-field
		switch @ordering-method
		| \asc  => (if a < b then -1 else if a > b then 1 else 0)
		| \desc => (if a > b then -1 else if a < b then 1 else 0)
		| _     => ...
	
	on-order-by: (field)!->
		switch
		| @ordering-field is field =>
			@ordering-method =
				switch @ordering-method
				| \asc  => \desc
				| \desc => \asc
				| _     => ...
		| otherwise => @ordering-field = field
		@sort!
	
	fetch: (opts={})!->
		# 'reset' flag fixes magic error with fetching after reordering
		super {} <<< opts <<< { +reset }


module.exports = OrderingElementsListCollection
