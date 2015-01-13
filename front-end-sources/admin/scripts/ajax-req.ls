/**
 * AJAX request abstration
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery : $
	\backbone.wreqr : W
}

module.exports = (options)->
	options = {
		data-type: \json
		method: \POST
		cache: false
		error: (xhr, status, err)!->
			W.radio.commands .execute \police, \panic, err
	} <<<< options

	$ .ajax options
