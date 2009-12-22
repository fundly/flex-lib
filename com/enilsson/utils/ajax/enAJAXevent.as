package com.enilsson.utils.ajax
{
	import flash.events.Event;
	
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;

	public class enAJAXevent extends Event
	{
		public static const AJAX_RESULT:String = "result";
		public static const AJAX_FAULT:String = "fault";
		
		public var data:*;
		public var fault:*;

		public function enAJAXevent(type:String, data:Object, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
			switch(type){
				case AJAX_RESULT :
					this.data = data;
				break;
				case AJAX_FAULT :
					this.fault = data;
				break;
			}
		}
		
	}
}