/**
 * Mixins helpers
 *
 * @author Viacheslav Lotsmanov
 * @author Andrew Fatkulin
 */


# call method of every mixin
export call-mixins = (mixins, method)-->
	!-> for mixins then ..[method]? ...

# like `call-mixins` but also call parent class method
export call-class-mixins = (mixins, superproto, method)-->
	!-> for [superproto] ++ mixins then ..[method]? ...


# get new object of merged properties (objects) from mixins
export extend-mixins = (mixins, property)-->
	mixins.reduce (ob, x)-> (ob <<< x[property]), {}

# like `extend-mixins` but also merge with super class property
export extend-class-mixins = (mixins, superproto, property)-->
	([superproto] ++ mixins).reduce (ob, x)-> (ob <<< x[property]), {}
