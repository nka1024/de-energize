package actor;
import aze.motion.EazeTween;
import building.Building;
import com.haxepunk.Entity;
import game.city.City;
import logic.CityGrid;
import nme.geom.Point;
import ui.Minimap;

/**
 * ...
 * @author k.nepomnyaschiy
 */

class Enemy extends Entity
{
	
	private var grid:CityGrid;
	private var minimap:Minimap;
	private var city:City;
	
	private var pos:Point;
	public var spot:Point;
	
	private var speed:Point;
	
	private var dead:Bool;
	public function new(_grid:CityGrid, _minimap:Minimap, _city:City)
	{
		dead = false;
		city = _city;
		grid = _grid;
		minimap = _minimap;
		
		pos = new Point(
					Math.floor(Math.random() * grid.size),
					Math.floor(Math.random() * grid.size));
		
		speed = new Point(
					Math.random() > 0.5 ? -1:1,
					Math.random() > 0.5 ? -1:1);
		
		spot = pos.clone();
		minimap.enemies.push(this);
		
		super();
	}
	
	override public function added():Void
	{
		super.added();
		
		delayMove();
	}
	
	private function delayMove():Void
	{
		EazeTween.eaze(this)
			.delay(0.5, false)
			.onComplete(move, []);
	}
	
	private function move():Void
	{
		if (dead)
			return;
		delayMove();
		
		if (minimap.get(pos.x + speed.x, pos.y) == 0)
		{
			var b:Building = grid.getBuilding(pos.x + speed.x, pos.y);
			if (b != null && b.touched && !b.halted)
			{
				city.restart();
				die();
				return;
			}
				
			speed.x = -speed.x;
		}
		pos.x += speed.x;
		
		if (minimap.get(pos.x, pos.y + speed.y) == 0)
		{
			var b:Building = grid.getBuilding(pos.x, pos.y + speed.y);
			if (b != null && b.touched && !b.halted)
			{
				city.restart();
				die();
				return;
			}
				
			speed.y = -speed.y;
		}
		pos.y += speed.y;
		
		
		if (minimap.get(pos.x, pos.y) == 0)
		{
			die();
		}
		
		if (spot != null)
			EazeTween.eaze(spot)
				.to(0.1, { x:pos.x, y:pos.y }, false );
			
	}
	
	private function die():Void
	{
		EazeTween.killTweensOf(this);
		spot = null;
	}
}