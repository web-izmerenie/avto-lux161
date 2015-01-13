/**
 * Loader view
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	'../model/basic' : BasicModel
	'./smooth' : SmoothView
}

class LoaderView extends SmoothView
	class-name: 'loading container'
	template: \loader
	model: new BasicModel!

module.exports = LoaderView
