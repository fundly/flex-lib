////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2007 Enilsson and its licensors.
// All Rights Reserved.
// Author: Rafael Cardoso (rafael.cardoso@enilsson.com)
//
////////////////////////////////////////////////////////////////////////////////

package com.enilsson.utils.buildform
{
    import mx.controls.Label;
    import mx.containers.TitleWindow;
    import mx.managers.PopUpManager;
	import mx.events.CloseEvent;
	import mx.core.Application;
	import flash.display.DisplayObject;
	import mx.effects.Fade;
	import flash.utils.Timer;
	
	public class PopUp
	{
		public var tw:TitleWindow = new TitleWindow();
		public var mainApp:DisplayObject = Application.application as DisplayObject;
		
		public function PopUp(title:String = "", label:String = "", effect:String = 'fade') : void {
			tw.setStyle("paddingBottom",10);
			tw.setStyle("paddingTop",10);
			tw.setStyle("paddingRight",10);
			tw.setStyle("paddingLeft",10);
			
			if (title != '') {			
				tw.title = title;
			}
			
			if (label != '') 
			{
				this.label = label;
			}
			
			if (effect != '') {
				applyEffect(effect+'_open');
				this.effect = effect;
			}
		}
		
		public function add():void
		{
			
			PopUpManager.addPopUp(tw, mainApp, true)
			PopUpManager.centerPopUp(tw);
		}
		
		   
		public function closeDialog(event : CloseEvent) : void {
			this.close();
		}           

		public function close() : void 
		{
			if (effect != '') {
				applyEffect(effect+'_close');
			}
	    	
	    	var dialogTimer:Timer = new Timer(1000,1);
	    	dialogTimer.addEventListener("timer", function():void { PopUpManager.removePopUp(tw);  });	
			dialogTimer.start();
			
		}           


      	public function applyEffect(effect:String):void
        {
            switch(effect)
            {
        		case 'fade_open':
				    // define our Fade effect
				    var myFade:Fade = new Fade(tw);
				    myFade.alphaFrom = 0;
				    myFade.alphaTo = 1;
				    myFade.duration = 1000;            	
				    myFade.play();
			    break;
        		case 'fade_close':
				    // define our Fade effect
				    var myFade2:Fade = new Fade(tw);
				    myFade2.alphaFrom = 1;
				    myFade2.alphaTo = 0;
				    myFade2.duration = 1000;            	
				    myFade2.play();
			    break;

            }
        }			    
	
	    //----------------------------------
	    //  show Close Button
	    //----------------------------------
	
	    /**
	     *  @private
	     *  Aplication url.
	     */

	   	public function get showCloseButton():Boolean
	    {
	        return tw.showCloseButton;
	    }
	
	    public function set showCloseButton(value:Boolean):void
	    {
	    	if (value) {
				tw.addEventListener(CloseEvent.CLOSE, closeDialog);
	    	}
			tw.showCloseButton = value;
	    }


	    //----------------------------------
	    //  title
	    //----------------------------------
	
		public var _title:String;
		
	   	public function get title():String
	    {
	        return _title;
	    }
	
	    public function set title(value:String):void
	    {
			tw.title = value;
			
			_title = value;
	    }


	    //----------------------------------
	    //  label
	    //----------------------------------
	
		public var _label:String;
		
	   	public function get label():String
	    {
	        return _label;
	    }
	
	    public function set label(value:String):void
	    {
			var lb:Label = new Label();
			lb.text = value;
			tw.addChild(lb);
			
			_label = value;
	    }

	    //----------------------------------
	    //  effect
	    //----------------------------------
	
		public var _effect:String;
		
	   	public function get effect():String
	    {
	        return _effect;
	    }
	
	    public function set effect(value:String):void
	    {
			_effect = value;
	    }




	}
}