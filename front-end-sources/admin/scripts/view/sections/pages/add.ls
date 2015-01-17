/**
 * Add Page View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone : B
	\marionette : M
	\backbone.wreqr : W
	'../../../ajax-req'
	'../../../config.json'

	'../../../model/basic' : BasicModel

	# views
	'../../smooth' : SmoothView
	'../../loader' : LoaderView
	'../../form' : FormView
}

class AddPageView extends SmoothView
	initialize: !->
		SmoothView.prototype.initialize ...

		@loader-view = (new LoaderView!).render!

	on-show: !->
		@get-region \main .show @loader-view

		@ajax = ajax-req {
			data:
				action: \get_fields
				args: JSON.stringify {
					model: \static_page
					exclude :
						\id
						\create_date
						\last_change
				}
			success: (json)!~>
				if json.status is not \success or not json.fields_list?
					W.radio.commands .execute \police, \panic,
						new Error 'Incorrect server data'

				new-arr = []
				for item in json.fields_list
					new-arr.push name: item

				list = new B.Collection new-arr
				list.comparator = (item)->
					return config.sections[\pages]
						.fields_sort
						.index-of (item.get \name)
				list.sort!

				view = new FormView {
					collection: list
					page: \pages
				}
				view.render!

				@get-region \main .show view
		}

	regions:
		\main : '.main'

	class-name: 'add-page v-stretchy'
	template: 'main'
	model: new BasicModel!

	on-destroy: !->
		@ajax.abort! if @ajax?

module.exports = AddPageView

