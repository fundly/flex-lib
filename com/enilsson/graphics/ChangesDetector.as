package com.enilsson.graphics
{
	import mx.controls.Alert;
	
	public class ChangesDetector extends Alert
	{
		[Embed(source="../assets/images/warning.png")]
		private static var iconError:Class;
		
		[Embed(source="../assets/images/warning.png")]
		private static var iconInfo:Class;
		
		[Embed(source="../assets/images/warning.png")]
		private static var iconConfirm:Class;
		
		public function ChangesDetector()
		{
			super();
			
			this.verticalScrollPolicy = 'off';
			this.horizontalScrollPolicy = 'off';
		}


		public static function info(message:String, closehandler:Function=null, heading:String = 'Information'):void
		{
			show(message, heading, Alert.OK, null, closehandler, iconInfo);
		}
		
		public static function error(message:String, closehandler:Function=null, heading:String = 'Error'):void
		{
			show(message, heading, Alert.OK, null, closehandler, iconError);
		}
		
		public static function confirm(message:String, closehandler:Function=null, heading:String = 'Confirmation'):void
		{
			show(message, heading, Alert.YES | Alert.NO, null, closehandler, iconConfirm,Alert.NO);
		}
	
		
	}
	
}