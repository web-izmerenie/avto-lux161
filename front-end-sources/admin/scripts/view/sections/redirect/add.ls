/**
 * Add Redirect View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	'../../form-edit' : FormEditView
}

class AddRedirectView extends FormEditView
	initialize: !->
		@options.type = \add
		@options[\list-page] = '#panel/redirect'
		@options.section = \redirect
		FormEditView.prototype.initialize ...

module.exports = AddRedirectView
