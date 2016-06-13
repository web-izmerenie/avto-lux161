/**
 * template handlers
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\jquery              : $
	\backbone.marionette : M
	\jade/jade
}

static-url = $ \html .attr \data-templates-path

# let webpack deal with it
templates-bundle =
	\accounts/list-item           : require \adminbase/templates/accounts/list-item.jade
	\accounts/list                : require \adminbase/templates/accounts/list.jade
	\catalog/elements-list-header : require \adminbase/templates/catalog/elements-list-header.jade
	\catalog/elements-list-item   : require \adminbase/templates/catalog/elements-list-item.jade
	\catalog/elements-list-main   : require \adminbase/templates/catalog/elements-list-main.jade
	\catalog/elements-list        : require \adminbase/templates/catalog/elements-list.jade
	\catalog/sections-list-item   : require \adminbase/templates/catalog/sections-list-item.jade
	\catalog/sections-list        : require \adminbase/templates/catalog/sections-list.jade
	\data/list-item               : require \adminbase/templates/data/list-item.jade
	\data/list                    : require \adminbase/templates/data/list.jade
	\form/data-fields/add         : require \adminbase/templates/form/data-fields/add.jade
	\form/data-fields/field       : require \adminbase/templates/form/data-fields/field.jade
	\form/data-fields/text        : require \adminbase/templates/form/data-fields/text.jade
	\form/data-fields/textarea    : require \adminbase/templates/form/data-fields/textarea.jade
	\form/checkbox                : require \adminbase/templates/form/checkbox.jade
	\form/data-fields             : require \adminbase/templates/form/data-fields.jade
	\form/files                   : require \adminbase/templates/form/files.jade
	\form/form                    : require \adminbase/templates/form/form.jade
	\form/html                    : require \adminbase/templates/form/html.jade
	\form/password                : require \adminbase/templates/form/password.jade
	\form/select                  : require \adminbase/templates/form/select.jade
	\form/text                    : require \adminbase/templates/form/text.jade
	\pages/list-item              : require \adminbase/templates/pages/list-item.jade
	\pages/list                   : require \adminbase/templates/pages/list.jade
	\redirect/list-item           : require \adminbase/templates/redirect/list-item.jade
	\redirect/list                : require \adminbase/templates/redirect/list.jade
	\ask-sure                     : require \adminbase/templates/ask-sure.jade
	\err-msg                      : require \adminbase/templates/err-msg.jade
	\fatal-error                  : require \adminbase/templates/fatal-error.jade
	\loader                       : require \adminbase/templates/loader.jade
	\login-form                   : require \adminbase/templates/login-form.jade
	\main                         : require \adminbase/templates/main.jade
	\menu-item                    : require \adminbase/templates/menu-item.jade
	\panel                        : require \adminbase/templates/panel.jade

compiled-templates = {}
for k of templates-bundle
	compiled-templates[k] = jade.compile templates-bundle[k]

export load = (template-id)->
	if compiled-templates.has-own-property template-id
		then compiled-templates[template-id]
		else throw new Error "Template '#{template-id}' isn't declared"

export compile = (raw-template)-> raw-template
export render = (template, data)-> (M.TemplateCache .get template) data
