/**
 * Basic model
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\underscore             : _
	\backbone               : { Model }
	\backbone.marionette    : { proxy-get-option }
	
	\app/model/localization : { LocalizationModel }
	
	\app/config.json        : { ajax_data_url }
}


export class BasicModel extends Model
	
	(attrs = {}, opts = {})!->
		
		attrs = { local: new LocalizationModel! }
			<<< (if opts.parse then @parse attrs, opts else attrs)
		
		@options = {} <<< (_.result @, \options) <<< opts
		
		super? attrs, {} <<< @options <<< { -parse }
	
	url: ajax_data_url
	
	get-option: proxy-get-option
