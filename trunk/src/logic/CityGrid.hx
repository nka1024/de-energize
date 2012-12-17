package logic;
import building.Building;
import com.haxepunk.Entity;
import nme.geom.Point;
import nme.geom.Rectangle;

/**
 * ...
 * @author k.nepomnyaschiy
 */

class CityGrid
{
	public static var gridCellRect:Rectangle;
	
	public var width:Float;
	public var height:Float;
	public var spacing:Float;
	public var size:Float;
		
	private var cells:Array < Array<Building>>;
	
	/**
	 * Creates the city grid
	 * @param	width	grid cell width
	 * @param	height	grid cell height
	 * @param	spacing	cells spacing
	 * @param	size	grid side in cells
	 */
	public function new(width:Float, height:Float, spacing:Float, size:Float)
	{
		this.width = width;
		this.height = height;
		this.spacing = spacing;
		this.size = size;
		resetArray();
		
		gridCellRect = new Rectangle(0, 0, width, height);
	}
	
	/**
	 * Create new array and fill it with nulls
	 */
	private function resetArray():Void
	{
		cells = new Array<Array<Building>>();
		for (x in 0...Std.int(size))
		{
			cells[x] = new Array<Building>();
			for (y in 0...Std.int(size))
			{
				cells[x][y] = null;
			}
		}
	}
	
	public function iterateAll(_func:Dynamic->Building):Void
	{
		var func = callback(_func);
		
		for (x in 0...Std.int(size))
		{
			for (y in 0...Std.int(size))
			{
				cells[x][y] = func({o:cells[x][y], x:x, y:y});
			}
		}
	}
	
	public function getRandomBuilding():Building
	{
		var x:Int = Math.floor(Math.random() * cells.length);
		var y:Int = Math.floor(Math.random() * cells[x].length);
		
		return cells[x][y];
	}
	
	public function getBuilding(_x:Float, _y:Float):Building
	{
		if (cells.length <= _x || _x < 0)
			return null;
		if (cells[Std.int(_x)].length <= _y || _y < 0)
			return null;
		
		return cells[Std.int(_x)][Std.int(_y)];
	}
	
	public function getCellCenter(_x:Int, _y:Int):Point
	{
		var spot:Point = new Point();
		spot.x = width * (_x+0.5) + spacing * (_x);
		spot.y = width * (_y+0.5) + spacing * (_y);
		
		return spot;
	}
	
	
}