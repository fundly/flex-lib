package com.enilsson.events
{
	import flash.events.Event;

	public class CallbackEvent extends Event
	{
		public var callback : Function;
		
		public function CallbackEvent(type:String, callback:Function=null) {
			super(type, true, false);
			this.callback = callback;
		}
		
		override public function clone() : Event {
			return new CallbackEvent(type, callback);
		}
		
	}
}