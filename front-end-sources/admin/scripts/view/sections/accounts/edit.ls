/**
 * Edit Page View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	'../../form-edit' : FormEditView
}

class EditAccountView extends FormEditView
	initialize: !->
		@options.type = \edit
		@options.id = @get-option \id
		@options[\list-page] = '#panel/accounts'
		@options.section = \accounts
		FormEditView.prototype.initialize ...

module.exports = EditAccountView
