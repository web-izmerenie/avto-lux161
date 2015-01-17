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

		@ajax.abort! if @ajax?
		@ajax = ajax-req {
			data:
				action: \get_fields
				args: JSON.stringify {
					model: \static_page
				}
			success: (json)!~>
				if json.status is not \success or not json.fields_list?
					W.radio.commands .execute \police, \panic,
						new Error 'Incorrect server data'

				list = new B.Collection json.fields_list

				list.comparator = (item)->
					return config.sections[\pages]
						.fields_sort
						.index-of (item.get \name)
				list.sort!

				@ajax = null

				view = new FormView {
					collection: list
					page: \pages
					type: \add
				}

				parent-view = @
				view.on \render !->
					$form = @$el
					return if $form.data \has-submit-handler
					$form.on \submit.submit ~>
						vals = {}
						for item in $form.serialize-array!
							vals[item.name] = item.value
						parent-view.send-to-server vals, @
						false
					$form.data \has-submit-handler, true

				view.render!

				@get-region \main .show view
		}

	send-to-server: (vals, form-view)!->
		vals.section = \pages
		@ajax.abort! if @ajax
		@ajax = ajax-req {
			data:
				action: \add
				args: JSON.stringify vals
			success: (json)!~>
				if json.status is \error
					if json.error_code is \unique_key_exist
						form-view.trigger \form-msg, \unique_key_exist
						@ajax = null
					else
						W.radio.commands .execute \police, \panic,
							new Error 'Incorrect server data'
					return

				if json.status is not \success
					W.radio.commands .execute \police, \panic,
						new Error 'Incorrect server data'

				@ajax = null
				B.history.navigate '#panel/pages', trigger: true
		}

	regions:
		\main : '.main'

	class-name: 'add-page v-stretchy'
	template: 'main'
	model: new BasicModel!

	on-destroy: !->
		@ajax.abort! if @ajax?

module.exports = AddPageView

