package ui;
import actor.Enemy;
import building.Building;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;
import logic.CityGrid;
import nme.geom.Point;

/**
 * ...
 * @author k.nepomnyaschiy
 */

class Minimap extends Entity
{
	private var cells:Array<Array<Int>>;
	private var labels:Array<Array<Int>>;
	private var grid:CityGrid;
	
	public var player:Point;
	public var enemies:Array<Enemy>;
	
	public var cropped:Float;
	private var filled:Float;
	public function new(grid:CityGrid)
	{
		cropped = 0;
		filled = 0;
		this.grid = grid;
		player = new Point();
		
		
		
		enemies = [];
		resetArray();
		super();
		
		layer = - 999999;
	}
	
	private function resetArray():Void
	{
		cells = new Array<Array<Int>>();
		for (x in 0...Std.int(grid.size))
		{
			cells[x] = new Array<Int>();
			for (y in 0...Std.int(grid.size))
				cells[x][y] = 1;
		}
	}
	
	public function set(_x:Float, _y:Float, _mark:Int):Void
	{
		if (cells.length <= _x || _x < 0)				return;
		if (cells[Std.int(_x)].length <= _y || _y < 0)	return;
			
		cells[Std.int(_x)][Std.int(_y)] = _mark;
	}
	
	public function get(_x:Float, _y:Float):Int
	{
		if (cells.length <= _x || _x < 0) 				return 0;
		if (cells[Std.int(_x)].length <= _y || _y < 0)	return 0;
			
		return cells[Std.int(_x)][Std.int(_y)];
	}
	
	override public function render():Void
	{
		var alpha:Float = 0.9;
		var size:Int = 5;
		var a:Point = new Point(HXP.camera.x + HXP.halfWidth + 50 , HXP.camera.y + HXP.halfHeight - size * grid.size/2 );
		x = a.x;
		y = a.y;
		
		for (_x in 0...Std.int(grid.size))
		{
			for (_y in 0...Std.int(grid.size))
			{
				if (get(_x, _y) == 1)
				{
					Draw.rect(Std.int(a.x + _x*size), Std.int(a.y+ _y*size), size, size, 0x0a3e05, alpha);
				}
			}
		}
		
		if (player != null)
			Draw.rect(Std.int(a.x + player.x*size), Std.int(a.y+ player.y*size), size, size, 0xffffff, 1);
		
		for (enemy in enemies)
		{
			if (enemy.spot != null)
			Draw.rect(Std.int(a.x + enemy.spot.x * size), Std.int(a.y + enemy.spot.y * size), size, size, 0xff0000, 1);
		}
			
		height = width = Std.int(grid.size * size);
		super.render();
	}
	
	public function crop():Void
	{
		labels = new Array<Array<Int>>();
		for (_x in 0...Std.int(grid.size))
		{
			labels[_x] = [];
			for (_y in 0...Std.int(grid.size))
			{
				labels[_x][_y] = 0;
			}
		}
		
		labeling();
		
		
		var all:Array<Int> = [];
		
		for (line in labels)
			all = all.concat(line);
		
		all.sort(function (a:Int, b:Int):Int {
			if (a == b)
				return 0;
			else if (a > b)
				return 1;
			else
				return -1;
		} );
		
		var maxCountValue:Int = 0;
		var maxCountToken:Int = 0;
		var currentCount:Int = 0;
		var lastToken:Int = 0;
		for (i in 0...all.length)
		{
			var token:Int = all.pop();
			if (token == lastToken)
				currentCount++;
			else
			{
				if (currentCount > maxCountValue)
				{
					maxCountToken = lastToken;
					maxCountValue = currentCount;
				}
				currentCount = 0;
			}
			lastToken = token;
		}
		
		
		for (_x in 0...Std.int(grid.size))
		{
			for (_y in 0...Std.int(grid.size))
			{
				if (labels[_x][_y] != maxCountToken)
				{
					var b:Building = grid.getBuilding(_x , _y);
					b.touched = true;
					b.halted = true;
					set(_x, _y, 0);
				}
				filled += get(_x, _y);
			}
		}
		
		cropped = 1 - filled / grid.size / grid.size;
		filled = 0;
	}
	
	private function labeling()
	{
		var L:Int = 1;
		
		for (_x in 0...Std.int(grid.size))
		{
			for (_y in 0...Std.int(grid.size))
			{
				fill(_x, _y, L++);
			}
		}
	}
	
	private function fill(_x:Int, _y:Int, L:Int)
	{
		if((labels[_x][_y] == 0) && (cells[_x][_y] == 1))
		{
			labels[_x][_y] = L;
			if( _x > 0 )
				fill(Std.int(_x - 1), _y, L);
			if( _x < grid.size - 1 )
				fill(Std.int(_x + 1), _y, L);
			if( _y > 0 )
				fill(_x, Std.int(_y - 1), L);
			if( _y < grid.size - 1 )
				fill(_x, Std.int(_y + 1), L);
		}
	}
	
	
}