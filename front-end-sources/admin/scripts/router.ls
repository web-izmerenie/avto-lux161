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
		#'panel/catalog/section_:sid/:eid.html' : \catalog-elements-edit
		'panel/redirect' : \redirect-list
		'panel/accounts' : \accounts

		'logout' : \logout

		'*defaults' : \unknown # route not found

module.exports = AppRouter
