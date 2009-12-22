package com.enilsson.graphics.skins
{
	
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import mx.core.EdgeMetrics;
	import mx.skins.halo.HaloBorder;
	import mx.utils.ColorUtil;
	import mx.utils.GraphicsUtil;
	
	public class clearTextAreaBorder extends HaloBorder 
	{
		
		// ------------------------------------------------------------------------------------- //
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);	
			
			var g:Graphics = graphics;
			var b:EdgeMetrics = borderMetrics;
			var w:Number = unscaledWidth - b.left - b.right;
			
			g.beginFill(0x6d6f70);
			g.lineStyle(1,0x6d6f70);
			g.moveTo(0,0);
			g.lineTo(width,0);
			g.endFill();
		}
		
	}
}