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
		'panel/pages' : \panel
		'panel/catalog' : \panel
		'panel/redirect' : \panel

		'*defaults' : \unknown # route not found

module.exports = AppRouter
