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
	\accounts/list-item           : require \base/templates/accounts/list-item.jade
	\accounts/list                : require \base/templates/accounts/list.jade
	\catalog/elements-list-header : require \base/templates/catalog/elements-list-header.jade
	\catalog/elements-list-item   : require \base/templates/catalog/elements-list-item.jade
	\catalog/elements-list-main   : require \base/templates/catalog/elements-list-main.jade
	\catalog/elements-list        : require \base/templates/catalog/elements-list.jade
	\catalog/sections-list-item   : require \base/templates/catalog/sections-list-item.jade
	\catalog/sections-list        : require \base/templates/catalog/sections-list.jade
	\data/list-item               : require \base/templates/data/list-item.jade
	\data/list                    : require \base/templates/data/list.jade
	\form/data-fields/add         : require \base/templates/form/data-fields/add.jade
	\form/data-fields/field       : require \base/templates/form/data-fields/field.jade
	\form/data-fields/text        : require \base/templates/form/data-fields/text.jade
	\form/data-fields/textarea    : require \base/templates/form/data-fields/textarea.jade
	\form/checkbox                : require \base/templates/form/checkbox.jade
	\form/data-fields             : require \base/templates/form/data-fields.jade
	\form/files                   : require \base/templates/form/files.jade
	\form/form                    : require \base/templates/form/form.jade
	\form/html                    : require \base/templates/form/html.jade
	\form/password                : require \base/templates/form/password.jade
	\form/select                  : require \base/templates/form/select.jade
	\form/text                    : require \base/templates/form/text.jade
	\pages/list-item              : require \base/templates/pages/list-item.jade
	\pages/list                   : require \base/templates/pages/list.jade
	\redirect/list-item           : require \base/templates/redirect/list-item.jade
	\redirect/list                : require \base/templates/redirect/list.jade
	\ask-sure                     : require \base/templates/ask-sure.jade
	\err-msg                      : require \base/templates/err-msg.jade
	\fatal-error                  : require \base/templates/fatal-error.jade
	\loader                       : require \base/templates/loader.jade
	\login-form                   : require \base/templates/login-form.jade
	\main                         : require \base/templates/main.jade
	\menu-item                    : require \base/templates/menu-item.jade
	\panel                        : require \base/templates/panel.jade

compiled-templates = {}
for k of templates-bundle
	compiled-templates[k] = jade.compile templates-bundle[k]

export load = (template-id)->
	if compiled-templates.has-own-property template-id
		then compiled-templates[template-id]
		else throw new Error "Template '#{template-id}' isn't declared"

export compile = (raw-template)-> raw-template
export render = (template, data)-> (M.TemplateCache .get template) data
