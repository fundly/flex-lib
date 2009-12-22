package com.enilsson.controls
{
	import flash.events.FocusEvent;
	import flash.events.TextEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	
	import mx.controls.TextInput;
	
	import org.osflash.thunderbolt.Logger;

	public class clearTextInput extends TextInput
	{
		private var _textColor:uint;
		private var _init:Boolean = true;
		private var _textChanged:Boolean = false;
		
		public function clearTextInput()
		{
			super();
			
			// hide the background and the focus skin in the default state
			setStyle('borderStyle', 'none');
			setStyle('backgroundAlpha', 0);
			setStyle('focusAlpha', 0);
			
			// add event listeners for the focus and text changing			
			addEventListener(FocusEvent.FOCUS_IN, clearTextInputFocusInHandler);
			addEventListener(FocusEvent.FOCUS_OUT, clearTextInputFocusOutHandler);
			addEventListener(TextEvent.TEXT_INPUT, clearTextInputChangedHandler);
		}

		override protected function commitProperties():void
		{
			// only set the field to empty on the first pass
			if(_init){
				_textColor = getStyle('color');
				if(this.text == ''){
					this.text = _defaultText;
					Logger.info('Text', this.text);
					setStyle('color', 0x999999);
					_textChanged = false;
				} else {
					_textChanged = true;
				}
				_init = false;
			}

		    super.commitProperties();
		}
		
		/**
		 * Handler for the on focus event
		 * will blank out any empty data, show the background box and set the colours correctly
		 */
		private function clearTextInputFocusInHandler(e:FocusEvent):void
		{
			this.text = _textChanged ? this.text : '';
			
			// shows the box and sets the text colour
			setStyle('color', _textColor);
			setStyle('borderStyle', 'none');
			setStyle('backgroundAlpha', 1);
			// adds dropshadow to the input so it looks like it jumps out of the page
			this.filters = [dropshadowFilter()];
		}

		/**
		 * Handler for the focus out event
		 * Removes the background box and resets the default value if blank
		 */
		private function clearTextInputFocusOutHandler(e:FocusEvent):void
		{
			if(this.text == ''){
				this.text = _defaultText;
				_textChanged = false;
				setStyle('color', 0x999999);
			}
			
			// hides the box
			setStyle('borderStyle', 'none');
			setStyle('backgroundAlpha', 0);
			// removes the dropshadow
			this.filters = [];
		}
		
		/**
		 * Handler to register that the text has changed
		 */
		private function clearTextInputChangedHandler(e:TextEvent):void
		{
			_textChanged = true;
		}
		
		/**
		 * @ private
		 * Variable to define what is put into the input if there is no value set
		 */
		private var _defaultText:String = 'None';
		public function set defaultText(value:String):void
		{
			_defaultText = value;
		}
		
		
		/**
		 * Dropshadow filter to be used if needed
		 */		
		private function dropshadowFilter():DropShadowFilter 
		{		    
		    var distance:Number 	= 2;
		    var angle:Number 		= 90;
		    var color:Number 		= 0x000000;
		    var alpha:Number 		= 1;
		    var blurX:Number 		= 6;
		    var blurY:Number 		= 6;
		    var strength:Number 	= 0.75;
		    var quality:Number 		= BitmapFilterQuality.LOW;
		    var inner:Boolean 		= false;
		    var knockout:Boolean 	= false;
		
		    return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout);
		}		
		
	}
}