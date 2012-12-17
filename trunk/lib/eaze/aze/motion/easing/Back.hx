package aze.motion.easing;

import aze.motion.easing.Back;
/**
 * ...
 * @author Philippe / http://philippe.elsass.me
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */
class Back
{
	static public var easeIn:Dynamic = easeInWith();
	static public var easeOut:Dynamic = easeOutWith();
	static public var easeInOut:Dynamic = easeInOutWith();
	
	static public function easeInWith(s:Float = 1.70158):Dynamic
	{
		return function (k:Float):Float 
			{
				return k * k * ((s + 1) * k - s);
			}
	}
	static public function easeOutWith(s:Float = 1.70158):Dynamic
	{
		return function (k:Float):Float 
			{
				return (k = k - 1) * k * ((s + 1) * k + s) + 1;
			}
	}
	static public function easeInOutWith(s:Float = 1.70158):Dynamic
	{
		s *= 1.525;
		return function (k:Float):Float 
			{
				if ((k *= 2) < 1) return 0.5 * (k * k * ((s + 1) * k - s));
				return 0.5 * ((k -= 2) * k * ((s + 1) * k + s) + 2);
			}
	}
}
/*
	public function calculate(t:Number, b:Number, c:Number, d:Number):Number
	{
		if ((t /= d / 2) < 1) {
			return c / 2 * (t * t * (((s * 1.525) + 1) * t - s * 1.525)) + b;
		}
		return c / 2 * ((t -= 2) * t * (((s * 1.525) + 1) * t + s * 1.525) + 2) + b;
	}*/
