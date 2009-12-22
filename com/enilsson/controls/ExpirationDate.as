package com.enilsson.controls
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.controls.ComboBox;
	import mx.controls.TextInput;
	import mx.core.UITextField;
	import mx.formatters.DateFormatter;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	[Event(name="dataChange", type="flash.events.Event")]
	
	[Style(name="monthWidth", type="String", inherit="no")]
	[Style(name="yearWidth", type="String", inherit="no")]

	public class ExpirationDate extends TextInput
	{
		private var expMonth:ComboBox;
		private var expYear:ComboBox;
		private var sep:UITextField;
		
		private var df:DateFormatter = new DateFormatter();
		
		public function ExpirationDate()
		{
			super();
			
			setStyle('borderStyle', 'none');
			setStyle('backgroundAlpha', 0);
			setStyle('focusAlpha', 0);
			
			setStyles();
			
			focusEnabled = false;
			editable = false;
		}
		
		private function setStyles():void
		{
			if (!StyleManager.getStyleDeclaration("ExpirationDate")) {
	            var componentLayoutStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
	            componentLayoutStyles.defaultFactory = function():void {
					this.monthWidth = '50%';
					this.yearWidth = '50%';
	            }
	            StyleManager.setStyleDeclaration("ExpirationDate", componentLayoutStyles, true);
	        }
		}				
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if( !expMonth )
			{
				expMonth = new ComboBox();
				expMonth.styleName = styleName;
				expMonth.dataProvider = months;
				expMonth.prompt = 'Month';
				expMonth.selectedIndex = -1;
				expMonth.addEventListener(FocusEvent.FOCUS_OUT, function(event:FocusEvent):void{
					if(event.relatedObject == expYear)
						event.stopImmediatePropagation();
				});
				addChild( expMonth );
				
				expMonth.addEventListener(Event.CHANGE, changeHandler);
			}

			if( !expYear )
			{
				expYear = new ComboBox();
				expYear.styleName = styleName;
				expYear.dataProvider = years;
				expYear.prompt = 'Year';
				expYear.selectedIndex = -1;
				expYear.addEventListener(FocusEvent.FOCUS_OUT, function(event:FocusEvent):void{
					if(event.relatedObject == expMonth)
						event.stopImmediatePropagation();
				});
				addChild( expYear );
				
				expYear.addEventListener(Event.CHANGE, changeHandler);
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if( expMonth )
			{
				if ( getStyle('monthWidth') == '50%' )
					expMonth.setActualSize( unscaledWidth/2 - 1, unscaledHeight );
				else
					expMonth.setActualSize( getStyle('monthWidth'), unscaledHeight );
				
				expMonth.move( 0, 0 );
			}
			
			if( expYear )
			{				
				if ( getStyle('yearWidth') == '50%' )
				{
					expYear.setActualSize( unscaledWidth/2 - 1, unscaledHeight );
					expYear.move(  unscaledWidth/2 + 1, 0 );
				}
				else
				{
					expYear.setActualSize( getStyle('yearWidth'), unscaledHeight );				
					expYear.move(  width - expYear.width, 0 );
				}
			}
		}
		
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			invalidateDisplayList();
		}
		
		
		private function changeHandler ( event:Event ):void
		{
			if(expYear.selectedIndex > -1 && expMonth.selectedIndex > -1)
				dispatchEvent( new Event ( 'dataChange' ) );
		}

		/**
		 * When there is an error on the component tell the month and year combos
		 */
		override public function get errorString():String
		{
			return super.errorString
		}
		override public function set errorString(value:String):void
		{
			super.errorString = value;
			expMonth.errorString = value;
			expYear.errorString = value;
		}

		/**
		 * Set and get the month from the component
		 */
		public function set month ( value:String ):void
		{
			var val:int = int(value);
			if ( val > 0 && val <= 12)
				expMonth.selectedIndex = val - 1;
		}
		public function get month ():String
		{
			return expMonth.selectedItem.value;
		}
		
		/**
		 * Set and get the year from the component
		 */
		public function set year ( value:int ):void
		{
			var startYear:int = years[0].value;
			var endYear:int = years[yearsAhead-1].value;
			
			if ( value > (startYear -1) && value < (endYear + 1) )
				expYear.selectedIndex = value - startYear - 1; 
		}
		public function get year ():int
		{
			return expYear.selectedItem.value;
		}	

		/**
		 * Set and get the date from the component
		 */		
		public function set date ( value:String ):void
		{
			var dateArray:Array = value.split('/');
			month = dateArray[0];
			year = dateArray[1];
		}
		public function get date ():String
		{
			if ( expMonth.selectedIndex < 0 || expYear.selectedIndex < 0 )
				return '';
			else
				return expMonth.selectedItem.value + '/' + expYear.selectedItem.value;
		}	
			
		
		private var _monthFormat:String = 'MMM';
		public function set monthFormat ( value:String ):void
		{
			_monthFormat = value;
		}
		public function get monthFormat ():String
		{
			return _monthFormat;
		}
		
		/**
		 * Create an array of months to display in the combo
		 */
		public function get months():Array
		{
			var m:Array = new Array();
			
			var d:Date = new Date();
			df.formatString = monthFormat
			
			for ( var i:int = 0; i < 12; i++)
			{
				d.setMonth(i,1);
				
				var monthObj:Object = new Object();
				monthObj['value'] = leadingZero(i + 1, 2); // set value as literal month with leading zero 01=Jan 12=Dec
				monthObj['label'] = monthObj['value'] + _separator + df.format(d); // set label as "Jan - 01"
				
				m.push(monthObj);
			}
			
			return m;  //returns in format "04/2009"
		}

		/**
		 * Adds a leading zero to 1 digit numbers and returns it as a string
		 */
		private function leadingZero(number: int, digits: int) : String{
			var zeros:String = '';
			var length:int = String(number).length;
			if (digits - length > 0)
				for (var i: int = 0; i < digits - length; i++){
					zeros += '0';
			}
			
			return zeros+number;
		}


		/**
		 * Set the number of years in advance the year combo should show
		 */
		private var _yearsAhead:Number = 10;
		public function set yearsAhead ( value:Number ):void
		{
			_yearsAhead = value;
			if(expYear)
				expYear.dataProvider = years;
		}
		public function get yearsAhead ():Number
		{
			return _yearsAhead;
		}
		
		/**
		 * Create an array of years starting from this year till the set years in advance
		 */
		public function get years ():Array
		{
			var y:Array = new Array();
			
			var d:Date = new Date();
			var currYear:Number = d.getFullYear();
			
			for ( var i:Number = currYear; i < (currYear + yearsAhead); i++)
			{
				var yearObj:Object = new Object();
				yearObj['value'] = i;
				yearObj['label'] = i.toString();
				
				y.push(yearObj);
			}
			
			return y;
		}
		
		/**
		 * List the seperator between month value and string
		 */
		private var _separator:String = ' - ';
		public function set separator ( value:String ):void
		{
			_separator = value;
			
			if(expMonth)
				expMonth.dataProvider = months;
			
			invalidateDisplayList();
		}
		public function get separator ():String
		{
			return _separator;
		}
		
	}
}