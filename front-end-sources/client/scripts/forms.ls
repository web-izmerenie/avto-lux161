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
