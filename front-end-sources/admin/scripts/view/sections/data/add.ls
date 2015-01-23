/**
 * Add Data View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	'../../form-edit' : FormEditView
}

class AddDataView extends FormEditView
	initialize: !->
		@options.type = \add
		@options[\list-page] = '#panel/data'
		@options.section = \data
		FormEditView.prototype.initialize ...

module.exports = AddDataView
