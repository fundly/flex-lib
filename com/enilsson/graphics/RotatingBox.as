package com.enilsson.graphics
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class RotatingBox extends Sprite
	{
		private var intervalId:uint;
		public var speed:Number;
		public var cornerRadius:Number;
		public var fillColors:Array;
		public var size:Number;

		public function RotatingBox(boxSize:Number, radius:Number, colors:Array, speed:Number)
		{
			super();
			this.size = boxSize
			this.speed = speed;
			this.cornerRadius = radius;
			this.fillColors = colors;

			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(size, size, 0, 0, 0);

			graphics.beginGradientFill(GradientType.LINEAR, fillColors,[1,1],[0,255], matrix);
			graphics.drawRoundRect(-Math.round(size/2),-Math.round(size/2),size,size,cornerRadius);
			graphics.endFill();
		}

		public function update(boxSize:Number, radius:Number, colors:Array, speed:Number):void
		{
			this.size = boxSize
			this.speed = speed;
			this.cornerRadius = radius;
			this.fillColors = colors;
		}

		private function stepComponent():void
		{
			this.rotation += 3;
		}

		public function stop():void
		{
			clearInterval(intervalId);
		}
		
		public function play():void
		{
			intervalId = setInterval(stepComponent, speed);
		}
	}
}