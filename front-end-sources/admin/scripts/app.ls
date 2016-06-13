/**
 * App
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone                   : B
	\backbone.marionette        : M
	'./config.json'             : config
	
	\adminbase/styles/main.styl : {}
}

class App extends M.Application
	get-option: M.proxy-get-option
	
	container: \body
	is-auth: false
	
	initialize: !->
		@add-regions container: @get-option \container
	
	start: (options)!->
		B.history .start root: config.root_url
	
	on-destroy: !->
		B.history .stop!

module.exports = App
