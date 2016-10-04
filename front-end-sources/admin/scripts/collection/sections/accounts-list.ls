/**
 * Accounts elements list section collection
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\app/model/sections/account-list-item      : { AccountListItemModel }
	\app/collection/elements-list/index        : { ElementsListCollection }
	\app/collection/elements-list/delete-mixin : {
		delete-elements-list-collection-mixin
	}
	
	\app/utils/mixins : { call-class-mixins }
}


export class AccountsListCollection
extends ElementsListCollection
implements delete-elements-list-collection-mixin
	
	[ delete-elements-list-collection-mixin ]
		@_call-class = call-class-mixins ..
	
	model: AccountListItemModel
	action: \get_accounts_list
	
	initialize: !-> (@@_call-class super::, \initialize) ...
