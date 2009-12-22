package com.enilsson.controls
{
	import flash.filters.DropShadowFilter;
	
	import mx.containers.Panel;
	import mx.controls.Text;
	import mx.core.IToolTip;
	import mx.effects.Fade;
	import mx.events.FlexEvent;
	
	public class InfoTip extends Panel implements IToolTip
	{
		[Bindable] private var _fadeInFX:Fade;
		[Bindable] private var _fadeOutFX:Fade;
		[Bindable] private var _dropShadow:DropShadowFilter;
		
		private var _textField:Text;
		
		public function InfoTip()
		{
			super();
		
			this._fadeInFX = new Fade();
			this._fadeInFX.alphaFrom = 0;
			this._fadeInFX.alphaTo = 1;
			this._fadeInFX.duration = 200;
			
			this._fadeOutFX = new Fade();
			this._fadeOutFX.alphaFrom = 1;
			this._fadeOutFX.alphaTo = 0;
			this._fadeOutFX.duration = 200;
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			this.addEventListener(FlexEvent.HIDE, hideHandler);
		
			this._dropShadow = new DropShadowFilter();
			this._dropShadow.blurX = 30;
			this._dropShadow.blurY = 30;
			this._dropShadow.distance = 0;
			this._dropShadow.alpha = 0.5;
			
			this.filters = [this._dropShadow];
			
			this._textField = new Text();
			this._textField.percentWidth = 100;
			
			this.addChild(this._textField);
			
    		// set the default styles including any changes from the parent CSS
    		this.setStyle('cornerRadius', getStyle('cornerRadius') || 6);
    		this.setStyle('roundedBottomCorners', getStyle('roundedBottomCorners') || true);
    		this.setStyle('fontSize', getStyle('fontSize') || 10);
    		this.setStyle('borderColor', getStyle('borderColor') || 0x333333);
    		this.setStyle('backgroundColor', getStyle('backgroundColor') || 0xFFFF66);
    		this.setStyle('color', getStyle('color') || 0x333333);
    		this.setStyle('dropShadowEnabled', getStyle('dropShadowEnabled') || false);
    		this.setStyle('borderStyle', getStyle('borderStyle') || 'solid');
    		this.setStyle('headerHeight', getStyle('headerHeight') || 20);
    		this.setStyle('headerColors', getStyle('headerColors') || [0xE0E0E0,0x999999]);			
		}

		
		/**
		 * Change the styles and run an effect with the component is created
		 */
		private function creationCompleteHandler ( e:FlexEvent ):void
		{
			// run the default show effect
			this._fadeInFX.play();
		}
		
		private function hideHandler ( e:FlexEvent ):void
		{
			this._fadeOutFX.play();
		}
		
		[Bindable]
        public function get text():String 
        { 
            return _textField.text;
        } 
        
        public function set text(value:String):void 
        {
        	this._textField.text = value;
        }
        
        [Bindable]
        public function get htmlText():String 
        { 
            return _textField.htmlText;
        } 
        
        public function set htmlText(value:String):void 
        {
        	this._textField.htmlText = value;
        }
	}
}