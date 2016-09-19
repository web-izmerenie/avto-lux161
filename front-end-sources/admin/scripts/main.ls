/**
 * admin interface application
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery              : $
	\backbone            : B
	\backbone.marionette : { TemplateCache, Renderer }
	\backbone.wreqr      : { radio }
	
	# just to check if config file exists
	\./config.json       : {}
}


police = radio.channel \police

B.$ = $

# must be declared here, before any project modules requiring,
# because they can create new instances of models as static or
# prototype properties that in tern can immidiately call
# `.fetch` method skipping this middleware.
B.ajax = (opts)->
	B.$.ajax {} <<< opts <<< do
		cache        : opts.force-cache  ? off
		type         : opts.force-method ? \POST
		method       : opts.force-method ? \POST
		data-type    : \json
		content-type : 'application/x-www-form-urlencoded; charset=UTF-8'
		parse        : on
		process-data : on
		error: (xhr, status, err)!->
			return if status is \abort
			police.commands.execute \panic, err

require! {
	\./model/localization : LocalizationModel
}

# caching localization data
<-! (!-> new LocalizationModel! .fetch success: it)

<-! $ # dom ready

$html = $ \html

require! {
	\./template-handlers
	\./app                   : App
	\./view/fatal-error      : FatalErrorView
	\./router                : AppRouter
	\./controller/app-router : AppRouterController
}

TemplateCache::load-template = template-handlers.load
TemplateCache::compile-template = template-handlers.compile
Renderer.render = template-handlers.render

app = new App do
	is-auth: ($ \html .attr \data-is-auth .to-string! is \1)
	container: \.main-page-container

router-controller = new AppRouterController app: app
router = new AppRouter controller: router-controller

police.commands.set-handler \panic, (err)!->
	app.get-region \container .show new FatalErrorView exception: err
	app.destroy!
	router-controller.destroy!
	router := void
	throw err

app.start!
