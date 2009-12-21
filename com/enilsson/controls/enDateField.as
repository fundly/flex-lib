package com.enilsson.controls
{
	import flash.events.MouseEvent;
	import com.enilsson.graphics.enCloseBtn;
	import mx.controls.DateField;

	public class enDateField extends DateField
	{
		public var clearBtn:enCloseBtn = new enCloseBtn();
		
		public function enDateField()
		{
			super();
			
			addEventListener(MouseEvent.MOUSE_OVER, showClearBtn);
			addEventListener(MouseEvent.MOUSE_OUT, hideClearBtn);			
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
		    clearBtn = new enCloseBtn();
		    clearBtn.dropShadow = false;
		    clearBtn.backgroundColor =  0xbebebe;
		    clearBtn.rollOverAlpha = 1;
		    clearBtn.toolTip = 'Clear date';
		    clearBtn.visible = false;
		    clearBtn.addEventListener(MouseEvent.CLICK, clearDate);
		    textInput.addChild(clearBtn);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			clearBtn.size = textInput.height - 4;
	    	clearBtn.crossSize = textInput.height - 20;
		    clearBtn.move((textInput.width - (textInput.height - 2) - 2), 2);
		}
		
		public function showClearBtn(e:MouseEvent):void
		{
			clearBtn.visible = true;
		}
		
		public function hideClearBtn(e:MouseEvent):void
		{
			clearBtn.visible = false;			
		}
		
		public function clearDate(e:MouseEvent):void
		{
			textInput.text = '';			
		}
		
	}
}