/*
Eaze is an Actionscript 3 tween library by Philippe Elsass
Contact: philippe.elsass*gmail.com
Website: http://code.google.com/p/eaze-tween/
License: http://www.opensource.org/licenses/mit-license.php
*/
package aze.motion;

import aze.motion.easing.Linear;
import aze.motion.specials.EazeSpecial;
import aze.motion.easing.Quadratic;
import aze.motion.EazeTween;

import jota.utils.Dictionary;

import aze.motion.specials.PropertyTint;
import aze.motion.specials.PropertyFrame;
import aze.motion.specials.PropertyFilter;
import aze.motion.specials.PropertyBezier;
import aze.motion.specials.PropertyShortRotation;
import aze.motion.specials.PropertyRect;

#if flash
import aze.motion.specials.PropertyColorMatrix;
import aze.motion.specials.PropertyVolume;
import flash.filters.ColorMatrixFilter;
import flash.display.Shape;
import flash.display.Sprite;
import flash.errors.ArgumentError;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.Lib;
#else
import nme.display.Shape;
import nme.display.Sprite;
import nme.errors.ArgumentError;
import nme.events.Event;
import nme.geom.Rectangle;
import nme.Lib;
#end

/**
 * EazeTween tween object
 * @author Philippe - http://philippe.elsass.me
 */
class EazeTween
{
	//--- STATIC ----------------------------------------------------------
	
	/** Defines default easing method to use when no ease is specified */
	static public var defaultEasing:Dynamic = Quadratic.easeOut;
	static public var defaultDuration:Dynamic = { slow:1, normal:0.4, fast:0.2 };
	
	/** Registered plugins */ 
	static public var specialProperties:Dictionary = new Dictionary();
	//specialProperties.alpha = true;
	//specialProperties.alphaVisible = true;
	//specialProperties.scale = true;
	
	static private var running:Dictionary = new Dictionary();
	static private var ticker:Shape = createTicker();
	static private var pauseTime:Float;
	static private var head:EazeTween;
	static private var tweenCount:Int = 0;
	
	inline public static var NaN : Float = Math.NaN;
	
	static public function eaze ( target:Dynamic ) : EazeTween
	{
		return new EazeTween(target);
	}
	
	/**
	 * Stop immediately all running tweens
	 */
	static public function killAllTweens():Void
	{
		//for (var target:Object in running);
		for (target in running.iterator())
		{
			killTweensOf(target);
		}
	}
	
	/**
	 * Stop immediately all tweens associated with target
	 * @param	target		Target object
	 */
	static public function killTweensOf(target:Dynamic):Void
	{
		if (target==null) return;
		
		var tween:EazeTween = running.get(target);
		var rprev:EazeTween;
		while (tween!=null)
		{
			tween.isDead = true;
			tween.dispose();
			if (tween.rnext!=null) { rprev = tween; tween = tween.rnext; rprev.rnext = null; }
			else tween = null;
		}
		running.remove(target);
	}
	
	/**
	 * Temporarily stop all tweens
	 */
	static public function pauseAllTweens():Void
	{
		if (ticker.hasEventListener(Event.ENTER_FRAME))
		{
			pauseTime = flash.Lib.getTimer();
			ticker.removeEventListener(Event.ENTER_FRAME, tick);
			Lib.current.removeChild(ticker);
		}
	}
	
	/**
	 * Reactivate tweens
	 */
	static public function resumeAllTweens():Void
	{
		if (!ticker.hasEventListener(Event.ENTER_FRAME))
		{
			var delta:Float = flash.Lib.getTimer() - pauseTime;
			var tween:EazeTween = head;
			while (tween!=null)
			{
				tween.startTime += delta;
				tween.endTime += delta;
				tween = tween.next;
			}
			ticker.addEventListener(Event.ENTER_FRAME, tick);
			Lib.current.addChild(ticker);
		}
	}
	
	/// Setup enterframe event for update
	static private function createTicker():Shape
	{
		var sp:Shape = new Shape();
		sp.addEventListener(Event.ENTER_FRAME, EazeTween.tick);
		Lib.current.addChild(sp);
		return sp;
	}
	
	/// Enterframe handler for update
	static private function tick(e:Event):Void 
	{
		if (head!=null) 
		{
			updateTweens(flash.Lib.getTimer());
		}
	}
	
	/// Main update loop
	static private function updateTweens(time:Int):Void 
	{
		var complete:/*CompleteData*/Array<Dynamic> = [];
		var ct:Int = 0;
		var t:EazeTween = head;
		var cpt:Int = 0;

		while (t!=null)
		{
			cpt++;
			var isComplete:Bool;
			if (t.isDead) {
				isComplete = true;
			}
			else
			{
				isComplete = time >= t.endTime;
				var k:Float = isComplete ? 1.0 : (time - t.startTime) / t._duration;
				//var ke:Float = t._ease(k > 0 || 0);
				/**
				 * TODO: check this ease call but seems to be fixed
				 */
				if (k < 0) k = 0;
				var ke:Float = t._ease(k);
				var target:Dynamic = t.target;
				
				// update
				var p:EazeProperty = t.properties;
				
				while (p!=null)
				{
					//target[p.name] = p.start + p.delta * ke;
					//Reflect.setField(target, p.name, p.start + p.delta * ke);
					Reflect.setProperty(target, p.name, p.start + p.delta * ke);
					p = p.next;
				}
				
				if (t.slowTween)
				{
					if (t.autoVisible) target.visible = (target.alpha > 0.001);
					if (t.specials!=null)
					{
						var s:EazeSpecial = t.specials;
						while (s!=null)
						{
							s.update(ke, isComplete);
							s = s.next;
						}
					}
		
					if (t._onStart != null)
					{
						t._onStart.apply(null, t._onStartArgs);
						t._onStart = null;
						t._onStartArgs = null;
					}
					
					if (t._onUpdate != null)
						t._onUpdate.apply(null, t._onUpdateArgs);
				}
			}
			
			if (isComplete) // tween ends
			{
				if (t._started)
				{
					var cd:CompleteData = new CompleteData(t._onComplete, t._onCompleteArgs, t._chain, t.endTime - time);
					t._chain = null;
					complete.unshift(cd);
					ct++;
				}

				// finalize
				t.isDead = true;
				t.detach();
				t.dispose();
				
				// remove from chain
				var dead:EazeTween = t;
				var prev:EazeTween = t.prev;
				t = dead.next; // next tween
				
				if (prev != null) { 
					prev.next = t; 
					if (t != null) t.prev = prev; 
				}
				else { 
					head = t; 
					if (t != null) t.prev = null; 
				}
				dead.prev = dead.next = null;
			}
			else t = t.next; // next tween
		}
		
		// honor completed tweens notifications & chaining
		if (ct>0)
		{
			for (i in 0...ct) {
				complete[i].execute();
			}
		}
		
		tweenCount = cpt;
	}
	
	//--- INSTANCE --------------------------------------------------------
	
	//static private var id:int = 0;
	//private var _id:int = id++;
	
	private var prev:EazeTween;
	private var next:EazeTween;
	private var rnext:EazeTween;
	private var isDead:Bool;
	
	private var target:Dynamic;
	private var reversed:Bool;
	private var overwrite:Bool;
	private var autoStart:Bool;
	private var _configured:Bool;
	private var _started:Bool;
	private var _inited:Bool;
	private var duration:Dynamic;
	private var _duration:Float;
	private var _ease:Dynamic;
	private var startTime:Float;
	private var endTime:Float;
	private var properties:EazeProperty;
	private var specials:EazeSpecial;
	private var autoVisible:Bool;
	private var slowTween:Bool;
	private var _chain:Array<Dynamic>;
	
	private var _onStart:Dynamic;
	private var _onStartArgs:Array<Dynamic>;
	private var _onUpdate:Dynamic;
	private var _onUpdateArgs:Array<Dynamic>;
	private var _onComplete:Dynamic;
	private var _onCompleteArgs:Array<Dynamic>;
	
	/**
	 * Creates a tween instance
	 * @param	target		Target object
	 * @param	autoStart	Start tween immediately after .to / .from are called
	 */
	public function new(target:Dynamic, autoStart:Bool = true)
	{
		if (target==null) throw new ArgumentError("EazeTween: target can not be null");
		
		PropertyTint.register();
		PropertyFrame.register();
		PropertyFilter.register();
		#if flash
		PropertyVolume.register();
		PropertyColorMatrix.register();
		#end
		PropertyBezier.register();
		PropertyShortRotation.register();
		PropertyRect.register();
		
		specialProperties.set("alpha",true);
		specialProperties.set("alphaVisible",true);
		specialProperties.set("scale",true);
		
		this.target = target;
		this.autoStart = autoStart;
		_ease = defaultEasing;
	}
	
	/// Set tween parameters
	private function configure(duration:Dynamic, newState:Dynamic = null, reversed:Bool = false):Void
	{
		_configured = true;
		this.reversed = reversed;
		this.duration = duration;
		
		// properties
		if (newState!=null)
		for (name in Reflect.fields(newState).iterator())
		{
			//var value:Dynamic = Reflect.field(newState,name);
			var value:Dynamic = Reflect.getProperty(newState,name);
			if ( specialProperties.exists(name) )
			{
				if (name == "alpha") { autoVisible = true; slowTween = true; }
				else if (name == "alphaVisible") { name = "alpha"; autoVisible = false; }
				else if (!Reflect.hasField(target,name))
				{
					if (name == "scale")
					{
						configure(duration, { scaleX:value, scaleY:value }, reversed);
						continue;
					}
					else
					{
						//specials = new specialProperties[name](target, name, value, specials);
						specials = Type.createInstance(specialProperties.get(name),[target, name, value, specials]);
						slowTween = true;
						continue;
					}
				}
			}
			//if (value is Array<Dynamic> && target[name] is Float)
			//if ( Std.is(value,Array) && Std.is( Reflect.field(target,name),Float) )
			if ( Std.is(value,Array) && Std.is( Reflect.getProperty(target,name),Float) )
			{
				if (specialProperties.exists("__bezier"))
				{
					//specials = new specialProperties["__bezier"](target, name, value, specials);
					specials = Type.createInstance(specialProperties.get("__bezier"),[target, name, value, specials]);
					slowTween = true;
				}
				continue;
			}
			properties = new EazeProperty(name, value, properties);
		}
	}
	
	/** 
	 * Start this tween if it was created with autoStart disabled
	 */
	public function start(killTargetTweens:Bool = true, timeOffset:Float = 0):Void
	{
		if (_started) return;
		if (!_inited) init();
		overwrite = killTargetTweens;
		
		// add to main tween chain
		startTime = flash.Lib.getTimer() + timeOffset;
		_duration = (Math.isNaN(duration) ? smartDuration(Std.string(duration)) : Std.parseFloat(duration)) * 1000;
		endTime = startTime + _duration;

		// set values
		if (reversed || _duration == 0) {
			update(startTime);
		}
		if (autoVisible && _duration > 0) {
			target.visible = true;
		}
		_started = true;
		attach(overwrite);
	}
	
	/// Read target properties
	private function init():Void
	{
		if (_inited) return;
		
		// configure properties
		var p:EazeProperty = properties;
		while (p!=null) { p.init(target, reversed); p = p.next; }
		
		var s:EazeSpecial = specials;
		while (s!=null) { s.init(reversed); s = s.next; }
		
		_inited = true;
	}
	
	/// Resolve non numeric durations
	private function smartDuration(duration:String):Float
	{
		//if (duration in defaultDuration) return defaultDuration[duration];
		//if (Reflect.hasField(defaultDuration, duration)) return Reflect.field(defaultDuration, duration);
		if (Reflect.hasField(defaultDuration, duration)) return Reflect.getProperty(defaultDuration, duration);
		else if (duration == "auto")
		{
			// look for a special property willing to provide an optimal duration
			var s:EazeSpecial = specials;
			while (s!=null)
			{
				//if ("getPreferredDuration" in s) return s["getPreferredDuration"]();
				if (Reflect.hasField(s, "getPreferredDuration")) {
					//var func = Reflect.field(s, "getPreferredDuration");
					var func = Reflect.getProperty(s, "getPreferredDuration");
					return Reflect.callMethod(s, func, []);
					//return s["getPreferredDuration"]();
				}
				
				s = s.next;
			}
		}
		return defaultDuration.normal;
	}
	
	/**
	 * Set easing method
	 * @param	f	Easing function(k:Number):Number
	 * @return	Tween reference
	 */
	public function easing(f:Dynamic):EazeTween
	{
		if (f == null) f = defaultEasing;
		_ease = f;
		return this;
	}
	
	/**
	 * Add a filter animation (PropertyFilter must be activated)
	 * @param	classRef	Filter class (ex: BlurFilter or "blurFilter")
	 * @param	parameters	Filter properties (ex: { blurX:10, blurY:10 })
	 * @return	Tween reference
	 */
	public function filter(classRef:Dynamic, parameters:Dynamic, removeWhenDone:Bool = false):EazeTween
	{
		if (!parameters) parameters = { };
		if (removeWhenDone) parameters.remove = true;
		addSpecial(classRef, classRef, parameters);
		return this;
	}
	
	/**
	 * Add a colorTransform tween (PropertyTint must be activated)
	 * @param	tint		Color value or null (remove tint)
	 * @param	colorize	Colorization offset ratio (0..1)
	 * @param	multiply	Existing color ratio (0..1+)
	 * @return	Tween reference
	 */
	//public function tint(tint:Dynamic = null, colorize:Float = 1, multiply:Float = Math.NaN):EazeTween
	public function tint(tint:Dynamic = null, colorize:Float = 1, multiply:Float = 0.0):EazeTween
	{
		//if (Math.isNaN(multiply)) multiply = 1 - colorize;
		if (multiply==0.0) multiply = 1 - colorize;
		addSpecial("tint", "tint", [tint, colorize, multiply]);
		return this;
	}
	
	/**
	 * Add a ColorMatrix filter tween (PropertyColorMatrix must be activated)
	 * @param	brightness	Brightness ratio (-1..1)
	 * @param	contrast	Contrast ratio (-1..1)
	 * @param	saturation	Saturation ratio (-1..1)
	 * @param	hue			Rotation angle (-180..180)
	 * @param	tint		Color value
	 * @param	colorize	Colorization ratio (0..1)
	 * @return	Tween reference
	 */
	public function colorMatrix(brightness:Float = 0, contrast:Float = 0, saturation:Float = 0,
		hue:Float = 0, tint:Int = 0xffffff, colorize:Float = 0):EazeTween
	{
		#if flash
		var remove:Bool = brightness == 0 && contrast == 0 && saturation == 0 && hue == 0 && colorize == 0;
		return filter(ColorMatrixFilter, { 
			brightness:brightness, contrast:contrast, saturation:saturation,
			hue:hue, tint:tint, colorize:colorize
		}, remove);
		#end
		return null;
	}
	
	/**
	 * Add a short-rotation tween (PropertyShortRotation must be activated)
	 * @param	value	Rotation value
	 * @param	name	Target member name (defaults to "rotation")
	 * @param	useRadian	Use radians instead of degrees (default)
	 * @return	Tween reference
	 */
	public function short(value:Float, name:String = "rotation", useRadian:Bool = false):EazeTween
	{
		addSpecial("__short", name, [value, useRadian]);
		return this;
	}
	
	/**
	 * Add a scrollRect tween (PropertyScrollRect must be activated)
	 * @param	value	Rectangle value
	 * @param	name	Target member name (defaults to "scrollRect")
	 * @return	Tween reference
	 */
	public function rect(value:Rectangle, name:String = "scrollRect"):EazeTween
	{
		addSpecial("__rect", name, value);
		return this;
	}
	
	/// apply or append a special property tween
	private function addSpecial(special:Dynamic, name:Dynamic, value:Dynamic):Void
	{
		if (specialProperties.exists(special) && target != null)
		{
			if ((!_inited || _duration == 0) && autoStart)
			{
				// apply
				//EazeSpecial(new specialProperties[special](target, name, value, null));
					//.init(true);
				var eazeClass:Dynamic = Type.createInstance(specialProperties.get(special),[target, name, value, null]);
				cast( eazeClass, EazeSpecial ).init(true);
			}
			else 
			{
				//specials = new specialProperties[special](target, name, value, specials);
				specials = Type.createInstance(specialProperties.get(special), [target, name, value, null]);
				if (_started) specials.init(reversed);
				slowTween = true;
			}
		}
	}
	
	/**
	 * Set callback on tween startup
	 * @param	handler
	 * @param	...args
	 * @return	Tween reference
	 */
	public function onStart(handler:Dynamic, args:Array<Dynamic>):EazeTween
	{
		_onStart = handler;
		_onStartArgs = args;
		slowTween = !autoVisible || specials != null || _onUpdate != null || _onStart != null;
		return this;
	}
	
	/**
	 * Set callback on tween update
	 * @param	handler
	 * @param	...args
	 * @return	Tween reference
	 */
	public function onUpdate(handler:Dynamic, args:Array<Dynamic>):EazeTween
	{
		_onUpdate = handler;
		_onUpdateArgs = args;
		slowTween = !autoVisible || specials != null || _onUpdate != null || _onStart != null;
		return this;
	}
	
	/**
	 * Set callback on tween end
	 * @param	handler
	 * @param	...args
	 * @return	Tween reference
	 */
	public function onComplete(handler:Dynamic, args:Array<Dynamic>):EazeTween
	{
		_onComplete = handler;
		_onCompleteArgs = args;
		return this;
	}
	
	/**
	 * Stop tween immediately
	 * @param	setEndValues	Set final tween values to target
	 */
	public function kill(setEndValues:Bool = false):Void
	{
		if (isDead) return;
		
		if (setEndValues) 
		{
			_onUpdate = _onComplete = null;
			update(endTime);
		}
		else 
		{
			detach();
			dispose();
		}
		isDead = true;
	}
	
	/**
	 * Stop immediately all tweens associated with target
	 * @return Tween reference
	 */
	public function killTweens():EazeTween
	{
		EazeTween.killTweensOf(target);
		return this;
	}
	
	/**
	 * Update tween values immediately
	 */
	public function updateNow():EazeTween
	{
		if (_started)
		{
			var t:Float = Math.max(startTime, flash.Lib.getTimer());
			update(t);
		}
		else 
		{
			init();
			endTime = _duration = 1;
			update(0);
		}
		return this;
	}
	
	/// Update this tween alone
	private function update(time:Float):Void
	{
		// make this tween the only tween to update 
		var h:EazeTween = head;
		head = this;
		updateTweens(Std.int(time));
		head = h;
	}
	
	/// push tween in process chain and associate target/tween in running Dictionnary
	private function attach(overwrite:Bool):Void
	{
		var parallel:EazeTween = null;
		
		if (overwrite) {
			killTweensOf(target);
		} else {
			parallel = running.get(target);
		}
		
		if (parallel!=null)
		{
			prev = parallel;
			next = parallel.next;
			if (next!=null) next.prev = this;
			parallel.next = this;
			rnext = parallel;
		}
		else
		{
			if (head!=null) head.prev = this;
			next = head;
			head = this;
		}
		running.set(target,this);			
	}
	
	/// delete target/tween association in running Dictionnary
	private function detach():Void
	{
		if (target && _started)
		{
			var targetTweens:EazeTween = running.get(target);
			if (targetTweens == this) 
			{
				if (rnext!=null) running.set(target,rnext);
				else {
					running.remove(target);
				}
			}
			else if (targetTweens!=null)
			{
				var prev:EazeTween = targetTweens;
				targetTweens = targetTweens.rnext;
				/**
				 * TODO: while loop?
				 */
				while (targetTweens!=null)
				{
					if (targetTweens == this)
					{
						prev.rnext = rnext;
						break;
					}
					prev = targetTweens;
					targetTweens = targetTweens.rnext;
				}
			}
			rnext = null;
		}
	}
	
	/// Cleanup all references except main chaining
	private function dispose():Void
	{
		if (_started) 
		{
			target = null;
			_onComplete = null;
			_onCompleteArgs = null;
			if (_chain!=null)
			{
				//for each(var tween:EazeTween in _chain) tween.dispose();
				for(tween in _chain) tween.dispose();
				_chain = null;
			}
		}
		if (properties!=null) { properties.dispose(); properties = null; }
		_ease = null;
		_onStart = null;
		_onStartArgs = null;
		if (slowTween)
		{
			if (specials!=null) { specials.dispose(); specials = null; }
			autoVisible = false; 
			_onUpdate = null;
			_onUpdateArgs = null;
		}
	}
	
	/**
	 * Create a blank tween for delaying
	 * @param	duration	Seconds or "slow/normal/fast/auto"
	 * @return Tween object
	 */
	public function delay(duration:Dynamic, overwrite:Bool = true):EazeTween
	{
		return add(duration, null, overwrite);
	}
	
	/**
	 * Immediately change target properties
	 * @param	newState	Properties to animate
	 * @param	overwrite	(default: true) Kill existing tweens of target
	 */
	public function apply(newState:Dynamic = null, overwrite:Bool = true):EazeTween
	{
		return add(0, newState, overwrite);
	}
	
	/**
	 * Play target MovieClip timeline
	 * @param	frame		Frame number or label (default: totalFrames)
	 * @param	overwrite	(default: true) Kill existing tweens of target
	 * @return	Tween object
	 */
	public function play(frame:Dynamic = 0, overwrite:Bool = true):EazeTween
	{
		return add("auto", { frame:frame }, overwrite).easing(Linear.easeNone);
	}
	
	/**
	 * Animate target from current state to provided new state
	 * @param	duration	Seconds or "slow/normal/fast/auto"
	 * @param	newState	Properties to animate
	 * @param	overwrite	(default: true) Kill existing tweens of target
	 * @return Tween object
	 */
	public function to(duration:Dynamic, newState:Dynamic = null, overwrite:Bool = true):EazeTween
	{
		return add(duration, newState, overwrite);
	}
	
	/**
	 * Animate target from provided new state to current state
	 * @param	duration	Seconds or "slow/normal/fast/auto"
	 * @param	newState	Properties to animate
	 * @param	overwrite	(default: true) Kill existing tweens of target
	 * @return Tween object
	 */
	public function from(duration:Dynamic, fromState:Dynamic = null, overwrite:Bool = true):EazeTween
	{
		return add(duration, fromState, overwrite, true);
	}
	
	/// Create or chain a new tween
	private function add(duration:Dynamic, state:Dynamic, overwrite:Bool, reversed:Bool = false):EazeTween
	{
		if (isDead) return new EazeTween(target).add(duration, state, overwrite, reversed);
		if (_configured) return chain().add(duration, state, overwrite, reversed);
		configure(duration, state, reversed);
		if (autoStart) start(overwrite);
		return this;
	}
	
	/**
	 * Chain another tween after current tween
	 * @param	otherTarget		Chain another target after the current tween ends
	 */
	public function chain(target:Dynamic = null):EazeTween
	{
		//var tween:EazeTween = new EazeTween(target!=null || this.target!=null, false);
		/**
		 * TODO: check this initialization
		 */
		if (target == null) target = this.target;
		var tween:EazeTween = new EazeTween(target, false);
		if (_chain==null) _chain = [];
		_chain.push(tween);
		return tween;
	}
	
	/** Tween is running */
	public function isStartedGetter():Bool { return _started; }
	
	/** Tween is finished */
	public function isFinishedGetter():Bool { return isDead; }
}


/**
* Tweened propertie infos (chained list)
*/
class EazeProperty
{
	public var name:String;
	public var start:Float;
	public var end:Float;
	public var delta:Float;
	public var next:EazeProperty;

	public function new(name:String, end:Float, next:EazeProperty)
	{
		this.name = name;
		this.end = end;
		this.next = next;
	}

	public function init(target:Dynamic, reversed:Bool):Void
	{
		if (reversed)
		{
			start = end;
			//end = Reflect.field(target, name);
			end = Reflect.getProperty(target, name);
			//Reflect.setField(target, name, start);
			Reflect.setProperty(target, name, start);
		}
		else start = Reflect.getProperty(target,name);
		//else start = Reflect.field(target,name);
		this.delta = end - start;
	}

	public function dispose():Void
	{
		if (next!=null) next.dispose();
		next = null;
	}
}


/**
* Information to honor tween completion: complete event, chaining.
*/
class CompleteData
{
	private var _callback:Dynamic;
	private var args:Array<Dynamic>;
	private var chain:Array<Dynamic>;
	private var diff:Float;

	public function new(_callback:Dynamic, args:Array<Dynamic>, chain:Array<Dynamic>, diff:Float)
	{
		this._callback = _callback;
		this.args = args;
		this.chain = chain;
		this.diff = diff;
	}

	public function execute():Void
	{
		if (_callback != null)
		{
			//_callback.apply(null, args);
			Reflect.callMethod(null, _callback, args);
			_callback = null;
		}
		args = null;
		if (chain!=null)
		{
			//trace(chain[0].properties.name);
			var len:Int = chain.length;
			for (i in 0...len) {
				var tween:EazeTween = chain[i];
				tween.start(false, diff);
				//cast(chain[i],EazeTween).start(false, diff);
			}
			chain = null;
		}
	}
}

