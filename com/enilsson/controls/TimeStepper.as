package com.enilsson.controls
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.controls.LinkButton;
	import mx.controls.NumericStepper;
	import mx.controls.TextInput;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;

	[Event(name="dataChange", type="flash.events.Event")]
	
	[Style(name="hourWidth", type="String", inherit="no")]
	[Style(name="minuteWidth", type="String", inherit="no")]
	[Style(name="periodWidth", type="String", inherit="no")]

	public class TimeStepper extends TextInput
	{
		protected var hourStepper:NumericStepper;
		protected var minuteStepper:NumericStepper;
		protected var periodButton:LinkButton;
		private var pm:Boolean = false;

		public function TimeStepper()
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
			if (!StyleManager.getStyleDeclaration("TimeStepper")) {
				var componentLayoutStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
				componentLayoutStyles.defaultFactory = function():void {
					this.hourWidth = '45%';
					this.minuteWidth = '45%';
					this.periodWidth = '10%';
				}
				StyleManager.setStyleDeclaration("TimeStepper", componentLayoutStyles, true);
			}
		}

		override protected function createChildren():void
		{
			super.createChildren();
			if( !hourStepper )
			{
				hourStepper = new NumericStepper();
				hourStepper.styleName = styleName;
				hourStepper.minimum = 0;
				hourStepper.maximum = 13;
				hourStepper.maxChars = 2;
				hourStepper.addEventListener(FocusEvent.FOCUS_OUT, function(event:FocusEvent):void{
					if(event.relatedObject == minuteStepper || event.relatedObject == periodButton)
						event.stopImmediatePropagation();
				});
				hourStepper.addEventListener(Event.CHANGE, hourChangeHandler);
				hourStepper.addEventListener(Event.CHANGE, changeHandler);

				addChild( hourStepper );
			}

			if( !minuteStepper )
			{
				minuteStepper = new NumericStepper();
				minuteStepper.styleName = styleName;
				minuteStepper.minimum = -1;
				minuteStepper.stepSize = 5;
				minuteStepper.maximum = 60;
				minuteStepper.maxChars = 2;
				minuteStepper.addEventListener(FocusEvent.FOCUS_OUT, function(event:FocusEvent):void{
					if(event.relatedObject == hourStepper || event.relatedObject == periodButton)
						event.stopImmediatePropagation();
				});
				minuteStepper.addEventListener(Event.CHANGE, minuteChangeHandler);
				minuteStepper.addEventListener(Event.CHANGE, changeHandler);
				minuteStepper.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
					formatMinuteStepper();
					minuteStepper.addEventListener(FlexEvent.VALUE_COMMIT, formatMinuteStepper);
				});

				addChild( minuteStepper );
			}

			if( !periodButton )
			{
				periodButton = new LinkButton();
				periodButton.styleName = styleName;
				periodButton.addEventListener(FocusEvent.FOCUS_OUT, function(event:FocusEvent):void{
					if(event.relatedObject == hourStepper || event.relatedObject == minuteStepper)
						event.stopImmediatePropagation();
				});
				periodButton.addEventListener(MouseEvent.CLICK, togglePeriod);
				periodButton.addEventListener(MouseEvent.CLICK, changeHandler);
				periodButton.label = "AM";

				addChild( periodButton );
			}
		}

		override protected function commitProperties():void
		{
			super.commitProperties();
			if(_time.getUTCHours() > 11)
			{
				pm = true;
				periodButton.label = 'PM';
				if(_time.getUTCHours() == 12)
					hourStepper.value = 12;
				else
					hourStepper.value = _time.getUTCHours() - 12;
			}
			else
			{
				pm = false;
				periodButton.label = 'AM';

				if(_time.getUTCHours() == 0)
					hourStepper.value = 12;
				else
					hourStepper.value = _time.getUTCHours();
			}
			minuteStepper.value = _time.getUTCMinutes();

			timestamp = _time.getTime() / 1000;
			_prevHourValue = hour;
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			if( hourStepper )
			{
				hourStepper.setActualSize( 50, unscaledHeight );
				hourStepper.move( 0, 0 );
			}
			
			if( minuteStepper )
			{
				minuteStepper.setActualSize( 50, unscaledHeight );
				minuteStepper.move( hourStepper.width + 5, 0 );
				minuteStepper.stepSize = _minuteStepping;
			}

			if( periodButton )
			{
				periodButton.setActualSize( 40, unscaledHeight );
				periodButton.move( minuteStepper.x + minuteStepper.width, 0 );
			}
		}

		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			invalidateDisplayList();
		}

		private function changeHandler ( event:Event ):void
		{
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
			hourStepper.errorString = value;
			minuteStepper.errorString = value;
			periodButton.errorString = value;
		}

		/**
		 * Set and get the month from the component
		 */
		[Bindable]
		public function get hour ():int
		{
			return time.getUTCHours();
		}
		public function set hour ( value:int ):void
		{
			var newTime:Date = baseTime;
			newTime.setUTCHours(value, time.getUTCMinutes(),0,0);
			time = newTime;
		}
		private var _prevHourValue:int;

		/**
		 * Set and get the year from the component
		 */
		public function get minute ():int
		{
			return time.getUTCMinutes();
		}
		public function set minute ( value:int ):void
		{
			var newTime:Date = baseTime;
			newTime.setUTCHours(time.getUTCHours(),value,0,0);
			time = newTime;
		}

		/**
		 * Set and get the time from the component
		 */		
		[Bindable]
		public function get timestamp ():int
		{
			return _timestamp;
		}
		private var _timestamp:int;
		public function set timestamp ( value:int ):void
		{
			if(_timestamp != value && value >= 0)
			{
				_timestamp = value;
				time = new Date(value * 1000);
			}
		}

		[Bindable]
		public function get time():Date
		{
			return _time;
		}
		public function set time ( value:Date ):void
		{
			_time = value
			timestamp = _time.getTime() / 1000;

			invalidateProperties();
		}
		private var _time:Date = baseTime;

		public function get minuteStepping ():int
		{
			return _minuteStepping;
		}
		private var _minuteStepping:int = 5;
		public function set minuteStepping ( value:int ):void
		{
			_minuteStepping = value;
			invalidateDisplayList();
		}

		private function hourChangeHandler(event:Event):void
		{
			switch(hourStepper.value)
			{
				case 0:
					if(pm)
						hour = 12;
					else
						hour = 0;
					break;
				case 13:
					if(pm)
						hour = 13;
					else
						hour = 1;
					break;
				case 11:
					// AM/PM Check needed for stepper button presses
					if(_prevHourValue == 12 || _prevHourValue == 10)	// 12 pm - 1 or 10 am + 1
						hour = 11;										// = 11am
					else if(_prevHourValue == 0 || _prevHourValue == 22)// 12 am - 1 or 10 pm + 1
						hour = 23;										// = 11 pm
					else
					{
					//For manual input number
						if(pm)
							hour = 11;
						else
							hour = 23;
					}
					break;
				case 12:
					if(_prevHourValue == 23 || _prevHourValue == 1)		// 11 pm + 1 or 1 am -1
						hour = 0;										// = 12 am
					else if(_prevHourValue == 11|| _prevHourValue == 13)// 11 am + 1 or 1 pm - 1
						hour = 12;										// = 12 pm
					else
					{
						if(pm)
							hour = 12;
						else
							hour = 0;
					}
					break;
				default:
					if(pm)
					{
						hour = hourStepper.value + 12;
					}
					else
						hour = hourStepper.value;
					break;
			}
		}

		private function minuteChangeHandler(event:Event):void
		{
			switch(minuteStepper.value)
			{
				case -1:
					minuteStepper.value = 60 - minuteStepping;
					break;
				case 60:
					minuteStepper.value = 0;
					break;
			}
			minute = minuteStepper.value;
		}

		private function togglePeriod(event:Event = null):void
		{
			if(pm)
			{
				hour = hour - 12;
			}
			else
			{
				hour = hour + 12;
			}
		}

		private function formatMinuteStepper(event:FlexEvent = null):void {
			var minuteMask:String = "00";
			var value:String = minuteStepper.value.toString();
			value = (minuteMask + value).substr(-minuteMask.length);
			if(minuteStepper)
				minuteStepper.mx_internal::inputField.text = value;
		}

		private function get baseTime():Date
		{
			var baseTime:Date = new Date();
			baseTime.setTime(0);
			return baseTime;
		}
	}
}