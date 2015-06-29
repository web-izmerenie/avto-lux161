/**
 * LoginForm view
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone : B
	\marionette : M
	\backbone.wreqr : W
	'../model/basic' : BasicModel
	'../model/localization' : LocalizationModel
	'./smooth' : SmoothView
	'./loader' : LoaderView
	'./error-msg' : ErrorMessageView
	'../ajax-req'
}

# TODO remove this
localization-model = new LocalizationModel!

class LoginFormView extends SmoothView
	\auth-url : '/adm/auth' # TODO try get with prefix from B
	get-option: M.proxy-get-option
	
	initialize: !->
		SmoothView.prototype.initialize ...
	
	process: false
	set-processing: (b)!-> @.process = b
	is-processing: -> @.process
	
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
		'submit @ui.form': \form-handler
	
	on-json-error : (json)!->
		if not json.error_code?
		or not (json.error_code |> (in <[ user_not_found incorrect_password ]>))
			W.radio.commands .execute \police, \panic,
				new Error 'Unknown "error_code"'
		
		err-view = new ErrorMessageView {
			message: localization-model .get \forms .err[json.error_code]
		}
		@ .get-region \message .show err-view
	
	on-json-success : (json)!->
		@ .get-option \app .is-auth = true
		B.history .navigate '#panel', { trigger: true, replace: true }
	
	\form-handler : ->
		return false if @.is-processing!
		@ .set-processing true
		
		ajax-req {
			url: @ .get-option \auth-url
			data:
				user: @.ui.user .val!
				pass: @.ui.pass .val!
			success: (json)!~>
				switch json.status
				| \success => @ .trigger-method \jsonSuccess, json
				| \error => @ .trigger-method \jsonError, json
				| _ => W.radio.commands .execute \police, \panic,
					new Error 'Unknown response JSON status'
				@ .set-processing false
		}
		
		false

module.exports = LoginFormView
