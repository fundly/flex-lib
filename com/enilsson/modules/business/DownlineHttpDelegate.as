package com.enilsson.modules.business
{
	import mx.rpc.AsyncToken;
	import mx.rpc.http.mxml.HTTPService;
	
	public class DownlineHttpDelegate implements IDownlineDelegate
	{
		public function DownlineHttpDelegate( service : HTTPService )
		{
			_service = service;
		}
		
		public function getDownline( userId : int, nodeLevels : int ) : AsyncToken {
			return _service.send();
		}
		
		public function getDownlineParents( userId : int ) : AsyncToken {
			return _service.send();
		}
		
		private var _service : HTTPService;
	}
}