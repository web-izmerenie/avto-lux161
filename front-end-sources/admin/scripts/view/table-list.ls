/**
 * Table List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\marionette : M
	
	'../model/basic' : BasicModel
}

class TableListView extends M.CompositeView
	class-name: 'panel panel-default'
	model: new BasicModel!
	child-view-container: \tbody
	
	ui:
		\refresh : \.refresh
	events:
		'click @ui.refresh': \refresh-list
	\refresh-list : ->
		@trigger \refresh:list
		false

module.exports = TableListView
