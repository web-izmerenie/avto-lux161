/**
 * Account list element model
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\app/model/basic                        : { BasicModel }
	\app/model/localization                 : { LocalizationModel }
	\app/model/type-validation-mixin        : { type-validation-model-mixin }
	\app/model/ordering-elements-item-mixin : { ordering-elements-item-model-mixin }
	
	\app/utils/panic-attack                 : { panic-attack }
}


export class AccountListItemModel
extends BasicModel
implements type-validation-model-mixin
	
	section: \accounts
	
	attributes-typings:
		local     : (instanceof LocalizationModel)
		
		id        : \Number
		login     : \String
		ref       : \String
		is_active : \Boolean
	
	initialize: !->
		super ...
		@check-if-is-valid!
		@on \change, @check-if-is-valid
	
	parse: (response)->
		try
			{
				response.id
				ref: "\#panel/accounts/edit_#{response.id}.html"
				response.login
				response.is_active
			}
		catch
			panic-attack e
