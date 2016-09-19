/**
 * AskSureModel
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\./basic : BasicModel
}


class AskSureModel extends BasicModel
	
	defaults:
		message: null
	
	initialize: !->
		super ...
		unless (@get \message)?
			@set \message, _ <| @get \local .get \sure .msg


module.exports = AskSureModel
