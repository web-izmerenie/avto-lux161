/**
 * localization module
 *
 * @author Viacheslav Lotsmanov
 */

require! \jquery : $

local = null

module.exports = (cb)->
	return local if local?

	lang = $ \html .attr \lang
	url = $ \html .attr \data-local-file

	unless lang?
		throw new Error "Can't get 'lang' attribute from <html> tag"
	unless url?
		throw new Error "Can't get 'data-local-file' attribute from <html> tag"

	$ .get url
		.error !-> throw new Error "Can't get localization json file by url: #url"
		.success (json)!->
			try
				JSON.stringify json
			catch
				throw new Error "Incorrect JSON file by url: #url"

			unless json[lang]?
				throw new Error "Can't get localization by this language: #lang"

			cb json[lang]
