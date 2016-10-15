/**
 * Add Page View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! \app/view/form-edit : FormEditView


class AddPageView extends FormEditView
	initialize: !->
		@options.type = \add
		@options.\list-page = \#panel/pages
		@options.section = \pages
		super? ...


module.exports = AddPageView
