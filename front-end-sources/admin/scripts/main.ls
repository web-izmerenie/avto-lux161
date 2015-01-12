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
	'./basic-model' : BasicModel
	'./smooth-view' : SmoothView
	'./ajax-req'
}

M.TemplateCache.prototype.load-template = template.load
M.TemplateCache.prototype.compileTemplate = template.compile
M.Renderer.render = template.render

LoaderView = SmoothView .extend {
	class-name: 'loading container'
	template: \loader
	model: new BasicModel!
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
	events:
		'submit @ui.form': \form-handler
	\form-handler : ->
		return false if @.process
		@.process = true

		ajax-req app, {
			url: '/adm/auth/'
			data:
				...
			success: (json)!->
				void
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
