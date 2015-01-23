/**
 * DataFieldsItemView of FormView
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery : $
	\jquery-ui
	\jquery-ui.sortable

	\backbone : B
	\marionette : M

	'../error-msg' : ErrorMessageView
	'../ask-sure' : AskSureView
}

sort-collection-cb = (e, ui)!->
	models = @collection.models
	model = ui.item.data \model
	index = ui.item.index!

	new-order = []
	for i from 0 til models.length
		new-order.push models[i] if models[i] isnt model

	new-list = []
	for i from 0 til models.length
		new-list.push model if i is index
		new-list.push new-order[i] if new-order[i]?

	@collection.set new-list
	@collection.trigger \change

# {{{
class FieldView extends M.CompositeView
	tag-name: \li
	class-name: \list-group-item
	template: 'form/data-fields/field'
	child-view-container: \.input-container
	child-view-options: (model, index)!~>
		model.set \multiple, @model.get \multiple
		model.set \local, @model.get \local
	model-white-list:
		\value
		...
	initialize: !->
		@collection = new B.Collection @model.get \values
		@$el.data \model, @model
	on-render: !->
		if @model.get \multiple
			@ui.list.sortable update: (e, ui)!~>
				sort-collection-cb ...
		@collection.on 'change remove add', !~>
			arr = @collection.toJSON!
			new-arr = []
			for item in arr
				new-item = {}
				for key in @model-white-list
					new-item[key] = item[key]
				new-arr.push new-item
			@model.set \values new-arr
	ui:
		del: \.del-field
		delmsg: '.del-area .del-msg'
		add: '.add-area .add-value'
		name: \input.name
		list: \ul.input-container
	events:
		'click @ui.del': \del-field
		'click @ui.add': \add-value
		'change @ui.name': \updated-name
	\updated-name : !->
		@model.set \name, @ui.name.val!
	\del-field : ->
		ask = new AskSureView!
		ask.render!
		@ui.delmsg.html ask.$el
		ask.on-before-show!
		ask.on 'yes', ~>
			@model.collection.remove @model
			false
		false
	\add-value : ->
		@collection.push value: ''
		false

# value item
class FieldItemView extends M.ItemView
	tag-name: \li
	class-name: \list-group-item
	events:
		'change @ui.val': \change
		'click @ui.add': \add
		'click @ui.del': \del
	change: !->
		val = @ui.val.val!
		@model.set \value val
	del: ->
		@model.collection.remove @model
		false
	add: ->
		@model.collection.add {value: ''}, {at: (+ 1) @$el.index!}
		false
	initialize: !->
		@$el.data \model, @model
# }}}

# {{{
class AddFieldView extends M.ItemView
	tag-name: \li
	class-name: \list-group-item
	template: 'form/data-fields/add'
	ui:
		err: \.err-block
		code: \input.code
		type: \select.type-chooser
		multiple: \input.multiple
		add: \.add-field
		del: \.cancel
	events:
		'click @ui.add': \add
		'click @ui.del': \del
	add: ->
		if @ui.code.val! is ''
			err-view = new ErrorMessageView {
				message: @model.get \local
					.get \forms .data_fields.err.code_is_empty
			}
			err-view.render!
			@ui.err.html err-view.$el
			err-view.on-before-show!
			return false

		model = @model.collection.find-where code: @ui.code.val!
		if model?
			err-view = new ErrorMessageView {
				message: @model.get \local
					.get \forms .data_fields.err.code_already_exists
			}
			err-view.render!
			@ui.err.html err-view.$el
			err-view.on-before-show!
			return false

		@model.collection.push {
			type: @ui.type.val!
			multiple: @ui.multiple.is \:checked
			code: @ui.code.val!
			name: ''
			values: [value: '']
		}
		@del!

		false
	del: ->
		@model.collection.remove @model
		false
# }}}

# {{{
class TextItemFieldView extends FieldItemView
	template: 'form/data-fields/text'
	ui:
		\val : \input:text
		\add : \.add
		\del : \.del

class TextFieldView extends FieldView
	child-view: TextItemFieldView
# }}}

# {{{
class TextareaItemFieldView extends FieldItemView
	template: 'form/data-fields/textarea'
	ui:
		\val : \textarea
		\add : \.add
		\del : \.del

class TextareaFieldView extends FieldView
	child-view: TextareaItemFieldView
# }}}

class ListView extends M.CollectionView
	tag-name: \ul
	class-name: \list-group
	child-view-options: (model, index)!~>
		model.set \local, @model.get \local
	get-child-view: (item)~>
		switch item.get \type
		| \add => return AddFieldView
		| \text => return TextFieldView
		| \textarea => return TextareaFieldView
		| _ => ...
	on-render: !->
		@$el.sortable update: (e, ui)!~>
			sort-collection-cb ...

class DataFieldsItemView extends M.ItemView
	tag-name: \div
	class-name: \data-fields
	template: 'form/data-fields'

	ui:
		add: \.add-new-field
		flist: \.data-fields-area
		data: \input:hidden

	events:
		'click @ui.add': \add-field

	\add-field : ->
		unless @flist.find-where type: \add
			@flist.push type: \add
		false

	initialize: !->
		values = (@model.get \values) or {}
		values = {} unless typeof! values is \Object

		data = []
		if values[@model.get \name]?
		and typeof! values[@model.get \name] is \String
		and values[@model.get \name] isnt ''
			data = JSON.parse values[@model.get \name]
			data = [] unless typeof! data is \Array

		@flist = new B.Collection data
		@flist-view = new ListView {
			collection: @flist
			model: @model.clone!
		}

	on-render: !->
		@flist-view.render!
		@ui.flist.append @flist-view.$el
		@flist.on 'change remove add', !~>
			data = @flist.toJSON!
			new-data = []
			for item in data
				new-item = {}
				for key of item
					continue if key |> (in <[ local ]>)
					new-item[key] = item[key]
				continue if item.type is \add
				new-data.push new-item
			data = new-data

			@ui.data.val JSON.stringify data

module.exports = DataFieldsItemView
