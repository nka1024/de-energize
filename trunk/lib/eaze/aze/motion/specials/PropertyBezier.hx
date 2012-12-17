package aze.motion.specials;

import aze.motion.EazeTween;
import aze.motion.specials.PropertyBezier;
import aze.motion.specials.EazeSpecial;

/**
 * Numeric tweening along a Bezier curve
 * @author Philippe / http://philippe.elsass.me
 */
class PropertyBezier extends EazeSpecial
{
	static public function register():Void
	{
		EazeTween.specialProperties.set("__bezier", PropertyBezier);
	}
	
	private var fvalue:Array<Dynamic>;
	private var through:Bool;
	private var length:Int;
	private var segments:Array<Dynamic>;
	
	public function new(target:Dynamic, property:Dynamic, value:Dynamic, next:EazeSpecial) 
	{
		super(target, property, value, next);
		
		// [50, 100] -> prop, control, end
		// [50, 100, 150] -> prop, control1, control2, end
		// [50, 50, 100] -> prop, through, end
		fvalue = value;
		//if (fvalue[0] is Array<Dynamic>)
		if (Std.is(fvalue[0],Array))
		{
			through = true;
			fvalue = fvalue[0];
		}
	}
	
	override public function init(reverse:Bool):Void 
	{
		//var current:Dynamic = Reflect.field(target,property);
		var current:Dynamic = Reflect.getProperty(target,property);
		
		fvalue = [current].concat(fvalue);
		if (reverse) fvalue.reverse();
		
		var p0:Float, p1:Float, p2:Float = fvalue[0];
		var last:Int = fvalue.length - 1;
		var index:Int = 1;
		var auto:Float = Math.NaN;
		segments = [];
		length = 0;
		
		while (index < last)
		{
			p0 = p2;
			p1 = fvalue[index];
			p2 = fvalue[++index];
			if (through)
			{
				if (length==0)
				{
					auto = (p2 - p0) / 4;
					segments[length++] = new BezierSegment(p0, p1 - auto, p1);
				}
				segments[length++] = new BezierSegment(p1, p1 + auto, p2);
				auto = p2 - (p1 + auto);
			}
			else 
			{
				if (index != last) p2 = (p1 + p2) / 2;
				segments[length++] = new BezierSegment(p0, p1, p2);
			}
		}
		fvalue = null;
		
		if (reverse) update(0, false);
	}
	
	override public function update(ke:Float, isComplete:Bool):Void 
	{
		var segment:BezierSegment;
		var last:Int = length - 1;
		
		if (isComplete)
		{
			segment = segments[last];
			//Reflect.setField(target, property, segment.p0 + segment.d2);
			Reflect.setProperty(target, property, segment.p0 + segment.d2);
		}
		else if (length == 1) 
		{
			segment = segments[0];
			//Reflect.setField(target, property, segment.calculate(ke));
			Reflect.setProperty(target, property, segment.calculate(ke));
		}
		else
		{
			var index:Dynamic = Std.int((ke * length)) >> 0;
			if (index < 0) index = 0;
			else if (index > last) index = last;
			segment = segments[index];
			ke = length * (ke - index / length);
			//Reflect.setField(target, property, segment.calculate(ke));
			Reflect.setProperty(target, property, segment.calculate(ke));
		}
	}
	
	override public function dispose():Void 
	{
		fvalue = null;
		segments = null;
		
		super.dispose();
	}
}

class BezierSegment
{
	public var p0:Float;
	public var d1:Float;
	public var d2:Float;

	public function new (p0:Float, p1:Float, p2:Float)
	{
		this.p0 = p0;
		d1 = p1 - p0;
		d2 = p2 - p0;
	}

	public function calculate(t:Float):Float
	{
		return p0 + t * (2 * (1 - t) * d1 + t * d2);
	}
}
