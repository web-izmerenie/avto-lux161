/**
 * Form Edit View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone : B
	\marionette : M
	\backbone.wreqr : W
	'../ajax-req'
	'../config.json'

	'../model/basic' : BasicModel

	# views
	'./smooth' : SmoothView
	'./loader' : LoaderView
	'./form' : FormView
}

class FormEditView extends SmoothView
	initialize: !->
		SmoothView.prototype.initialize ...

		@loader-view = (new LoaderView!).render!

	on-show: !->
		@get-region \main .show @loader-view

		args = {
			model: @get-option \section
		}

		if (@get-option \type) is \edit
			args.id = @get-option \id
			args.edit = true

		@ajax.abort! if @ajax?
		@ajax = ajax-req {
			data:
				action: \get_fields
				args: JSON.stringify args
			success: (json)!~>
				if json.status is not \success or not json.fields_list?
					W.radio.commands .execute \police, \panic,
						new Error 'Incorrect server data'

				list = new B.Collection json.fields_list

				list.comparator = (item)~>
					return config.sections[@get-option \section]
						.fields_sort
						.index-of (item.get \name)
				list.sort!

				@ajax = null

				view = new FormView {
					collection: list
					page: @get-option \section
					type: @get-option \type
				}

				view.on 'cancel:form', !~>
					@ajax.abort! if @ajax
					B.history.navigate (@get-option \list-page), trigger: true

				if (@get-option \type) is \edit and json.values_list?
					view.model.set \values, json.values_list

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
		vals.section = @get-option \section
		vals.id = @get-option \id if (@get-option \type) is \edit
		@ajax.abort! if @ajax
		@ajax = ajax-req {
			data:
				action: ((@get-option \type) is \edit) and \update or \add
				args: JSON.stringify vals
			success: (json)!~>
				if json.status is \error
					switch json.error_code
					| \unique_key_exist \incorrect_data =>
						form-view.trigger \form-msg, json.error_code
						@ajax = null
					| _ =>
						W.radio.commands .execute \police, \panic,
							new Error 'Incorrect server data'
					return

				if json.status is not \success
					W.radio.commands .execute \police, \panic,
						new Error 'Incorrect server data'

				@ajax = null
				B.history.navigate (@get-option \list-page), trigger: true
		}

	regions:
		\main : '.main'

	class-name: 'v-stretchy'
	template: 'main'
	model: new BasicModel!

	on-destroy: !->
		@ajax.abort! if @ajax?

module.exports = FormEditView
