/**
 * throw fatal error abstraction
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! './view/fatal-error' : FatalErrorView

module.exports = (app, err)!->
	app .get-region \container .show new FatalErrorView exception: err
	throw err
