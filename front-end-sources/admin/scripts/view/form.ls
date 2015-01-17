/**
 * Form View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\marionette : M

	'../model/basic' : BasicModel
}

class HTMLInputItemView extends M.ItemView
	tag-name: \label
	class-name: 'html'

class TextItemView extends M.ItemView
	tag-name: \label
	class-name: 'text'
	template: 'form/text'

class CheckboxItemView extends M.ItemView
	tag-name: \label
	class-name: 'checkbox'
	template: 'form/checkbox'

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
		name = item.get \name

		if (name.index-of \is_) is 0 or (name.index-of \has_) is 0
			return CheckboxItemView

		TextItemView

module.exports = FormView
