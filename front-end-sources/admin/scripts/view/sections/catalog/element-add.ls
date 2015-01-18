/**
 * Catalog Element Add View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	'../../form-edit' : FormEditView
}

class CatalogElementAddView extends FormEditView
	initialize: !->
		@options.type = \add
		section-id = @get-option \section-id
		@options[\section-id] = section-id
		@options[\list-page] = "\#panel/catalog/section_#section-id/"
		@options.section = \catalog_element
		FormEditView.prototype.initialize ...

module.exports = CatalogElementAddView
