/**
 * AJAX request abstration
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery : $
	'./throw-fatal-error'
}

module.exports = (app, options)!->
	options = {
		data-type: \json
		method: \POST
		error: (xhr, status, err)!-> throw-fatal-error app, err
	} <<<< options

	$ .ajax options
