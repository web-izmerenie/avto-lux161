/**
 * Add Account View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	'../../form-edit' : FormEditView
}

class AddAccountView extends FormEditView
	initialize: !->
		@options.type = \add
		@options[\list-page] = '#panel/accounts'
		@options.section = \accounts
		FormEditView.prototype.initialize ...

module.exports = AddAccountView
