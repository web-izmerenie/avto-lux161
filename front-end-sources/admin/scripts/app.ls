/**
 * App
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone : B
	\marionette : M
	'./view/loader' : LoaderView
	'./router' : AppRouter
	'./controller/app-router' : AppRouterController
}

App = M.Application.extend {
	container: \body
	get-option: M.proxy-get-option

	initialize: !->
		@.loader-view = new LoaderView
		@.loader-view.render!

		@ .add-regions container: @.get-option \container

		@.router-controller = new AppRouterController app: @
		@.router = new AppRouter app: @, controller: @.router-controller

	start: (options)!->
		B.history .start push-state: true

	on-destroy: !->
		B.history .stop!
		@.loader-view .destroy!
		@.login-form-view .destroy!
}

module.exports = App
