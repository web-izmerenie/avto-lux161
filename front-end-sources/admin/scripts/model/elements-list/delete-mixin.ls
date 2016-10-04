/**
 * Deletion support elements list item model mixin
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! \app/utils/panic-attack : { panic-attack }


# supposed to be used with model of ElementsListCollection
export delete-elements-item-model-mixin =
	
	# must be set (can be set by constructor options)
	# section: \section-value-example
	
	destroy: (opts = {})!-> @sync \delete, @, {} <<< opts <<< do
		data:
			action: \delete
			args: JSON.stringify do
				section : @get-option \section
				id      : @id
		success: (response)!~>
			if response.status isnt \success
				panic-attack new Error "destruction error#{
					if response.error_code? then ": #{response.error_code}"
					else ''
				}"
			opts.success? @, response
			@trigger \element-was-destoyed, @id # notify collection
