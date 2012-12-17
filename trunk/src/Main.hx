package ;

import com.haxepunk.Engine;
import com.haxepunk.HXP;
import com.haxepunk.Sfx;
import com.haxepunk.World;
import game.city.City;
import game.city.Menu;
import Global;
import nme.Assets;


import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;

/**
 * ...
 * @author k.nepomnyaschiy
 */

class Main extends Engine
{
	private var w:World;
	
	public function new()
	{
		super(800, 480, 60, true);
	}
	
	override public function init():Dynamic
	{
		Global.init();
		
		HXP.world = new Menu();
		HXP.screen.color = 0;
		
		Global.music = new Sfx(Assets.getSound("sfx/theme.wav"));
		Global.music.play();
		Global.music.loop();
		Global.music.volume = 0.6;
	}
	
}
