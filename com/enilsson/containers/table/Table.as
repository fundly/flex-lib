package com.enilsson.containers.table 
{
	import mx.containers.Grid;
	import mx.controls.Text;
	import mx.events.ResizeEvent;
	
     public class Table extends Grid 
     {

		// Define the constructor.
		public function Table() 
		{
		     super();

		     // set width to 100%
		     percentWidth = 100;
		     
		     this.addEventListener(ResizeEvent.RESIZE, resizeHandler);
		}
		/**
	     *  @private
	     * set the cellpadding
	     */
		private var _cellpadding:* = 0;

	   	public function get cellpadding():*
	    {
	        return _cellpadding;
	    }
	
	    public function set cellpadding(value:*):void
	    {
			_cellpadding = value;	
	    }
	    
		/**
	     *  @private
	     * set the cellspacing
	     */
		private var _cellspacing:Number = 0;

	   	public function get cellspacing():Number
	    {
	        return _cellspacing;
	    }
	
	    public function set cellspacing(value:Number):void
	    {
			_cellspacing = value;	
	    }
	    
		/**
	     *  @private
	     * alternate colors
	     */
		private var _alternateBgColor:Array = [0xEEEEEE,0xFFFFFF];

	   	public function get alternateBgColor():Array
	    {
	        return _alternateBgColor;
	    }
	
	    public function set alternateBgColor(value:Array):void
	    {
			_alternateBgColor = value;	
	    }	    
	    
	    private function resizeHandler(e:ResizeEvent):void
	    {
	    	this.invalidateDisplayList();	    	
	    }
	    
    	override protected function commitProperties():void 
        {
            super.commitProperties();

			// set cellspacing
 			setStyle("horizontalGap",cellspacing);
	    	setStyle("verticalGap",cellspacing);
             
			function setDetails(mainChild:*):void 
			{
				var n:int = mainChild.numChildren;
				for (var i:int = 0; i < n; i++)
				{
				    var child:* = mainChild.getChildAt(i);
				    
				    if (child is TR) 
				    {	
						child.setStyle("backgroundColor",((child.getStyle('backgroundColor')) ? child.getStyle('backgroundColor') : (((i%2)==0) ? alternateBgColor[0] : alternateBgColor[1])));
				    }
				    
					// set cellspacing
					var padding:Array  = cellpadding.toString().split(" ");
					    
				    if ((child is Text) && (child.parent is TD)) 
				    {
						if (padding.length == 2) 
						{
				 			child.setStyle("paddingTop",padding[0]);
					    	child.setStyle("paddingBottom",padding[0]);
				 			child.setStyle("paddingLeft",padding[1]);
					    	child.setStyle("paddingRight",padding[1]);
						} 
						else if (padding.length == 3) 
						{
				 			child.setStyle("paddingTop",padding[0]);
					    	child.setStyle("paddingBottom",padding[2]);
				 			child.setStyle("paddingLeft",padding[1]);
					    	child.setStyle("paddingRight",padding[1]);
						} 
						else if (padding.length == 4) 
						{
				 			child.setStyle("paddingTop",padding[0]);
					    	child.setStyle("paddingRight",padding[1]);
					    	child.setStyle("paddingBottom",padding[2]);
				 			child.setStyle("paddingLeft",padding[3]);
						} 
						else 
						{
				 			child.setStyle("paddingTop",cellpadding);
					    	child.setStyle("paddingBottom",cellpadding);
				 			child.setStyle("paddingLeft",cellpadding);
					    	child.setStyle("paddingRight",cellpadding);
				  		}
				    }
					if (child.hasOwnProperty('numChildren') && (child.numChildren > 0)) {
				    	setDetails(child);
				 	}
				 	
				}
			}
			
			setDetails(this);
			
         }   	
         
         	    
     }

}
