/**
 * Edit Redirect View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	'../../form-edit' : FormEditView
}

class EditRedirectView extends FormEditView
	initialize: !->
		@options.type = \edit
		@options.id = @get-option \id
		@options[\list-page] = '#panel/redirect'
		@options.section = \redirect
		FormEditView.prototype.initialize ...

module.exports = EditRedirectView
