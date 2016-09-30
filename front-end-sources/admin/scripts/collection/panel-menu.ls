/**
 * Panel Menu collection
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\./basic : { BasicCollection }
}


data =
	* ref: \#panel/pages    , title: 'Статические страницы'
	* ref: \#panel/catalog  , title: \Каталог
	* ref: \#panel/redirect , title: \Редиректы
	* ref: \#panel/data     , title: \Данные
	* ref: \#panel/accounts , title: \Аккаунты
	* ref: \#logout         , title: \Выход


export panel-menu-list = new BasicCollection data
