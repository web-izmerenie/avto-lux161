/**
 * Panel View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone : B
	'./smooth' : SmoothView
	'../model/basic' : BasicModel
	'../view/loader' : LoaderView
	'../view/panel/menu' : PanelMenuListView
	'../view/panel/pages-list' : PagesListView
	'../collection/panel-menu' : panel-menu-list
	'../ajax-req'
}

class PanelView extends SmoothView
	initialize: !->
		SmoothView.prototype .initialize ...

		@menu-list-view = new PanelMenuListView collection: panel-menu-list
		@menu-list-view.render!

		switch @get-option \page
		| \pages =>
			@loader-view = (new LoaderView!).render!

	on-show: !->
		@get-region \menu .show @menu-list-view

		switch @get-option \page
		| \pages =>
			@get-region \work-area .show @loader-view

			@ajax = ajax-req {
				url: 'data.json'
				data:
					action: \get_pages_list
				success: (json)!~>
					if json.status is not \success or not json.data_list?
						W.radio.commands .execute \police, \panic,
							new Error 'Incorrect server data'

					new-data-list = []
					for item in json.data_list
						new-data-list.push {
							ref: '#panel/pages/edit_' + item.id + '.html'
							title: item.title
						}

					list = new B.Collection new-data-list
					view = new PagesListView collection: list
					view.render!
					@get-region \work-area .show view
			}

	on-destroy: !->
		@ajax.abort! if @ajax?

	class-name: 'panel container'
	template: \panel
	model: new BasicModel!
	regions:
		\menu : \.panel-menu
		\work-area : \.work-area

module.exports = PanelView
