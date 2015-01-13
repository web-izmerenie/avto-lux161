/**
 * Smooth View mixin
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\marionette : M
}

class SmoothView extends M.LayoutView
	initialize: !->
		@.$el .css \opacity, 0
	on-before-show: !->
		@.$el .animate opacity: 1

module.exports = SmoothView
