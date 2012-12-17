package aze.motion.specials;

import aze.motion.EazeTween;
import aze.motion.specials.PropertyFrame;
import aze.motion.specials.EazeSpecial;

#if flash
import flash.display.MovieClip;
#else
import nme.display.MovieClip;
#end


/**
 * Frame tweening as a special property
 * @author Philippe / http://philippe.elsass.me
 */
class PropertyFrame extends EazeSpecial
{
	static public function register():Void
	{
		//EazeTween.specialProperties.frame = PropertyFrame;
		EazeTween.specialProperties.set("frame", PropertyFrame);
	}
	
	private var start:Int;
	private var delta:Int;
	private var frameStart:Dynamic;
	private var frameEnd:Dynamic;
	
	public function new(target:Dynamic, property:Dynamic, value:Dynamic, next:EazeSpecial)
	{
		super(target, property, value, next);
	
		//var mc:MovieClip = cast( target, MovieClip );
		var mc:Dynamic = target;
		
		var parts:Array<Dynamic>;
		if ( Std.is(value, String) ) 
		{
			// smart frame label handling
			var label:String = value;
			if (label.indexOf("+") > 0) 
			{
				parts = label.split("+");
				frameStart = parts[0];
				frameEnd = label;
			}
			else if (label.indexOf(">") > 0) 
			{
				parts = label.split(">");
				frameStart = parts[0];
				frameEnd = parts[1];
			}
			else frameEnd = label;
		}
		else 
		{
			// numeric frame index
			var index:Int = value;
			if (index <= 0) index += mc.totalFrames;
			frameEnd = Math.max(1, Math.min(mc.totalFrames, index));
		}
	}
	
	override public function init(reverse:Bool):Void 
	{
		//var mc:MovieClip = cast( target, MovieClip );
		var mc:Dynamic = target;

		// convert labels to num
		if ( Std.is(frameStart, String) ) frameStart = findLabel(mc, frameStart);
		else frameStart = mc.currentFrame;
		if ( Std.is(frameEnd, String) ) frameEnd = findLabel(mc, frameEnd);
		
		if (reverse) { 
			start = frameEnd;
			delta = Std.int(frameStart) - start; 
		}
		else { start = frameStart; delta = Std.int(frameEnd) - start; }
		
		mc.gotoAndStop(start);
	}
	
	private function findLabel(mc:MovieClip, name:String):Int
	{
		#if flash
		for(label in mc.currentLabels.iterator())
			if (label.name == name) return label.frame;
		#end
		return 1;
	}
	
	override public function update(ke:Float, isComplete:Bool):Void
	{
		//var mc:MovieClip = cast( target, MovieClip );
		var mc:Dynamic = target;

		mc.gotoAndStop(Math.round(start + delta * ke));
	}
	
	public function getPreferredDuration():Float
	{
		//var mc:MovieClip = cast( target, MovieClip );
		var mc:Dynamic = target;
		
		var fps:Float = mc.stage != null ? mc.stage.frameRate : 30;
		return Math.abs(delta / fps);
	}
}

