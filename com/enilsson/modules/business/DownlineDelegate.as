package com.enilsson.modules.business
{
	import mx.rpc.AsyncToken;
	import mx.rpc.remoting.mxml.RemoteObject;
	
	public class DownlineDelegate implements IDownlineDelegate
	{
		public function DownlineDelegate( service : RemoteObject )
		{
			_service = service;
		}
		
		public function getDownline( userId : int, nodeLevels : int ) : AsyncToken {
			return _service.get_downline( userId, nodeLevels );
		}
		
		public function getDownlineParents( userId : int ) : AsyncToken {
			return _service.get_parents( userId );
		}
		
		private var _service : RemoteObject;
	}
}