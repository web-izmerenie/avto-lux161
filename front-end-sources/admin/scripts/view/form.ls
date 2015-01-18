/**
 * Form View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery : $
	\jquery.tinymce : jquery-tinymce
	\marionette : M
	'../config.json'

	'../view/error-msg' : ErrorMessageView
	'../model/basic' : BasicModel
}

tinymce = window.tinymce

class InputItemView extends M.ItemView
	tag-name: \label

class TextItemView extends InputItemView
	class-name: 'text'
	template: 'form/text'

class CheckboxItemView extends InputItemView
	class-name: 'checkbox'
	template: 'form/checkbox'

class HTMLInputItemView extends InputItemView
	class-name: 'html'
	template: 'form/html'
	ui:
		textarea: 'textarea'
	on-render: !->
		return if @has-tinymce?
		@has-tinymce = true
		set-timeout (!~> # async hack
			return unless @? and @ui? and @ui.textarea? and @ui.textarea.tinymce?
			try
				@ui.textarea.tinymce config.tinymce_options
			catch e
				console.error \sheeeeeiiiiiiiiiit, e
		), 1

class SelectItemView extends InputItemView
	class-name: \select
	template: 'form/select'

class FormView extends M.CompositeView
	tag-name: \form
	class-name: 'form edit-form'
	child-view-container: \.fields
	template: 'form/form'
	ui:
		\cancel : \.cancel
	events:
		'click @ui.cancel': \cancel

	cancel: ->
		@trigger \cancel:form
		false

	initialize: !->
		@model = new BasicModel {
			page: @get-option \page
			type: @get-option \type
			err_key: null
			values: {}
		}

		@on \form-msg, (err-key)!->
			@model.set \err_key, err-key
			$ 'html,body' .scroll-top 0
			@render!

	on-render: !->
		$form = @$el
		$form.off \submit.store-values
		$form.on \submit.store-values, !~>
			vals = {}
			for item in $form.serialize-array!
				vals[item.name] = item.value
			@model.set \values, vals

	child-view-options: (model, index)~>
		model.set \local, @model.get \local
		model.set \page @get-option \page
		model.set \values @model.get \values

	get-child-view: (item)~>
		switch item.get \type
		| \checkbox => return CheckboxItemView
		| \html => return HTMLInputItemView
		| \select => return SelectItemView

		TextItemView

module.exports = FormView
