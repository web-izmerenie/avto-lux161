/**
 * App Router Controller
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone                               : { history }
	\backbone.marionette                    : { Controller, proxy-get-option }
	\backbone.wreqr                         : { radio }
	
	\../config.json                         : { logout_url }
	\../ajax-req
	
	\../collection/panel-menu               : panel-menu-list
	\../view/login-form                     : LoginFormView
	\../view/panel                          : PanelView
	\../view/sections/pages/list            : PagesListView
	\../view/sections/pages/add             : AddPageView
	\../view/sections/pages/edit            : EditPageView
	\../view/sections/catalog/sections-list : CatalogSectionsListView
	\../view/sections/catalog/section-add   : CatalogSectionAddView
	\../view/sections/catalog/section-edit  : CatalogSectionEditView
	\../view/sections/catalog/elements-list : CatalogElementsListView
	\../view/sections/catalog/element-add   : CatalogElementAddView
	\../view/sections/catalog/element-edit  : CatalogElementEditView
	\../view/sections/redirect/list         : RedirectListView
	\../view/sections/redirect/add          : AddRedirectView
	\../view/sections/redirect/edit         : EditRedirectView
	\../view/sections/data/list             : DataListView
	\../view/sections/data/add              : AddDataView
	\../view/sections/data/edit             : EditDataView
	\../view/sections/accounts/list         : AccountsListView
	\../view/sections/accounts/add          : AddAccountView
	\../view/sections/accounts/edit         : EditAccountView
}


police = radio.channel \police


# semaphore {{{

stop-counter = 0
stop-last-page = null

police.commands.set-handler \request-stop, !->
	stop-counter++
	if stop-counter is 1
		stop-last-page := history.fragment

police.commands.set-handler \request-free, !->
	stop-counter--
	if stop-counter is 0
		stop-last-page := null
	if stop-counter < 0
		throw new Error 'stop-counter cannot be less than zero'

restore-last-page = ->
	return true if stop-counter <= 0
	unless stop-last-page?
		throw new Error 'stop-last-page must be a string'
	history.navigate "\##stop-last-page", { +replace }
	false

# semaphore }}}


class AppRouterController extends Controller
	
	get-option: proxy-get-option
	
	\main : !->
		
		return unless restore-last-page!
		
		if @get-option \app .is-auth
			history.navigate \#panel, { +trigger, +replace }
			return
		
		login-form-view = new LoginFormView app: @get-option \app .render!
		
		@get-option \app .get-region \container .show login-form-view
	
	\panel : !->
		
		return if not restore-last-page! or not @auth-handler!
		
		if history.fragment is \panel
			# go to first menu item
			first-ref = panel-menu-list.toJSON![0].ref
			history.navigate first-ref, { +trigger, +replace }
	
	\pages-list : !->
		@panel-page-handler <| new PagesListView! .render!
	\add-page : !->
		@panel-page-handler <| new AddPageView! .render!
	\edit-page : (id)!->
		@panel-page-handler <| new EditPageView {id} .render!
	
	\catalog-sections-list : !->
		@panel-page-handler <| new CatalogSectionsListView! .render!
	\catalog-section-add : !->
		@panel-page-handler <| new CatalogSectionAddView! .render!
	\catalog-section-edit : (sid)!->
		new CatalogSectionEditView {\section-id : sid, id: sid} .render!
		|> @panel-page-handler
	
	\catalog-elements-list : (sid)!->
		new CatalogElementsListView {\section-id : sid} .render!
		|> @panel-page-handler
	\catalog-element-add : (sid)!->
		new CatalogElementAddView {\section-id : sid} .render!
		|> @panel-page-handler
	\catalog-element-edit : (sid, eid)!->
		new CatalogElementEditView {\section-id : sid, id: eid} .render!
		|> @panel-page-handler
	
	\redirect-list : !->
		@panel-page-handler <| new RedirectListView! .render!
	\add-redirect : !->
		@panel-page-handler <| new AddRedirectView! .render!
	\edit-redirect : (id)!->
		@panel-page-handler <| new EditRedirectView {id} .render!
	
	\data-list : !->
		@panel-page-handler <| new DataListView! .render!
	\add-data : !->
		@panel-page-handler <| new AddDataView! .render!
	\edit-data : (id)!->
		@panel-page-handler <| new EditDataView {id} .render!
	
	\accounts : !->
		@panel-page-handler <| new AccountsListView! .render!
	\account-add : !->
		@panel-page-handler <| new AddAccountView! .render!
	\account-edit : (id)!->
		@panel-page-handler <| new EditAccountView {id} .render!
	
	\logout : !->
		
		return if not restore-last-page! or not @auth-handler false
		
		ajax-req do
			url: logout_url
			success: (json)!~>
				
				unless json.status is \logout
					police.commands.execute \panic, new Error 'Logout error'
				
				@get-option \app .is-auth = false
				history.navigate \#, { +trigger, +replace }
	
	\unknown : !->
		return unless restore-last-page!
		police.commands.execute \panic, new Error 'Route not found'
	
	
	auth-handler: (store-ref=true)->
		| not @get-option \app .is-auth =>
			@store-ref = history.fragment if store-ref
			history.navigate \#, { +trigger, +replace }
			false
		| @store-ref? =>
			ref = delete @store-ref
			history.navigate "##ref", { +trigger, +replace }
			false
		| otherwise => true
	
	panel-page-handler: (view)!->
		
		return if not restore-last-page! or not @auth-handler!
		
		panel-view = new PanelView! .render!
		
		@get-option \app .get-region \container .show panel-view
		panel-view.get-option \work-area .show view


module.exports = AppRouterController
