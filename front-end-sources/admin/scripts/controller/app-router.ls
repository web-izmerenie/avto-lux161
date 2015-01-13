/**
 * App Router Controller
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone : B
	\marionette : M
	\backbone.wreqr : W
	'../view/login-form' : LoginFormView
	'../view/panel' : PanelView
	'../collection/panel-menu' : panel-menu-list
}

# TODO save url if unauthorized and go to this url after authorization

class AppRouterController extends M.Controller
	get-option: M.proxy-get-option

	main: !->
		if @get-option \app .is-auth
			B.history .navigate '#panel', { trigger: true, replace: true }
			return

		unless @login-form-view?
			@login-form-view = new LoginFormView app: @get-option \app

		@login-form-view .render!
		@get-option \app .get-region \container .show @login-form-view

	panel: !->
		unless @get-option \app .is-auth
			B.history .navigate '#', { trigger: true, replace: true }
			return

		@panel-view.destroy! if @panel-view?

		# subrouting

		if B.history.fragment is \panel
			# go to first menu item
			first-ref = panel-menu-list.toJSON![0].ref
			B.history .navigate first-ref, { trigger: true, replace: true }
			return

		page = B.history.fragment
		panel-page =
			| (page .index-of 'panel/pages') is 0 => \pages
			| (page .index-of 'panel/catalog') is 0 => \catalog
			| _ => null

		unless panel-page?
			W.radio.commands .execute \police, \panic,
				new Error 'Subroute of panel not found'

		@panel-view = new PanelView {
			app: @get-option \app
			page: panel-page
		}
		@panel-view.render!
		@get-option \app .get-region \container .show @panel-view

	unknown: !->
		W.radio.commands .execute \police, \panic,
			new Error 'Route not found'

	on-destroy: !->
		@login-form-view .destroy! if @login-form-view?

module.exports = AppRouterController
