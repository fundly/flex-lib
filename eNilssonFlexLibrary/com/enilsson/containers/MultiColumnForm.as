package com.enilsson.containers
{
	import mx.containers.Form;
	
	public class MultiColumnForm extends Form
	{
		public function MultiColumnForm()
		{
			super();
			
			this.horizontalScrollPolicy = 'off';
			this.verticalScrollPolicy = 'off';
		}
	
	
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(maxHeight == 10000) return;
			
			var vGap:int = getStyle('verticalGap');
			var currColumn:Number = 0;
			var cumlHt:Number = 0;
			var startHeight:Number = 0;
			var alleyWidth:Number = Math.floor(width/_numColumns);
			
			for( var i:int=0; i<numChildren; i++)
			{
				var child:* = getChildAt(i);
				
				if(i == 0 && child.className != 'StackableFormItem')
					startHeight = child.height + vGap;
				
				if((cumlHt + vGap + child.height) > maxHeight)
				{
					currColumn++;
					cumlHt = startHeight;
				}
				
				child.move(currColumn * alleyWidth, cumlHt);
				cumlHt += vGap + child.height;
			}
		}
	
	
	    /**
	     *  @private
	     *  number of columns the form should have
	     */	    
		private var _numColumns:int = 1;
	
	   	public function get numColumns():int
	    {
	        return _numColumns;
	    }
	
	    public function set numColumns(value:int):void
	    {
			_numColumns = value;
	    }	    
	}

}