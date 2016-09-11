/**
 * Panel View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone.marionette      : { LayoutView }
	
	\../model/basic           : BasicModel
	\../view/panel-menu       : PanelMenuListView
	\../collection/panel-menu : panel-menu-list
}


class PanelView extends LayoutView
	
	initialize: !->
		@menu-list-view =
			new PanelMenuListView collection: panel-menu-list .render!
	
	on-show: !->
		@get-region \menu .show @menu-list-view
	
	class-name: 'panel-view container'
	template: \panel
	model: new BasicModel!
	regions:
		\menu      : \.panel-menu
		\work-area : \.work-area


module.exports = PanelView
