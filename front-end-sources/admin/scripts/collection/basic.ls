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
}


export class BasicCollection extends Collection
	
	get-option: proxy-get-option
	
	initialize: (models=null, options={})!->
		super ...
		@options = {} <<< (_.result @, \options) <<< options
		@cid = _.unique-id \BasicCollection