/**
 * @author Viacheslav Lotsmanov
 */

require! \jquery : $
require \jquery-colorbox

<-! $ # dom ready

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

$forms.each !->
	$closer = $ '<button/>' .add-class \closer .html \Закрыть
	$closer.click ->
		false
	$ @ .prepend $closer
