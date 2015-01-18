/**
 * App Router
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\marionette : M
}

class AppRouter extends M.AppRouter
	app-routes:
		'' : \main # login form

		'panel' : \panel
		'panel/pages' : \pages-list
		'panel/pages/add.html' : \add-page
		'panel/pages/edit_:id.html' : \edit-page
		'panel/catalog' : \catalog-sections-list
		'panel/catalog/section_:id/' : \catalog-elements-list
		'panel/catalog/section_:sid/add.html' : \catalog-element-add
		'panel/catalog/section_:sid/edit_:eid.html' : \catalog-element-edit
		'panel/redirect' : \redirect-list
		'panel/redirect/add.html' : \add-redirect
		'panel/redirect/edit_:id.html' : \edit-redirect
		'panel/accounts' : \accounts

		'logout' : \logout

		'*defaults' : \unknown # route not found

module.exports = AppRouter
