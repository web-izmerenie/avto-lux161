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

	'../model/basic' : BasicModel
}

tinymce = window.tinymce

class TextItemView extends M.ItemView
	tag-name: \label
	class-name: 'text'
	template: 'form/text'

class CheckboxItemView extends M.ItemView
	tag-name: \label
	class-name: 'checkbox'
	template: 'form/checkbox'

class HTMLInputItemView extends M.ItemView
	tag-name: \label
	class-name: 'html'
	template: 'form/html'
	ui:
		textarea: 'textarea'
	on-render: !->
		@ui.textarea.tinymce config.tinymce_options

class FormView extends M.CompositeView
	tag-name: \form
	class-name: 'form edit-form'
	child-view-container: \.fields
	template: 'form/form'
	initialize: !->
		@model = new BasicModel {
			page: @get-option \page
			\form_title_key : (@get-option \form-title-key) or ''
		}

	child-view-options: (model, index)~>
		model.set \local, @model.get \local
		model.set \page @get-option \page

	get-child-view: (item)~>
		switch item.get \type
		| \checkbox => return CheckboxItemView
		| \html => return HTMLInputItemView

		TextItemView

module.exports = FormView
