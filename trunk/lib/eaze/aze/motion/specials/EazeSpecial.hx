package aze.motion.specials;

import aze.motion.specials.EazeSpecial;

/**
 * ...
 * @author Philippe / http://philippe.elsass.me
 */
class EazeSpecial
{
	private var target:Dynamic;
	private var property:String;
	public var next:EazeSpecial;
	
	/**
	 * Configure special tween
	 * @param	target	Target object
	 * @param	prop	Special property name
	 * @param	value	Special property parameter(s)
	 * @param	reverse	Animate "from" value instead of "to" value
	 * @param	next	Reference to another special tween
	 */
	public function new(target:Dynamic, property:Dynamic, value:Dynamic, next:EazeSpecial)
	{
		this.target = target;
		this.property = property;
		this.next = next;
	}
	
	/**
	 * Prepare tween first use (ie. read "start" value);
	 */
	public function init(reverse:Bool):Void
	{
		
	}
	
	public function update(ke:Float, isComplete:Bool):Void
	{
		
	}
	
	public function dispose():Void
	{
		target = null;
		if (next!=null) next.dispose();
		next = null;
	}
}

