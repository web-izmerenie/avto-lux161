/**
 * App
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone : B
	\marionette : M
	\backbone.wreqr : W
	'./template-handlers'
	'./view/loader' : LoaderView
	'./view/login-form' : LoginFormView
}

App = M.Application.extend {
	container: \body
	get-option: M.proxy-get-option

	initialize: !->
		@.loader-view = new LoaderView
		@.loader-view.render!

		@.login-form-view = new LoginFormView
		@.login-form-view.render!

		@ .add-regions container: @.get-option \container

	start: (options)!->
		B.history .start!
		@ .get-region \container .show @.login-form-view

	on-destroy: !->
		B.history .stop!
		@.loader-view .destroy!
		@.login-form-view .destroy!
}

module.exports = App
