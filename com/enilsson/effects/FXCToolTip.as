/*
    FXCToolTipBorder
    
    HTML supported tooltip, I just love it when code comes together
    Now with the sticky tooltip feature;
    
    version 0.2
    -	It's trying not fall off screen
    	(fix made by: Luke McLean)
    
    version 0.1
    -	Background is scaling to match htmlText;
    -	Tooltip sticks to mouse;
    
    TODO:
    - For some reason it's ignoring the style in the HTML-text
    
    Created by Maikel Sibbald
    info@flexcoders.nl
    http://labs.flexcoders.nl
    
    Free to use.... just give me some credit
*/
package com.enilsson.effects {
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    
    import mx.controls.ToolTip;
    import mx.core.Application;
    import mx.core.UITextField;
    import mx.effects.Fade;
    import mx.events.EffectEvent;
    import mx.managers.ToolTipManager;
    import mx.skins.halo.ToolTipBorder;

    public class FXCToolTip extends ToolTipBorder{
        private var isInit:Boolean;
		private var relx:Number;
		private var rely:Number;
		
       	public function FXCToolTip():void{
        	super();
        	//if you want your regular tooltip with HTML support, comment the following out
        	this.makeSticky();
        }
        
        private function makeSticky():void{
				this.addEventListener(Event.ENTER_FRAME, function():void{
					if(parent != null){
						var xBounds:Boolean = (((Application.application.mouseX + parent.width - relx) < Application.application.screen.width)&&(Application.application.mouseX - relx > 0));
						var yBounds:Boolean = (((Application.application.mouseY + parent.height - rely) < Application.application.screen.height)&&(Application.application.mouseY - rely > 0));
						
						if (!isInit) {
							relx = Application.application.mouseX - parent.x;
							rely = Application.application.mouseY - parent.y;
							isInit = true;
						}
	
						if (xBounds && yBounds) {
							parent.x = Application.application.mouseX - relx;
							parent.y = Application.application.mouseY - rely;
						} else if (yBounds) {
							parent.y = Application.application.mouseY - rely;
							relx = Application.application.mouseX - parent.x;
						} else if (xBounds) {
							parent.x = Application.application.mouseX - relx;
							rely = Application.application.mouseY - parent.y;
						} else {
							relx = Application.application.mouseX - parent.x;
							rely = Application.application.mouseY - parent.y;
						}
					}
			});
        }
        
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
            this.makeSticky();
            
            var toolTip:ToolTip = (this.parent as ToolTip);
            var textField:UITextField = toolTip.getChildAt(1) as UITextField;
            textField.htmlText = textField.text;
            
            var calHeight:Number = textField.height;
            calHeight += textField.y*2;
            calHeight += textField.getStyle("paddingTop");
            calHeight += textField.getStyle("paddingBottom");
            
            var calWidth:Number = textField.textWidth;
            calWidth += textField.x*2;
            calWidth += textField.getStyle("paddingLeft");
            calWidth += textField.getStyle("paddingRight");
            
            super.updateDisplayList(unscaledWidth, calHeight);
        }

    }
}