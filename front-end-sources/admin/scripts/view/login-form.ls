/**
 * LoginForm view
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone            : { history }
	\backbone.marionette : { proxy-get-option }
	\backbone.wreqr      : { radio }
	
	\./smooth            : SmoothView
	\./error-msg         : ErrorMessageView
}


class LoginFormView extends SmoothView
	
	get-option: proxy-get-option
	
	initialize: !->
		super ...
		@model = @get-option \app .auth-model
	
	is-processing: no
	
	class-name: 'login-form container'
	template: \login-form
	regions:
		message: \.message
	ui:
		form: 'form[role=form]'
		user: 'input[name=user]'
		pass: 'input[name=pass]'
	events:
		'submit @ui.form' : \form-handler
	
	on-auth-fail: !->
		
		error_code = @model.get \error_code
		
		if not error_code?
		or error_code not in <[ user_not_found incorrect_password ]>
			new Error "Unknown 'error_code': '#error_code'"
			|> radio.commands.execute \police, \panic, _
		
		err-view = new ErrorMessageView do
			message: @model.get \local .get \forms .err[error_code]
		
		@get-region \message .show err-view
	
	on-auth-success: !->
		history.navigate \#panel, { +trigger, +replace }
	
	\form-handler : (e)!->
		
		e.prevent-default!
		if @is-processing
			then return
			else @is-processing = yes
		
		@model.login @ui.user.val!, @ui.pass.val!, do
			success: !~>
				@on-auth-success!
				@is-processing = no
			fail: !~>
				@on-auth-fail!
				@is-processing = no


module.exports = LoginFormView
