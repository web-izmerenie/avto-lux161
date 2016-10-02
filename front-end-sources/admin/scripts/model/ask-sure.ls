/**
 * AskSureModel
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\app/model/basic : { BasicModel }
}


export class AskSureModel extends BasicModel
	
	url: null
	
	defaults:
		message: null
	
	initialize: !->
		super ...
		unless (@get \message)?
			@set \message, _ <| @get \local .get \sure .msg
