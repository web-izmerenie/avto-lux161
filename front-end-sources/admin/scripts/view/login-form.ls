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
	'../ajax-req'
}

localization-model = new LocalizationModel!

class LoginFormErrorView extends SmoothView
	initialize: (options)!->
		SmoothView.prototype.initialize ...
		@.model = new BasicModel {
			message: options.message or ''
		}
	template: \err-msg

class LoginFormView extends SmoothView
	\auth-url : '/adm/auth' # TODO try get with prefix from B
	get-option: M.proxy-get-option

	initialize: !->
		SmoothView.prototype.initialize ...

	on-show: !->
		# temporary for development
		@ui.user.val \admin
		@ui.pass.val \admin
		@ui.form.submit!

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

		err-view = new LoginFormErrorView {
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
