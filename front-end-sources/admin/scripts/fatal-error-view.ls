require! {
	'./smooth-view' : SmoothView
	'./basic-model' : BasicModel
}

FatalErrorView = SmoothView .extend {
	initialize: (options)!->
		SmoothView.prototype.initialize ...
		@.model = new BasicModel {
			exception: options.exception or ''
		}
	class-name: 'fatal-error container'
	template: \fatal-error
}

module.exports = FatalErrorView
