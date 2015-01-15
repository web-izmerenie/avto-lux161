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
		'panel/pages' : \pages-elements-list
		'panel/catalog' : \catalog-sections-list
		'panel/catalog/section_:id/' : \catalog-elements-list

		'*defaults' : \unknown # route not found

module.exports = AppRouter
