/**
 * Fatal Error view
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	'./smooth' : SmoothView
	'../model/basic' : BasicModel
}

class FatalErrorView extends SmoothView
	initialize: (options)!->
		SmoothView.prototype.initialize ...
		@.model = new BasicModel {
			exception: options.exception or ''
		}
	class-name: 'fatal-error container'
	template: \fatal-error

module.exports = FatalErrorView
