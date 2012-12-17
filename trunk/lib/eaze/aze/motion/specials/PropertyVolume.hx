package aze.motion.specials;

import aze.motion.EazeTween;
import aze.motion.specials.PropertyVolume;
import aze.motion.specials.EazeSpecial;

#if flash
import flash.media.SoundMixer;
import flash.media.SoundTransform;
#else
import nme.media.SoundTransform;
#end

/**
 * Volume tweening as a special property
 * @author Philippe / http://philippe.elsass.me
 */
class PropertyVolume extends EazeSpecial
{
	static public function register():Void
	{
		//EazeTween.specialProperties.volume = PropertyVolume;
		EazeTween.specialProperties.set("volume", PropertyVolume);
	}
	
	private var start:Float;
	private var delta:Float;
	private var vvalue:Float;
	private var targetVolume:Bool;
	
	public function new(target:Dynamic, property:Dynamic, value:Dynamic, next:EazeSpecial)
	{
		super(target, property, value, next);
		vvalue = value;
	}
	
	override public function init(reverse:Bool):Void 
	{
		targetVolume = Reflect.hasField(target, "soundTransform");// && (target.soundTransform != null);
		var st:SoundTransform = targetVolume ? target.soundTransform : SoundMixer.soundTransform;
		
		var end:Float;
		if (reverse) { start = vvalue; end = st.volume; }
		else { end = vvalue; start = st.volume; }
		
		delta = end - start;
	}
	
	override public function update(ke:Float, isComplete:Bool):Void 
	{
		var st:SoundTransform = targetVolume ? target.soundTransform : SoundMixer.soundTransform;
		
		st.volume = start + delta * ke;
		
		if (targetVolume) target.soundTransform = st;
		else SoundMixer.soundTransform = st;
	}
}

