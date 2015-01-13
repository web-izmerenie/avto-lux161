/**
 * Pages View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\marionette : M
}

class PagesItemView extends M.ItemView
	tag-name: \li
	class-name: \list-group-item
	template: 'menu-item'

class PagesListView extends M.CollectionView
	tag-name: \ul
	class-name: \list-group
	child-view: PagesItemView

module.exports = PagesListView
