/**
 * Ordering elements list model
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone.wreqr : { radio }
	
	\./basic        : BasicModel
	\../config.json : { ajax_data_url }
}


panic-attack = (err)!->
	radio.commands.execute \police, \panic, err
	throw err


class OrderingElementsItemModel extends BasicModel
	
	action: null # must be overwritten (can be overwritten by options)
	url: ajax_data_url
	
	put-at: (at-model)!-> @sync \update, @, do
		data:
			action: @get-option \action
			args: JSON.stringify do
				at_id: at-model.id
				page_id: @id
		success: (response)!~>
			if response.status isnt \success
				panic-attack new Error "reordering error#{
					if response.error_code? then ": #{response.error_code}"
					else ''
				}"
			@trigger \reordered


module.exports = OrderingElementsItemModel
