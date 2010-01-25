package com.enilsson.controls
{
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	import mx.core.IFlexDisplayObject;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
		
	[Style(name="infoTipStyleName", type="String", inherit="no")]
	[Style(name="infoTipTitle", type="String", inherit="no")]
	[Style(name="infoTipWidth", type="Number", inherit="no")]

	[ResourceBundle("_InfoBtn")]
	public class InfoBtn extends Button
	{		
		[Embed (source="../assets/skins/assets.swf", symbol="info_btn_over")]
		private static var UP_SKIN:Class;
		
		[Embed (source="../assets/skins/assets.swf", symbol="info_btn_up")]
		private static var OVER_SKIN:Class;

		[Bindable] public var text:String;
		[Bindable] public var htmlText:String;
		
		{
			initializeClass();
		}		
		
		private static function initializeClass():void {
			if ( !StyleManager.getStyleDeclaration( "InfoBtn" ) ) {
				var componentLayoutStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
	            componentLayoutStyles.defaultFactory = function():void {
					this.infoTipTitle = ResourceManager.getInstance().getString("_InfoBtn", "title");
					if(this.infoTipTitle == null) this.infoTipTitle = "What is this?";
						
					this.infoTipWidth = 200;
					this.infoTipStyleName = 'infoTipStyleName';
	            }
	            StyleManager.setStyleDeclaration("InfoBtn", componentLayoutStyles, true);
	        }
		}
		
		public function InfoBtn()
		{
			super();
			
			// remove the default behaviours of the button in favour of new ones
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			removeEventListener(MouseEvent.CLICK, clickHandler);
			
			// add the skins to the button
			setStyle('upSkin', getStyle('upSkin') || UP_SKIN);
			setStyle('overSkin', getStyle('overSkin') || OVER_SKIN);
			setStyle('downSkin', getStyle('downSkin') || OVER_SKIN);
			
			// disable the btn from tabs
			this.tabEnabled = false;
		}
		
		public var infoTip:IFlexDisplayObject;

 		override protected function rollOverHandler(event:MouseEvent):void
		{
			super.rollOverHandler(event);
			createCustomTip(event);
		}

		override protected function rollOutHandler(event:MouseEvent):void
		{
			super.rollOutHandler(event);
			destroyCustomTip();
		}

        private function createCustomTip(event:MouseEvent):void 
        {
			// create the infoTip with the PopUpManager
			infoTip = PopUpManager.createPopUp(this,InfoTip);
			var tip : InfoTip = infoTip as InfoTip;
			
			// assign the htmlText or text, title and styleName to the infoTip
			if(htmlText) 
				tip.htmlText = htmlText;
			else 
				tip.text = text;	
						
			tip.title = getStyle('infoTipTitle');
			tip.styleName = getStyle('infoTipStyleName');
			tip.width = getStyle('infoTipWidth');

			// set the X/Y of the infoTip taking into account the right hand edge of the stage
 			var posX:Number = (event.stageX + tip.width) > stage.width ? 
 									(stage.width - tip.width - 20) : (event.stageX + this.width);
 			var posY:Number = (event.stageY + tip.height) > stage.height ? 
 									(stage.height - tip.height - 20) : (event.stageY + this.height);
 			
 			// move the infoTip into position
 			infoTip.x = posX;
 			infoTip.y = posY;
        }
        
		private function destroyCustomTip():void 
		{
			infoTip.visible = false;
			PopUpManager.removePopUp(infoTip);
			infoTip = null;
		}
	}
	
	
}