package com.enilsson.events
{
	import flash.events.Event;

	public class GetEvent extends Event
	{
		public var host		: Object;
		public var prop		: String;
		public var params  	: Array;
		
		public function GetEvent(type:String, host : Object, prop : String, params : Array = null) {
			super(type, true, false);

			this.host 	= host;
			this.prop 	= prop; 
			this.params = params; 
		}
		
		override public function clone() : Event {
			return new GetEvent( type, host, prop, params );
		}
		
	}
}