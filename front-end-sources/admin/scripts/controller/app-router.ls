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
		return unless auth-handler @

		panel-view = (new PanelView!).render!
		pages-view = (new PagesListView!).render!

		@get-option \app .get-region \container .show panel-view
		panel-view.get-option \work-area .show pages-view

	\add-page : !->
		return unless auth-handler @

		panel-view = (new PanelView!).render!
		view = (new AddPageView!).render!

		@get-option \app .get-region \container .show panel-view
		panel-view.get-option \work-area .show view

	\edit-page : (id)!->
		return unless auth-handler @

		panel-view = (new PanelView!).render!
		view = (new EditPageView id: id).render!

		@get-option \app .get-region \container .show panel-view
		panel-view.get-option \work-area .show view

	\catalog-sections-list : !->
		return unless auth-handler @

		panel-view = (new PanelView!).render!
		catalog-view = (new CatalogSectionsListView!).render!

		@get-option \app .get-region \container .show panel-view
		panel-view.get-option \work-area .show catalog-view

	\catalog-elements-list : (section-id)!->
		return unless auth-handler @

		panel-view = (new PanelView!).render!
		catalog-view = new CatalogElementsListView \section-id : section-id
		catalog-view.render!

		@get-option \app .get-region \container .show panel-view
		panel-view.get-option \work-area .show catalog-view

	\catalog-element-add : (sid)!->
		return unless auth-handler @

		panel-view = (new PanelView!).render!
		view = (new CatalogElementAddView {\section-id : sid}).render!

		@get-option \app .get-region \container .show panel-view
		panel-view.get-option \work-area .show view

	\catalog-element-edit : (sid, eid)!->
		return unless auth-handler @

		panel-view = (new PanelView!).render!
		view = (new CatalogElementEditView {\section-id : sid, id: eid}).render!

		@get-option \app .get-region \container .show panel-view
		panel-view.get-option \work-area .show view

	\redirect-list : !->
		return unless auth-handler @

		panel-view = (new PanelView!).render!
		redirect-view = (new RedirectListView!).render!

		@get-option \app .get-region \container .show panel-view
		panel-view.get-option \work-area .show redirect-view

	\add-redirect : !->
		return unless auth-handler @

		panel-view = (new PanelView!).render!
		view = (new AddRedirectView!).render!

		@get-option \app .get-region \container .show panel-view
		panel-view.get-option \work-area .show view

	\edit-redirect : (id)!->
		return unless auth-handler @

		panel-view = (new PanelView!).render!
		view = (new EditRedirectView id: id).render!

		@get-option \app .get-region \container .show panel-view
		panel-view.get-option \work-area .show view

	\accounts : !->
		return unless auth-handler @

		panel-view = (new PanelView!).render!
		accounts-view = (new AccountsListView!).render!

		@get-option \app .get-region \container .show panel-view
		panel-view.get-option \work-area .show accounts-view

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
