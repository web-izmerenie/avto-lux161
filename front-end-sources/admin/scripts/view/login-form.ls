/**
 * LoginForm view
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\marionette : M
	\backbone.wreqr : W
	'../model/basic' : BasicModel
	'../model/localization' : Localization
	'./smooth' : SmoothView
	'./loader' : LoaderView
	'../ajax-req'
}

localization = new Localization!

LoginFormErrorView = SmoothView .extend {
	initialize: (options)!->
		SmoothView.prototype.initialize ...
		@.model = new BasicModel {
			message: options.message or ''
		}
	template: \err-msg
}

LoginFormView = SmoothView .extend {
	auth-url: '/adm/auth/'
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

	\form-handler : ->
		return false if @.is-processing!
		@ .set-processing true

		app = void
		ajax-req {
			url: @ .get-option \auth-url
			data:
				user: @.ui.user .val!
				pass: @.ui.pass .val!
			success: (json)!~>
				switch json.status
				| \success =>
					void
				| \error =>
					if not json.error_code?
					or not (json.error_code |> (in <[ user_not_found incorrect_password ]>))
						W.radio.commands .execute \police, \panic, new Error 'Unknown "error_code"'

					err-view = new LoginFormErrorView {
						message: localization .get \forms .err[json.error_code]
					}
					@ .get-region \message .show err-view
				| _ => W.radio.commands .execute \police, \panic, new Error 'Unknown response JSON status'
				@ .set-processing false
		}

		false
}

module.exports = LoginFormView
