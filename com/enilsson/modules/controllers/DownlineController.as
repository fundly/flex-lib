package com.enilsson.modules.controllers
{
	import com.enilsson.events.GetEvent;
	import com.enilsson.modules.business.IDownlineDelegate;
	
	public class DownlineController extends ControllerBase
	{
		public function getDownline( event : GetEvent ) : void {
			if( _delegate && event )
				executeGet( event, _delegate.getDownline );				
		}
		
		public function getDownlineParents( event : GetEvent ) : void {
			if( _delegate && event )
				executeGet( event, _delegate.getDownlineParents );
		}
		
		override public function set delegate(val:Object):void {
			_delegate = val as IDownlineDelegate;	
		}
		override public function get delegate():Object {
			return _delegate;
		}
		
		private var _delegate : IDownlineDelegate;
	}
}