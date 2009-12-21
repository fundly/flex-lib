package com.enilsson.containers.table
{
	import mx.containers.GridItem;
	import mx.controls.Text;
	import mx.events.FlexEvent;
	
	import org.osflash.thunderbolt.Logger;
	
     public class TD extends GridItem 
     {

		public function TD() 
		{
		     super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void 
		{
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// set heigh to 100%
			if (height == 0) {
		  	  percentHeight = 100;
		 	}

		    // set width to 100%
		    if (width == 0) {
		    	percentWidth = 100;
		    }
		}
	    /**
	     *  @private
	     * innerHTML add a HTML code to the TD
	     */
		private var _innerHTML:String;

	   	public function get innerHTML():String
	    {
	        return _innerHTML;
	    }
	
	    public function set innerHTML(value:String):void
	    {
	    	removeAllChildren();
	    	
	    	var txt:Text = new Text();
	    	txt.htmlText = value;
	    	txt.styleName = "txtInside";
			/*
			var txt:TextArea = new TextArea();
			txt.wordWrap = true;
			txt.percentWidth = 100;
			txt.editable = false;
			txt.condenseWhite = true;
			txt.setStyle("backgroundAlpha",0);
			txt.setStyle("borderStyle","none");
			txt.htmlText = value;
			txt.validateNow();
			txt.height = txt.textHeight + txt.getStyle("fontSize")+5;
			*/
			    	
	    	if (value != "") {
	    		addChild(txt);
	    	}

			_innerHTML = value;	
	    }
     }

}
