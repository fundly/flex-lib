package com.enilsson.controls
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import mx.controls.ComboBox;
	import mx.events.ListEvent;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	public class ComboBoxMultiple extends ComboBox
	
	{
		private var ctrlKey:Boolean = false;
		
		public function ComboBoxMultiple()
		{
			super();
		}

		override protected function  updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
		{
			
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			var values:Array = new Array();
			if (dropdown)
			{
				
				if (dropdown.allowMultipleSelection) 
				{
					for (var index:String in this.selectedIndices)
					{
						values.push(this.selectedItems[index][this.labelField]);	
					}
					values = values.sort();
					textInput.text = values.join(',');
					this.toolTip = values.join(',');
				
					if (textInput.measureText(textInput.text).width > textInput.width)
					{
						var letters:Array = textInput.text.split('');
						var str:String = '';
						for (var i:String in letters)
						{
							str += letters[i];
							if (textInput.measureText(str).width > textInput.width)
							{
								textInput.text = str.substr(0,str.length-6) + '...';
								break;
							}
						}
					}
					
				}
				
			}
		}
		
		override public function close(trigger:Event=null) : void
		{
			if ( !ctrlKey )
				super.close( trigger );
		
		}
		
		override protected function keyDownHandler(event:KeyboardEvent) : void
		{
			super.keyDownHandler( event );
		
			ctrlKey = event.ctrlKey;
		
		
			if ( ctrlKey )
				dropdown.allowMultipleSelection = true;
		}
		
		override protected function keyUpHandler(event:KeyboardEvent) : void
		{
			super.keyUpHandler( event );
		
			ctrlKey = event.ctrlKey;
		
		
			if ( !ctrlKey )
			{
				close();
				var changeEvent:ListEvent = new ListEvent( ListEvent.CHANGE )
				
				dispatchEvent( changeEvent );
			}
		}
		
		public function set selectedItems( value:Array ) : void
		{
			if ( dropdown )
				dropdown.selectedItems = value;
		
		}
		
		[Bindable("change")]
		public function get selectedItems( ) : Array
		{
			if ( dropdown )
				return dropdown.selectedItems;
			else
				return null;
		}
		
		private var indices:Array = new Array();
		public function set selectedIndices( value:Array ) : void
		{
			if ( dropdown ) {
				dropdown.selectedIndices = value;
			} else {
				this.indices = value; // Save the value in private array
				callLater(this.setIndices); // Request function setIndices be called later
			}
		}
		
		[Bindable("change")]
		public function get selectedIndices( ) : Array
		{
			if ( dropdown )
				return dropdown.selectedIndices;
			else
				return null;
		}

		public function setIndices():void
		{
			this.selectedIndices = this.indices;
		}
	}
}