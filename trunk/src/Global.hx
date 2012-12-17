package ;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.Sfx;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;

/**
 * ...
 * @author k.nepomnyaschiy
 */

class Global
{
	public static var zoom:Float = 0.1;
	
	public static var level:Int = 1;
	
	/**
	 * Color schemes
	 */
	public static var base_colors:Dynamic 	= 	{ darkest:0x272B34, dark: 0x323336, normal:0x37393C, bright:0x46474B, brightest:0x46484B };
	public static var second_colors:Dynamic = 	{ darkest:0x4D4639, dark: 0x504F4B, normal:0x595752, bright:0x66635E, brightest:0x66645F };
	public static var blue_colors:Dynamic   = 	{ darkest:0x0A64A4, dark: 0x24577B, /**/normal:0x2F72D3, bright:0x3E94D1, brightest:0x65A5D1 };
	public static var yellow_colors:Dynamic =	{ darkest:0xFFD300, dark: 0xBFA730, /**/normal:0xF4CD27, bright:0xFFDE40, brightest:0xFFE773 };
	static public var visible:Bool = false;
	static public var music:Sfx;
	
	public static function init():Void
	{
		initControls();
	}
	
	private static function initControls():Void
	{
		Input.define("left", 	[Key.LEFT, 	Key.A]);
		Input.define("right", 	[Key.RIGHT, Key.D]);
		Input.define("up", 		[Key.UP, 	Key.W]);
		Input.define("down", 	[Key.DOWN,	Key.S]);
		Input.define("restart",	[Key.ESCAPE,Key.R]);
		Input.define("zoom_in",	[/*Key.NUMPAD_ADD*/]);
		Input.define("zoom_out",[/*Key.NUMPAD_SUBTRACT*/]);
	}
}