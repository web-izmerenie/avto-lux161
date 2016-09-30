/**
 * Add Account View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\app/view/form-edit : FormEditView
}


class AddAccountView extends FormEditView
	initialize: !->
		@options.type = \add
		@options.\list-page = '#panel/accounts'
		@options.section = \accounts
		super ...


module.exports = AddAccountView
