/**
 * AskSureView
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\../model/basic : BasicModel
	\./smooth       : SmoothView
}


class AskSureView extends SmoothView
	initialize: (options)!->
		super ...
		@model = new BasicModel message: (options.message or null)
		unless (@model.get \message)?
			@model.set \message, _ <| @model.get \local .get \sure .msg
	template: \ask-sure
	ui:
		yes : \.btn.yes
		no  : \.btn.no
	events:
		'click @ui.yes' : \yes
		'click @ui.no'  : \no
	yes: (e)!->
		e.prevent-default! if e?prevent-default?
		@trigger \yes
	no: (e)!->
		e.prevent-default! if e?prevent-default?
		@destroy!


module.exports = AskSureView
