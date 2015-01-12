/**
 * Localization model
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery : $
	\backbone : B
}

lang = $ \html .attr \lang
local = {}

Localization = B.Model.extend {
	lang: lang
	initialize: (options={})!->
		@.lang = options.lang if options.lang?

		if local[@.lang]?
			@ .set local[@.lang]
			return

		$ .ajax {
			url: $ \html .attr \data-local-file
			method: \GET
			cache: false
			async: false
			data-type: \json
			success: (json)!~>
				unless json[@.lang]?
					throw new Error "
						Can't get localization data by this lang: #{@.lang}"
				local[@.lang] := json[@.lang]
			error: (xhr, status, err)!->
				throw err
		}

		@ .set local[@.lang]
}

module.exports = Localization
