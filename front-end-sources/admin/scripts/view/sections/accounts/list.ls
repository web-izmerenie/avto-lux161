/**
 * Accounts List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	# views
	'../../table-list' : TableListView
	'../../table-item' : TableItemView
	'../../list'       : ListView
}

class ItemView extends TableItemView
	template: 'accounts/list-item'

class CompositeListView extends TableListView
	template: 'accounts/list'
	child-view: ItemView
	child-view-options: (model, index)~>
		model.set \local , @model.get \local

class AccountsListView extends ListView
	initialize: !->
		ListView.prototype.initialize ...
		@init-table-list CompositeListView
	
	on-show: !->
		ListView.prototype.on-show ...
		@update-list !~> @get-region \main .show @table-view
	
	update-list: (cb)!->
		(data-arr)<~! @get-list { action: \get_accounts_list }
		
		new-data-list = []
		for item in data-arr
			new-data-list.push {
				id: item.id
				ref: '#panel/accounts/edit_' + item.id + '.html'
				login: item.login
				is_active: item.is_active
			}
		
		@table-list.reset new-data-list
		cb! if cb?

module.exports = AccountsListView
