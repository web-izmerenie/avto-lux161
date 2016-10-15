/**
 * Form View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	# libs
	\jquery                   : $
	\ckeditor/adapters/jquery : {}
	\backbone.marionette      : { ItemView, CompositeView, LayoutView, Region }
	
	# views
	\./files       : FilesItemView
	\./data-fields : DataFieldsItemView
	
	# fields models
	\app/model/form/field-by-type/checkbox : { CheckboxFormFieldModel }
	\app/model/form/field-by-type/text     : { TextFormFieldModel }
	\app/model/form/field-by-type/html     : { HtmlFormFieldModel }
	\app/model/form/field-by-type/password : { PasswordFormFieldModel }
	
	# utils
	\app/utils/panic-attack : { panic-attack }
	\app/utils/dashes       : { camelize }
}


class InputItemView extends ItemView
	tag-name: \label


class TextItemView extends InputItemView
	class-name: \text
	template: \form/text
	ui:
		input: \input
	events:
		'input @ui.input': camelize \update-value
	update-value: !->
		@model.set \value, @ui.input.val!
		@model.check-if-is-valid!


class CheckboxItemView extends InputItemView
	class-name: \checkbox
	template: \form/checkbox
	ui:
		input: \input
	events:
		'input @ui.input': camelize \update-value
	update-value: !->
		@model.set \value, @ui.input.prop \checked
		@model.check-if-is-valid!


class HTMLInputItemView extends InputItemView
	
	class-name: \html
	template: \form/html
	ui:
		textarea: \textarea
	
	check-for-alive: -> Boolean @?ui?textarea?ckeditor?
		
	on-render: !->
		<~! set-timeout _, 1 # hack
		return unless @check-for-alive!
		@ui.textarea.ckeditor!


class SelectItemView extends InputItemView
	class-name: \select
	template: \form/select


class PasswordItemView extends TextItemView
	class-name: \password
	template: \form/password
	ui:
		input: \input
	events:
		'input @ui.input': camelize \update-value
	update-value: !->
		@model.set \value, @ui.input.val!
		@model.check-if-is-valid!


class FormErrorView extends LayoutView
	template: \form/error
	initialize: !->
		super? ...
		@listen-to @model, \change:error_message_code, @render


class FormView extends CompositeView
	
	tag-name: \form
	class-name: 'form edit-form'
	child-view-container: \.fields
	template: \form/form
	ui:
		\cancel       : \.cancel
		\error-region : \.js-error-region
	events:
		'click @ui.cancel' : \cancel
		\submit            : camelize \on-form-submit
	
	initialize: !->
		super? ...
		@model.check-if-is-valid!
		@_mutex = false
		@listen-to @collection, \reset:error_message_code, !->
			@model.set \error_message_code, null
		@listen-to @collection, \error_message_code, !->
			@model.set \error_message_code, it
	
	on-show: !->
		super? ...
		@form-error-view = new FormErrorView { @model, el: @ui.\error-region }
			..render!
	
	on-destroy: !->
		if @form-error-view?
			@form-error-view.destroy!
			delete @form-error-view
		super? ...
		delete @_mutex
	
	on-form-submit: (e)!->
		
		e.prevent-default!
		e.stop-propagation!
		
		switch @_mutex
		| on  => return
		| off => @_mutex = true
		
		@collection.save do
			fail: !~> @_mutex = false
			success: !~>
				@_mutex = false
				@trigger \cancel:form
	
	cancel: (e)!->
		e.prevent-default!
		e.stop-propagation!
		@trigger \cancel:form
	
	@model-to-view-map =
		* CheckboxFormFieldModel , CheckboxItemView
		* TextFormFieldModel     , TextItemView
		* HtmlFormFieldModel     , null # TODO
		* PasswordFormFieldModel , PasswordItemView
	
	get-child-view: (model)~>
		
		FoundView = null
		@@model-to-view-map.some ([ModelClass, ViewClass])->
			| model instanceof ModelClass =>
				FoundView := ViewClass
				true
			| otherwise => false
		
		unless FoundView?
			panic-attack new Error "Cannot find View class for model instance"
		
		FoundView


module.exports = FormView
