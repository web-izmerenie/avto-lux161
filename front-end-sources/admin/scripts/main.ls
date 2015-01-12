/**
 * main admin interface module
 *
 * @author Viacheslav Lotsmanov
 */

require! {
	\jquery : $
	\backbone : B
}

B.$ = $

require! \marionette : M

My-App = new M.Application

My-App .add-initializer (options)!->
	B.history .start!

My-App .start!
