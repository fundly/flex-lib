package com.enilsson.modules.business
{
	import mx.rpc.AsyncToken;
	
	public interface IDownlineDelegate
	{
		function getDownline( userId : int, nodeLevels : int ) : AsyncToken;
		function getDownlineParents( userId : int ) : AsyncToken;
	}
}