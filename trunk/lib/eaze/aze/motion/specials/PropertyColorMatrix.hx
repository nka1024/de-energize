package aze.motion.specials;

import aze.motion.specials.PropertyFilter;
import aze.motion.EazeTween;
import aze.motion.specials.PropertyColorMatrix;
import aze.motion.specials.EazeSpecial;

#if flash
import flash.filters.ColorMatrixFilter;
import flash.display.DisplayObject;
#else
import nme.display.DisplayObject;
#end

/**
 * Color matrix filter tweening
 * @author Philippe / http://philippe.elsass.me
 */
class PropertyColorMatrix extends EazeSpecial
{
	//public var filter(filterGetter,null):ColorMatrixFilter;
	private var removeWhenComplete:Bool;
	private var colorMatrix:ColorMatrix;
	private var delta:Array<Dynamic>;
	private var start:Array<Dynamic>;
	private var temp:Array<Dynamic>;
	
	static public function register():Void
	{
		EazeTween.specialProperties.set("colorMatrixFilter", PropertyColorMatrix);
		EazeTween.specialProperties.set(ColorMatrixFilter, PropertyColorMatrix);
	}
	
	public function new(target:Dynamic, property:Dynamic, value:Dynamic, next:EazeSpecial)
	{
		super(target, property, value, next);
		
		colorMatrix = new ColorMatrix();
		if (value.brightness) colorMatrix.adjustBrightness(value.brightness * 0xff);
		if (value.contrast) colorMatrix.adjustContrast(value.contrast);
		if (value.hue) colorMatrix.adjustHue(value.hue);
		if (value.saturation) colorMatrix.adjustSaturation(value.saturation + 1);
		if (value.colorize)
		{
			var tint:Int = Reflect.hasField(value,"tint") ? Std.int(value.tint) : 0xffffff;
			colorMatrix.colorize(tint, value.colorize);
		}
		removeWhenComplete = (value.remove);
	}
	
	//public function filterGetter():ColorMatrixFilter
	//{
		//return new ColorMatrixFilter( matrix );
	//}
	
	override public function init(reverse:Bool):Void 
	{
		var disp:DisplayObject = cast(target,DisplayObject);
		var current:ColorMatrixFilter = cast( PropertyFilter.getCurrentFilter(ColorMatrixFilter, disp, true), ColorMatrixFilter ); // get and remove
		if (current==null) current = new ColorMatrixFilter();
		
		var begin:Array<Dynamic>;
		var end:Array<Dynamic>;
		if (reverse) { end = current.matrix; begin = colorMatrix.matrix; }
		else { end = colorMatrix.matrix; begin = current.matrix; }
		
		delta = new Array<Dynamic>();
		for (i in 0...20)
			delta[i] = end[i] - begin[i];
		
		start = begin;
		temp = new Array<Dynamic>();
		
		PropertyFilter.addFilter(disp, new ColorMatrixFilter(begin)); // apply filter
	}
	
	override public function update(ke:Float, isComplete:Bool):Void
	{
		var disp:DisplayObject = cast(target,DisplayObject);
		cast(PropertyFilter.getCurrentFilter(ColorMatrixFilter, disp, true),ColorMatrixFilter); // remove
		
		if (removeWhenComplete && isComplete) 
		{
			disp.filters = disp.filters;
			return;
		}
		
		for (i in 0...20)
			temp[i] = start[i] + ke * delta[i];
		
		PropertyFilter.addFilter(disp, new ColorMatrixFilter(temp));
	}
	
	override public function dispose():Void 
	{
		colorMatrix = null;
		delta = null;
		start = null;
		temp = null;
		super.dispose();
	}
}


// ColorMatrix Class v2.1    (stripped down by Philippe to needed features)
//
// released under MIT License (X11)
// http://www.opensource.org/licenses/mit-license.php
//
// Author: Mario Klingemann
// http://www.quasimondo.com

/*
Copyright (c) 2008 Mario Klingemann

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
class ColorMatrix 
{
	// RGB to Luminance conversion constants as found on
	// Charles A. Poynton's colorspace-faq:
	// http://www.faqs.org/faqs/graphics/colorspace-faq/
	private static inline var LUMA_R:Float = 0.212671;
	private static inline var LUMA_G:Float = 0.71516;
	private static inline var LUMA_B:Float = 0.072169;

	// There seem different standards for converting RGB
	// values to Luminance. This is the one by Paul Haeberli:
	private static inline var LUMA_R2:Float = 0.3086;
	private static inline var LUMA_G2:Float = 0.6094;
	private static inline var LUMA_B2:Float = 0.0820;

	private static inline var ONETHIRD:Float = 1 / 3;

	private static inline var IDENTITY:Array<Dynamic> = [
		1, 0, 0, 0, 0,
		0, 1, 0, 0, 0,
		0, 0, 1, 0, 0,
		0, 0, 0, 1, 0
	];

	private static inline var RAD:Float = Math.PI / 180;

	public var matrix:Array<Dynamic>;

	/*
	Function: ColorMatrix

	  Constructor

	Parameters:

	  mat - if omitted matrix gets initialized with an
			identity matrix. Alternatively it can be 
			initialized with another ColorMatrix or 
			an array (there is currently no check 
			if the array is valid. A correct array 
			contains 20 elements.)
	*/
	public function new ( mat:Dynamic = null )
	{
		if ( Std.is( mat, ColorMatrix ) )
		{
			matrix = mat.matrix.concat();
		} else if ( Std.is( mat, Array ) )
		{
			matrix = mat.concat();
		} else 
		{
			reset();
		}
	}

	/*
	Function: reset

	  resets the matrix to the neutral identity matrix. Applying this
	  matrix to an image will not make any changes to it.

	Parameters:

	  none
	  
	Returns:

		nothing
	*/

	public function reset():Void
	{
		//matrix = IDENTITY.concat();
		matrix = new Array<Dynamic>();
	}

	/*
	Function: adjustSaturation

	  changes the saturation

	Parameters:

	  s - typical values come in the range 0.0 ... 2.0 where
				 0.0 means 0% Saturation
				 0.5 means 50% Saturation
				 1.0 is 100% Saturation (aka no change)
				 2.0 is 200% Saturation
				 
				 Other values outside of this range are possible
				 -1.0 will invert the hue but keep the luminance
						
	Returns:

		nothing
	*/
	public function adjustSaturation( s:Float ):Void
	{
		var sInv:Float;
		var irlum:Float;
		var iglum:Float;
		var iblum:Float;
		
		sInv = (1 - s);
		irlum = (sInv * LUMA_R);
		iglum = (sInv * LUMA_G);
		iblum = (sInv * LUMA_B);
		
		concat([(irlum + s), iglum, iblum, 0, 0,
				irlum, (iglum + s), iblum, 0, 0,
				irlum, iglum, (iblum + s), 0, 0,
				0, 0, 0, 1, 0]);
	}

	static public inline var NaN:Float = Math.NaN;
	
	/*
	Function: adjustContrast

	  changes the contrast

	Parameters:

	  s - typical values come in the range -1.0 ... 1.0 where
				 -1.0 means no contrast (grey)
				 0 means no change
				 1.0 is high contrast
				
						
	  
	Returns:

		nothing
	*/
	public function adjustContrast( r:Float, g:Float = 0.0, b:Float = 0.0 ):Void
	{
		if (g==0.0) g = r;
		if (b==0.0) b = r;
		r += 1;
		g += 1;
		b += 1;
		
		concat([r, 0, 0, 0, (128 * (1 - r)),
				0, g, 0, 0, (128 * (1 - g)),
				0, 0, b, 0, (128 * (1 - b)),
				0, 0, 0, 1, 0]);
	}

	public function adjustBrightness(r:Float, g:Float=0.0, b:Float=0.0):Void
	{
		if (g==0.0) g = r;
		if (b==0.0) b = r;
		concat([1, 0, 0, 0, r,
				0, 1, 0, 0, g,
				0, 0, 1, 0, b,
				0, 0, 0, 1, 0]);
	}

	public function adjustHue( degrees:Float ):Void
	{
		degrees *= RAD;
		var cos:Float = Math.cos(degrees);
		var sin:Float = Math.sin(degrees);
		concat([((LUMA_R + (cos * (1 - LUMA_R))) + (sin * -(LUMA_R))), ((LUMA_G + (cos * -(LUMA_G))) + (sin * -(LUMA_G))), ((LUMA_B + (cos * -(LUMA_B))) + (sin * (1 - LUMA_B))), 0, 0,
				((LUMA_R + (cos * -(LUMA_R))) + (sin * 0.143)), ((LUMA_G + (cos * (1 - LUMA_G))) + (sin * 0.14)), ((LUMA_B + (cos * -(LUMA_B))) + (sin * -0.283)), 0, 0,
				((LUMA_R + (cos * -(LUMA_R))) + (sin * -((1 - LUMA_R)))), ((LUMA_G + (cos * -(LUMA_G))) + (sin * LUMA_G)), ((LUMA_B + (cos * (1 - LUMA_B))) + (sin * LUMA_B)), 0, 0,
				0, 0, 0, 1, 0]);
	}

	public function colorize(rgb:Int, amount:Float=1):Void
	{
		var r:Float;
		var g:Float;
		var b:Float;
		var inv_amount:Float;
		
		r = (((rgb >> 16) & 0xFF) / 0xFF);
		g = (((rgb >> 8) & 0xFF) / 0xFF);
		b = ((rgb & 0xFF) / 0xFF);
		inv_amount = (1 - amount);
		
		concat([(inv_amount + ((amount * r) * LUMA_R)), ((amount * r) * LUMA_G), ((amount * r) * LUMA_B), 0, 0,
				((amount * g) * LUMA_R), (inv_amount + ((amount * g) * LUMA_G)), ((amount * g) * LUMA_B), 0, 0,
				((amount * b) * LUMA_R), ((amount * b) * LUMA_G), (inv_amount + ((amount * b) * LUMA_B)), 0, 0,
				0, 0, 0, 1, 0]);
	}

	public function filterGetter():ColorMatrixFilter
	{
		return new ColorMatrixFilter( matrix );
	}

	public function concat( mat:Array<Dynamic> ):Void
	{
		var temp:Array<Dynamic> = [];
		var i:Int = 0;
		var x:Int, y:Int;
		for (y in 0...4) 
		{
			for (x in 0...5) 
			{
				temp[ Std.int( i + x) ] =  (mat[i  ])      * (matrix[x]) + 
									   (mat[Std.int(i+1)]) * (matrix[Std.int(x +  5)]) +
									   (mat[Std.int(i+2)]) * (matrix[Std.int(x + 10)]) +
									   (mat[Std.int(i+3)]) * (matrix[Std.int(x + 15)]) +
									   (x == 4 ? (mat[Std.int(i+4)]) : 0);
			}
			i+=5;
		}
		
		matrix = temp;
	}

}