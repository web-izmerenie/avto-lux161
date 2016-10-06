/**
 * Accounts List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone.wreqr : { radio }
	
	# models
	\app/collection/sections/accounts-list : { AccountsListCollection }
	
	# views
	\app/view/list                      : ListView
	\app/view/elements-table/list/index : TableListView
	\app/view/elements-table/item/index : TableItemView
	
	# view mixins
	\app/view/elements-table/list/drag-row-mixin : {
		drag-row-table-list-view-mixin
	}
	\app/view/elements-table/item/drag-row-mixin : {
		drag-row-table-item-view-mixin
	}
	\app/view/elements-table/list/drop-delete-mixin : {
		drop-delete-table-list-view-mixin
	}
	\app/view/elements-table/list/by-column-ordering-mixin : {
		by-column-ordering-table-list-view-mixin
	}
	
	# helpers
	\app/utils/mixins : { call-class-mixins, extend-class-mixins }
	\app/utils/dashes : { camelize }
	\app/utils/panic-attack : { panic-attack }
}


authentication = radio.channel \authentication


class ItemView extends TableItemView implements drag-row-table-item-view-mixin
	
	[ drag-row-table-item-view-mixin ]
		@_call-class = call-class-mixins ..
		@_extend-class = extend-class-mixins ..
	
	template   : \accounts/list-item
	
	ui         : @@_extend-class super::, \ui
	events     : @@_extend-class super::, \events
	
	initialize : !-> (@@_call-class super::, \initialize) ...
	on-render  : !-> (@@_call-class super::, camelize \on-render) ...


class CompositeListView
extends TableListView
implements \
drag-row-table-list-view-mixin, \
drop-delete-table-list-view-mixin, \
by-column-ordering-table-list-view-mixin
	
	[
		drag-row-table-list-view-mixin
		drop-delete-table-list-view-mixin
		by-column-ordering-table-list-view-mixin
	]
		@_call-class = call-class-mixins ..
		@_extend-class = extend-class-mixins ..
	
	template: \accounts/list
	child-view: ItemView
	
	ui         : @@_extend-class super::, \ui
	events     : @@_extend-class super::, \events
	
	initialize : !-> (@@_call-class super::, \initialize) ...
	on-render  : !-> (@@_call-class super::, camelize \on-render) ...
	
	delete-by-model-id: (model-id, cb = null)!->
		
		model = @collection.get model-id
			unless ..?
				panic-attack new Error "Model by id '#model-id' not found"
		
		switch
		| (authentication.reqres.request \username) is (model.get \login) =>
			window.alert <|
				@model.get \local .get \sections
					.accounts.err.cannot_remove_current_user
		| otherwise =>
			if window.confirm <| @model.get \local .get \sections
				.accounts.confirm_remove
				.replace /{username}/gi, model.get \login
			then @collection.get model-id .destroy!
		
		cb?!


class AccountsListView extends ListView
	initialize: !->
		super? ...
		@init-table-list do
			CompositeListView
			null
			Collection: AccountsListCollection


module.exports = AccountsListView
