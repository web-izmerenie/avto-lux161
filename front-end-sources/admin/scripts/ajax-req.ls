/**
 * AJAX request abstration
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery : $
	\backbone.wreqr : W
	'./config.json' : config
}

module.exports = (options)->
	options = {
		url: config.ajax_data_url
		data-type: \json
		method: \POST
		cache: false
		error: (xhr, status, err)!->
			W.radio.commands .execute \police, \panic, err
	} <<<< options

	$ .ajax options
