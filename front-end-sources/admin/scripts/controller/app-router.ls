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

	'../config.json' : config
	'../ajax-req'

	'../collection/panel-menu' : panel-menu-list
	'../view/login-form' : LoginFormView
	'../view/panel' : PanelView
	'../view/sections/pages/list' : PagesListView
	'../view/sections/pages/add' : AddPageView
	'../view/sections/pages/edit' : EditPageView
	'../view/sections/catalog/sections-list' : CatalogSectionsListView
	'../view/sections/catalog/elements-list' : CatalogElementsListView
	'../view/sections/catalog/element-add' : CatalogElementAddView
	'../view/sections/catalog/element-edit' : CatalogElementEditView
	'../view/sections/redirect/list' : RedirectListView
	'../view/sections/redirect/add' : AddRedirectView
	'../view/sections/redirect/edit' : EditRedirectView
	'../view/sections/accounts/list' : AccountsListView
}

auth-handler = (obj, store-ref=true)->
	unless obj.get-option \app .is-auth
		obj.store-ref = B.history.fragment if store-ref
		B.history.navigate '#', { trigger: true, replace: true }
		return false
	else if obj.store-ref?
		ref = delete obj.store-ref
		B.history.navigate "##ref", { trigger: true, replace: true }
		return false

	true

panel-page-handler = (controller, view)->
	return unless auth-handler controller

	panel-view = (new PanelView!).render!

	controller.get-option \app .get-region \container .show panel-view
	panel-view.get-option \work-area .show view

class AppRouterController extends M.Controller
	get-option: M.proxy-get-option

	\main : !->
		if @get-option \app .is-auth
			B.history .navigate '#panel', { trigger: true, replace: true }
			return

		login-form-view = new LoginFormView app: @get-option \app
		login-form-view .render!

		@get-option \app .get-region \container .show login-form-view

	\panel : !->
		return unless auth-handler @

		if B.history.fragment is \panel
			# go to first menu item
			first-ref = panel-menu-list.toJSON![0].ref
			B.history .navigate first-ref, { trigger: true, replace: true }
			return

	\pages-list : !->
		panel-page-handler @, (new PagesListView!).render!

	\add-page : !->
		panel-page-handler @, (new AddPageView!).render!

	\edit-page : (id)!->
		panel-page-handler @, (new EditPageView id: id).render!

	\catalog-sections-list : !->
		panel-page-handler @, (new CatalogSectionsListView!).render!

	\catalog-elements-list : (section-id)!->
		view = (new CatalogElementsListView \section-id : section-id).render!
		panel-page-handler @, view

	\catalog-element-add : (sid)!->
		view = (new CatalogElementAddView {\section-id : sid}).render!
		panel-page-handler @, view

	\catalog-element-edit : (sid, eid)!->
		view = (new CatalogElementEditView {\section-id : sid, id: eid}).render!
		panel-page-handler @, view

	\redirect-list : !->
		panel-page-handler @, (new RedirectListView!).render!

	\add-redirect : !->
		panel-page-handler @, (new AddRedirectView!).render!

	\edit-redirect : (id)!->
		panel-page-handler @, (new EditRedirectView id: id).render!

	\accounts : !->
		panel-page-handler @, (new AccountsListView!).render!

	\logout : !->
		return unless auth-handler @, false

		ajax-req {
			url: config.logout_url
			success: (json)!~>
				unless json.status is \logout
					W.radio.commands .execute \police, \panic,
						new Error 'Logout error'

				@get-option \app .is-auth = false
				B.history.navigate '#', { trigger: true, replace: true }
		}

	\unknown : !->
		W.radio.commands .execute \police, \panic,
			new Error 'Route not found'

module.exports = AppRouterController
