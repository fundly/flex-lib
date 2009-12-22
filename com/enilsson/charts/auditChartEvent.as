 /**
 * All computational source code, intellectual property or other works 
 * contained herein are deemed Public Domain as per the Creative 
 * Commons Public Domain license.
 * 
 * http://creativecommons.org/licenses/publicdomain/
 * 
 * Author : Rafael Cardoso
 * Date: 20/07/2008
 * Reference : http://www.enilsson.com/
 * 
 * 
 **/

package com.enilsson.charts
{
	import flash.events.Event;
	
	public class auditChartEvent extends Event 
	{
		public static const LOADED:String = "LOADED";
		public static const DATA_LOADED:String = "DATA_LOADED";
		public static const ADDED_TO_STAGE:String = "ADDED_TO_STAGE";
		
		public function auditChartEvent(type:String)
		{
			super(type,true, true); //bubble by default
		}
		
		override public function clone():Event
		{
			return new auditChartEvent(type); // bubbling support inside
		} 
	}	

}