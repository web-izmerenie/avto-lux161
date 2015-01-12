/**
 * main admin interface module
 *
 * @author Viacheslav Lotsmanov
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
	'./template': template
}

M.TemplateCache.prototype.load-template = template.load
M.TemplateCache.prototype.compileTemplate = template.compile
M.Renderer.render = template.render

LoginFormView = M.LayoutView .extend {
	id: 'login-form'
	class-name: 'container'
	template: \login-form
}

App = M.Application.extend {
	initialize: (options)!->
		@.login-form-view = new LoginFormView
		@.login-form-view.render title: \lololo

		@ .add-regions container: options.container

	start: (options)!->
		B.history .start!
		@ .get-region \container .show @.login-form-view
}

app = new App container: \body
app .start!
