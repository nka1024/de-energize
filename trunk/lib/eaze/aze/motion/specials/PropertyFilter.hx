package aze.motion.specials;

import aze.motion.EazeTween;
import aze.motion.specials.PropertyFilter;
import aze.motion.specials.EazeSpecial;

#if flash
import flash.display.DisplayObject;
import flash.filters.BitmapFilter;
import flash.filters.BlurFilter;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
#else
import nme.display.DisplayObject;
import nme.filters.BitmapFilter;
import nme.filters.BlurFilter;
import nme.filters.DropShadowFilter;
import nme.filters.GlowFilter;
#end

/**
 * Filters tweening as special properties
 * @author Philippe / http://philippe.elsass.me
 */
class PropertyFilter extends EazeSpecial
{
	static public function register():Void
	{
		EazeTween.specialProperties.set("blurFilter", PropertyFilter);
		EazeTween.specialProperties.set("glowFilter", PropertyFilter);
		EazeTween.specialProperties.set("dropShadowFilter", PropertyFilter);
		EazeTween.specialProperties.set(BlurFilter, PropertyFilter);
		EazeTween.specialProperties.set(GlowFilter, PropertyFilter);
		EazeTween.specialProperties.set(DropShadowFilter, PropertyFilter);
	}

	/**
	 * @private
	 * Get existing matching filer or create new one.
	 */
	static public function getCurrentFilter(filterClass:Dynamic, disp:DisplayObject, remove:Bool):BitmapFilter
	{
		if (disp.filters!=null)
		{
			var index:Int;
			#if flash
				var filters:Array<flash.filters.BitmapFilter> = disp.filters;
			#else
				var filters:Array<Dynamic> = disp.filters;
			#end
			//for (index = 0; index < filters.length; index++);
			for( index in 0 ... filters.length ) {
				if (Std.is(filters[index], filterClass)) 
				{
					if (remove) 
					{
						var filter:BitmapFilter = filters.splice(index, 1)[0];
						disp.filters = filters;
						return filter;
					}
					else return filters[index];
				}
			}
		}
		return null;
	}
	
	/**
	 * @private
	 * Add a filter to a display object
	 */
	static public function addFilter(disp:DisplayObject, filter:BitmapFilter):Void
	{
		//var filters:Array<Dynamic> = disp.filters || [];
		#if flash
			var filters:Array<flash.filters.BitmapFilter> = if (disp.filters.length > 0) disp.filters else [];
		#else
			var filters:Array<Dynamic> = if (disp.filters.length > 0) disp.filters else [];
		#end
		filters.push(filter);
		disp.filters = filters;
	}
	
	/**
	 * @private
	 * Filter properties which can not be animated
	 */
	static public inline var fixedProp:Dynamic = { quality:true, color:true };
	
	private var properties:Array<Dynamic>;
	private var fvalue:BitmapFilter;
	private var start:Dynamic;
	private var delta:Dynamic;
	private var fColor:Dynamic;
	private var startColor:Dynamic;
	private var deltaColor:Dynamic;
	private var removeWhenComplete:Bool;
	private var isNewFilter:Bool;
	private var filterClass:Dynamic;
	
	function new(target:Dynamic, property:Dynamic, value:Dynamic, next:EazeSpecial)
	{
		super(target, property, value, next);
		
		filterClass = resolveFilterClass(property);
		
		var disp:DisplayObject = cast(target,DisplayObject);
		var current:BitmapFilter = PropertyFilter.getCurrentFilter(filterClass, disp, false); // read filter only
		if (current==null)
		{
			isNewFilter = true;
			current = Type.createInstance(filterClass,[]);
		}
		
		properties = [];
		fvalue = current.clone();
		//for (prop in Reflect.fields(value))
		for (prop in Reflect.fields(value))
		{
			//var val:Dynamic = Reflect.field(value, prop);
			var val:Dynamic = Reflect.getProperty(value, prop);
			if (prop == "remove") 
			{
				// special: remove filter when tween ends
				removeWhenComplete = val;
			}
			else
			{
				if (prop == "color" && !isNewFilter)
					fColor = { r:(val >> 16) & 0xff, g:(val >> 8) & 0xff, b:val & 0xff };
				//Reflect.setField(fvalue, prop, val);
				Reflect.setProperty(fvalue, prop, val);
				properties.push(prop);
			}
		}
	}
	
	private function resolveFilterClass(property:Dynamic):Dynamic
	{
		if (Std.is(property, Class)) return property;
		switch (property)
		{
			case "blurFilter": return BlurFilter;
			case "glowFilter": return GlowFilter;
			case "dropShadowFilter": return DropShadowFilter;
		}
		return BlurFilter;
	}
	
	override public function init(reverse:Bool):Void 
	{
		var disp:DisplayObject = cast(target,DisplayObject);
		var current:BitmapFilter = PropertyFilter.getCurrentFilter(filterClass, disp, true); // get and remove
		if (current==null) {
			current = Type.createInstance(filterClass,[]);
			//current = new filterClass();
		}
		
		var begin:BitmapFilter;
		var end:BitmapFilter;
		var curColor:Dynamic = null;
		var endColor:Dynamic = null;
		var val:Dynamic;
		
		if (fColor!=null) 
		{
			//val = Reflect.field(current,"color");
			val = Reflect.getProperty(current,"color");
			curColor = { r:(val >> 16) & 0xff, g:(val >> 8) & 0xff, b:val & 0xff };
		}
		if (reverse) { 
			begin = fvalue; 
			end = current; 
			startColor = fColor; 
			endColor = curColor; 
		}
		else { 
			begin = current; 
			end = fvalue; 
			startColor = curColor; 
			endColor = fColor; 
		}
		
		start = { };
		delta = { };
		
		for (i in 0...properties.length) 
		{
			var prop:String = properties[i];
			//val = Reflect.field(fvalue,prop);
			val = Reflect.getProperty(fvalue,prop);
			if (Std.is(val, Bool))
			{
				// filter options set immediately
				//Reflect.setField(current, prop, val);
				Reflect.setProperty(current, prop, val);
				properties[i] = null;
				continue;
			}
			else if (isNewFilter) 
			{
				// object did not have the filter, initialize it
				if (Reflect.hasField(fixedProp,prop)) 
				{
					// set property and do not tween it
					//Reflect.setField(current, prop, val);
					Reflect.setProperty(current, prop, val);
					properties[i] = null;
					continue;
				}
				else 
				{
					// set to 0
					//Reflect.setField(current, prop, 0);
					Reflect.setProperty(current, prop, 0);
				}
			}
			else if (prop == "color" && fColor)
			{
				// decompose color for tweening
				deltaColor = { 
					r:endColor.r - startColor.r,
					g:endColor.g - startColor.g,
					b:endColor.b - startColor.b
				};
				properties[i] = null; // not tweened
				continue;
			}
			//Reflect.setField(start, prop, Reflect.field(begin, prop));
			Reflect.setProperty(start, prop, Reflect.getProperty(begin, prop));
			//Reflect.setField(delta, prop, Reflect.field(end, prop) - Reflect.field(start, prop));
			Reflect.setProperty(delta, prop, Reflect.getProperty(end, prop) - Reflect.getProperty(start, prop));
		}
		fvalue = null;
		fColor = null;
		
		PropertyFilter.addFilter(disp, begin);
	}
	
	override public function update(ke:Float, isComplete:Bool):Void
	{
		var disp:DisplayObject = cast(target,DisplayObject);
		var current:BitmapFilter = PropertyFilter.getCurrentFilter(filterClass, disp, true); // and remove
		
		if (removeWhenComplete && isComplete) 
		{
			disp.filters = disp.filters;
			return;
		}
		
		if (current==null) {
			current = Type.createInstance(filterClass,[]);
		}
		
		for (i in 0...properties.length) 
		{
			var prop:String = properties[i];
			if (prop!=null)
			{
				//Reflect.setField(current, prop, Reflect.field(start, prop) + ke * Reflect.field(delta, prop));
				Reflect.setProperty(current, prop, Reflect.getProperty(start, prop) + ke * Reflect.getProperty(delta, prop));
			}
		}
		if (startColor!=null)
		{
			var tmpcolor = 
				((startColor.r + ke * deltaColor.r) << 16)
				| ((startColor.g + ke * deltaColor.g) << 8)
				| (startColor.b + ke * deltaColor.b);
			//Reflect.setField(current, "color", tmpcolor);
			Reflect.setProperty(current, "color", tmpcolor);
		}
		
		PropertyFilter.addFilter(disp, current);
	}
		
	override public function dispose():Void
	{
		filterClass = null;
		start = delta = null;
		startColor = deltaColor = null;
		fvalue = null; fColor = null;
		properties = null;
		super.dispose();
	}
}

