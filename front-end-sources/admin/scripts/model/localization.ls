/**
 * Localization model
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery                 : $
	\backbone               : { Model }
	
	\app/utils/panic-attack : { panic-attack }
}


$html = $ \html
$body = $html.children \body

lang  = $html.attr \lang
url   = $html.attr \data-local-file


export class LocalizationModel extends Model
	
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
			new Error "Can't get localization data by this lang: #{@lang}"
			|> panic-attack
	
	defaults:
		page_loading: \Loading...
		error: \Error
		fatal_error: 'Fatal error!'
