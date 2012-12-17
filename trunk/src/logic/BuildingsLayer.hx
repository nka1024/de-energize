package logic;
import building.Building;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import nme.geom.Point;
import logic.BuildingFactory;

/**
 * ...
 * @author k.nepomnyaschiy
 */

class BuildingsLayer extends Entity
{
	private var buildingFactory:BuildingFactory;
	public var grid:CityGrid;
	private var _cb:Void->Dynamic;
	public function new(__cb:Void->Dynamic, _a:Float, _b:Float, _c:Float, _d:Float )
	{
		super();
		
		_cb = __cb;
		
		//grid = new CityGrid(100, 100, 20, 30);
		grid = new CityGrid(_a, _b, _c, _d);
		buildingFactory = new BuildingFactory();
	}
	
	override public function added():Void
	{
		populateRandom();
	}
	
	public function populateRandom():Void
	{
		grid.iterateAll(function(args:Dynamic):Building
			{
				var o:Building = args.o;
				o = buildingFactory.getRandomBuilding();
				o.x = args.x * (grid.width + grid.spacing);
				o.y = args.y * (grid.height + grid.spacing);
				
				world.add(o);
				return o;
			}
		);
		
		_cb();
	}
	
}