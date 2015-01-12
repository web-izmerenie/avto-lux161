/**
 * Smooth View mixin
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\marionette : M
}

SmoothView = M.LayoutView .extend {
	initialize: !->
		@.$el .css \opacity, 0
	on-before-show: !->
		@.$el .animate opacity: 1
}

module.exports = SmoothView
