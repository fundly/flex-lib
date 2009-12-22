package com.enilsson.utils
{
	public class EDateUtil
	{
		/**
		 * dateToTimestamp functions
		 * 
		 * Converts a time into a timezone-neutral UTC format to be stored in the Database.
		 * If the local time is "4:21pm" this function will convert it to "4:21pm" in UTC time.
		 * This way, the same formatted date/time string will be seen in any client timezone
		 * after converting the UTC date back to the client's local date.
		 *
 		 * This is a workaround for Flex Date which always offsets formatted time according to client's timezone,
		 * causing the date to be incorect after using DateFormatter in some timezones
		 */

		public static function dateToTimestamp(localDate:Date):int
		{
			if(localDate == null)
				return 0;
			var utcDate:Date = new Date( Date.UTC( localDate.getFullYear(), localDate.getMonth(), localDate.getDate() ) );
			return utcDate.getTime() / 1000;
		}

		// Convert timezone-independent date from the database for DateFormatter
		public static function dateFromTimestamp(timestamp:int):Date
		{
			if(timestamp == 0)
				return null;
			var utcDate:Date = new Date(timestamp * 1000);
			return new Date( utcDate.getUTCFullYear(), utcDate.getUTCMonth(), utcDate.getUTCDate() );
		}

		public static function todayToTimestamp():int
		{
			var localDate:Date = new Date();
			var utcDate:Date = new Date( Date.UTC( localDate.getFullYear(), localDate.getMonth(), localDate.getDate() ) );
			return utcDate.getTime() / 1000;
		}
	}
}