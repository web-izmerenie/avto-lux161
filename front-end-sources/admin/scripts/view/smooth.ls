/**
 * Smooth View mixin
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone.marionette : { LayoutView }
}


class SmoothView extends LayoutView
	initialize: !-> @$el.css \opacity, 0
	on-before-show: !-> @$el.animate opacity: 1
	on-show: !-> void


module.exports = SmoothView
