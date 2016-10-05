/**
 * App
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone              : { history }
	\backbone.marionette   : { Application, proxy-get-option }
	\backbone.wreqr        : { radio }
	
	\app/model/auth        : { auth-model }
	
	\app/config.json       : { root_url }
	
	\base/styles/main.styl : {}
}


authentication = radio.channel \authentication


class App extends Application
	
	get-option: proxy-get-option
	
	container: \body
	auth-model: auth-model
	
	initialize: !->
		
		super? ...
		
		@add-regions container: @get-option \container
		
		authentication.reqres
			..set-handler \username, ~> @auth-model.get \username
		@listen-to @auth-model, \change:username, !->
			authentication.vent.trigger \username, @auth-model.get \username
	
	start: (options)!->
		super? ...
		history.start root: root_url
	
	on-destroy: !->
		super? ...
		history.stop!
		authentication.reqres.remove-handler \username


module.exports = App
