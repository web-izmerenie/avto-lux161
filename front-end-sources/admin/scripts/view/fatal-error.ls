/**
 * Fatal Error view
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\./smooth       : SmoothView
	\../model/basic : { BasicModel }
}


class FatalErrorView extends SmoothView
	initialize: (options)!->
		super ...
		@model = new BasicModel { options.exception ? '' }
	class-name: 'fatal-error container'
	template: \fatal-error


module.exports = FatalErrorView
