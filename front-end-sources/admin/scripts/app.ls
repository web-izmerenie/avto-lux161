/**
 * App
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone : B
	\marionette : M
}

class App extends M.Application
	get-option: M.proxy-get-option

	container: \body
	is-auth: false

	initialize: !->
		@add-regions container: @get-option \container

	start: (options)!->
		B.history .start root: '/adm/'

	on-destroy: !->
		B.history .stop!

module.exports = App
