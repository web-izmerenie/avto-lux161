/**
 * Catalog Sections List View
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
	template: 'catalog/sections-list-item'

class TableListView extends M.CompositeView
	class-name: 'panel panel-default'
	template: 'catalog/sections-list'
	model: new BasicModel!
	child-view-container: \tbody
	child-view: ItemView

class CatalogSectionsListView extends SmoothView
	initialize: !->
		SmoothView.prototype.initialize ...

		@loader-view = (new LoaderView!).render!

	on-show: !->
		@get-region \main .show @loader-view

		@ajax = ajax-req {
			data:
				action: \get_catalog_sections
			success: (json)!~>
				if json.status is not \success or not json.data_list?
					W.radio.commands .execute \police, \panic,
						new Error 'Incorrect server data'

				new-data-list = []
				for item in json.data_list
					new-data-list.push {
						id: item.id
						ref: '#panel/catalog/section_' + item.id + '/'
						name: item.title
						elements_count: item.count
					}

				list = new B.Collection new-data-list
				table-view = new TableListView collection: list
				table-view.render!

				@get-region \main .show table-view
		}

	regions:
		\main : '.main'

	class-name: 'catalog-sections-list v-stretchy'
	template: 'main'

	on-destroy: !->
		@ajax.abort! if @ajax?

module.exports = CatalogSectionsListView
