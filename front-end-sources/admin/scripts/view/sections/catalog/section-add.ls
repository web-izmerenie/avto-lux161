/**
 * Catalog Section Add View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	'../../form-edit' : FormEditView
}

class CatalogSectionAddView extends FormEditView
	initialize: !->
		@options.type = \add
		section-id = @get-option \section-id
		@options[\section-id] = section-id
		@options[\list-page] = '#panel/catalog'
		@options.section = \catalog_section
		FormEditView.prototype.initialize ...

module.exports = CatalogSectionAddView
