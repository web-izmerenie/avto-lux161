/**
 * Basic model
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone        : B
	'./localization' : LocalizationModel
}

class BasicModel extends B.Model
	initialize: !->
		super ...
		@set \local, new LocalizationModel!

module.exports = BasicModel
