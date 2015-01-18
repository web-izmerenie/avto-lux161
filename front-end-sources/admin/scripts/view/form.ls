/**
 * Form View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery : $
	\marionette : M
	\backbone.wreqr : W
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
		textarea: \textarea
	check-for-alive: ->
		unless @? and @ui? and @ui.textarea? and @ui.textarea.ckeditor?
			false
		else
			true
	on-render: !->
		require \jquery.ckeditor
		set-timeout (!~> #hack
			return unless @check-for-alive!
			@ui.textarea.ckeditor!
		), 1

class SelectItemView extends InputItemView
	class-name: \select
	template: 'form/select'

class FilesItemView extends InputItemView
	class-name: \files
	template: 'form/files'
	ui:
		input: \input
		upload_list: \ul.upload-list
		dragndrop_area: \.upload-area
	check-for-alive: ->
		unless @? and @ui? and @ui.input? and @ui.upload_list
		and @ui.dragndrop_area
			false
		else
			true
	on-render: !->
		D = require \jquery.dragndrop-file-upload
		set-timeout (!~> #hack
			return unless @check-for-alive!
			@files-dom-list = {}
			@D = new D {
				dragndrop-area: @ui.dragndrop_area
				upload-url: config.upload_file_url
				drag-over-class: \fileover

				add-file-callback: (err, id, file-name, file-size, file-type)!~>
					return unless @check-for-alive!

					if err?
						window.alert err
						return

					$li = $ '<li/>' data-upload-id: id
					$filename = $ '<div/>' class: \filename
					$progress = $ '<div/>' class: \progress
					$bar = $ '<div/>' class: \progress-bar .css \width, \0%
					$progress.append $bar
					$li.append $filename
					$li.append $progress
					$bar.text \0%
					file-size = (file-size / 1024.0 / 1024.0).to-fixed 2
					mib = @model.get \local .get \mib
					$filename.text "#file-name (#file-size #mib)"

					@files-dom-list[id] = $bar: $bar

					$ @ui.upload_list[0] .append $li

				progress-callback: (id, progress)!~>
					return unless @check-for-alive!

					@files-dom-list[id].$bar
						.css \width, progress + '%'
						.text progress + '%'

				end-callback: (err, id, response)!~>
					return unless @check-for-alive!

					$el = @files-dom-list[id].$bar

					if err?
						$el.add-class \progress-bar-danger
						$el .text (@model.get \local .get \forms .err.upload_error) .css \width, \100%
						window.alert err
						return

					console.log response

					$el.css \window, \100%
					$el.add-class \progress-bar-success

				input-file: $ @ui.input[0]
			}
		), 1
	on-destroy: !->
		@D.destroy! if @D?
		delete! @D
		delete! @files-dom-list

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
		| \files => return FilesItemView

		TextItemView

module.exports = FormView
