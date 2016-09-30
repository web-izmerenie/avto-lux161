/**
 * Static pages elements list section collection
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\app/model/sections/static-page-list-item    : { StaticPageListItemModel }
	\app/collection/elements-list                : { ElementsListCollection }
	\app/collection/ordering-elements-list-mixin : {
		ordering-elements-list-collection-mixin
	}
}


export class StaticPagesListCollection
extends ElementsListCollection
implements ordering-elements-list-collection-mixin
	
	model: StaticPageListItemModel
	action: \get_pages_list
	
	initialize: !->
		super ...
		ordering-elements-list-collection-mixin.initialize ...
