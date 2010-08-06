package com.enilsson.modules.downline
{
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.effects.Rotate;

	public class RotatingButton extends Canvas
	{
		private var wt:WhiteTriangle;
		
		public function RotatingButton()
		{
			super();
			
			verticalScrollPolicy = 'off';
			horizontalScrollPolicy = 'off';
			clipContent = true;
			useHandCursor = true;
			buttonMode = true;
			
			width = 10;
			height = 10;
			
			var boxHolder:UIComponent = new UIComponent();
			addChild(boxHolder);
			boxHolder.width = width;
			boxHolder.height = height;
			boxHolder.x = 0;
			boxHolder.y = 0;
			
			wt = new WhiteTriangle(6);
			boxHolder.addChild(wt);
			wt.x = 4;
			wt.y = 4;
		}
		
		public function rotateTriangle():void
		{
			wt.rotation = wt.rotation == 0 ? 180 : 0;			
		}
		
		
	}
}