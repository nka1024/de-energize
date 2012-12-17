package aze.motion.specials;

import aze.motion.EazeTween;
import aze.motion.specials.PropertyShortRotation;
import aze.motion.specials.EazeSpecial;

/**
 * Short rotation tweening
 * @author Philippe / http://philippe.elsass.me
 */
class PropertyShortRotation extends EazeSpecial
{
	static public function register():Void
	{
		EazeTween.specialProperties.set("__short", PropertyShortRotation);
	}
	
	private var fvalue:Float;
	private var radius:Float;
	private var start:Float;
	private var delta:Float;
	
	public function new(target:Dynamic, property:Dynamic, value:Dynamic, next:EazeSpecial) 
	{
		super(target, property, value, next);
		fvalue = value[0];
		radius = value[1] ? Math.PI : 180;
	}
	
	override public function init(reverse:Bool):Void 
	{
		//start = Reflect.field(target,property);
		start = Reflect.getProperty(target,property);
		var end:Float;
		if (reverse) { 
			end = start; 
			//Reflect.setField(target, property, fvalue);
			Reflect.setProperty(target, property, fvalue);
			start = fvalue; 
		}
		else { end = fvalue; }
		while (end - start > radius) start += radius * 2;
		while (end - start < -radius) start -= radius * 2;
		delta = end - start;
	}
	
	override public function update(ke:Float, isComplete:Bool):Void 
	{
		//Reflect.setField(target, property, start + ke * delta);
		Reflect.setProperty(target, property, start + ke * delta);
	}
}

