/**
 * Static page list element model
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone.wreqr : { radio }
	
	\./basic        : BasicModel
	\./localization : LocalizationModel
}


class StaticPageListItemModel extends BasicModel
	
	defaults:
		local     : null # instance of LocalizationModel
		
		is_active : null # boolean
		id        : null # number
		sort      : null # number
		ref       : null # string
		name      : null # string
		url       : null # string
	
	initialize: !->
		super local: new LocalizationModel!
	
	parse: (response)->
		try
			{
				response.is_active
				response.id
				response.sort
				ref: "\#panel/pages/edit_#{response.id}.html"
				name: response.title
				url: response.alias
			}
		catch
			radio.commands.execute \police, \panic, e
			throw e


module.exports = StaticPageListItemModel
