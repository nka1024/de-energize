package game;
import actor.Player;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.World;
import Global;

/**
 * ...
 * @author k.nepomnyaschiy
 */

class Game extends World
{

	private var player:Player;
	
	public function new()
	{
		super();
	}
	
	override public function update():Dynamic
	{
		super.update();
		
		if (PlayerControls.needToRestart())
			restart();
		
		if (Input.pressed(Key.M))
			if (Global.music.volume > 0)
				Global.music.volume = 0;
			else
				Global.music.volume = 0.6;
			
		if (PlayerControls.needToZoomIn())
			Global.zoom += 0.01;
		if (PlayerControls.needToZoomOut())
			Global.zoom -= 0.01;
	}
	
	override public function begin()
	{
		load_background();
	}
	
	private function load_background():Void
	{
		
	}
	
	
	public function restart():Void
	{
		HXP.world = Type.createInstance(Type.getClass(this), []);
	}
	
}