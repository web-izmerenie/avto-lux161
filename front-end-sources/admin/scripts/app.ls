/**
 * App
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery                : $
	\backbone              : { history }
	\backbone.marionette   : { Application, proxy-get-option }
	\backbone.wreqr        : { radio }
	
	\app/model/auth        : { AuthModel }
	
	\app/config.json       : { root_url }
	
	\base/styles/main.styl : {}
}


is-auth-at-start = $ \html .attr \data-is-auth .to-string! is \1
authentication = radio.channel \authentication


class App extends Application
	
	get-option: proxy-get-option
	
	container: \body
	
	initialize: !->
		super? ...
		@add-regions container: @get-option \container
		@auth-model = new AuthModel is_authorized: is-auth-at-start
	
	start: (options)!->
		
		super? ...
		
		authentication.reqres
			..set-handler \username, ~> @auth-model.get \username
		@listen-to @auth-model, \change:username, !->
			authentication.vent.trigger \username, @auth-model.get \username
		
		@auth-model.fetch! if is-auth-at-start
		history.start root: root_url
	
	on-destroy: !->
		super? ...
		history.stop!
		authentication.reqres.remove-handler \username
		delete @auth-model


module.exports = App
