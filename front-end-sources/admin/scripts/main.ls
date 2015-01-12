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
}

M.TemplateCache.prototype.load-template = template.load
M.TemplateCache.prototype.compileTemplate = template.compile
M.Renderer.render = template.render

book = new B.Model {
	title: \Test
}

LoginFormView = M.LayoutView .extend {
	id: 'login-form'
	class-name: 'container'
	template: \login-form
	model: book
}

App = M.Application.extend {
	initialize: (options)!->
		@.login-form-view = new LoginFormView
		@.login-form-view.render!

		@ .add-regions container: options.container

	start: (options)!->
		B.history .start!
		@ .get-region \container .show @.login-form-view
}

app = new App container: \body
app .start!
