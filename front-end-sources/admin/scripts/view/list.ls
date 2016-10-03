/**
 * List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone.wreqr : { radio }
	
	# helpers
	\../ajax-req
	
	# models
	\app/model/basic                    : { BasicModel }
	\app/collection/basic               : { BasicCollection }
	\app/collection/elements-list/index : { ElementsListCollection }
	
	# views
	\app/view/loader : LoaderView
	\app/view/smooth : SmoothView
}


class TableListCollection extends BasicCollection
	comparator: \id


class ListView extends SmoothView
	
	initialize: !->
		super? ...
		@loader-view = new LoaderView! .render!
	
	on-show: !->
		super? ...
		@get-region \main .show @loader-view
		@table-list.fetch! if @table-list instanceof ElementsListCollection
	
	init-table-list: (View, options = {}, {
		Collection = TableListCollection
		collection-options = {}
	} = {})!->
		
		@table-list = new Collection [], collection-options
		@table-view = new View {} <<< options <<< { collection: @table-list }
		@table-view.render!
		
		# fetch again when refresh event is triggered
		@listen-to @table-view, \refresh:list, @update-list
		
		# replace loader to table after fetch
		@listen-to-once @table-list, 'sync reset', @show-table-view
	
	show-table-view: !->
		@get-region \main .show @table-view
	
	update-list: !->
		@table-list.fetch! if @table-list instanceof ElementsListCollection
	
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
