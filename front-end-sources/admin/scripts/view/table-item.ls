/**
 * Table Item View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone            : { history }
	\backbone.marionette : { ItemView }
}


class TableItemView extends ItemView
	
	tag-name: \tr
	
	ui:
		link: \a
	
	events:
		click: \on-row-click
	
	on-render: !->
		super? ...
		@$el.css \cursor, \pointer
	
	\on-row-click : (e)!->
		e.prevent-default!
		history.navigate _, { +trigger } <| @ui.link.attr \href


module.exports = TableItemView
