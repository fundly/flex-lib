package com.enilsson.graphics
{
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	
	public class enDropShadows
	{
		public function enDropShadows()
		{
		}

		public static function tightDS():DropShadowFilter 
		{	
		    var distance:Number 	= 1;
		    var angle:Number 		= 90;
		    var color:Number 		= 0x000000;
		    var alpha:Number 		= 1;
		    var blurX:Number 		= 2;
		    var blurY:Number 		= 2;
		    var strength:Number 	= 0.35;
		    var quality:Number 		= BitmapFilterQuality.LOW;
		    var inner:Boolean 		= false;
		    var knockout:Boolean 	= false;
		
		    return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout);
		}		

		public static function standardDS():DropShadowFilter 
		{	
		    var distance:Number 	= 2;
		    var angle:Number 		= 90;
		    var color:Number 		= 0x000000;
		    var alpha:Number 		= 1;
		    var blurX:Number 		= 6;
		    var blurY:Number 		= 6;
		    var strength:Number 	= 0.75;
		    var quality:Number 		= BitmapFilterQuality.LOW;
		    var inner:Boolean 		= false;
		    var knockout:Boolean 	= false;
		
		    return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout);
		}
		
		public static function textDS(dsColor:uint=0xffffff):DropShadowFilter
		{
		    var distance:Number 	= 1;
		    var angle:Number 		= 90;
		    var color:Number 		= dsColor;
		    var alpha:Number 		= 1;
		    var blurX:Number 		= 3;
		    var blurY:Number 		= 3;
		    var strength:Number 	= 0.75;
		    var quality:Number 		= BitmapFilterQuality.LOW;
		    var inner:Boolean 		= false;
		    var knockout:Boolean 	= false;
		
		    return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout);
		}		

		public static function invertedDS(dsColor:uint=0x000000):DropShadowFilter 
		{	
		    var distance:Number 	= 4;
		    var angle:Number 		= 270;
		    var color:Number 		= dsColor;
		    var alpha:Number 		= 0.50;
		    var blurX:Number 		= 6;
		    var blurY:Number 		= 6;
		    var strength:Number 	= 0.75;
		    var quality:Number 		= BitmapFilterQuality.LOW;
		    var inner:Boolean 		= false;
		    var knockout:Boolean 	= false;
		
		    return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout);
		}

	}
}