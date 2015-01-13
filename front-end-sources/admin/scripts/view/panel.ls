/**
 * Panel View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	'./smooth' : SmoothView
	'../model/basic' : BasicModel
}

PanelView = SmoothView .extend {
	initialize: !->
		SmoothView.prototype .initialize ...

	class-name: 'panel container'
	template: \panel
	model: new BasicModel!
}

module.exports = PanelView
