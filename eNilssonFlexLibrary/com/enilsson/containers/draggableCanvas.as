package com.enilsson.containers
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.osflash.thunderbolt.Logger;
	import mx.utils.ObjectUtil;
	import mx.containers.Canvas;

	public class draggableCanvas extends Canvas
	{
		public function draggableCanvas()
		{
			super();
		}
		
		override protected function createChildren():void
		{
        	super.createChildren();
        	
			if(!_dragHandle){
				addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			} else {
				_dragHandle.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			}	

		}

	    /**
	     *  @private
	     *  Horizontal location where the user pressed the mouse button
	     *  on the titlebar to start dragging, relative to the original
	     *  horizontal location of the Panel.
	     */
	    private var regX:Number;
	    
	    /**
	     *  @private
	     *  Vertical location where the user pressed the mouse button
	     *  on the titlebar to start dragging, relative to the original
	     *  vertical location of the Panel.
	     */
	    private var regY:Number;
	    
	    /**
	    * @private
	    * Register a display element within the canvas to use as the drag handle
	    */		    
	    private var _dragHandle:DisplayObject;
	    
	    public function set dragHandle(value:DisplayObject):void
	    {
	    	if(_dragHandle){
	    		_dragHandle.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	    	}
	    	
	    	_dragHandle = value;
	    	
	    	removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	    	_dragHandle.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler)
	    }

	    public function get dragHandle():DisplayObject
	    {
	    	return _dragHandle;
	    }
	    
	    /**
	    * @private
	    * List of display objects within the canvas that should not initiate the drag
	    */
	    private var _stopObjects:Array;
	    
	    public function set stopObjects(value:Array):void
	    {
	    	_stopObjects = value;
	    }

	    public function get stopObjects():Array
	    {
	    	return _stopObjects;
	    }

		
	    /**
	     *  Called when the user starts dragging the canvas
	     */
	    protected function startDragging(event:MouseEvent):void
	    {
	        regX = event.stageX - x;
	        regY = event.stageY - y;
	        
	        systemManager.addEventListener(MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);
	        systemManager.addEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true);
	        systemManager.stage.addEventListener(Event.MOUSE_LEAVE, stage_mouseLeaveHandler);
	    }
	
	    /**
	     *  Called when the user stops dragging the canvas
	     */
	    protected function stopDragging():void
	    {
	        systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);
	        systemManager.removeEventListener(MouseEvent.MOUSE_UP, systemManager_mouseUpHandler, true);
	        systemManager.stage.removeEventListener(Event.MOUSE_LEAVE, stage_mouseLeaveHandler);
	
	        regX = NaN;
	        regY = NaN;
	    }



		//-----------------------
		//	Event Handlers
		//-----------------------

	    /**
	     *  @private
	     */
		private function mouseDownHandler(e:MouseEvent):void
		{
			// loop through any stop objects and reject the drag if there is a match
			for(var i:String in _stopObjects){
				if(e.target == _stopObjects[i]){
					return;
				}
			}
			// if there is a drag handle registered stop the drag if there is no match
			if(_dragHandle){
				if(e.target != _dragHandle){
					return;
				}
			}
			// if all is well start the drag
			startDragging(e);
		}

	    /**
	     *  @private
	     */
	    private function systemManager_mouseMoveHandler(event:MouseEvent):void
	    {
	    	event.stopImmediatePropagation();
				    	
	        move(event.stageX - regX, event.stageY - regY);
	    }
	
	    /**
	     *  @private
	     */
	    private function systemManager_mouseUpHandler(event:MouseEvent):void
	    {
	        if (!isNaN(regX))
	            stopDragging();
	    }
	
	    /**
	     *  @private
	     */
	    private function stage_mouseLeaveHandler(event:Event):void
	    {
	        if (!isNaN(regX))
	            stopDragging();
	    }

		
	}
}