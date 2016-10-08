/**
 * Form View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery                   : $
	\ckeditor/adapters/jquery : {}
	
	\backbone.marionette      : { ItemView, CompositeView }
	
	\./files                  : FilesItemView
	\./data-fields            : DataFieldsItemView
	\app/model/basic          : { BasicModel }
}


class InputItemView extends ItemView
	tag-name: \label


class TextItemView extends InputItemView
	class-name: \text
	template: \form/text


class CheckboxItemView extends InputItemView
	class-name: \checkbox
	template: \form/checkbox


class HTMLInputItemView extends InputItemView
	
	class-name: \html
	template: \form/html
	ui:
		textarea: \textarea
	check-for-alive: -> Boolean @?ui?textarea?ckeditor?
		
	on-render: !->
		!~>
			return unless @check-for-alive!
			@ui.textarea.ckeditor!
		|> set-timeout _, 1 #hack


class SelectItemView extends InputItemView
	class-name: \select
	template: \form/select


class PasswordItemView extends TextItemView
	class-name: \password
	template: \form/password


class FormView extends CompositeView
	
	tag-name: \form
	class-name: 'form edit-form'
	child-view-container: \.fields
	template: \form/form
	ui:
		\cancel : \.cancel
	events:
		'click @ui.cancel' : \cancel
	
	initialize: !->
		
		super ...
		
		@model = new BasicModel do
			page: @get-option \page
			type: @get-option \type
			err_key: null
			values: {}
		
		@on \form-msg, @on-form-msg
	
	on-form-msg: (err-key)!->
		@model.set \err_key, err-key
		$ 'html,body' .scroll-top 0
		@render!
	
	cancel: (e)!->
		e.prevent-default!
		@trigger \cancel:form
	
	on-render: !->
		@$el.off \submit.store-values
		@$el.on \submit.store-values, !~>
			@model.set \values, \
				{[x.name, x.value] for x in @$el.serialize-array!}
	
	child-view-options: (model, index)!~>
		model.set do
			local  : @model.get \local
			page   : @get-option \page
			values : @model.get \values
	
	get-child-view: (item)~>
		switch item.get \type
		| \checkbox    => CheckboxItemView
		| \html        => HTMLInputItemView
		| \select      => SelectItemView
		| \files       => FilesItemView
		| \password    => PasswordItemView
		| \data_fields => DataFieldsItemView
		| otherwise    => TextItemView


module.exports = FormView
