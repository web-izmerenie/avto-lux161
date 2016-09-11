/**
 * Basic model
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\underscore          : _
	\backbone            : { Model }
	\backbone.marionette : { proxy-get-option }
	
	'./localization'     : LocalizationModel
}


class BasicModel extends Model
	
	initialize: (attrs=null, options={})!->
		super ...
		@options = {} <<< (_.result @, \options) <<< options
		@set \local, new LocalizationModel!
	
	get-option: proxy-get-option


module.exports = BasicModel
