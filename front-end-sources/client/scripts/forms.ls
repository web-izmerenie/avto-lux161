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

	$closer .click ~>
		return false if process
		process := true

		$overlay
			.animate opacity: 0, speed, !-> $ @ .remove!
			.off \click
		$ @ .animate opacity: 0, speed, !->
			$ @ .css \display, \none
			$html .remove-class \form-popup
			process := false

		false

	$ @ .prepend $closer

	<- $ @ .submit
	return false if process
	process := true

	$ @ .find 'label > .err-msg' .each !->
		$ @ .closest \label .find \input .off \focus
		$ @ .animate opacity: 0, speed, !-> $ @ .remove!

	data-to-send = $ @ .serialize-array!
	data-to-send.push name: \ajax, value: \Y

	$ .ajax {
		url: $ @ .attr \action
		method: \POST
		data: data-to-send
		data-type: \json
		success: (json)!~>
			unless json.status?
				window.alert local.forms.err.server_data
				process := false
				return

			switch json.status
			| \success =>
				console.log 2222
			| _ =>
				window.alert local.forms.err.server_data
				process := false
				return

			process := false
		error: (xhr, status, err)!~>
			if xhr.responseJSON and xhr.responseJSON.status
				switch xhr.responseJSON.status
				| \unknown_form =>
					window.alert local.forms.err.unknown_form
					process := false
					return
				| \error =>
					unless xhr.responseJSON.error_fields?
						window.alert local.forms.err.server_data
						process := false
						return

					f-arr = []

					for fname, err-type of xhr.responseJSON.error_fields
						$field = $ @ .find "input[name=#fname]"
						if $field.length <= 0
							$ @ .find 'label > .err-msg' .remove!
							window.alert local.forms.err.field_not_found
							process := false
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

					process := false
					return
				| \system_fail =>
					window.alert local.forms.err.system_fail
					process := false
					return
				| _ =>
					window.alert local.forms.err.server_data
					process := false
					return

			if err instanceof SyntaxError
				window.alert local.forms.err.server_data
			else
				window.alert local.forms.err.ajax
			process := false
	}

	false
