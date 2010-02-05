package com.enilsson.utils
{
	public class EDateUtil
	{
		public static const TIMESTAMP_FACTOR : int = 1000;
		
		
		public static function timestampToLocalDate( timestamp : int ) :Date {
			var localDate : Date = new Date( timestamp * TIMESTAMP_FACTOR );
			return localDate;
		}
		
		public static function localDateToTimestamp( localDate : Date ) : int {
			if( ! localDate ) return 0;
											
			var timestamp : Number = localDate.getTime() / TIMESTAMP_FACTOR;
			return timestamp;
		}
		
		public static function nowToTimestamp():int {
			return localDateToTimestamp( new Date() );
		}

		public static function todayToTimestamp():int {
			return localDateToTimestamp( today() );			
		}
		
		public static function today() : Date {
			var localDate:Date = new Date();
			localDate.setHours(0,0,0,0);
			
			return localDate;
		}
		
		public static function setEndOfDay( localDate : Date ) : void {
			if( ! localDate ) return;
			localDate.setHours( 23,59,59,0 );
		}
	}
}