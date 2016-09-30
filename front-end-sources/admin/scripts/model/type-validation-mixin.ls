/**
 * Model mixin with type validation
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! \app/utils/panic-attack : { panic-attack }


export type-validation-model-mixin =
	
	check-if-is-valid: !->
		unless @is-valid!
			panic-attack new Error @validation-error
	
	# nulls for every field from @attributes-typings by default
	defaults: -> {[k, null] for k of @attributes-typings}
	
	# must be overwritten
	attributes-typings: null
		# local     : (instanceof LocalizationModel)
		# is_active : \Boolean
		# id        : \Number
		# sort      : \Number
		# title     : \String
	
	# if you overwrite this method you should call super::validate first
	validate: (attrs, opts)->
		
		available-keys = Object.keys @attributes-typings
		unknown-attrs = [k for k of attrs when k not in available-keys]
		
		if unknown-attrs.length > 0
			return "unknown attributes: #{unknown-attrs * ', '}"
		
		invalid-attrs = [k for k, v of attrs when (not) do
			switch typeof! @attributes-typings[k]
			| \Function => v |> @attributes-typings[k]
			| \String   => typeof! v is @attributes-typings[k]
			| otherwise => ...
		]
		
		if invalid-attrs.length > 0
			return "invalid attributes: #{invalid-attrs * ', '}"
		
		null
