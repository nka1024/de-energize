package game.city;
import actor.Enemy;
import actor.Player;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import game.Game;
import logic.BuildingsLayer;
import logic.CityGrid;
import logic.TrafficLine;
import building.Building;
import nme.geom.Point;
import ui.HUD;
import ui.Minimap;

/**
 * ...
 * @author k.nepomnyaschiy
 */

class Menu extends Game
{
	private var time:Float;
	private var buildingsLayer:BuildingsLayer;
	private var minimap:Minimap;
	
	public function new()
	{
		super();
		
		buildingsLayer = new BuildingsLayer(init, 40, 40, 20, 20);
		Global.visible = false;
		minimap = new Minimap(buildingsLayer.grid);
		
		time = 0;
	}
	
	override public function begin():Dynamic
	{
		super.begin();
		
		add(buildingsLayer);
	}
	
	override public function update():Dynamic
	{
		if (Input.pressed(Key.M))
			Global.music.volume = 0;
		else if (Input.pressed(Key.ANY))
			HXP.world = new City();
		
		return super.update();
	}
	
	private function init():Dynamic
	{
		var _grid:CityGrid = buildingsLayer.grid;
		
		HXP.camera.x = -200;
		HXP.camera.y = -200;
		
		var MIN:Int = -4;
		var MAX:Int = Std.int(_grid.size+2);
		
		for (i in MIN...MAX)
		{
			var _x1:Float = _grid.width * i + _grid.spacing * (i-0.7);
			var _x2:Float = _grid.width * i + _grid.spacing * (i-0.3);
			var _toY:Float = _grid.height * MAX + _grid.spacing * MAX;
			var _fromY:Float = _grid.height * MIN + _grid.spacing * MIN;
			
			var _y1:Float = _grid.height * i + _grid.spacing * (i-0.7);
			var _y2:Float = _grid.height * i + _grid.spacing * (i-0.3);
			var _toX:Float = _grid.width * MAX + _grid.spacing * MAX;
			var _fromX:Float = _grid.width * MIN + _grid.spacing * MIN;
			
			add (new TrafficLine(_x1, _fromY, _x1, _toY));
			add (new TrafficLine(_x2, _toY, _x2, _fromY));
			
			add (new TrafficLine(_fromX, _y1, _toX, _y1));
			add (new TrafficLine(_toX, _y2, _fromX, _y2));
		}
		
	}
	
	
	
	override public function render():Dynamic
	{
		super.render();
		
		var p:Point = new Point(0,0);
		HUD.showTitle(HXP.halfWidth-70, 150 );
		HUD.showCopyright(HXP.halfWidth - 63, 220 );
		HUD.showMyName(HXP.width - 210, HXP.height -20 );
	
	}
	
}