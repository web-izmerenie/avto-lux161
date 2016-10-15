/**
 * Form view-model
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	# libs
	\underscore : _
	
	# models
	\app/model/basic                 : { BasicModel }
	\app/model/localization          : { LocalizationModel }
	\app/model/type-validation-mixin : { type-validation-model-mixin }
	
	# helpers
	\app/utils/mixins : { call-class-mixins }
}


export class FormViewModel
extends BasicModel
implements type-validation-model-mixin
	
	[ type-validation-model-mixin ]
		@_call-class = call-class-mixins ..
	
	initialize: !-> (@@_call-class super::, \initialize) ...
	
	url: null
	
	attributes-typings:
		local: (instanceof LocalizationModel)
		
		section: \String
		type: (in <[add edit]>)
		
		error_message_code: (typeof!) >> (in <[Null String]>)
