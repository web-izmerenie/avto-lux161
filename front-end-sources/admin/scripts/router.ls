/**
 * App Router
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\marionette : M
}

pfx = 'adm/'

AppRouter = M.AppRouter.extend {
	get-option: M.proxy-get-option

	app: null
	app-routes:
		(pfx) : \main
}

module.exports = AppRouter
