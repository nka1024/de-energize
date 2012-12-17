package aze.motion.easing;

import aze.motion.easing.Quart;

/**
 * ...
 * @author Philippe / http://philippe.elsass.me
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */
class Quart
{
	static public function easeIn(k:Float):Float 
	{
		return k * k * k * k;
	}
	static public function easeOut(k:Float):Float 
	{
		return -(--k * k * k * k - 1);
	}
	static public function easeInOut(k:Float):Float 
	{
		if ((k *= 2) < 1) return 0.5 * k * k * k * k;
		return -0.5 * ((k -= 2) * k * k * k - 2);
	}
}

