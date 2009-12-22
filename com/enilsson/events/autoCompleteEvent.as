package com.enilsson.events
{
	import flash.events.Event;

	public class autoCompleteEvent extends Event
	{
		public static const AC_SEARCHCOMPLETE:String = "searchComplete";
		
		public var data:*;

		public function autoCompleteEvent(type:String, data:Object, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
			switch(type){
				case AC_SEARCHCOMPLETE :
					this.data = data;
				break;
			}
		}
		
	}
}