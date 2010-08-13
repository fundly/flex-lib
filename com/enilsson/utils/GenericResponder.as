package com.enilsson.utils
{
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	public class GenericResponder implements IResponder
	{
		public function GenericResponder( resultHandler : Function = null, faultHandler : Function = null ) {
			_resultHandler = resultHandler;
			_faultHandler = faultHandler;	
		}
		
		public function result( data:Object ):void
		{			
			if( _resultHandler != null ) 
				_resultHandler( data as ResultEvent );
		}
		
		public function fault( info:Object ):void
		{
			if( _faultHandler != null )
				_faultHandler( info as FaultEvent );
		}
		
		private var _resultHandler 	: Function;
		private var _faultHandler 	: Function;
	}
}