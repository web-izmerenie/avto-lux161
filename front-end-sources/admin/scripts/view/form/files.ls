/**
 * FilesItemView of FormView
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery              : $
	\jquery-ui/sortable  : {}
	
	\backbone.marionette : M
	\backbone.wreqr      : W
	
	'../../ajax-req'
	'../../config.json'
}

class FilesItemView extends M.ItemView
	tag-name: \div
	class-name: \files
	template: 'form/files'
	
	ui:
		file: 'input[type=file]'
		json: 'input[type=hidden]'
		list: 'ul.uploaded-earlier-list'
	
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
			W.radio.commands .execute \police, \request-stop
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
					W.radio.commands .execute \police, \request-free
	on-destroy: !->
		@ajax.abort! if @ajax?
		@ui.file.off \change
		
		# TODO :: need to check if initialized
		#@ui.list.sortable \destroy
	
	# TODO :: backend fix
	#ui:
		#input: \input
		#upload_list: \ul.upload-list
		#dragndrop_area: \.upload-area
	#check-for-alive: ->
		#unless @? and @ui? and @ui.input? and @ui.upload_list
		#and @ui.dragndrop_area
			#false
		#else
			#true
	#on-render: !->
		#D = require \jquery.dragndrop-file-upload
		#set-timeout (!~> #hack
			#return unless @check-for-alive!
			#@files-dom-list = {}
			#@D = new D {
				#dragndrop-area: @ui.dragndrop_area
				#upload-url: config.upload_file_url
				#drag-over-class: \fileover
				
				#add-file-callback: (err, id, file-name, file-size, file-type)!~>
					#return unless @check-for-alive!
					
					#if err?
						#window.alert err
						#return
					
					#$li = $ '<li/>' data-upload-id: id
					#$filename = $ '<div/>' class: \filename
					#$progress = $ '<div/>' class: \progress
					#$bar = $ '<div/>' class: \progress-bar .css \width, \0%
					#$progress.append $bar
					#$li.append $filename
					#$li.append $progress
					#$bar.text \0%
					#file-size = (file-size / 1024.0 / 1024.0).to-fixed 2
					#mib = @model.get \local .get \mib
					#$filename.text "#file-name (#file-size #mib)"
					
					#@files-dom-list[id] = $bar: $bar
					
					#$ @ui.upload_list[0] .append $li
				
				#progress-callback: (id, progress)!~>
					#return unless @check-for-alive!
					
					#@files-dom-list[id].$bar
						#.css \width, progress + '%'
						#.text progress + '%'
				
				#end-callback: (err, id, response)!~>
					#return unless @check-for-alive!
					
					#$el = @files-dom-list[id].$bar
					
					#if err?
						#$el.add-class \progress-bar-danger
						#$el .text (@model.get \local .get \forms .err.upload_error) .css \width, \100%
						#window.alert err
						#return
					
					#console.log response
					
					#$el.css \window, \100%
					#$el.add-class \progress-bar-success
				
				#input-file: $ @ui.input[0]
			#}
		#), 1
	#on-destroy: !->
		#@D.destroy! if @D?
		#delete! @D
		#delete! @files-dom-list

module.exports = FilesItemView
