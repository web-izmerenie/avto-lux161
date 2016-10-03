/**
 * Accounts List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	# models
	\app/collection/sections/accounts-list : { AccountsListCollection }
	
	# views
	\app/view/list                      : ListView
	\app/view/elements-table/list/index : TableListView
	\app/view/elements-table/item/index : TableItemView
}


class ItemView extends TableItemView
	template: \accounts/list-item


class CompositeListView extends TableListView
	template: \accounts/list
	child-view: ItemView


class AccountsListView extends ListView
	initialize: !->
		super? ...
		@init-table-list do
			CompositeListView
			null
			Collection: AccountsListCollection


module.exports = AccountsListView
