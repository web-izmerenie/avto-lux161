/**
 * Error Message View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\marionette : M
	'../model/basic' : BasicModel
	'./smooth' : SmoothView
}

class ErrorMessageView extends SmoothView
	initialize: (options)!->
		SmoothView.prototype.initialize ...
		@model = new BasicModel message: options.message or ''
	template: \err-msg

module.exports = ErrorMessageView
