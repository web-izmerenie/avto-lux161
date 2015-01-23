/**
 * AskSureView
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\marionette : M
	'../model/basic' : BasicModel
	'./smooth' : SmoothView
}

class AskSureView extends SmoothView
	initialize: (options)!->
		SmoothView.prototype.initialize ...
		@model = new BasicModel message: options.message or null
		unless (@model.get \message)?
			@model.set \message, (@model.get \local .get \sure .msg)
	template: \ask-sure
	ui:
		yes: \.btn.yes
		no: \.btn.no
	events:
		'click @ui.yes': \yes
		'click @ui.no': \no
	yes: ->
		@trigger \yes
		false
	no: ->
		@destroy!
		false

module.exports = AskSureView

