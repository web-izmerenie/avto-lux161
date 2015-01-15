/**
 * Panel View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\marionette : M
	'../model/basic' : BasicModel
	'../view/panel-menu' : PanelMenuListView
	'../collection/panel-menu' : panel-menu-list
}

class PanelView extends M.LayoutView
	initialize: !->
		@menu-list-view = new PanelMenuListView collection: panel-menu-list
		@menu-list-view.render!

	on-show: !->
		@get-region \menu .show @menu-list-view

	class-name: 'panel-view container'
	template: \panel
	model: new BasicModel!
	regions:
		\menu : \.panel-menu
		\work-area : \.work-area

module.exports = PanelView
