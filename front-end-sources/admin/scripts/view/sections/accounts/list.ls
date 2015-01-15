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
}

class ItemView extends M.ItemView
	tag-name: \tr
	template: 'accounts/list-item'

class TableListView extends M.CompositeView
	class-name: 'panel panel-default'
	template: 'accounts/list'
	model: new BasicModel!
	child-view-container: \tbody
	child-view: ItemView
	child-view-options: (model, index)~>
		model.set \local , @model.get \local

class AccountsListView extends SmoothView
	initialize: !->
		SmoothView.prototype.initialize ...

		@loader-view = (new LoaderView!).render!

	on-show: !->
		@get-region \main .show @loader-view

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

				list = new B.Collection new-data-list
				table-view = new TableListView collection: list
				table-view.render!

				@get-region \main .show table-view
		}

	regions:
		\main : \.main

	class-name: 'redirect-list v-stretchy'
	template: \main
	model: new BasicModel!

	on-destroy: !->
		@ajax.abort! if @ajax?

module.exports = AccountsListView
