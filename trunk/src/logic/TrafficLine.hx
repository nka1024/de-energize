package logic;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;
import nme.Assets;
import nme.display.BitmapData;
import nme.geom.Point;

/**
 * ...
 * @author k.nepomnyaschiy
 */

class TrafficLine extends Entity
{
	private var __toX:Float;
	private var __toY:Float;
	private var __vehicles:Array<Point>;
	private var __velocity:Array<Float>;
		
	private static var __imgRedLights:Image;
	private static var __imgWhiteLights:Image;
	
	public static inline var MAX_DISTANCE:Float = 300;
	
	public function new(_x:Float, _y:Float, _toX:Float, _toY:Float)
	{
		super(_x, _y);
	
		__toX = _toX;
		__toY = _toY;
		
		layer = 999999;
		
		__imgRedLights = new Image(Assets.getBitmapData("gfx/red_lights.png"));
		__imgWhiteLights = new Image(Assets.getBitmapData("gfx/white_lights.png"));
	}
	
	
	
	override public function added():Void
	{
		super.added();
	
		__vehicles = [];
		__velocity = [];
		var _vehicle:Point;
		
		var COUNT:Int = 99+ Global.level*10;
		for (i in 0...COUNT)
		{
			_vehicle = new Point();
			_vehicle.x = x + (__toX - x) * (i + Math.random() * 10) / COUNT;
			_vehicle.y = y + (__toY - y) * (i + Math.random() * 10) / COUNT;
			__vehicles.push(_vehicle);
			__velocity.push(Math.random()/3);
		}
	}
	
	
	
	override public function render():Void
	{
		super.render();
		
		var vertical:Bool = (__toX - x) == 0;
		var horizontal:Bool = (__toY - y) == 0;
		
		var _camCenter:Point = new Point ();
		_camCenter.x = HXP.camera.x + HXP.halfWidth;
		_camCenter.y = HXP.camera.y + HXP.halfHeight;
		
		var _id:Int = 0;
		var _color:Int = 0;
		for(_vehicle in __vehicles)
		{
			if (vertical)
			{
				_vehicle.y +=  (__toY - y) * 0.001 * __velocity[_id];
				
				var _up:Bool = __toY - y < 0;
				var _down:Bool = __toY - y > 0;
				
				if (_down && _vehicle.y > __toY)	_vehicle.y = y;
				else if (_up && _vehicle.y < __toY)	_vehicle.y = y;
					
				if (_down)		_color = _vehicle.y > _camCenter.y ? 0xff0000 : 0xffffff;
				else if (_up)	_color = _vehicle.y < _camCenter.y ? 0xff0000 : 0xffffff;
			}
			else if (horizontal)
			{
				_vehicle.x +=  (__toX - x) * 0.001 * __velocity[_id];
				
				var _left:Bool = __toX - x < 0;
				var _right:Bool = __toX - x > 0;
				
				if (_right && _vehicle.x > __toX)	_vehicle.x = x;
				else if (_left && _vehicle.x < __toX)	_vehicle.x = x;
					
				if (_right)		_color = _vehicle.x > _camCenter.x ? 0xff0000 : 0xffffff;
				else if (_left)	_color = _vehicle.x < _camCenter.x ? 0xff0000 : 0xffffff;
			}
			
			//if (HXP.distance(_vehicle.x, _vehicle.y, _camCenter.x, _camCenter.y) < MAX_DISTANCE)
				Draw.graphic(_color == 0xff0000 ? __imgRedLights : __imgWhiteLights, Std.int(_vehicle.x - 8), Std.int(_vehicle.y - 8));
			
			_id++;
		}
		
	}
	
	
	
}