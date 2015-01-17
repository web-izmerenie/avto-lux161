/**
 * Pages List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone : B
	\marionette : M
	\backbone.wreqr : W
	'../../../ajax-req'

	'../../../model/basic' : BasicModel

	# views
	'../../smooth' : SmoothView
	'../../loader' : LoaderView
}

class ItemView extends M.ItemView
	tag-name: \tr
	template: 'pages/list-item'

class TableListView extends M.CompositeView
	class-name: 'panel panel-default'
	template: 'pages/list'
	model: new BasicModel!
	child-view-container: \tbody
	child-view: ItemView

	ui:
		\refresh : \.refresh
	events:
		'click @ui.refresh': \refresh-list
	\refresh-list : ->
		@trigger \refresh:list
		false

class PagesListView extends SmoothView
	initialize: !->
		SmoothView.prototype.initialize ...

		@loader-view = (new LoaderView!).render!

		@table-list = new B.Collection []
		@table-view = new TableListView collection: @table-list
		@table-view.render!

		@table-view.on \refresh:list, !~> @get-list!

	on-show: !->
		@get-region \main .show @loader-view
		@get-list !~> @get-region \main .show @table-view

	get-list : (cb)!->
		@ajax = ajax-req {
			data:
				action: \get_pages_list
			success: (json)!~>
				if json.status is not \success or not json.data_list?
					W.radio.commands .execute \police, \panic,
						new Error 'Incorrect server data'

				new-data-list = []
				for item in json.data_list
					new-data-list.push {
						id: item.id
						ref: '#panel/pages/edit_' + item.id + '.html'
						name: item.title
						url: item.alias
					}

				@table-list.reset new-data-list
				cb! if cb?
		}

	regions:
		\main : '.main'

	class-name: 'pages-list v-stretchy'
	template: 'main'
	model: new BasicModel!

	on-destroy: !->
		@ajax.abort! if @ajax?

module.exports = PagesListView
