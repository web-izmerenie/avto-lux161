/**
 * Authentication model
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone                        : { history }
	
	\app/model/basic                 : { BasicModel }
	\app/model/localization          : { LocalizationModel }
	\app/model/type-validation-mixin : { type-validation-model-mixin }
	
	\app/config.json                 : { login_url, logout_url }
	\app/utils/panic-attack          : { panic-attack }
}


is-auth-at-start = $ \html .attr \data-is-auth .to-string! is \1


export class AuthModel
extends BasicModel
implements type-validation-model-mixin
	
	url: null
	
	attributes-typings:
		local         : (instanceof LocalizationModel)
		
		status        : (in <[success error logout]>)
		error_code    : (typeof!) >> (in <[Null String]>)
		
		is_authorized : \Boolean
	
	parse: (response)-> {} <<< response <<< { response.error_code ? null }
	
	login: (user, pass, { success = null, fail = null } = {})!->
		
		unless [user, pass].every (-> (typeof! it) is \String)
			throw new Error 'Invalid arguments'
		
		@fetch do
			url: login_url
			data: { user, pass }
			parse: off
			silent: on
			success: (model, response)!~>
				
				data = @parse response
				data.is_authorized = data.status is \success
				
				@set data
				@check-if-is-valid!
				
				switch data.status
				| \success =>
					success? ...
					@trigger \login-success
				| \error =>
					fail? ...
					@trigger \login-fail, data.error_code
				| _ => throw new Error "Unexpected status: #{data.status}"
	
	logout: ({ success = null } = {})!->
		@fetch do
			url: logout_url
			parse: off
			silent: on
			success: (model, response)!~>
				
				data = @parse response
				data.is_authorized = data.status |> (is \logout) |> (not)
				
				@set data
				@check-if-is-valid!
				
				unless data.status is \logout
					panic-attack new Error "
						Logout error (
							status isn't 'logout',
							\ status is '#{data.status}',
							\ error code: '#{data.error_code}'
						)
					"
				
				success? ...
				@trigger \logout-success


export auth-model = new AuthModel is_authorized: is-auth-at-start
