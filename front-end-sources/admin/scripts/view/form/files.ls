/**
 * FilesItemView of FormView
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery              : $
	\jquery-ui/sortable  : {}
	
	\backbone.marionette : { ItemView }
	\backbone.wreqr      : { radio }
	
	'../../ajax-req' # TODO remove
	
	\app/config.json
}


class FilesItemView extends ItemView
	
	tag-name: \div
	class-name: \files
	template: \form/files
	
	ui:
		file: 'input[type=file]'
		json: 'input[type=hidden]'
		list: \ul.js-uploaded-earlier-list
	
	rebuild-files: !->
		name = @model.get \name
		if name is \images or name is \main_image
			@ui.list.css \max-width \400px
			@ui.list.sortable update: !~>
				new_json = []
				@ui.list.find 'li' .each !->
					data = $ @ .data \val
					return unless data?
					new_json.push ($ @ .data \val)
				@ui.json.val JSON.stringify new_json
		
		json = JSON.parse @ui.json.val!
		@ui.list.html ''
		for item in json
			$el = $ '<li/>' class: 'list-group-item'
			$el.data \val, item
			$inp = $ '<input/>' {
				type: \text
				value: config.uploaded_file_prefix + item.filename
				readonly: \readonly
				class: 'form-control'
			}
			if name is \images or name is \main_image
				$inp = $ '<img/>' {
					alt: ''
					src: config.uploaded_file_prefix + item.filename
					class: 'form-control'
				}
				$inp.css {
					width: \100%
					height: \auto
				}
			$igrp = $ '<div/>' class: 'input-group'
			$igrp.append $inp
			$a = $ '<span/>' class: 'input-group-btn'
			$b = $ '<button/>' {
				class: 'btn btn-default'
				type: 'button'
			}
			$b.text (@model.get \local .get \forms .delete)
			$a.append $b
			$igrp.append $a
			$el.append $igrp
			$b.on \click, let f=item.filename then ~>
				old_json = JSON.parse @ui.json.val!
				new_json = []
				for item in old_json
					if item.filename isnt f
						new_json.push filename: item.filename
				@ui.json.val JSON.stringify new_json
				@rebuild-files!
				false
			@ui.list.append $el
	
	on-render: !->
		if @ui.json.val!.length <= 0
			@ui.json.val JSON.stringify []
		
		@rebuild-files!
		
		name = @model.get \name
		
		@ui.file.on \change, !~>
			@ui.file.attr \disabled, \disabled
			fd = new FormData!
			for file,i in @ui.file[0].files
				fd.append \file_ + i, file
			@ajax = ajax-req do
				url: config.upload_file_url
				data: fd
				processData: false
				contentType: false
				success: (json)!~>
					return unless @ui? and @ui.file and @ui.list and @ui.json
					
					new_json = JSON.parse @ui.json.val!
					for file in json.files
						new_json.push filename: file.name
					@ui.json.val JSON.stringify new_json
					@rebuild-files!
					@ui.file.remove-attr \disabled
					@ajax = null
	on-destroy: !->
		@ajax.abort! if @ajax?
		@ui.file.off \change
		
		# TODO :: need to check if initialized
		#@ui.list.sortable \destroy


module.exports = FilesItemView
