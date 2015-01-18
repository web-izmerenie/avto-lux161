/**
 * Table Item View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone : B
	\marionette : M
}

class TableItemView extends M.ItemView
	tag-name: \tr
	ui:
		link: \a
	on-render: !->
		@$el.css \cursor, \pointer
		@$el.on \click (e)~>
			return false unless @$el? and @$el[0]?
			B.history.navigate (@ui.link.attr \href), trigger: true
			false
	on-destroy: !->
		return false unless @$el? and @$el[0]?
		@$el.off \click

module.exports = TableItemView
