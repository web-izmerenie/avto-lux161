/**
 * List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone       : { Collection }
	\backbone.wreqr : { radio }
	
	# helpers
	\../ajax-req
	
	# models
	\../model/basic : BasicModel
	
	# views
	\./loader       : LoaderView
	\./smooth       : SmoothView
}


class TableListCollection extends Collection
	comparator: \id


class ListView extends SmoothView
	
	initialize: !->
		super ...
		@loader-view = new LoaderView! .render!
	
	on-show: !-> @get-region \main .show @loader-view
	
	init-table-list: (View, options = {}, {
		Collection = TableListCollection
		collection-options = {}
	} = {})!->
		@table-list = new Collection [], collection-options
		@table-view = new View {} <<< options <<< { collection: @table-list }
		@table-view.render!
		@listen-to @table-view, \refresh:list, @update-list
	
	# cb: data-arr
	# TODO remove after refactoring
	get-list: (ajax-data, cb)!->
		@ajax = ajax-req do
			data: ajax-data
			success: (json)!~>
				if json.status is not \success or not json.data_list?
					radio.commands.execute \police, \panic,
						new Error 'Incorrect server data'
					return
				
				r = null ; (try r = @get-region \main) ; return unless r?
				cb json.data_list, json
	
	regions:
		main: \.main
	
	class-name: \v-stretchy
	template: \main
	model: new BasicModel!
	
	on-destroy: !-> @ajax.abort! if @ajax?


module.exports = ListView
