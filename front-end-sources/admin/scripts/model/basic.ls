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
		@ .set \local, new LocalizationModel!

module.exports = BasicModel
