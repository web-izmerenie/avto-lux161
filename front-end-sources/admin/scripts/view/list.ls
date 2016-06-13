/**
 * List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone        : B
	\backbone.wreqr  : W
	'../ajax-req'
	
	'../model/basic' : BasicModel
	
	# views
	'./loader'       : LoaderView
	'./smooth'       : SmoothView
}

class TableListCollection extends B.Collection
	comparator: (v) -> if v.id then v.id else 0

class ListView extends SmoothView
	initialize: !->
		SmoothView.prototype.initialize ...
		
		@loader-view = (new LoaderView!).render!
	
	on-show: !->
		@get-region \main .show @loader-view
	
	init-table-list: (View, options, CollectionClass=TableListCollection)!->
		@table-list = new CollectionClass []
		options = collection: @table-list <<<< (options or {})
		@table-view = new View options
		@table-view.render!
		
		@table-view.on \refresh:list, !~> @update-list!
	
	# cb: data-arr
	get-list: (ajax-data, cb)!->
		@ajax = ajax-req {
			data: ajax-data
			success: (json)!~>
				if json.status is not \success or not json.data_list?
					W.radio.commands .execute \police, \panic,
						new Error 'Incorrect server data'
					return
				
				r = null ; (try r = @get-region \main) ; return unless r?
				cb json.data_list, json
		}
	
	regions:
		\main : \.main
	
	class-name: 'v-stretchy'
	template: \main
	model: new BasicModel!
	
	on-destroy: !->
		@ajax.abort! if @ajax?

module.exports = ListView
