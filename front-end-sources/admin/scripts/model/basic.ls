/**
 * Basic model
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone : B
	'./localization' : Localization
}

BasicModel = B.Model.extend {
	initialize: !->
		@ .set \local, new Localization!
}

module.exports = BasicModel
