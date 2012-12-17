package aze.motion.easing;

import aze.motion.easing.Quadratic;

/**
 * ...
 * @author Philippe / http://philippe.elsass.me
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */
class Quadratic
{
	static public function easeIn(k:Float):Float 
	{
		return k * k;
	}
	static public function easeOut(k:Float):Float 
	{
		return -k * (k - 2);
	}
	static public function easeInOut(k:Float):Float 
	{
		if ((k *= 2) < 1) return 0.5 * k * k;
		return -0.5 * (--k * (k - 2) - 1);
	}
}

