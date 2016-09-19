/**
 * Localization model
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery         : $
	\backbone       : { Model }
	\backbone.wreqr : { radio }
}


$html = $ \html
$body = $html.children \body

lang  = $html.attr \lang
url   = $html.attr \data-local-file


class LocalizationModel extends Model
	
	lang : lang
	url  : url
	
	@_cache = {}
	
	initialize: (attrs = null, options = {})!->
		super ...
		@lang = options.lang if options.lang?
		@@_cache[@lang] ? {} |> @set _, { +silent }
		@changed = {}
	
	fetch: (opts)!->
		super {} <<< opts <<< do
			force-method: \GET
			force-cache: on # revision mark in file path to clear cache
			success: (model, response)!~>
				@@_cache[@lang] = @parse response
				opts.success? ...
	
	# must be determined and immutable
	parse: (response)->
		| response[@lang]? => response[@lang]
		| otherwise =>
			err = new Error "Can't get localization data by this lang: #{@lang}"
			radio.commands.execute \police, \panic, err
			throw err
	
	defaults:
		page_loading: \Loading...


module.exports = LocalizationModel
