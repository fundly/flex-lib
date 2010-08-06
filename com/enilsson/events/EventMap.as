package com.enilsson.events
{
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	public class EventMap
	{
		public function set dispatcher( val : IEventDispatcher ) : void {
			if( val != _dispatcher ) {
				removeListeners();
				_dispatcher = val;
				addListeners();
			}
		}
		private var _dispatcher : IEventDispatcher;
		
		public function set mappings( val : Array ) : void {
			if( val != _mappings ) {
				removeListeners();
				_mappings = val;
				addListeners();	
			}
		}
		private var _mappings : Array;
		
		private function addListeners() : void {
			if(_mappings) {
				for each( var m : EventMapping in _mappings ) {
					addListener( m.type, m.handler );
				}
			}
		}
		
		private function addListener( type : String, func : Function ) : void {
			if( _dispatcher != null && type != null  && func != null ) {
				_listeners[func] = type;
				_dispatcher.addEventListener( type, func );
			}
		}
		
		private function removeListeners() : void {
			for each( var func : Function in _listeners ) {
				
				if(_dispatcher) {
					_dispatcher.removeEventListener( _listeners[func], func );
				}
				
				delete _listeners[func];
			}	
		}
		
		private var _listeners : Dictionary = new Dictionary( true );
		
	}
}