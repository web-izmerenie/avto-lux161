/**
 * admin interface application
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery : $
	\backbone : B
}
B.$ = $

<-! $ # dom ready

$html = $ \html

require! {
	\marionette : M
	'./template'
	'./ajax-req'
	'./model/basic' : BasicModel
	'./model/localization' : Localization
	'./view/smooth' : SmoothView
	'./throw-fatal-error'
}

M.TemplateCache.prototype.load-template = template.load
M.TemplateCache.prototype.compileTemplate = template.compile
M.Renderer.render = template.render

localization = new Localization!

LoaderView = SmoothView .extend {
	class-name: 'loading container'
	template: \loader
	model: new BasicModel!
}

LoginFormErrorView = SmoothView .extend {
	initialize: (options)!->
		SmoothView.prototype.initialize ...
		@.model = new BasicModel {
			message: options.message or ''
		}
	template: \err-msg
}

LoginFormView = SmoothView .extend {
	initialize: !->
		SmoothView.prototype.initialize ...
		@.process = false
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
		return false if @.process
		@.process = true

		ajax-req app, {
			url: '/adm/auth/'
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
						throw-fatal-error app, new Error 'Unknown "error_code"'

					err-view = new LoginFormErrorView {
						message: localization .get \forms .err[json.error_code]
					}
					@.get-region \message .show err-view
				| _ => throw-fatal-error app, new Error 'Unknown response JSON status'
				@.process = false
		}

		false
}

App = M.Application.extend {
	initialize: (options)!->
		@.loader-view = new LoaderView
		@.loader-view.render!

		@.login-form-view = new LoginFormView
		@.login-form-view.render!

		@ .add-regions container: options.container

	start: (options)!->
		B.history .start!
		@ .get-region \container .show @.login-form-view
}

app = new App container: \body
app .start!
