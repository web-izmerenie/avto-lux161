/**
 * Panel menu view
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone            : B
	\backbone.marionette : M
}

class PanelMenuItemView extends M.ItemView
	template: \menu-item
	tag-name: \li

class PanelMenuListView extends M.CollectionView
	tag-name: \ul
	class-name: 'nav nav-pills nav-stacked'
	child-view: PanelMenuItemView
	child-view-options: (model, index)->
		page = B.history.fragment
		ref = model.get \ref .slice 1
		class-name: \active if (page.index-of ref) is 0

module.exports = PanelMenuListView
