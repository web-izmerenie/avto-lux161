/**
 * Catalog Section Edit View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	'../../form-edit' : FormEditView
}

class CatalogSectionEditView extends FormEditView
	initialize: !->
		@options.type = \edit
		section-id = @get-option \section-id
		@options[\section-id] = section-id
		@options.id = @get-option \id
		@options[\list-page] = "\#panel/catalog/section_#section-id/"
		@options.section = \catalog_section
		FormEditView.prototype.initialize ...

module.exports = CatalogSectionEditView
