/**
 * admin interface application
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery : $
	\backbone : B
}
B.$ = $

<-! $ # dom ready

$html = $ \html

require! {
	\marionette : M
	\backbone.wreqr : W
	'./template-handlers'
	'./app' : App
	'./view/fatal-error' : FatalErrorView
}

M.TemplateCache.prototype.load-template = template-handlers.load
M.TemplateCache.prototype.compile-template = template-handlers.compile
M.Renderer.render = template-handlers.render

app = new App!

police = W.radio .channel \police

police.commands .set-handler \panic, (err)!->
	app .get-region \container .show new FatalErrorView exception: err
	app .destroy!
	throw err

app .start!
