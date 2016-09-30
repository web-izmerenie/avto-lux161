/**
 * Static page list element model
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


export class StaticPageListItemModel
extends BasicModel
implements type-validation-model-mixin, ordering-elements-item-model-mixin
	
	section: \pages
	
	attributes-typings:
		local             : (instanceof LocalizationModel)
		
		is_active         : \Boolean
		id                : \Number
		sort              : \Number
		ref               : \String
		name              : \String
		url               : \String
		is_main_menu_item : \Boolean
	
	initialize: !->
		super ...
		@check-if-is-valid!
		@on \change, @check-if-is-valid
	
	parse: (response)->
		try
			{
				response.is_active
				response.id
				response.sort
				ref: "\#panel/pages/edit_#{response.id}.html"
				name: response.title
				url: response.alias
				response.is_main_menu_item ? false
			}
		catch
			panic-attack e
