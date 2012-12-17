package actor;
import aze.motion.EazeTween;
import building.Building;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;
import com.haxepunk.utils.Input;
import logic.CityGrid;
import nme.Assets;
import nme.geom.Point;
import nme.geom.Rectangle;
import Global;
import ui.Minimap;

/**
 * ...
 * @author k.nepomnyaschiy
 */

class Player extends Entity
{
	private static var DEFAULT_WIDTH:Float = 2;
	private static var DEFAULT_HEIGHT:Float = 2;
	
	private var building:Building;
	public var grid:CityGrid;
	public var minimap:Minimap;
	private var pos:Point;
	private var canMoveX:Bool = true;
	private var canMoveY:Bool = true;
	public var inside:Bool = false;
	public var halted:Bool = false;
	private static inline var MOVE_TIME:Float = 1;
	
	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
		
		pos = new Point();
		
		vx = WALK_SPEED;
		vy = WALK_SPEED;
		layer = -99999;
		
		setHitbox(Std.int(DEFAULT_WIDTH), Std.int(DEFAULT_HEIGHT));
		centerOrigin();
	}
	
	public function jumpTo(xCord:Float, yCord:Float):Void
	{
		var _xCord:Int = Std.int(xCord);
		var _yCord:Int = Std.int(yCord);
		
		halted = false;
		
		var __building:Building = grid.getBuilding(_xCord, _yCord);
		if (__building != null)
		{
			building = __building;
			pos.x = _xCord;
			pos.y = _yCord;
			var rect:Rectangle =  __building.topRectBB;
			var spot:Point = new Point(	__building.centerX,	__building.centerY	);
				
			EazeTween.eaze(this)
				.to(MOVE_TIME, { x:spot.x, y:spot.y }, false);
				
			if (building.halted && inside)
				minimap.crop();
			else
				inside = true;
						
			building.touched = true;
			if (building.halted)
				halted = true;
			
		} else {
			pos.x = _xCord;
			pos.y = _yCord;
			
			var spot:Point = grid.getCellCenter(_xCord, _yCord);
			EazeTween.eaze(this)
				.to(MOVE_TIME, { x:spot.x, y:spot.y }, false);
				
			if (inside)
				minimap.crop();
			inside = false;
		}
		
		if (minimap != null)
		{
			minimap.set(pos.x, pos.y, 0);
			
			EazeTween.eaze(minimap.player)
				.to(0.1, { x:pos.x, y:pos.y }, false );
		}
	}
	
	override public function update():Void
	{
		move();
		moveCamera();
	}

	
	private function moveCamera()
	{
		HXP.camera.x = Std.int(x - HXP.width / 2);
		HXP.camera.y = Std.int(y - HXP.height / 2);
	}
	
	private static inline var WALK_SPEED:Float = 4;
	private var vx:Float;
	private var vy:Float;
	private var go:String;
	private function move():Void
	{
		if ((!inside || halted)&& ! (Input.check("left") || Input.check("right") || Input.check("up") || Input.check("down")))
			go = "";
			
		if (Input.pressed("left")) go = "left";
		if (Input.pressed("right")) go = "right";
		if (Input.pressed("up")) go = "up";
		if (Input.pressed("down")) go = "down";

		if (canMoveX)
		{
			var movex:Bool = true;
			
			if (go == "left")		jumpTo(pos.x-1, pos.y);
			else if (go =="right")	jumpTo(pos.x + 1, pos.y);
			else movex = false;
			
			if (movex)
			{
				canMoveX = false;
				EazeTween.eaze(this)
					.delay(0.2, false)
					.onComplete(function():Void { canMoveX = true; }, []);
			}
		}
		if (canMoveY)
		{
			var movey:Bool = true;
			
			if (go == "up")			jumpTo(pos.x, pos.y-1);
			else if (go =="down")	jumpTo(pos.x, pos.y+1);
			else movey = false;
			
			if (movey)
			{
				canMoveY = false;
				EazeTween.eaze(this)
					.delay(0.2, false)
					.onComplete(function():Void { canMoveY = true; }, []);
			}
		}
		
	}
	
	override public function render():Void
	{
		super.render();
		
		Draw.rect(Std.int(x), Std.int(y), 2, 2, 0xff0000);
	}
}