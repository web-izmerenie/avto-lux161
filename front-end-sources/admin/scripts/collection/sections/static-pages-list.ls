/**
 * Static pages elements list section collection
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\app/model/sections/static-page-list-item : { StaticPageListItemModel }
	\app/collection/elements-list/index : { ElementsListCollection }
	\app/collection/elements-list/by-column-ordering-mixin : {
		by-column-ordering-elements-list-collection-mixin
	}
	
	\app/utils/mixins : { call-class-mixins }
}


export class StaticPagesListCollection
extends ElementsListCollection
implements by-column-ordering-elements-list-collection-mixin
	
	[ by-column-ordering-elements-list-collection-mixin ]
		@_call-class = call-class-mixins ..
	
	model: StaticPageListItemModel
	action: \get_pages_list
	
	initialize: !-> (@@_call-class super::, \initialize) ...
