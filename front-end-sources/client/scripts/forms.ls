/**
 * forms behavior
 *
 * @author Viacheslav Lotsmanov
 */

require! \jquery : $

speed = 500 # ms, animation

$html = $ \html
$body = $html .find \body

$forms = $ 'body > form'
$overlay = $ '<div/>' .add-class \form-overlay
process = false

(local) <-! (require './get-local')

hide-form-selector = '>label, >input:not(.b), >.time'

reset-form-bind = !->
	$ @ .find 'label > .err-msg' .each !->
		$ @ .closest \label .find \input .off \focus
		$ @ .animate opacity: 0, speed, !-> $ @ .remove!

restore-form-bind = !->
	return if $ @ .find '.success-msg' .length <= 0
	$ @ .find hide-form-selector .slide-down speed
	$ @ .find 'input:text, input[type=tel], input[type=date]' .val ''
	$ @ .find 'input[type=number]' .val '0'
	$ @ .find \.success-msg .remove!

$forms.each !->
	id = $ @ .attr \id
	$closer = $ '<button/>' .add-class \closer .html \Закрыть

	$ "a[href=\##id]" .click ~>
		return false if process
		process := true

		$html .add-class \form-popup
		$body .append $overlay

		$overlay
			.animate opacity: 1, speed
			.on \click ~>
				$closer .trigger \click
				false
		$ @ .css \display, \block .animate opacity: 1, speed, !->
			process := false

		false

	restore-form = ~> restore-form-bind .call @

	$closer .click ~>
		return false if process
		process := true

		$overlay
			.animate opacity: 0, speed, !-> $ @ .remove!
			.off \click
		$ @ .animate opacity: 0, speed, !->
			$ @ .css \display, \none
			restore-form!
			$html .remove-class \form-popup
			process := false

		false

	$ @ .prepend $closer

	$ @ .find 'input[type=date]' .each !->
		Modernizr = require \modernizr
		unless Modernizr.inputtypes.date
			require './datepicker-init'
			$ @ .attr \type \text
			$ @ .datepicker!

	reset-form = ~> reset-form-bind .call @
	free = !~>
		$ @ .remove-class \ajax-process
		process := false

	<- $ @ .submit
	return false if process
	process := true
	$ @ .add-class \ajax-process

	reset-form!

	data-to-send = $ @ .serialize-array!
	data-to-send.push name: \ajax, value: \Y

	action = $ @ .find 'input[name=action]' .val!

	$ .ajax {
		url: $ @ .attr \action
		method: \POST
		data: data-to-send
		data-type: \json
		success: (json)!~>
			unless json.status?
				window.alert local.forms.err.server_data
				free!
				return

			switch json.status
			| \success =>
				$wrap = $ '<div/>' .add-class \success-msg .hide!
				$msg = $ '<p/>' .html local.forms.response[action].success
				$wrap .append $msg
				$ @ .find hide-form-selector .slide-up speed
				$ @ .append $wrap
				$wrap.slide-down speed
			| _ =>
				window.alert local.forms.err.server_data
				free!
				return

			free!
		error: (xhr, status, err)!~>
			if xhr.responseJSON and xhr.responseJSON.status
				switch xhr.responseJSON.status
				| \unknown_form =>
					window.alert local.forms.err.unknown_form
					free!
					return
				| \error =>
					unless xhr.responseJSON.error_fields?
						window.alert local.forms.err.server_data
						free!
						return

					f-arr = []

					for fname, err-type of xhr.responseJSON.error_fields
						$field = $ @ .find "input[name=#fname]"
						if $field.length <= 0
							$ @ .find 'label > .err-msg' .remove!
							window.alert local.forms.err.field_not_found
							free!
							return
						$err-msg = $ '<span/>'
							.add-class \err-msg
							.html local.forms.err[err-type]
						$field .closest \label .prepend $err-msg
						$err-msg.animate opacity: 1, speed
						f-arr.push {
							$field: $field
							$err-msg: $err-msg
						}

					for item in f-arr then let item
						item.$field .on \focus ->
							item.$err-msg .animate opacity: 0, speed, !->
								$ @ .remove!
								item.$field .off \focus
							false

					free!
					return
				| \system_fail =>
					window.alert local.forms.err.system_fail
					free!
					return
				| _ =>
					window.alert local.forms.err.server_data
					free!
					return

			if err instanceof SyntaxError
				window.alert local.forms.err.server_data
			else
				window.alert local.forms.err.ajax
			free!
	}

	false
