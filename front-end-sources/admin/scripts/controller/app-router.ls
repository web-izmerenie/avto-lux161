/**
 * App Router Controller
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\marionette : M
	'../view/login-form' : LoginFormView
}

AppRouterController = M.Controller.extend {
	get-option: M.proxy-get-option

	main: !->
		@.login-form-view = new LoginFormView! unless @.login-form-view?

		@.login-form-view .render!
		@ .get-option \app .get-region \container .show @.login-form-view
}

module.exports = AppRouterController
