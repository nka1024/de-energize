package ui;
import com.haxepunk.graphics.Text;
import com.haxepunk.HXP;
import com.haxepunk.utils.Draw;
import util.TimeFormat;

/**
 * ...
 * @author k.nepomnyaschiy
 */

class HUD
{

	public function new()
	{
		
	}
	
	
	public static function showTime(time:Float, x:Float, y:Float):Void
	{
		var timelapse:String = TimeFormat.formatTime(time,1);
		var t:Text = new Text("" + timelapse, 0, 0);
		
		drawFixed(t, x, y);
	}
	
	static public function showLevel(level:Int, x:Float, y:Float)
	{
		var t:Text = new Text(Std.string(level) + " level", 0, 0);
		
		drawFixed(t, x, y);
	}
	
	static public function showTitle(x:Float, y:Float)
	{
		
		var t:Text = new Text("De-energize", 0, 0, 300, 36);
			
		t.size = 24;
		t.smooth = false;
			
		drawFixed(t, x, y);
	}
	
	static public function showCopyright(x:Float, y:Float)
	{
		
		var t:Text = new Text("press any key ", 0, 0, 800, 36);
			
		t.size = 16;
		t.smooth = false;
			
		drawFixed(t, x, y);
	}
	
	static public function showMyName(x:Float, y:Float)
	{
		var t:Text = new Text("by Kirill Nepomnyaschiy for Ludum Dare #25 ", 0, 0, 800, 36);
			
		t.size = 8;
		t.smooth = false;
			
		drawFixed(t, x, y);
	}
	

	static private function drawFixed(t:Text, x:Float, y:Float)
	{
		Draw.graphic(t, Std.int(HXP.camera.x + x), Std.int(HXP.camera.y + y));
	}
	
	
}