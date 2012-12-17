package util;

/**
 * ...
 * @author k.nepomnyaschiy
 */

class TimeFormat
{

	public static inline var HOURS:Int = 2;
	public static inline var MINUTES:Int = 1;
	public static inline var SECONDS:Int = 0;
	
	public function new()
	{
		
	}
	
	public static function formatTime(time:Float, detailLevel:Int = 2):String
	{
		var intTime:Int = Math.floor(time);
		var hours:Int = Math.floor(intTime/ 3600);
		var minutes:Int = Std.int((intTime - (hours*3600))/60);
		var seconds:Int = Std.int(intTime -  (hours*3600) - (minutes * 60));
		var hourString:String = detailLevel == HOURS ? hours + ":":"";
		var minuteString:String = detailLevel >= MINUTES ? ((detailLevel == HOURS && minutes <10 ? "0":"") + minutes + ":"):"";
		var secondString:String = ((seconds < 10 && (detailLevel >= MINUTES)) ? "0":"") + seconds;
		
		return hourString + minuteString + secondString;
		
	}
	
}

