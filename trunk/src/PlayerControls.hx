package ;
import com.haxepunk.utils.Input;

/**
 * ...
 * @author k.nepomnyaschiy
 */

class PlayerControls
{

	public function new()
	{
		
	}
	
	public static function needToGoLeft():Bool
	{
		return Input.check("left");
	}
	public static function needToGoRight():Bool
	{
		return Input.check("right");
	}
	public static function needToGoUp():Bool
	{
		return Input.check("up");
	}
	public static function needToGoDown():Bool
	{
		return Input.check("down");
	}
	public static function needToPickup():Bool
	{
		return Input.check("action");
	}
	public static function needToShoot():Bool
	{
		return Input.check("shoot");
	}
	static public function needToRestart()
	{
		return Input.pressed("restart");
	}
	
	public static function needToZoomIn():Bool
	{
		return Input.check("zoom_in");
	}
	static public function needToZoomOut()
	{
		return Input.check("zoom_out");
	}
	
}

