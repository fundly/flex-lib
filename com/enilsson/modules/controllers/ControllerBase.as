package com.enilsson.modules.controllers
{
	import com.enilsson.events.GetEvent;
	import com.enilsson.events.GetEventHandler;
	import com.enilsson.utils.DictionaryUtil;
	import com.enilsson.utils.GenericResponder;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	public class ControllerBase
	{
		public function executeGet( event : GetEvent, delegateFunction : Function ) : AsyncToken {
			if( event == null || delegateFunction == null ) 
				return null;
			
			var t : AsyncToken;
			if(event.params != null) 
				t = delegateFunction.apply(null, event.params);
			else
				t = delegateFunction(); 				
			
			t.addResponder( new GenericResponder( handleGetEventResult, handleGetEventFault ) );
			_tokenEventDict.add( t, event );
			
			return t; 			
		}
		
		public function handleGetEventResult( result : ResultEvent ) : void {
			var t : AsyncToken = result.token;
			GetEventHandler.handleResult( _tokenEventDict.getItem(t) as GetEvent, result );
			_tokenEventDict.remove(t);
		}
		public function handleGetEventFault( fault : FaultEvent ) : void {
			var t : AsyncToken = fault.token;
			GetEventHandler.handleFault( _tokenEventDict.getItem(t) as GetEvent, fault );
			_tokenEventDict.remove(t);			
		}

		protected var _tokenEventDict : DictionaryUtil = new DictionaryUtil();
		
		public function get delegate() : Object { return null; }
		public function set delegate( val : Object ) : void { }
	}
}