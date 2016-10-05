/**
 * Panel View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone.marionette       : { LayoutView }
	\backbone.wreqr            : { radio }
	
	\app/model/basic           : { BasicModel }
	\app/collection/panel-menu : { panel-menu-list }
	
	\app/view/panel-menu       : PanelMenuListView
}


authentication = radio.channel \authentication


class UsernameView extends LayoutView
	
	initialize: !->
		
		super? ...
		
		@model = new BasicModel do
			username: authentication.reqres.request \username
		
		@listen-to authentication.vent, \username, !-> @model.set \username, it
		@listen-to @model, \change, @render
	
	class-name: \auth-username-block
	template: \panel-username


class PanelView extends LayoutView
	
	initialize: !->
		super? ...
		@menu-list-view =
			new PanelMenuListView collection: panel-menu-list .render!
		@username-view =
			new UsernameView! .render!
	
	on-show: !->
		super? ...
		@get-region \username .show @username-view
		@get-region \menu     .show @menu-list-view
	
	class-name: 'panel-view container'
	template: \panel
	model: new BasicModel!
	regions:
		\menu      : \.panel-menu
		\username  : \.auth-username
		\work-area : \.work-area


module.exports = PanelView
