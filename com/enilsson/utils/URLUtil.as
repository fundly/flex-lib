package com.enilsson.utils
{
	/**
	 * URLUtil provides a couple of convenient URL parsing methods.
	 **/
	public class URLUtil
	{
		public static const REMOTE_PATTERN	: RegExp = /^(http|https):[\/]{2}[^\/]*/g;
		public static const LOCAL_PATTERN	: RegExp = /^file:[\/]{3}.*/g;
		
		
		/**
		 * Returns the document root of a given URL.
		 * @param url The url for whose document root should be returned.
		 * @return The URL of the document root or null if URL is invalid.
		 */
		public static function getRoot( url : String ) : String {
			var localMatch 	: String = getMatch( url, LOCAL_PATTERN );
			var remoteMatch	: String = getMatch( url, REMOTE_PATTERN );
			
			if( localMatch ) { 
				return localMatch + "/";
			}	
			else if ( remoteMatch ) {
				return remoteMatch + "/";
			}
				
			return null;
		}
		
		/**
		 * Returns the URL free of any Flex specific strings attached to it.
		 * 
		 * @param url The url.
		 * @return The cleaned URL or null if URL is invalid.
		 **/
		public static function getCleanUrl( url : String ) : String {
			
			if(! url) return null;
			
			var cleanUrl : String; 
			
			if( isUrlLocal(url) || isUrlRemote(url) ) {
				cleanUrl = url.replace( /\/\[\[DYNAMIC\]\].*/, "");
				return cleanUrl;
			}
			
			return null;
		}
		
		/**
		 * Returns the URL path without the actual document that was called.
		 * 
		 * @param url
		 * @return The URL path without the document name.
		 **/
		public static function getUrlPath( url : String ) : String {
			var url : String = getCleanUrl( url );
			if( ! url ) return null;
			
			// remove a filename at the end of the url if there is one
			return url.replace(/\/[\w\d]*\.\w{1,4}[^\/]*$/, "/");
		}
		
		/**
		 * Find out if a url is local.
		 * 
		 * @param url The URL to check.
		 * @return A Boolean value indicating if the URL is local.
		 **/
		public static function isUrlLocal( url : String ) : Boolean {
			return getMatch( url, LOCAL_PATTERN ) != null;
		}
		
		/**
		 * Find out if a url is remote.
		 * 
		 * @param url The URL to check.
		 * @return A Boolean value indicating if the URL is remote.
		 **/
		public static function isUrlRemote( url : String ) : Boolean {
			return getMatch( url, REMOTE_PATTERN ) != null;
		}
		
		private static function getMatch( url : String, pattern : RegExp ) : String 
		{
			if( ! url ) return null;
			var matches	: Array = url.match( pattern );
			return ( matches && matches.length > 0 ) ? matches[0] : null;
		}
	}
}