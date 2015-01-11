/**
 * @author Viacheslav Lotsmanov
 */

require! \jquery : $
require \jquery-colorbox

speed = 500 # ms, animation

<-! $ # dom ready

$html = $ \html
$body = $html .find \body

# colorbox for catalog detail page
$ \.catalog-page.detail .each (i)!->
	$links = $ @ .find 'ul.photos > li > a'
	$links.colorbox {
		rel: "group_#i"
		opacity: 1
		transition: \fade
		max-height: \80%
		loop: false
	}

# forms

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
