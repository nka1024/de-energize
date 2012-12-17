package aze.motion.easing;

import aze.motion.easing.Elastic;

/**
 * ...
 * @author Philippe / http://philippe.elsass.me
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */
class Elastic
{
	static public inline var easeIn:Dynamic = easeInWith(0.1, 0.4);
	static public inline var easeOut:Dynamic = easeOutWith(0.1, 0.4);
	static public inline var easeInOut:Dynamic = easeInOutWith(0.1, 0.4);
	
	static public function easeInWith(a:Float, p:Float):Dynamic
	{
		return function (k:Float):Float 
			{
				if (k == 0) return 0; if (k == 1) return 1; if (!p) p = 0.3;
				var s:Float;
				if (!a || a < 1) { a = 1; s = p / 4; }
				else s = p / (2 * Math.PI) * Math.asin (1 / a);
				return -(a * Math.pow(2, 10 * (k -= 1)) * Math.sin( (k - s) * (2 * Math.PI) / p ));
			}
	}
	static public function easeOutWith(a:Float, p:Float):Dynamic
	{
		return function (k:Float):Float 
			{
				if (k == 0) return 0; if (k == 1) return 1; if (!p) p = 0.3;
				var s:Float;
				if (!a || a < 1) { a = 1; s = p / 4; }
				else s = p / (2 * Math.PI) * Math.asin (1 / a);
				return (a * Math.pow(2, -10 * k) * Math.sin((k - s) * (2 * Math.PI) / p ) + 1);
			}
	}
	static public function easeInOutWith(a:Float, p:Float):Dynamic
	{
		return function (k:Float):Float 
			{
				if (k == 0) return 0; if (k == 1) return 1; if (!p) p = 0.3;
				var s:Float;
				if (!a || a < 1) { a = 1; s = p / 4; }
				else s = p / (2 * Math.PI) * Math.asin (1 / a);
				if ((k *= 2) < 1) return -0.5 * (a * Math.pow(2, 10 * (k -= 1)) * Math.sin( (k - s) * (2 * Math.PI) / p ));
				return a * Math.pow(2, -10 * (k -= 1)) * Math.sin( (k - s) * (2 * Math.PI) / p ) * .5 + 1;
			}
	}
}

