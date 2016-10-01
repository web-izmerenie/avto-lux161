/**
 * Ordering elements list item model mixin
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! \app/utils/panic-attack : { panic-attack }


export custom-reordering-elements-item-model-mixin =
	
	# must be set (can be set by constructor options)
	# section: \section-value-example
	
	put-at: (at-model)!-> @sync \update, @, do
		data:
			action: \reorder
			args: JSON.stringify do
				section   : @get-option \section
				target_id : @id
				at_id     : at-model.id
		success: (response)!~>
			if response.status isnt \success
				panic-attack new Error "reordering error#{
					if response.error_code? then ": #{response.error_code}"
					else ''
				}"
			@trigger \reordered
