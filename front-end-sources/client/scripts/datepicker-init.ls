/**
 * ui datepicker initializator
 *
 * @author Viacheslav Lotsmanov
 * @charset utf-8
 */

require! \jquery : $
require \jquery-ui.datepicker

$html = $ \html

$.datepicker.regional.ru =
	close-text: \Закрыть
	prev-text: 'Предыдущий месяц'
	next-text: 'Следующий месяц'
	current-text: \Сегодня
	month-names:
		\Январь
		\Февраль
		\Март
		\Апрель
		\Май
		\Июнь
		\Июль
		\Август
		\Сентябрь
		\Октябрь
		\Ноябрь
		\Декабрь
	month-names-short:
		\Янв
		\Фев
		\Мар
		\Апр
		\Май
		\Июн
		\Июл
		\Авг
		\Сен
		\Окт
		\Ноя
		\Дек
	day-names:
		\воскресенье
		\понедельник
		\вторник
		\среда
		\четверг
		\пятница
		\суббота
	day-names-short:
		\вск
		\пнд
		\втр
		\срд
		\чтв
		\птн
		\сбт
	day-names-min:
		\Вс
		\Пн
		\Вт
		\Ср
		\Чт
		\Пт
		\Сб
	week-header: \Не
	date-format: \dd.mm.yy
	first-day: 1
	isRTL: false
	show-month-after-year: false
	year-suffix: ''

if ($html .attr \lang) is not \en
	$.datepicker.set-defaults $.datepicker.regional[$html .attr \lang]
