/**
 * App Router
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone.marionette : M
}

class AppRouter extends M.AppRouter
	app-routes:
		''                                          : \main # login form
		
		'panel'                                     : \panel
		'panel/pages'                               : \pages-list
		'panel/pages/add.html'                      : \add-page
		'panel/pages/edit_:id.html'                 : \edit-page
		'panel/catalog'                             : \catalog-sections-list
		'panel/catalog/section_:id/'                : \catalog-elements-list
		'panel/catalog/add_section.html'            : \catalog-section-add
		'panel/catalog/section_:sid/edit.html'      : \catalog-section-edit
		'panel/catalog/section_:sid/add.html'       : \catalog-element-add
		'panel/catalog/section_:sid/edit_:eid.html' : \catalog-element-edit
		'panel/redirect'                            : \redirect-list
		'panel/redirect/add.html'                   : \add-redirect
		'panel/redirect/edit_:id.html'              : \edit-redirect
		'panel/data'                                : \data-list
		'panel/data/add.html'                       : \add-data
		'panel/data/edit_:eid.html'                 : \edit-data
		'panel/accounts'                            : \accounts
		'panel/accounts/add.html'                   : \account-add
		'panel/accounts/edit_:id.html'              : \account-edit
		
		'logout'                                    : \logout
		
		'*defaults'                                 : \unknown # route not found

module.exports = AppRouter
