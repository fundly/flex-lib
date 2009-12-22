package com.enilsson.controls
{
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	
	import mx.controls.Button;

	public class enSubmitButton extends Button
	{
		public function enSubmitButton()
		{
			super();
			
			this.useHandCursor = true;
			this.buttonMode = true;
			
			this.filters = [textDS()];
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

		}

		private function textDS(dsColor:uint=0xffffff):DropShadowFilter
		{
		    var distance:Number 	= 1;
		    var angle:Number 		= 90;
		    var color:Number 		= dsColor;
		    var alpha:Number 		= 1;
		    var blurX:Number 		= 2;
		    var blurY:Number 		= 2;
		    var strength:Number 	= 0.65;
		    var quality:Number 		= BitmapFilterQuality.HIGH;
		    var inner:Boolean 		= false;
		    var knockout:Boolean 	= false;
		
		    return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout);
		}		
		
	}
}