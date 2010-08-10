package com.enilsson.modules.downline.pm
{
	import com.adobe.serialization.json.JSON;
	import com.enilsson.events.GetEvent;
	import com.enilsson.modules.events.DownlineEvent;
	import com.enilsson.vo.ErrorVO;
	
	import flash.events.IEventDispatcher;
	
	import org.un.cava.birdeye.ravis.graphLayout.data.Graph;
	
	
	/**
	 * A collection of data for the My Downline module
	 */	
	[Bindable]	
	public class MyDownlinePM
	{
		public var gettingDownline:Boolean;
		public var gettingParents:Boolean;
		
		public var graphShow:Boolean;
		public var downlineXML:XML;
		public var graph:Graph;
		public var isEmpty:Boolean;
		
		public var parentGraphShow:Boolean;
		public var parentXML:XML;
		public var parentGraph:Graph;
		public var isParentsEmpty:Boolean;
		
		public var errorVO : ErrorVO;
		
		public function MyDownlinePM( dispatcher : IEventDispatcher ) {
			_dispatcher = dispatcher;
		}
		
		public function get downline() : Object { return _downline; }
		public function set downline( val : Object ) : void {
			
			var xml : XML;
			
			_downline = decodeResponse( val );
			
			try{
				xml = new XML(_downline);
			}
			catch( e : Error ) {
				_downline = null;
			}
			
			if(_downline != null ) 
			{				
				for ( var i:String in xml.Edge )
				{
					var edge:XML = xml.Edge[i];
					
					if ( edge.@fromID == userId )
					{
						delete xml.Edge[i];
						break;
					}
				}
				
				downlineXML = xml;
				graph = new Graph( "XMLAsDocsGraph", false, downlineXML	);
				graphShow = true; 
				
				isEmpty = _downline.toString().length == 0; 
			}
			else 
			{
				isEmpty = true;
				downlineXML = null;
				graph = null;
				graphShow = false;
				parents = null;
			}

			gettingDownline = false;
		}
		private var _downline : Object;	
		
		public function get parents() : Object { return _parents; }
		public function set parents( val : Object ) : void {
			var xml : XML;
			
			_parents = decodeResponse( val );
			
			try{
				xml = new XML(_parents);
			}
			catch( e : Error ) {
				_parents = null;
			}
			
			if(_parents != null )
			{
				parentXML = new XML(_parents);
				parentGraph = new Graph("XMLAsDocsGraph", false, parentXML);
				parentGraphShow = true;
			
				isParentsEmpty = _parents.toString().length == 0; 
			}
			else
			{
				isParentsEmpty = true;
				parentXML = null;
				parentGraphShow = false;
				parentGraph = null;
			}
			
			gettingParents = false;
		}
		private var _parents : Object;
				
		public function set userId( val : int ) : void {
			_userId = val;
			getDownline();
		}
		public function get userId() : int { return _userId; }
		private var _userId : int;
		
		
		public function set nodeLevels( val : int ) : void {
			_nodeLevels = val;
			getDownline();
		}
		public function get nodeLevels() : int { return _nodeLevels; }
		private var _nodeLevels : int = 8;
		
		
		public function getDownline() : void {
			
			if( userId == 0 ) {
				downline = null;
				return;
			}
			
			if( _dispatcher && gettingDownline == false ) 
			{
				gettingDownline = true;
				
			 	var e : GetEvent = new GetEvent( DownlineEvent.GET_DOWNLINE, this, 'downline', [ userId, nodeLevels ] );
				_dispatcher.dispatchEvent(e);
			} 
		}
		
		public function getParents() : void {
			
			if( userId == 0 ) {
				parents = null;
				return;
			}
			
			if( _dispatcher && gettingParents == false ) 
			{
				gettingParents = true;
					
				var e : GetEvent = new GetEvent( DownlineEvent.GET_DOWNLINE_PARENTS, this, 'parents', [ userId ] );
				_dispatcher.dispatchEvent(e);
			}
		}
		
		public function update() : void {
			getDownline();
		}
		
		private function decodeResponse( val : Object ) : String {
			
			var result : String;
			
			try {
				var raw		: String = val as String;
				// replace double quotes in graph attributes with single quotes
				var raw2 	: String = raw.replace( new RegExp('=\"([^\"]*)\"', 'g'), "=\'$1\'" );
				var o 		: Object = JSON.decode( raw2, false );
				
				result = o.response;
			}
			catch( e : Error ) {
				result = val as String;
			}
			
			return result;
		}
		
		private var _dispatcher : IEventDispatcher;	

	}
}