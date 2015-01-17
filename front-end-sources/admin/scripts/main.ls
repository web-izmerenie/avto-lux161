/**
 * admin interface application
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery : $
	\backbone : B

	'./config.json'
}
B.$ = $

<-! $ # dom ready

$html = $ \html

config.tinymce_options.script_url = $html .attr \data-tinymce-path

require! {
	\marionette : M
	\backbone.wreqr : W
	'./template-handlers'
	'./app' : App
	'./view/fatal-error' : FatalErrorView
	'./router' : AppRouter
	'./controller/app-router' : AppRouterController
}

M.TemplateCache.prototype.load-template = template-handlers.load
M.TemplateCache.prototype.compile-template = template-handlers.compile
M.Renderer.render = template-handlers.render

app = new App is-auth: ($ \html .attr \data-is-auth .to-string! is \1)

router-controller = new AppRouterController app: app
router = new AppRouter controller: router-controller

police = W.radio .channel \police

police.commands .set-handler \panic, (err)!->
	app .get-region \container .show new FatalErrorView exception: err
	app .destroy!
	router-controller .destroy!
	router := void
	throw err

app .start!
