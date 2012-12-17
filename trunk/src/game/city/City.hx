package game.city;
import actor.Enemy;
import actor.Player;
import com.haxepunk.HXP;
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

class City extends Game
{
	private var time:Float;
	private var buildingsLayer:BuildingsLayer;
	private var minimap:Minimap;
	
	public function new()
	{
		super();
		Global.visible = true;
		buildingsLayer = new BuildingsLayer(init, 30+Global.level*10, 30+Global.level*10, 20, 5 + Global.level*3);
		minimap = new Minimap(buildingsLayer.grid);
		
		time = 0;
	}
	
	override public function begin():Dynamic
	{
		super.begin();
		
		add(buildingsLayer);
		
		add(minimap);
	}
	
	override public function update():Dynamic
	{
		if (minimap.cropped > 0.5) {
			nextLevel();
		}
		
		time += HXP.elapsed;
		
		return super.update();
	}
	
	private function nextLevel()
	{
		Global.level++;
		restart();
	}
	
	private function init():Dynamic
	{
		var _grid:CityGrid = buildingsLayer.grid;
		
		add(player = new Player(0, 0));
		
		player.grid = _grid;
		player.minimap = minimap;
		
		player.jumpTo(-1,-1);
		
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
		
		for (i in 0...Global.level)
			add(new Enemy(_grid, minimap, this));
	}
	
	
	
	override public function render():Dynamic
	{
		super.render();
		var p:Point = new Point(minimap.x + 10 - HXP.camera.x, minimap.y - HXP.camera.y );
		var dy:Int = 15;
		
		HUD.showLevel(Global.level, p.x + minimap.width, p.y);
		HUD.showTime(time, p.x + minimap.width, p.y + 16);
	}
	
}