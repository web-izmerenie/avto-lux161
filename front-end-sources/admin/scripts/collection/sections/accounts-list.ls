/**
 * Accounts elements list section collection
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\app/model/sections/account-list-item : { AccountListItemModel }
	\app/collection/elements-list         : { ElementsListCollection }
}


export class AccountsListCollection
extends ElementsListCollection
	
	model: AccountListItemModel
	action: \get_accounts_list
