/**
 * Error Message View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\../model/basic : BasicModel
	\./smooth       : SmoothView
}


class ErrorMessageView extends SmoothView
	initialize: (options)!->
		super ...
		@model = new BasicModel message: (options.message or '')
	template: \err-msg


module.exports = ErrorMessageView
