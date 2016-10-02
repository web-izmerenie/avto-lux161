/**
 * Elements list collection
 * to fetch elements from server
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\underscore             : _
	\backbone.marionette    : { proxy-get-option }
	
	\app/collection/basic   : { BasicCollection }
	
	\app/config.json        : { ajax_data_url }
	\app/utils/panic-attack : { panic-attack }
}


export class ElementsListCollection extends BasicCollection
	
	url: ajax_data_url
	action: null # must be overwritten by child class or by option
	
	parse: (response)->
		try
			if response.status is not \success or not response.data_list?
				throw new Error 'Incorrect server data'
			response.data_list
		catch
			panic-attack e
	
	fetch: (opts={})->
		try
			action = @get-option \action
			
			unless typeof! action is \String
				throw new Error '@action must be overwritten'
			
			data = { action } <<< (opts.data ? {})
			super {} <<< opts <<< { data }
		catch
			panic-attack e
