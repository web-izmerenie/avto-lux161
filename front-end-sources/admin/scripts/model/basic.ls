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
	
	url: ajax_data_url
	
	initialize: (attrs = null, options = {})!->
		
		super ...
		@options = {} <<< (_.result @, \options) <<< options
		
		new LocalizationModel! |> @set \local, _, { +silent }
		@changed = {}
	
	get-option: proxy-get-option
