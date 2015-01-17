/**
 * Accounts List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone : B
	\marionette : M
	\backbone.wreqr : W
	'../../../ajax-req'

	'../../../model/basic' : BasicModel

	# views
	'../../smooth' : SmoothView
	'../../loader' : LoaderView
	'../../table-list' : TableListView
}

class ItemView extends M.ItemView
	tag-name: \tr
	template: 'accounts/list-item'

class CompositeListView extends TableListView
	template: 'accounts/list'
	child-view: ItemView
	child-view-options: (model, index)~>
		model.set \local , @model.get \local

class AccountsListView extends SmoothView
	initialize: !->
		SmoothView.prototype.initialize ...

		@loader-view = (new LoaderView!).render!

		@table-list = new B.Collection []
		@table-view = new CompositeListView collection: @table-list
		@table-view.render!

		@table-view.on \refresh:list, !~> @get-list!

	on-show: !->
		@get-region \main .show @loader-view
		@get-list !~> @get-region \main .show @table-view

	get-list: (cb)!->
		@ajax = ajax-req {
			data:
				action: \get_accounts_list
			success: (json)!~>
				if json.status is not \success or not json.data_list?
					W.radio.commands .execute \police, \panic,
						new Error 'Incorrect server data'

				new-data-list = []
				for item in json.data_list
					new-data-list.push {
						id: item.id
						ref: '#panel/accounts/edit_' + item.id + '.html'
						login: item.login
						is_active: item.is_active
					}

				@table-list.reset new-data-list
				cb! if cb?
		}

	regions:
		\main : \.main

	class-name: 'redirect-list v-stretchy'
	template: \main
	model: new BasicModel!

	on-destroy: !->
		@ajax.abort! if @ajax?

module.exports = AccountsListView
