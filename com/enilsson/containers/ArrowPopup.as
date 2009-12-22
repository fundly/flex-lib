package com.enilsson.containers
{
	import flash.display.GradientType;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	
	import mx.containers.Box;
	
	import org.osflash.thunderbolt.Logger;

	/**
	 * Styles
	 */
	// Position of the arrow
	[Style(name="arrowSide", type="String", enumeration="top,right,bottom,left", inherit="no")]	
	// the thickness of the popup border
	[Style(name="borderWidth", type="Number", format="Length", inherit="no")]	
	// the color of the gridlines marking the hours
	[Style(name="borderColor", type="uint", format="Color", inherit="no")]
	// the radius of the popup corners
	[Style(name="cornerRadius", type="Number", format="Length", inherit="no")]	
	// Array of fill colours for the popup
	[Style(name="gradientColors", type="Array", format="Color", inherit="no")]
	// Array of fill alphas for the popup
	[Style(name="gradientAlphas", type="Array", format="Number", inherit="no")]
	// Gradient rotation
	[Style(name="gradientRotation", type="Number", format="Number", inherit="no")]
	// Popup dropshadow filter
	[Style(name="dropShadow", type="Boolean", format="Boolean", inherit="no")]
	// Padding top
	[Style(name="paddingTop", type="Number", format="Number", inherit="no")]
	// Padding right
	[Style(name="paddingRight", type="Number", format="Number", inherit="no")]
	// Padding bottom
	[Style(name="paddingBottom", type="Number", format="Number", inherit="no")]
	// Padding left
	[Style(name="paddingLeft", type="Number", format="Number", inherit="no")]		
		
	public class ArrowPopup extends Box
	{
		private var pTop:uint = 0;
		private var pBottom:uint = 0;
		private var pRight:uint = 0;
		private var pLeft:uint = 0;
		
		public function ArrowPopup()
		{
			super();
			
			setStyle('horizontalScrollPolicy', 'off');
			
		}
		
		
		/**
		 * @private
		 * The length of the arrow in the X direction
		 */
		private var _arrowXLength:Number = 20;
		public function set arrowXLength(value:Number):void
		{
			_arrowXLength = value;
		}
		public function get arrowXLength():Number
		{
			return _arrowXLength;
		}

		/**
		 * @private
		 * The length of the arrow in the Y direction
		 */		
		private var _arrowYLength:Number = 26;
		public function set arrowYLength(value:Number):void
		{
			_arrowYLength = value;
		}
		public function get arrowYLength():Number
		{
			return _arrowYLength;
		}
		
		override protected function commitProperties():void 
		{
    		super.commitProperties();
			
			
			// adjust the padding of the box to include the space used by the arrow
			switch(getStyle("arrowSide")){
				case 'left' :
					if (pLeft == 0) {
						pLeft =  getStyle('paddingLeft') + _arrowXLength - 2;
					}
					setStyle('paddingLeft',pLeft);
				break;
				case 'right' :
					if (pRight == 0) {
						pRight = getStyle('paddingRight') + _arrowXLength - 2;
					}
					setStyle('paddingRight', pRight);
				break;
				case 'top' :
					if (pTop == 0) {
						pTop = getStyle('paddingTop')+_arrowYLength;
					}
					setStyle('paddingTop', pTop);
				break;
				case 'bottom' :
					if (pBottom == 0) {
						pBottom = getStyle('paddingBottom')+_arrowYLength;
					}
					setStyle('paddingBottom', pBottom);
				break;
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			// set some default styles
			setupStyles();
			// draw the container border and fill
			drawPopup();
		}
		
        override public function styleChanged(styleProp:String):void 
        {
            super.styleChanged(styleProp);
 
			invalidateDisplayList();
        }


		/**
		 * @private
		 * set of variables defining the styles of the component
		 */
		private var _arrowSide:String;
		private var _gradientColors:Array;
		private var _gradAlphas:Array;
		private var _gradRotation:Number;
		private var _borderWidth:Number;
		private var _borderColor:uint;
		private var _cornerRadius:Number;
		private var _dropShadow:Boolean;
		
		
		/**
		 * Setup the defaults of the component styles
		 */
		private function setupStyles():void
		{
			// setup the styles with defaults if nothing is entered
			_arrowSide = getStyle("arrowSide") || 'left';
			_gradientColors = getStyle("gradientColors") || [0xF7F7F7, 0x999999];
			_gradAlphas = getStyle("gradientAlphas") || [1, 1];
			_gradRotation = getStyle('gradientRotation') || Math.PI/2;
			_borderWidth = getStyle('borderWidth') || 1;
			_borderColor = getStyle('borderColor') || 0xFF0000;
			_cornerRadius = getStyle('cornerRadius') || 0;
			_dropShadow = getStyle('dropShadow') || true;
			
		}
		
		/**
		 * Draw the background graphics on the controller
		 */
		private function drawPopup():void
		{			
			// create a gradient matrix to work on the rotation of the gradient
			var matrix:Matrix = new Matrix();
			var boxWidth:Number = this.width;
			var boxHeight:Number = this.height;
			var boxRotation:Number = _gradRotation;
			var tx:Number = 0;
			var ty:Number = 0;
			matrix.createGradientBox(boxWidth, boxHeight, boxRotation, tx, ty);
	
			this.graphics.clear();
			this.graphics.beginGradientFill(GradientType.LINEAR, _gradientColors, _gradAlphas, [0, 255], matrix);
			this.graphics.lineStyle(_borderWidth,_borderColor);	
			
			switch(_arrowSide){
				
				case 'top' :
					this.graphics.moveTo(0 + _cornerRadius,	_arrowYLength);
					this.graphics.lineTo((this.width/2 - _arrowXLength/2),	_arrowYLength);
					this.graphics.lineTo((this.width/2), 0);
					this.graphics.lineTo((this.width/2 + _arrowXLength/2),	_arrowYLength);
					this.graphics.lineTo(this.width - _cornerRadius, _arrowYLength);
					this.graphics.curveTo(this.width,_arrowYLength,this.width, _arrowYLength + _cornerRadius);
					this.graphics.lineTo(this.width, this.height - _cornerRadius);
					this.graphics.curveTo(this.width, this.height, this.width - _cornerRadius, this.height);
					this.graphics.lineTo(0 + _cornerRadius, this.height);
					this.graphics.curveTo(0, this.height, 0, this.height - _cornerRadius);
					this.graphics.lineTo(0, _arrowYLength + _cornerRadius);
					this.graphics.curveTo(0, _arrowYLength, 0 + _cornerRadius, _arrowYLength);
				break;

				case 'left' :
					this.graphics.moveTo(0 + _arrowXLength + _cornerRadius,	0);
					this.graphics.lineTo((this.width - _cornerRadius), 0);
					this.graphics.curveTo(this.width, 0, this.width, 0 + _cornerRadius);
					this.graphics.lineTo(this.width, this.height - _cornerRadius);
					this.graphics.curveTo(this.width, this.height, (this.width - _cornerRadius), this.height);
					this.graphics.lineTo(0 + _arrowXLength + _cornerRadius,	this.height);
					this.graphics.curveTo(0 + _arrowXLength, this.height, 0 + _arrowXLength, this.height - _cornerRadius);
					this.graphics.lineTo(0 + _arrowXLength, (this.height/3 + _arrowYLength/2));
					this.graphics.lineTo(0, this.height/3);
					this.graphics.lineTo(0 + _arrowXLength, (this.height/3 - _arrowYLength/2));
					this.graphics.lineTo(0 + _arrowXLength, 0 + _cornerRadius);
					this.graphics.curveTo(0 + _arrowXLength, 0, 0 + _arrowXLength + _cornerRadius, 0);
				break;				

				case 'bottom' :
					this.graphics.moveTo(0 + _cornerRadius,	0);
					this.graphics.lineTo((this.width - _cornerRadius), 0);
					this.graphics.curveTo(this.width, 0, this.width, 0 + _cornerRadius);
					this.graphics.lineTo(this.width, this.height - _cornerRadius - _arrowYLength);
					this.graphics.curveTo(this.width, this.height - _arrowYLength, (this.width - _cornerRadius), this.height - _arrowYLength);
					this.graphics.lineTo((this.width/2 + _arrowXLength/2),	this.height - _arrowYLength);
					this.graphics.lineTo((this.width/2), this.height);
					this.graphics.lineTo((this.width/2 - _arrowXLength/2),	this.height - _arrowYLength);
					this.graphics.lineTo(0 + _cornerRadius, this.height - _arrowYLength);
					this.graphics.curveTo(0,this.height - _arrowYLength,0, this.height - _arrowYLength - _cornerRadius);
					this.graphics.lineTo(0, 0 + _cornerRadius);
					this.graphics.curveTo(0, 0, 0 + _cornerRadius, 0);
				break;				

				case 'right' :
					this.graphics.moveTo(0 + _arrowXLength + _cornerRadius,	0);
					this.graphics.lineTo((this.width - _cornerRadius - _arrowXLength), 0);
					this.graphics.curveTo(this.width - _arrowXLength, 0, this.width - _arrowXLength, 0 + _cornerRadius);
					this.graphics.lineTo(this.width - _arrowXLength, (this.height/3 - _arrowYLength/2));
					this.graphics.lineTo(this.width, this.height/3);
					this.graphics.lineTo(this.width - _arrowXLength, (this.height/3 + _arrowYLength/2));
					this.graphics.lineTo(this.width - _arrowXLength, this.height - _cornerRadius);
					this.graphics.curveTo(this.width - _arrowXLength,this.height,this.width - _arrowXLength - _cornerRadius, this.height);
					this.graphics.lineTo(0 + _cornerRadius, this.height);
					this.graphics.curveTo(0, this.height, 0, this.height - _cornerRadius);
					this.graphics.lineTo(0, 0 + _cornerRadius);
					this.graphics.curveTo(0, 0, 0 + _cornerRadius, 0);
				break;				
				
			}	
			
			this.graphics.endFill();	
			
			if(_dropShadow){
				this.filters = [dropshadowFilter()];
			}
		}

		/**
		 * Dropshadow filter to be used if needed
		 */		
		private function dropshadowFilter():DropShadowFilter 
		{		    
		    var distance:Number 	= 6;
		    var angle:Number 		= 90;
		    var color:Number 		= 0x000000;
		    var alpha:Number 		= 1;
		    var blurX:Number 		= 20;
		    var blurY:Number 		= 20;
		    var strength:Number 	= 0.55;
		    var quality:Number 		= BitmapFilterQuality.LOW;
		    var inner:Boolean 		= false;
		    var knockout:Boolean 	= false;
		
		    return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout);
		}
		
	}
}