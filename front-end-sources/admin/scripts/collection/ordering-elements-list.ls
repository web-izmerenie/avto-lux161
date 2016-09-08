/**
 * Panel Menu collection
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */

require! {
	\backbone        : B
	
	\./elements-list : ElementsListCollection
}


class OrderingElementsListCollection extends ElementsListCollection
	comparator: \sort # default ordering field


module.exports = OrderingElementsListCollection
