/**
 * Edit Page View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\app/view/form-edit : FormEditView
}


class EditAccountView extends FormEditView
	initialize: !->
		@options.type = \edit
		@options.id = @get-option \id
		@options.\list-page = '#panel/accounts'
		@options.section = \accounts
		super ...


module.exports = EditAccountView
