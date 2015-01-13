/**
 * App
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone : B
	\marionette : M
	'./view/loader' : LoaderView
}

App = M.Application.extend {
	get-option: M.proxy-get-option

	container: \body
	is-auth: false

	initialize: !->
		@.loader-view = new LoaderView
		@.loader-view.render!

		@ .add-regions container: @.get-option \container

	start: (options)!->
		B.history .start root: '/adm/'

	on-destroy: !->
		B.history .stop!
		@.loader-view .destroy!
}

module.exports = App
