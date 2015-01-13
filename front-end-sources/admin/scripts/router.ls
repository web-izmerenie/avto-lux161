/**
 * App Router
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\marionette : M
}

AppRouter = M.AppRouter.extend {
	app-routes:
		'' : \main
		'panel' : \panel
		'*defaults' : \unknown
}

module.exports = AppRouter
