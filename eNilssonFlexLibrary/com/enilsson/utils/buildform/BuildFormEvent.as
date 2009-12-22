////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2007 Enilsson and its licensors.
// All Rights Reserved.
// Author: Rafael Cardoso (rafael.cardoso@enilsson.com)
//
//
//	BuildFormEvent is an event listener for Buildform
//	
//
//	The following events are acceptable:
//	
//
//	LOADED - checks if the XML form has been loaded
//	POST_RESPONSE - return whenever gets a reponse from submitting the form
/////////////////////


package com.enilsson.utils.buildform
{
	import flash.events.Event;
	
	public class BuildFormEvent extends Event 
	{
		public static const LOADED:String = "LOADED";
		public static const POST_RESPONSE:String = "POST_RESPONSE";
		public static const DELETE_SUCCESS:String = "DELETE_SUCCESS";
		public static const DELETE_FAILED:String = "DELETE_FAILED";
		public static const UPSERT_SUCCESS:String = "UPSERT_SUCCESS";
		public static const UPSERT_FAILED:String = "UPSERT_FAILED";
		public static const ADDED_TO_STAGE:String = "ADDED_TO_STAGE";
		public static const DATA_CHANGE:String = "DATA_CHANGE";
		public static const RECORD_LOADED:String = "RECORD_LOADED";
		public static const INVALID_FORM:String = "INVALID_FORM";
		public static const VALID_FORM:String = "VALID_FORM";
		public static const LAYOUT_LOADED:String = "VALID_FORM";

		public var data:*;
		public var formContainer:*;
				
		public function BuildFormEvent(type:String, data:* = null)
		{
			super(type,true, true); //bubble by default
			switch(type){
				case 'ADDED_TO_STAGE' :
					this.formContainer = data;
				break
				default :
					this.data = data;	
				break
			}
		}
		
		override public function clone():Event
		{
			return new BuildFormEvent(type,data); // bubbling support inside
		} 
	}	

}