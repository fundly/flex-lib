package com.enilsson.graphics
{
	import caurina.transitions.Tweener;
	
	import flash.events.TimerEvent;
	import flash.text.TextLineMetrics;
	import flash.utils.Timer;
	
	import mx.containers.Canvas;
	import mx.controls.Text;
	import mx.core.UIComponent;
	
	
	[Style(name="textStyleName", type="String", inherit="no")]
	[Style(name="textAlpha", type="Number", inherit="no")]
	[Style(name="boxFillColors", type="Array",format="Color",inherit="no")]
	[Style(name="boxSize", type="Number", inherit="no")]
	[Style(name="boxCornerRadius", type="Number", inherit="no")]
	[Style(name="boxTopPosition", type="Number", inherit="no")]
	[Style(name="boxSpeed", type="Number", inherit="no")]	
	
	public class ActivityIndicator extends Canvas
	{
		private static const DEFAULT_TEXT_ALPHA : Number = 0.5;
		private static const DEFAULT_BOX_FILL_COLORS : Array = [0xf0f0f0, 0x999999];
		private static const DEFAULT_BOX_SIZE : Number = 30;
		private static const DEFAULT_BOX_CORNER_RADIUS : Number = 6;
		private static const DEFAULT_BOX_TOP_POSITION : Number = 20;
		private static const DEFAULT_BOX_SPEED : Number = 10;
		
		private var txt:Text;
		private var _init:Boolean = true;
		private var rBox:RotatingBox;
		private var textTimer:Timer;
		private var boxHolder:UIComponent;

		public function ActivityIndicator()
		{
			super();
			
			this.verticalScrollPolicy = 'off';
			this.horizontalScrollPolicy = 'off';
		}
		
		
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			var allStyles:Boolean = styleProp == null || styleProp == "styleName";

			if(	allStyles ||
				styleProp == "textStyleName" || 
				styleProp == "textAlpha" ||
				styleProp == "boxFillColors" ||
				styleProp == "boxSize" || 
				styleProp == "boxCornerRadius" ||
				styleProp == "boxTopPosition" ||
				styleProp == "boxSpeed" )
				{
					_init = true;
					invalidateDisplayList();
				}			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(_init){
				createLayout();
				
				_init = false;
			}		
		}

		private function createLayout():void
		{
			var txtAlpha : Number = getStyle('textAlpha');
			if(!txt)
			{
				txt = new Text();
				addChild(txt);
			}
			txt.text = _textMessage;
			txt.x = 0;
			txt.y = 0;
			txt.alpha = isNaN(txtAlpha) ? DEFAULT_TEXT_ALPHA : txtAlpha;
			txt.percentWidth = 100;
			txt.setStyle('textAlign', 'left');
			txt.styleName = getStyle('textStyleName');

			
			var bSize:Number = getStyle('boxSize');
			var bColors:Array = getStyle('boxFillColors');
			var bCorner:Number = getStyle('boxCornerRadius');
			var bSpeed:Number  = getStyle('boxSpeed');
			var bTextLength:TextLineMetrics = this.measureText(_textMessage);
			var bTop:Number = getStyle('boxTopPosition')
			
			bSize = isNaN(bSize) ? DEFAULT_BOX_SIZE : bSize;
			bColors = bColors == null ? DEFAULT_BOX_FILL_COLORS : bColors;
			bCorner = isNaN(bCorner) ? DEFAULT_BOX_CORNER_RADIUS : bCorner;
			bSpeed = isNaN(bSpeed) ? DEFAULT_BOX_SPEED : bSpeed;

			if(!boxHolder)
			{
				boxHolder = new UIComponent();
				addChild(boxHolder);
			}
			if(!rBox)
			{
				rBox = new RotatingBox(bSize, bCorner, bColors, bSpeed);
				boxHolder.addChild(rBox);
				rBox.play();
			}
			boxHolder.percentWidth = 100;
			boxHolder.x = 0;
			boxHolder.y = isNaN(bTop) ? DEFAULT_BOX_TOP_POSITION : bTop;

			rBox.update(bSize, bCorner, bColors, bSpeed);
			rBox.x = Math.round(bTextLength.width/2 - 2);
			rBox.y = Math.round(bSize/2);
			if(!textTimer)
			{
				textTimer = new Timer(500);
				textTimer.addEventListener(TimerEvent.TIMER, updateText);
				textTimer.start();
			}
		}

		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if(value)
			{
				rBox.play();
				textTimer.start();
			}
			else
			{
				rBox.stop();
				textTimer.stop();
			}
		}

		public function toggle(forceShow:Boolean = false):void
		{
			textTimer.start();
			
			var action:Boolean = forceShow ? false : this.visible;
			
			switch(action)
			{
				case true :
					Tweener.addTween(this, {
						alpha:0, 
						time:0.4, 
						onComplete: function(): void { 
							visible = false 
							textTimer.stop();
						}
					});
				break;
				case false :
					visible = true;
				break;	
			}
		}
		
		private function updateText(e:TimerEvent):void
		{
			var currText:String = txt.text;
			switch(currText.length)
			{
				case _textMessage.length :
					txt.text = _textMessage + '.';
				break;
				case (_textMessage.length+1) :
					txt.text = _textMessage + '..';
				break;			
				case (_textMessage.length+2) :
					txt.text = _textMessage + '...';
				break;
				case (_textMessage.length+3) :
				default :
					txt.text = _textMessage;
				break;						
			}
		}		
		
		
		private var _textMessage:String = 'Loading Data';
		public function set textMessage(value:String):void
		{
			_textMessage = value;
		}
		public function get textMessage():String
		{
			return _textMessage;
		}
		
	}
	
}