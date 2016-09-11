/**
 * Panel menu view
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone            : { history }
	\backbone.marionette : { ItemView, CollectionView }
}


class PanelMenuItemView extends ItemView
	template: \menu-item
	tag-name: \li


class PanelMenuListView extends CollectionView
	tag-name: \ul
	class-name: 'nav nav-pills nav-stacked'
	child-view: PanelMenuItemView
	child-view-options: (model, index)->
		page = history.fragment
		ref = model.get \ref .slice 1
		class-name: if (page.index-of ref) is 0 then \active else ''


module.exports = PanelMenuListView
