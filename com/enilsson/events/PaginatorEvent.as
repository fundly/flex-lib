package com.enilsson.events
{
	import flash.events.Event;

	public class PaginatorEvent extends Event
	{
		public static const PAGE_CHANGE:String = "pageChange";
		public static const NEW_PAGE:String = "newPage";		

		public var index:int;
		public var itemsTotal:int;
		public var itemsPerPage:int;
		
		public function PaginatorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}