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

Localization = B.Model.extend {
	lang: $ \html .attr \lang
	initialize: !->
		local = null
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
				local := json[@.lang]
			error: (xhr, status, err)!->
				throw err
		}
		@ .set local
}

module.exports = Localization
