/**
 * Localization model
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery   : $
	\backbone : { Model }
}


lang = $ \html .attr \lang
local = {}


# TODO refactoring
class LocalizationModel extends Model
	lang: lang
	initialize: (options={})!->
		@lang = options.lang if options.lang?
		
		if local[@.lang]?
			@set local[@.lang]
			return
		
		$ .ajax do
			url: $ \html .attr \data-local-file
			method: \GET
			cache: true # cache mark by back-end
			async: false
			data-type: \json
			success: (json)!~>
				unless json[@.lang]?
					throw new Error "
						Can't get localization data by this lang: #{@.lang}"
				local[@.lang] := json[@.lang]
			error: (xhr, status, err)!->
				throw err
		
		@set local[@.lang]


module.exports = LocalizationModel
