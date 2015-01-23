/**
 * Edit Data View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	'../../form-edit' : FormEditView
}

class EditDataView extends FormEditView
	initialize: !->
		@options.type = \edit
		@options.id = @get-option \id
		@options[\list-page] = '#panel/data'
		@options.section = \data
		FormEditView.prototype.initialize ...

module.exports = EditDataView
