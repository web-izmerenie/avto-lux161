/**
 * Panel Menu collection
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! \app/collection/basic : { BasicCollection }


data =
	* ref: \#panel/pages    , title: 'Статические страницы'
	* ref: \#panel/catalog  , title: \Каталог
	* ref: \#panel/redirect , title: \Редиректы
	* ref: \#panel/data     , title: \Данные
	* ref: \#panel/accounts , title: \Аккаунты
	* ref: \#logout         , title: \Выход


class PanelMenuListCollection extends BasicCollection
	url: null

export panel-menu-list = new PanelMenuListCollection data
