package com.enilsson.modules.downline
{
	import flash.display.Sprite;
	import flash.utils.Timer;

	public class WhiteTriangle extends Sprite
	{
		private var _color:uint;
		private var _height:int;
		private var _rotation:int;
		
		public function WhiteTriangle(height:int=10, color:uint=0xFFFFFF, rotation:int=0)
		{
			super();
			
			this._color = color;
			this._height = height;
			this._rotation = rotation;
			
			drawTriangle();
		}
		
		
		private function drawTriangle():void
		{			
			graphics.beginFill(_color);
			graphics.moveTo(0, Math.round(_height/2));
			graphics.lineTo(Math.round(_height/2), -Math.round(_height/2));
			graphics.lineTo(-Math.round(_height/2), -Math.round(_height/2));
			graphics.lineTo(0, Math.round(_height/2));
			
			this.rotation = _rotation;
		}
		
	}
}