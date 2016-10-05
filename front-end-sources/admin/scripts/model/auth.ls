/**
 * Authentication model
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\app/model/basic                 : { BasicModel }
	\app/model/localization          : { LocalizationModel }
	\app/model/type-validation-mixin : { type-validation-model-mixin }
	
	\app/config.json                 : { login_url, logout_url, auth_fetch_url }
	\app/utils/mixins                : { call-class-mixins }
	\app/utils/panic-attack          : { panic-attack }
}


export class AuthModel
extends BasicModel
implements type-validation-model-mixin
	
	[ type-validation-model-mixin ]
		@_call-class = call-class-mixins ..
	
	initialize: !-> (@@_call-class super::, \initialize) ...
	
	url: null
	
	attributes-typings:
		local         : (instanceof LocalizationModel)
		
		status        : (in <[success error logout]>)
		error_code    : (typeof!) >> (in <[Null String]>)
		
		username      : (typeof!) >> (in <[Null String]>)
		is_authorized : \Boolean
	
	parse: (response)-> {} <<< response <<< { response.error_code ? null }
	
	login: (user, pass, { success = null, fail = null } = {})!->
		
		unless [user, pass].every (-> (typeof! it) is \String)
			throw new Error 'Invalid arguments'
		
		@sync \update, @, do
			url: login_url
			data: { user, pass }
			success: (response)!~>
				
				data = @parse response
				data.is_authorized = data.status is \success
				
				@set data
				@check-if-is-valid!
				
				switch data.status
				| \success =>
					success? @, response
					@trigger \login-success
				| \error =>
					fail? @, response
					@trigger \login-fail, data.error_code
				| _ => throw new Error "Unexpected status: #{data.status}"
	
	logout: ({ success = null } = {})!->
		@sync \update, @, do
			url: logout_url
			success: (response)!~>
				
				data = @parse response
				data.is_authorized = data.status |> (is \logout) |> (not)
				data.username = null
				
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
				
				success? @, response
				@trigger \logout-success
	
	fetch: ({ success = null } = {})!->
		@sync \update, @, do
			url: auth_fetch_url
			success: (response)!~>
				
				data = @parse response
				data.is_authorized = data.status is \success
				
				@set data
				@check-if-is-valid!
				
				unless data.status is \success
					panic-attack new Error "
						Auth fetch error (
							status isn't 'success',
							\ status is '#{data.status}',
							\ error code: '#{data.error_code}'
						)
					"
				unless data.username?
					panic-attack new Error "
						Auth fetch error (incorrect username)
					"
				
				success? @, response
				@trigger \auth-fetch
