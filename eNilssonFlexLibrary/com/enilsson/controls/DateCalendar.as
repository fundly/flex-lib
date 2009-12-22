package com.enilsson.controls
{
	
import flash.events.Event;
import flash.text.TextLineMetrics;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.DateChooser;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.styles.StyleProxy;


use namespace mx_internal;

[Style(name="thisMonthSkin", type="Class", inherit="no", states="up, over, down, disabled")]

	public class DateCalendar extends DateChooser
	{
		public function DateCalendar()
		{
			super();
			
		}
		
		mx_internal var thisMonthButton:Button;
		
		private var thisMonthSkinWidth:Number = 6;
    	private var thisMonthSkinHeight:Number = 11;
 
     	protected function get thisMonthStyleFilters():Object
	    {
	        return _thisMonthStyleFilters;
	    }
	    
	    private static var _thisMonthStyleFilters:Object = 
	    {
	        "highlightAlphas" : "highlightAlphas",
	        "thisMonthUpSkin" : "thisMonthUpSkin",
	        "thisMonthOverSkin" : "thisMonthOverSkin",
	        "thisMonthDownSkin" : "thisMonthDownSkin",
	        "thisMonthDisabledSkin" : "thisMonthDisabledSkin",
	        "thisMonthSkin" : "thisMonthSkin",
	        "repeatDelay" : "repeatDelay",
	        "repeatInterval" : "repeatInterval"
	    };   	

	    override protected function measure():void
	    {
	        super.measure();

	        thisMonthSkinWidth = thisMonthButton.getExplicitOrMeasuredWidth();
	        thisMonthSkinHeight = thisMonthButton.getExplicitOrMeasuredHeight();	        
	    }

	    override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void
	    {
	        super.updateDisplayList(unscaledWidth, unscaledHeight);
	        
			var borderThickness:Number = getStyle("borderThickness");
	        var w:Number = unscaledWidth - borderThickness*2;
	        
	        var lineMetrics:TextLineMetrics;
	        lineMetrics = measureText(monthDisplay.text);
	        
	        //Alert.show(monthDisplay.width + ' | ' + lineMetrics.width + ' | ' + Math.floor(w/2 - lineMetrics.width));

			monthDisplay.setActualSize(lineMetrics.width + 18,monthDisplay.height);
	        monthDisplay.move(Math.floor(w/2 - monthDisplay.width), 17);
	        yearDisplay.move(Math.max(w/2 + 5), 17);
	        
	        thisMonthButton.setActualSize(thisMonthSkinWidth, thisMonthSkinHeight);
	       	thisMonthButton.move(Math.floor(w/2), (fwdMonthButton.y-2));

	       	fwdMonthButton.move((fwdMonthButton.x - 4), fwdMonthButton.y);
	       	backMonthButton.move((backMonthButton.x + 4), backMonthButton.y);	       	
	    }
	    
	    override protected function createChildren():void
	    {
	    	super.createChildren();
	    	
	    	// remove some of the style element we dont want
	    	removeChild(border);
	    	removeChild(background);
	    	removeChild(calHeader);
	    	
	    	// add a new button to jump to this month	
            thisMonthButton = new Button();
            
            thisMonthButton.styleName = new StyleProxy(this,thisMonthStyleFilters);
            thisMonthButton.autoRepeat = true;
            thisMonthButton.focusEnabled = false;
            thisMonthButton.upSkinName = "thisMonthUpSkin";
            thisMonthButton.overSkinName = "thisMonthOverSkin";
            thisMonthButton.downSkinName = "thisMonthDownSkin";
            thisMonthButton.disabledSkinName = "thisMonthDisabledSkin";
            thisMonthButton.skinName = "thisMonthSkin";
            thisMonthButton.useHandCursor = true;
            thisMonthButton.buttonMode = true;
            thisMonthButton.addEventListener(FlexEvent.BUTTON_DOWN, thisMonthButton_buttonDownHandler);
            addChild(thisMonthButton);
            
            fwdMonthButton.useHandCursor = true;
            fwdMonthButton.buttonMode = true;
            backMonthButton.useHandCursor = true;
            backMonthButton.buttonMode = true;
   	    }

	    private function thisMonthButton_buttonDownHandler(event:Event):void
	    {
	        var today:Date = new Date();

			dateGrid.setSelectedMonthAndYear(today.getMonth(), today.getFullYear());
	        invalidateDisplayList();
	    }
		
	}
}