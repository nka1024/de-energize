package building;
import aze.motion.EazeTween;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;
import nme.Assets;
import nme.geom.Point;
import logic.CityGrid;
import nme.geom.Rectangle;
import Global;

/**
 * ...
 * @author k.nepomnyaschiy
 */

class Building extends Entity
{
	public static inline var MAX_FLOORS:Float = 300;
	public static inline var MAX_DISTANCE:Float = 300;
	
	private var color:Int;
	public var floorsCount(getFloorsCount, setFloorsCount):Int;
	private var floors:Array<Floor>;
	
	public var camAngle:Float;
	public var camDistance:Float;
		
	private var direction:Int;
	
	public var topRect:Rectangle;
	public var topRectBB:Rectangle;
	
	private var touchedShadowing:Float = 0;
	public var halted:Bool;
	public var touched(getTouched, setTouched):Bool;
	private function getTouched():Bool { return touched; }
	private function setTouched(value:Bool):Bool
	{
		if (value && !touched)
		{
			EazeTween.eaze(this)
				.to(0.2, {touchedShadowing:1}, false)
				.onUpdate(function():Void {
					color = HXP.colorLerp(0xffffff, Std.int(0x202020), touchedShadowing);
				}, []);
		}
		
		if (!value && touched)
		{
			EazeTween.eaze(this)
				.to(0.2, {touchedShadowing:0}, false)
				.onUpdate(function():Void {
					color = HXP.colorLerp(0xffffff, Std.int(0x202020), touchedShadowing);
				}, []);
		}
		
		touched = value;
		return touched;
	}
	
	private static var __imgBlueLights:Image;
	
	public function new(X:Float = 0, Y:Float = 0)
	{
		touched = halted = !Global.visible;
		
		super(X, Y);
		setFloorsCount(Std.int(Math.random() * MAX_FLOORS + 1));
		color = Global.visible ? 0xffffff : 0x202020;
		
		width = Std.int(floors[0].rect.width);
		height = Std.int(floors[0].rect.height);
		
		var rectBorders:Rectangle = CityGrid.gridCellRect;
		x += (rectBorders.width - width)/2;
		y += (rectBorders.height - height)/2;
		
		type = "building";
		
		direction = Math.random() > 0.5? 1: -1;
		
		__imgBlueLights = new Image(Assets.getBitmapData("gfx/red_lights.png"));
	}

	
	public function setFloorsCount(count:Int):Int
	{
		clearFloors();
		
		for (i in 1...count+1)
		{
			floors.push(floorFactoryMethod());
		}
		
		return count;
	}
	public function getFloorsCount():Int
	{
		return (floors == null) ? 0 : floors.length;
	}
	
	private function floorFactoryMethod():Floor
	{
		var prevFloor:Floor = floors[floors.length - 1];
		
		return (prevFloor == null) ? new Floor() : new Floor(prevFloor);
	}
	
	private function clearFloors():Void
	{
		floors = new Array<Floor>();
	}
	
	override public function update():Void
	{
		super.update();
		
		var __zoom:Float = Global.zoom +Global.level/100;
		
		var __camCenter:Point = new Point ();
		__camCenter.x = HXP.camera.x + HXP.halfWidth;
		__camCenter.y = HXP.camera.y + HXP.halfHeight;
			
		var __distance:Float = HXP.distanceRectPoint(__camCenter.x, __camCenter.y, x, y, width, height);
		if (__distance > MAX_DISTANCE + 100 )
			return;
		
		layer = Std.int(__distance);
	}
	
	override public function render():Void
	{
		var zoom:Float = Global.zoom +Global.level/100;
	
		var camCenter:Point = new Point ();
		camCenter.x = HXP.camera.x + HXP.halfWidth;
		camCenter.y = HXP.camera.y + HXP.halfHeight;
		
		var shadowing:Float = HXP.distanceRectPoint(camCenter.x, camCenter.y, x, y, width, height);
		if (shadowing > MAX_DISTANCE )
			return;
			
		shadowing /= MAX_DISTANCE;
		
		if (!visible) return;
		
		var pit:Float = 0;
		
		for (floor in floors)
		{
			pit = floor.pit ? 0.1 : 0;
				
			var d_cam_x:Float = (x - camCenter.x) * (floor.id) / 20;
			var d_cam_y:Float = (y - camCenter.y) * (floor.id) / 20;
			
			var shaded:Int = HXP.colorLerp(color, HXP.screen.color, shadowing + pit + floor.id / MAX_FLOORS/1.5);
			var offset:Float = floor.id ;
			
			topRect = new Rectangle(
					x + floor.rect.x + (d_cam_x + offset) * zoom,
					y + floor.rect.y + (d_cam_y + offset) * zoom,
					floor.rect.width + (offset) * zoom,
					floor.rect.height + (offset) * zoom
				);
				
			Draw.rect(Std.int(topRect.x), Std.int(topRect.y), Std.int(topRect.width), Std.int(topRect.height), shaded);
			
			if ((floor.pit && floor.glow != 0) || floor == floors[floorsCount - 1])
			{
				var THICKNESS:Int = 1;
				
				if (touched)
				{
					Draw.graphic(__imgBlueLights, Std.int(topRect.x-9), Std.int(topRect.y-8));
					Draw.graphic(__imgBlueLights, Std.int(topRect.x + topRect.width-9), Std.int(topRect.y-8));
					Draw.graphic(__imgBlueLights, Std.int(topRect.x + topRect.width-9), Std.int(topRect.y + topRect.height-8));
					Draw.graphic(__imgBlueLights, Std.int(topRect.x - 9), Std.int(topRect.y + topRect.height - 8));
				}
			}
		}
		topRectBB = floors[floorsCount - 1].rect.clone();
	}
}

class Floor
{
	public static inline var MAX_FLOOR_HEIGHT:Float = 5;
	
	public var id:Float;
	public var height:Float;
	public var rect:Rectangle;
	public var pit:Bool;
	public var glow:Int;
	
	/**
	 * Narrowing rate (0...1)
	 */
	public function new(prev:Floor = null, _height:Float = 0)
	{
		pit = prev == null ? false : prev.pit;
		
		if (_height == 0)
			height = randomHeight();
		
		id = (prev == null) ? 0 : prev.id + 1;
		
		var rectBorders:Rectangle = CityGrid.gridCellRect;
		
		var newWidth:Int = Std.int(20 + Math.random() * (rectBorders.width - 20));
		var newHeight:Int = Std.int(20 + Math.random() * (rectBorders.height - 20));
		
		if (prev == null)
			rect = new Rectangle(0, 0, newWidth, newHeight);
		else
			rect = getRandomInnerRect(prev.rect);
	}
	
	private function getRandomInnerRect(baseRect:Rectangle):Rectangle
	{
		var result:Rectangle = baseRect.clone();
		
		if (pit)
		{
			result.width  *=  Math.random() ;
			result.height *=  Math.random() ;
		}
		
		pit = Math.random() > 0.98;
		
		glow = id > 150 ?  0xff0000 : 0;
			
		var dWidth  = baseRect.width  - result.width;
		var dHeight = baseRect.height - result.height;
		
		result.x += Math.random() * dWidth/2;
		result.y += Math.random() * dHeight/2;
		
		return result;
	}
	
	private function randomHeight()
	{
		return Math.random() * 10;
	}
	
}