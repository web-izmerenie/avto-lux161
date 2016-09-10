/**
 * Elements list collection
 * to fetch elements from server
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\underscore          : _
	\backbone            : { Collection }
	\backbone.marionette : { proxy-get-option }
	\backbone.wreqr      : { radio }
	
	\../config.json      : { ajax_data_url }
}


class ElementsListCollection extends Collection
	
	get-option: proxy-get-option
	
	initialize: (models=null, options={})!->
		super ...
		@options = {} <<< (_.result @, \options) <<< options
	
	url: ajax_data_url
	action: null # must be overwritten by child class or by option
	
	parse: (response)->
		try
			if response.status is not \success or not response.data_list?
				throw new Error 'Incorrect server data'
			response.data_list
		catch
			radio.commands.execute \police, \panic, e
			throw e
	
	fetch: (opts={})->
		try
			action = @get-option \action
			
			unless typeof! action is \String
				throw new Error '@action must be overwritten'
			
			data = { action } <<< (opts.data ? {})
			super {} <<< opts <<< { data }
		catch
			radio.commands.execute \police, \panic, e
			throw e


module.exports = ElementsListCollection
