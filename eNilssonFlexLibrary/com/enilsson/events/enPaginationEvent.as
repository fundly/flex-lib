package com.enilsson.events
{
	import flash.events.Event;
	
	import org.osflash.thunderbolt.Logger;

	public class enPaginationEvent extends Event
	{
		public static const PAGE_ACTION:String = "page_action";
		
		public var pageAction:*;

		public function enPaginationEvent(type:String, action:int, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			switch(type){
				case PAGE_ACTION :
					this.pageAction = action;
				break;
			}

		}
		
	}
}