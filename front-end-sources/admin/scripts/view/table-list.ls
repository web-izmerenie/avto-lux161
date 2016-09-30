/**
 * Table List View
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone.marionette : { CompositeView }
	
	\../model/basic      : { BasicModel }
}


class TableListView extends CompositeView
	
	class-name: 'panel panel-default'
	child-view-container: \tbody
	
	model: new BasicModel!
	
	ui:
		\refresh : \.refresh
	events:
		'click @ui.refresh' : \refresh-list
	model-events: {}
	collection-events: {}
	
	\refresh-list : (e)!->
		e.prevent-default!
		@trigger \refresh:list


module.exports = TableListView
