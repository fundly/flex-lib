package com.enilsson.events
{
	public class GetEventHandler
	{
		public static function handleResult( event : GetEvent, result : Object ) : void {
			if( isValidEvent(event) )
				event.host[event.prop] = result["result"];
		}
		
		public static function handleFault( event : GetEvent, fault : Object ) : void {
			if( isValidEvent(event) )
				event.host[event.prop] = null;
		} 
		
		private static function isValidEvent( event : GetEvent ) : Boolean {
			return event && event.host  && event.prop && event.host.hasOwnProperty( event.prop );
		}
	}
}