package com.enilsson.utils
{
	import flash.system.Security;
	
	public class DomainWhitelistChecker
	{
		/**
		 * Constructor
		 * 
		 * The constructor expects an Array of whitelisted domain names, e.g. ["domain.com", "anotherdomain.com"].
		 * 
		 * @param whitelist An array of allowed domain names.
		 **/
		public function DomainWhitelistChecker( whitelist : Array ) {
			if(whitelist)
				this.whitelist = whitelist;
			else
				this.whitelist = [];
		}
			
		
		/**
		 * Find out if a url is on the whitelist and therefore allowed.
		 * 
		 * @param url The URL to check.
		 * @return A Boolean value indicating if the URL is allowed.
		 **/
		public function isUrlAllowed( url : String ) : Boolean {
			
			if( !url ) return false;
			
			if( URLUtil.isUrlLocal( url ) && Security.sandboxType == Security.LOCAL_TRUSTED ) {
				return true;
			} 			
			else if( URLUtil.isUrlRemote( url ) && Security.sandboxType == Security.REMOTE ) 
			{
				var docroot : String = URLUtil.getRoot( url );				
				
				if( ! docroot ) return false; 
				
				for each( var d : String in whitelist ) {
					var match : Array = docroot.match( new RegExp( d + "\/$","g" ) );				
					if( match && match.length > 0) {
						return true; 
					}
				}
			}
			
			return false;
		}
		
		// array containing the whitelist of domain names
		private var whitelist : Array;
	}
}