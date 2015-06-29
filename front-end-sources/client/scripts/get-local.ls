/**
 * localization module
 *
 * @author Viacheslav Lotsmanov
 */

require! \jquery : $

module.exports = (cb)->
	lang = $ \html .attr \lang
	url = $ \html .attr \data-local-file
	
	unless lang?
		throw new Error "Can't get 'lang' attribute from <html> tag"
	unless url?
		throw new Error "Can't get 'data-local-file' attribute from <html> tag"
	
	$ .ajax {
		url: url,
		method: \GET,
		data-type: \json,
		error: !-> throw new Error "Can't get localization json file by url: #url"
		success: (json)!->
			unless json[lang]?
				throw new Error "Can't get localization by this language: #lang"
			
			cb json[lang]
	}
