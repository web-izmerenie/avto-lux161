/**
 * admin interface application
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery   : $
	\backbone : B
	
	\./config.json
}
B.$ = $

<-! $ # dom ready

$html = $ \html

require! {
	\backbone.marionette     : M
	\backbone.wreqr          : W
	
	\./template-handlers
	\./app                   : App
	\./view/fatal-error      : FatalErrorView
	\./router                : AppRouter
	\./controller/app-router : AppRouterController
}

M.TemplateCache.prototype.load-template = template-handlers.load
M.TemplateCache.prototype.compile-template = template-handlers.compile
M.Renderer.render = template-handlers.render

app = new App do
	is-auth: ($ \html .attr \data-is-auth .to-string! is \1)
	container: \.main-page-container

router-controller = new AppRouterController app: app
router = new AppRouter controller: router-controller

police = W.radio.channel \police

police.commands.set-handler \panic, (err)!->
	app.get-region \container .show new FatalErrorView exception: err
	app.destroy!
	router-controller.destroy!
	router := void
	throw err

B.ajax = (opts)-> B.$.ajax do
	{} <<< opts <<< {
		-cache
		type      : \POST
		method    : \POST
		data-type : \json
		error: (xhr, status, err)!->
			return if status is \abort
			W.radio.commands.execute \police, \panic, err
	}

app .start!
