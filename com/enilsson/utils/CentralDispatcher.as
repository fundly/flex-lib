package com.enilsson.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class CentralDispatcher extends EventDispatcher
	{
		public static function addEventListener( type:String, 
			listener:Function, 
			useCapture:Boolean = false, 
			priority:int = 0, 
			useWeakReference:Boolean = false ) : void {
			
			_dispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}
		
		public static function dispatch( eventType : String ) : void {
			_dispatcher.dispatchEvent( new Event( eventType ) );
		}
		
		public static function dispatchEvent( event : Event ) : void {
			_dispatcher.dispatchEvent( event );
		}
		
		public static function hasEventListener( type:String ) : Boolean {
			return _dispatcher.hasEventListener( type );	
		}
		
		public static function removeEventListener( type:String, listener:Function, useCapture:Boolean = false) : void {
			_dispatcher.removeEventListener( type, listener, useCapture );
		}
		
		public static function willTrigger( type : String ) : Boolean {
			return _dispatcher.willTrigger( type );
		}
		
		private static var _dispatcher : CentralDispatcher = new CentralDispatcher();
	}
}