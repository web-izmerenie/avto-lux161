/**
 * Static pages elements list section collection
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\app/model/sections/static-page-list-item : { StaticPageListItemModel }
	\app/collection/elements-list : { ElementsListCollection }
	\app/collection/by-column-ordering-elements-list-mixin : {
		by-column-ordering-elements-list-collection-mixin
	}
	
	\app/utils/mixins : { call-class-mixins }
}


list-mixins =
	* by-column-ordering-elements-list-collection-mixin
	...

call-class = call-class-mixins list-mixins

export class StaticPagesListCollection
extends ElementsListCollection
implements by-column-ordering-elements-list-collection-mixin
	
	model: StaticPageListItemModel
	action: \get_pages_list
	
	initialize: !-> (call-class super::, \initialize) ...
