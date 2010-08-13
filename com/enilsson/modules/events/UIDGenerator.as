package com.enilsson.modules.events
{
	import mx.utils.UIDUtil;
	
	public final class UIDGenerator
	{
		public static function createId( val : String ) : String {
			return val + "_" + UIDUtil.createUID(); 	
		}
	}
}