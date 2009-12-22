package com.enilsson.graphics
{
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import mx.core.UIComponent;

	public class enCloseBtn extends UIComponent
	{
		private static var BUTTON_PADDING:Number = 0;
		
		private var _size:Number = 20;
		private var sizeChanged:Boolean;
		private var _borderWidth:Number = 2;
		private var _backgroundColor:uint = 0x000000;
		private var _borderColor:uint = 0xFFFFFF;
		private var _crossSize:Number = 6;
		private var _crossColor:uint = 0xFFFFFF;
		private var _rollOverColor:uint = 0xFF0000;
		private var _rollOverAlpha:Number = 0.75;
		
		private var _currBackgroundColor:uint;

		public function enCloseBtn()
		{
			super();

	        addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
	        addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			
			_currBackgroundColor = _backgroundColor;
			
			this.useHandCursor = true;
			this.buttonMode = true;
			this.filters = [canvasDS()];
		}

		public function set size(value:Number):void {
			if (value != _size) {
				_size = value;
				sizeChanged = true;
				invalidateDisplayList();
				invalidateSize();
			}
		}

		public function set crossSize(value:Number):void {
			if (value != _crossSize) {
				_crossSize = value > (_size - (BUTTON_PADDING * 2) - (_borderWidth * 2)) ?
								_size - (BUTTON_PADDING * 2) - (_borderWidth * 2) : 
								value;
				sizeChanged = true;
				invalidateDisplayList();
				invalidateSize();
			}
		}

		public function set dropShadow(value:Boolean):void {
			if (!value) {
				this.filters = [];
				invalidateDisplayList();
				invalidateSize();
			}
		}

		public function set borderWidth(value:Number):void
		{
			_borderWidth = value;				
		}
		
		public function set backgroundColor(value:uint):void
		{
			if(value != _currBackgroundColor){
				_backgroundColor = value;
				_currBackgroundColor = _backgroundColor;
				invalidateDisplayList();
				invalidateSize();
			}
		}
		
		public function set borderColor(value:uint):void
		{
			_borderColor = value;				
			invalidateDisplayList();
			invalidateSize();
		}						
		
		public function set crossColor(value:uint):void
		{
			_crossColor = value;				
			invalidateDisplayList();
			invalidateSize();
		}						

		public function set rollOverAlpha(value:Number):void
		{
			_rollOverAlpha = value;				
			invalidateDisplayList();
			invalidateSize();		
		}						

		public function set rollOverColor(value:uint):void
		{
			_rollOverColor = value;				
			invalidateDisplayList();
			invalidateSize();
		}						

		override protected function measure():void {
			super.measure();
			
			width = _size;
			height = _size;
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
		
			drawCloseBtn();
		}
		
		private function drawCloseBtn():void
		{	
			var _radius:Number = (_size - (BUTTON_PADDING * 2) - (_borderWidth * 2))/2;
		
			this.graphics.beginFill(_currBackgroundColor);
			this.graphics.lineStyle(_borderWidth,_borderColor);
			this.graphics.drawCircle(_size/2, _size/2, _radius);
			this.graphics.endFill();
			
			var _crossStartX:Number = _radius - _crossSize/2 + _borderWidth;
			var _crossStartY:Number = _radius - _crossSize/2 + _borderWidth;
			
			this.graphics.beginFill(_currBackgroundColor);
			this.graphics.lineStyle(_borderWidth,_crossColor);
			this.graphics.moveTo(_crossStartX,_crossStartY);
			this.graphics.lineTo((_crossStartX+_crossSize),(_crossStartY+_crossSize));
			this.graphics.moveTo((_crossStartX+_crossSize),(_crossStartY));
			this.graphics.lineTo((_crossStartX),(_crossStartY+_crossSize));
			this.graphics.endFill();
		}
		
		private function rollOverHandler(e:MouseEvent):void
		{
			this.alpha = _rollOverAlpha;
			_currBackgroundColor = _rollOverColor;
			invalidateDisplayList();	
		}
		
		private function rollOutHandler(e:MouseEvent):void
		{
			this.alpha = 1;
			_currBackgroundColor = _backgroundColor;
			invalidateDisplayList();	
		}

		// DropShadow Filter for a canvas element
		private function canvasDS():DropShadowFilter 
		{
		    var distance:Number 	= 2;
		    var angle:Number 		= 90;
		    var color:Number 		= 0x000000;
		    var alpha:Number 		= 1;
		    var blurX:Number 		= 8;
		    var blurY:Number 		= 8;
		    var strength:Number 	= 0.65;
		    var quality:Number 		= BitmapFilterQuality.LOW;
		    var inner:Boolean 		= false;
		    var knockout:Boolean 	= false;
		
		    return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout);
		}
		
	}
}