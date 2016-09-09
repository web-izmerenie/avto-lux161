/**
 * Edit Page View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\../../form-edit : FormEditView
}


class EditPageView extends FormEditView
	initialize: !->
		@options.type = \edit
		@options.id = @get-option \id
		@options.\list-page = \#panel/pages
		@options.section = \pages
		super ...


module.exports = EditPageView
