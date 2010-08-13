package com.enilsson.utils
{
	import flash.utils.Dictionary;
	
	public class DictionaryUtil
	{		
		public function DictionaryUtil( weakKeys : Boolean = false ) {
			_dict = new Dictionary( weakKeys );		
		}
		
		public function getItem( key : Object ) : * {
			if(!key) return null;
			return _dict[key];
		}
		
		public function add( key : Object, val : * ) : void {
			if(!key) return;
			_dict[key] = val;
		}
		
		public function remove( key : Object ) : * {
			if(!key) return null;
			
			var item : * = getItem( key );
			delete _dict[key];
			return item;
		}
		
		private var _dict : Dictionary;	
	}
}