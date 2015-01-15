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
	'../collection/panel-menu' : panel-menu-list
	'../view/login-form' : LoginFormView
	'../view/panel' : PanelView
	'../view/sections/pages/elements-list' : PagesElementsListView
	'../view/sections/catalog/sections-list' : CatalogSectionsListView
	'../view/sections/catalog/subsections-list' : CatalogSubSectionsListView
}

# TODO save url if unauthorized and go to this url after authorization

class AppRouterController extends M.Controller
	get-option: M.proxy-get-option

	main: !->
		if @get-option \app .is-auth
			B.history .navigate '#panel', { trigger: true, replace: true }
			return

		login-form-view = new LoginFormView app: @get-option \app
		login-form-view .render!

		@get-option \app .get-region \container .show login-form-view

	panel: !->
		unless @get-option \app .is-auth
			B.history .navigate '#', { trigger: true, replace: true }
			return

		if B.history.fragment is \panel
			# go to first menu item
			first-ref = panel-menu-list.toJSON![0].ref
			B.history .navigate first-ref, { trigger: true, replace: true }
			return

	\pages-elements-list : !->
		unless @get-option \app .is-auth
			B.history .navigate '#', { trigger: true, replace: true }
			return

		panel-view = (new PanelView!).render!
		pages-view = (new PagesElementsListView!).render!

		@get-option \app .get-region \container .show panel-view
		panel-view.get-option \work-area .show pages-view

	\catalog-sections-list : !->
		unless @get-option \app .is-auth
			B.history .navigate '#', { trigger: true, replace: true }
			return

		panel-view = (new PanelView!).render!
		catalog-view = (new CatalogSectionsListView!).render!

		@get-option \app .get-region \container .show panel-view
		panel-view.get-option \work-area .show catalog-view

	\catalog-subsections-list : (section-id)!->
		unless @get-option \app .is-auth
			B.history .navigate '#', { trigger: true, replace: true }
			return

		panel-view = (new PanelView!).render!
		catalog-view = new CatalogSubSectionsListView \section-id : section-id
		catalog-view.render!

		@get-option \app .get-region \container .show panel-view
		panel-view.get-option \work-area .show catalog-view

	unknown: !->
		W.radio.commands .execute \police, \panic,
			new Error 'Route not found'

module.exports = AppRouterController
