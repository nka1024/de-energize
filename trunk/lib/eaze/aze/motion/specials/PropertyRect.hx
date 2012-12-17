package aze.motion.specials;

import aze.motion.EazeTween;
import aze.motion.specials.PropertyRect;
import aze.motion.specials.EazeSpecial;

#if flash
import flash.geom.Rectangle;
#else
import nme.geom.Rectangle;
#end

/**
 * Rectangle tweening (typically for DisplayObject.scrollRect)
 * @author Igor Almeida / http://ialmeida.com
 * @author Philippe / http://philippe.elsass.me
 */
class PropertyRect extends EazeSpecial
{
	static public function register():Void
	{
		EazeTween.specialProperties.set("__rect", PropertyRect);
	}

	private var original:Rectangle;
	private var targetRect:Rectangle;
	private var tmpRect:Rectangle;

	public function new(target:Dynamic, property:Dynamic, value:Dynamic, next:EazeSpecial):Void
	{
		super(target, property, value, next);
		targetRect = value && Std.is(value, Rectangle) ? value.clone() : new Rectangle();
	}

	override public function init(reverse:Bool):Void 
	{
		//original = Std.is(Reflect.field(target,property), Rectangle)
			//? cast(Reflect.field(target,property).clone(), Rectangle)
			//: new Rectangle(0, 0, target.width, target.height);
			
		original = Std.is(Reflect.getProperty(target,property), Rectangle)
			? cast(Reflect.getProperty(target,property).clone(), Rectangle)
			: new Rectangle(0, 0, target.width, target.height);
		
		if (reverse)
		{
			tmpRect = original;
			original = targetRect;
			targetRect = tmpRect;
		}
		tmpRect = new Rectangle();
	}

	override public function update(ke:Float, isComplete:Bool):Void 
	{
		if (isComplete) target.scrollRect = targetRect;
		else
		{
			tmpRect.x = original.x + (targetRect.x - original.x) * ke;
			tmpRect.y = original.y + (targetRect.y - original.y) * ke;
			tmpRect.width = original.width + (targetRect.width - original.width) * ke;
			tmpRect.height = original.height + (targetRect.height - original.height) * ke;
			//Reflect.setField(target,property,tmpRect);
			Reflect.setProperty(target,property,tmpRect);
		}
	}
	
	override public function dispose():Void 
	{
		original = targetRect = tmpRect = null;
		super.dispose();
	}
}
