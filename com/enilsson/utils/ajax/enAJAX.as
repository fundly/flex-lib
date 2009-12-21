package com.enilsson.utils.ajax
{	
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.managers.CursorManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.rpc.remoting.mxml.RemoteObject;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	
/**
 * Wrapper class for HTTP transport using either XML, JSON or AMF
 * Author: James Nicol, www.enilsson.com, April 2008
 */ 
	
	public class enAJAX extends EventDispatcher
	{
		public function enAJAX(req:Object = null)
		{
			if (req != null) {
				Request(req);
			}	
		}
		
		/**
		 * @private
		 * variable defining the transport method
		 */
		private var _type:String = 'amf';
		public function set type(value:String):void
		{
			_type = value;
		}
		public function get type():String
		{
			return _type;
		}

		/**
		 * @private
		 * variable defining the application name
		 */
		private var _appName:String = 'Struktor';
		public function set appName(value:String):void
		{
			_appName = value;
		}
		public function get appName():String
		{
			return _appName;
		}	
	
		/**
		 * @private
		 * variable defining the root node
		 */
		private var _rootNode:String = 'enilsson';
		public function set rootNode(value:String):void
		{
			_rootNode = value;
		}
		public function get rootNode():String
		{
			return _rootNode;
		}	
	
		/**
		 * @private
		 * remove the root node from the result
		 */	
		private var _removeRootNode:Boolean = true;	
		public function set removeRootNode(value:Boolean):void
		{
			_removeRootNode = value;
		}
		public function get removeRootNode():Boolean
		{
			return _removeRootNode;
		}	
	
		/**
		 * @private
		 * set the gateway endpoint
		 */	
		private var _gateway:String = 'gateway.php';	
		public function set gateway(value:String):void
		{
			_gateway = value;
		}
		public function get gateway():String
		{
			return _gateway;
		}
				
		/**
		 * @private
		 * set the gateway method
		 */	
		private var _source:String = 'action';	
		public function set source(value:String):void
		{
			_source = value;
		}
		public function get source():String
		{
			return _source;
		}		
		
		/**
		 * @private
		 * Set a debug flag
		 */	
		private var _debug:Boolean = false;	
		public function set debug(value:Boolean):void
		{
			_debug = value;
		}
		public function get debug():Boolean
		{
			return _debug;
		}				
		
		/**
		 * @private
		 * show the busy cursor
		 */	
		private var _showBusyCursor:Boolean = false;	
		public function set showBusyCursor(value:Boolean):void
		{
			_showBusyCursor = value;
		}
		public function get showBusyCursor():Boolean
		{
			return _showBusyCursor;
		}		
		
		/**
		 * @private
		 * Toggle whether or not to use the timeout feature
		 */	
		private var _useTimeOut:Boolean = true;	
		public function set useTimeOut(value:Boolean):void
		{
			_useTimeOut = value;
		}
		public function get useTimeOut():Boolean
		{
			return _useTimeOut;
		}		
		
		/**
		 * @private
		 * Toggle whether or not to use the authentication feature
		 */	
		private var _useAuthentication:Boolean = false;	
		public function set useAuthentication(value:Boolean):void
		{
			_useAuthentication = value;
		}
		public function get useAuthentication():Boolean
		{
			return _useAuthentication;
		}				
		
		/**
		 * @private
		 * Toggle whether or not to use the timeout feature
		 */	
		private var _redirectFn:Function;	
		public function set redirectFn(value:Function):void
		{
			_redirectFn = value;
		}
		
		/**
		 * @public
		 * Activate transport based on the variables supplied
		 */
		public function send(url:String, method:String, parameters:Array):void
		{
			var timestamp:Date = new Date();
			
			if(_showBusyCursor){
				CursorManager.setBusyCursor();
			}
			
			
			switch(_type){
				case 'amf' :
					if(_debug){
						Logger.info('AMF call', url, _source, method, ObjectUtil.toString(parameters));
					}
					
					var amfAJAX:RemoteObject = new RemoteObject('amfphp');
					amfAJAX.endpoint = url;
					amfAJAX.source = _source;
					amfAJAX[method].send.apply(null, parameters);	
					amfAJAX.addEventListener(ResultEvent.RESULT, function(e:ResultEvent):void {
						if(_debug){
							Logger.info('AMF Success', ObjectUtil.toString(e.currentTarget[method].lastResult));	
						}
						if(_showBusyCursor){
							CursorManager.removeBusyCursor();
						}
							
						if(_useTimeOut){
							if(timeOut(e.result)){ return; }
						}
						dispatchEvent(new enAJAXevent('result', e.currentTarget[method].lastResult));
					});
					amfAJAX.addEventListener(FaultEvent.FAULT, function(e:FaultEvent):void {
						if(_debug){
							Logger.info('AMF Fault', ObjectUtil.toString(e.fault));	
						}
						if(_useAuthentication){
							authenticated(e.fault);
						}
						if(_showBusyCursor){
							CursorManager.removeBusyCursor();
						}
						dispatchEvent(new enAJAXevent('fault', e.fault));
					});
				break;
				
				case 'xml' :
				default :
					var xmlAJAX:HTTPService = new HTTPService();
					xmlAJAX.url = url + method + 'data_' + timestamp.time + '.xml';
					xmlAJAX.resultFormat = "object";
					xmlAJAX.method = "post";
					xmlAJAX.send(parameters);
					xmlAJAX.addEventListener(ResultEvent.RESULT, function(e:ResultEvent):void {
						if(_debug){
							Logger.info('XML success', ObjectUtil.toString(e.result[_rootNode]));	
						}
						if(_showBusyCursor){
							CursorManager.removeBusyCursor();
						}
						if(_useTimeOut){
							if(timeOut(e.result)){ return; }
						}
						
						dispatchEvent(new enAJAXevent('result', clearItemObject(removeRootNodeFromResult(e.result))));
					});
					xmlAJAX.addEventListener(FaultEvent.FAULT, function(e:FaultEvent):void {
						if(_debug){
							Logger.info('XML fault', ObjectUtil.toString(e.fault[_rootNode]));	
						}
						if(_showBusyCursor){
							CursorManager.removeBusyCursor();
						}
						dispatchEvent(new enAJAXevent('fault', e.fault));
					});
				break;
			}
		}
		
		
		/**
		 * @private
		 * Function to remove the root node from the returned object
		 */
		private function removeRootNodeFromResult(result:Object):Object
		{
			if(_removeRootNode){
				return result[_rootNode];
			} else {
				return result;
			}
		}
		
		/**
		 * @private
		 * If data is XML it will have a root node as item, remove this and leave as object
		 */
		private function clearItemObject(result:Object):Object
		{
			if (result.item is ArrayCollection) {
				result.first = result.item[0];
				return result;
			} else {
				var first:Object = result.item;
				result.item = new ArrayCollection([first]);
				result.first = first;
				return result; 
			}
		}
		
		[Embed(source="../../assets/images/warning.png")] 
		[Bindable]
		private var _alertIcon:Class; 
		
		/**
		 * Check session is authenticated
		 **/
		 private var _authenticating:Boolean = false;
		 private function authenticated(response:Object):Boolean
		 {
		 	if(_authenticating){ return false; }
		 	_authenticating = true;
		 	
		 	if(response.faultCode){
		 		switch(response.faultCode)
		 		{
		 			case 'AMFPHP_AUTHENTICATE_ERROR' :
						Alert.show(	
							'Your ' + _appName + ' session has expired, please login to continue!',
							'Session timeout', 
							0, 
							null,
							_redirectFn,
							_alertIcon
						);
						return true;
					break;
					case 'Client.Error.MessageSend' :
						Alert.show(	
							'Your ' + _appName + ' session is not authenticated, please login to continue!',
							'Session authentication error', 
							0, 
							null,
							_redirectFn,
							_alertIcon
						);
						return true;
					break;
		 		}
		 	}
		 	return false;		 	
		 }
		
		
		/**
		 * @private
		 * Function to remove the root node from the returned object
		 */
		private var _timeout:Boolean = false;
		private function timeOut(response:Object):Boolean
		{	
			if(!_removeRootNode){ return true; }
			if(_timeout){ return true; }
			
			if(_debug){
				Logger.info('Timeout Response', ObjectUtil.toString(response));
			}
			
			for(var i:String in response) {
				if(response[i].hasOwnProperty('timeout')){
					if(response[i].timeout == 1){
						_timeout = true;
						Alert.show(	
							response[i].msg,
							response[i].type, 
							0, 
							null, 
							function():void {
								if(response[i].redirect != null){
									navigateToURL(new URLRequest(response[i].redirect), '_parent');
								}
							}
						);
						return true;
					}
				}
			}
			return false;
		}

		public function Request(args:Object):void 
		{	
			for(var field:String in args) 
			{
				switch (field) {
					case 'url' :
						var url:String = args[field];
					break;
					
					case 'method' :
						var method:String = args[field];
					break;
					
					case 'params' :
						var params:Array = args[field] == '' ? new Array() : args[field];
					break;
					
					case 'onComplete' :
						addEventListener(enAJAXevent.AJAX_RESULT, args[field]);
					break;
					
					case 'onFail' : 
						addEventListener(enAJAXevent.AJAX_FAULT, args[field]);
					break
					
					default :
						this[field] = args[field];
					break;
				}
			}

			send(url, method, params);
		}
	}
}