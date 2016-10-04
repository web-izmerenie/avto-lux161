/**
 * Deletion support elements list collection mixin
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */


export delete-elements-list-collection-mixin =
	initialize: !-> @on \element-was-destoyed, !-> @fetch!
