/**
 * Static page list element model
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone.wreqr           : { radio }
	
	\./localization           : LocalizationModel
	\./type-validation        : TypeValidationModelMixin
	\./ordering-elements-item : OrderingElementsItemModel
}


panic-attack = (err)!->
	radio.commands.execute \police, \panic, err
	throw err


class StaticPageListItemModel
extends OrderingElementsItemModel
implements TypeValidationModelMixin
	
	action: \reorder_page
	
	attributes-typings:
		local     : (instanceof LocalizationModel)
		
		is_active : \Boolean
		id        : \Number
		sort      : \Number
		ref       : \String
		name      : \String
		url       : \String
	
	\check-if-is-valid : !-> @check-if-is-valid ...
	check-if-is-valid: !->
		panic-attack new Error @validation-error unless @is-valid!
	
	initialize: !->
		super ...
		@check-if-is-valid!
		@on \change, \check-if-is-valid
	
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
			panic-attack e


module.exports = StaticPageListItemModel
