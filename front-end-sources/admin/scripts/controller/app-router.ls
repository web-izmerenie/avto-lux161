/**
 * App Router Controller
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery : $
	\backbone : B
	\marionette : M
	\backbone.wreqr : W
	'../view/login-form' : LoginFormView
	'../view/panel' : PanelView
}

# TODO save url if unauthorized and go to this url after authorization

AppRouterController = M.Controller.extend {
	get-option: M.proxy-get-option

	main: !->
		if @ .get-option \app .is-auth
			B.history .navigate '#panel', trigger: true
			return

		unless @.login-form-view?
			@.login-form-view = new LoginFormView app: @.get-option \app

		@.login-form-view .render!
		@ .get-option \app .get-region \container .show @.login-form-view

	panel: !->
		unless @ .get-option \app .is-auth
			B.history .navigate '#', trigger: true
			return

		unless @.panel-view?
			@.panel-view  = new PanelView app: @.get-option \app

		@.panel-view .render!
		@ .get-option \app .get-region \container .show @.panel-view

	unknown: !->
		W.radio.commands .execute \police, \panic,
			new Error 'Route not found'

	on-destroy: !->
		@.login-form-view .destroy! if @.login-form-view?
}

module.exports = AppRouterController
