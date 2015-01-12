/**
 * template handlers
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery : $
	\jade : jade
	\marionette : M
}

static-url = $ \html .attr \data-templates-path

module.exports.load = (template-id)->
	template = null

	$ .ajax {
		url: static-url + template-id + '.jade'
		method: \GET
		async: false
		cache: false
		data-type: \text
		success: (data)!->
			template := data
		error: (xhr, status, err)!->
			throw err
	}

	return template

module.exports.compile = (raw-template)->
	return raw-template

module.exports.render = (template, data)->
	raw-template = M.TemplateCache .get template
	jade.render raw-template, data
