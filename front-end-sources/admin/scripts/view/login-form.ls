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
	
	\../model/basic      : BasicModel
	\./smooth            : SmoothView
	\./loader            : LoaderView
	\./error-msg         : ErrorMessageView
	\../ajax-req
}


class LoginFormView extends SmoothView
	
	\auth-url : \/adm/auth # TODO try get with prefix from Backbone.history
	
	get-option: proxy-get-option
	
	process: no # default value
	set-processing: !-> @process = it
	is-processing: -> @process
	
	class-name: 'login-form container'
	template: \login-form
	model: new BasicModel!
	regions:
		message: \.message
	ui:
		form: 'form[role=form]'
		user: 'input[name=user]'
		pass: 'input[name=pass]'
	events:
		'submit @ui.form' : \form-handler
	
	on-json-error: (json)!->
		if not json.error_code?
		or json.error_code not in <[ user_not_found incorrect_password ]>
			new Error 'Unknown "error_code"'
			|> radio.commands.execute \police, \panic, _
		
		err-view = new ErrorMessageView do
			message: @model.get \local .get \forms .err[json.error_code]
		
		@get-region \message .show err-view
	
	on-json-success: (json)!->
		@get-option \app .is-auth = true
		history.navigate \#panel, { +trigger, +replace }
	
	\form-handler : (e)!->
		
		e.prevent-default!
		if @is-processing!
			then return
			else @set-processing true
		
		ajax-req do
			url: @get-option \auth-url
			data:
				user: @ui.user.val!
				pass: @ui.pass.val!
			success: (json)!~>
				switch json.status
				| \success => @trigger-method \jsonSuccess, json
				| \error => @trigger-method \jsonError, json
				| _ =>
					new Error 'Unknown response JSON status'
					|> radio.commands.execute \police, \panic, _
				@set-processing false


module.exports = LoginFormView
