/**
 * App
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone              : { history }
	\backbone.marionette   : { Application, proxy-get-option }
	
	\./model/auth          : { auth-model }
	
	\./config.json         : { root_url }
	
	\base/styles/main.styl : {}
}


class App extends Application
	
	get-option: proxy-get-option
	
	container: \body
	auth-model: auth-model
	
	initialize: !->
		super ...
		@add-regions container: @get-option \container
	
	start: (options)!->
		history.start root: root_url
	
	on-destroy: !->
		history.stop!


module.exports = App
