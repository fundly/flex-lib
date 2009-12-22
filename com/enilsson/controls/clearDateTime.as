package com.enilsson.controls
{
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.text.TextLineMetrics;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Text;
	import mx.controls.TextInput;
	
	import org.osflash.thunderbolt.Logger;
		
	public class clearDateTime extends TextInput
	{
		private var _now:Date;
		private var timezones:Object;
		private var tzArrayCol:ArrayCollection = new ArrayCollection();
		private var _yearPrevKey:String = '';
		
		
		private var _keyPressTimer:Timer;
		private var _currKeyBoardEvent:Object = new Object();
		
		private var _hours:TextInput;
		private var _mins:TextInput;
		private var _ampm:TextInput;
		private var _days:TextInput;
		private var _month:TextInput;
		private var _year:TextInput;						
		private var _tz:clearDropDown;
		
		private var _colon:Text;	
		private var _bkslash1:Text;
		private var _bkslash2:Text;					
		
		public function clearDateTime()
		{
			super();
			
			_now = new Date();
			timezoneList();
			
			// hide the background and the focus skin in the default state
			setStyle('borderStyle', 'none');
			setStyle('backgroundAlpha', 0);
			setStyle('focusAlpha', 0);
			
			this.focusEnabled = false;
			this.editable = false;
			
			// add event listeners for the focus and text changing			
			addEventListener(FocusEvent.FOCUS_IN, clearDateTimeFocusInHandler);
			addEventListener(FocusEvent.FOCUS_OUT, clearDateTimeFocusOutHandler);
		}
		
		/**
		 * @Public: Set the date time
		 */
		public function set dateTime(value:Date):void
		{
			_now = value;
			
			invalidateDisplayList();
		}

		/**
		 * @Public: Get the datetime
		 */
		public function get dateTime():Date
		{
			return _now;			
		}

		/**
		 * @Public: Set the date time via a unix timestamp
		 */
		public function set dateAsTimestamp(value:Number):void
		{
			_now = new Date(value*1000);
			
			invalidateDisplayList();
		}

		/**
		 * @Public: Get the datetime as a unix timestamp
		 */
		public function get dateAsTimestamp():Number
		{
			return _now.valueOf()/1000;			
		}
		
		/**
		 * @Public: Get the datetime as a unix timestamp normalised to UTC
		 */
		public function get dateAsUTCTimestamp():Number
		{
			return _now.valueOf()/1000 - timeZone * 60 * 60;			
		}		
		
		/**
		 * @Public: Set the timezone
		 */
		public function set timeZone(value:Number):void
		{
			for(var i:String in tzArrayCol){
				if(value == tzArrayCol[i].value){
					_tz.selectedIndex = parseInt(i);
				}
			}
		}
		
		/**
		 * @Public: Get the timezone
		 */
		public function get timeZone():Number
		{
			return _tz.selectedItem.value;			
		}

		override protected function createChildren():void
		{			
			super.createChildren();
			
			_hours = new TextInput();
			_hours.id = 'hours';
			_hours.maxChars = 2;
			_hours.restrict = '0-9';
			_hours.addEventListener(KeyboardEvent.KEY_UP, timeKeyPressHandler);
			_hours.addEventListener(FocusEvent.FOCUS_IN, inputFocusHandler);
			addChild(_hours);

			_mins = new TextInput();
			_mins.id = 'mins';
			_mins.maxChars = 2;
			_mins.restrict = '0-9';
			_mins.addEventListener(KeyboardEvent.KEY_UP, timeKeyPressHandler);
			_mins.addEventListener(FocusEvent.FOCUS_IN, inputFocusHandler);						
			addChild(_mins);
			
			_ampm = new TextInput();
			_ampm.id = 'mins';
			_ampm.maxChars = 2;
			_ampm.restrict = 'A-P^BCDEFGHIJKLNO';
			_ampm.addEventListener(KeyboardEvent.KEY_UP, ampmKeyPressHandler);
			_ampm.addEventListener(FocusEvent.FOCUS_IN, inputFocusHandler);						
			addChild(_ampm);
			
			_colon = new Text();
			_colon.text = ':';
			addChild(_colon);

			_month = new TextInput();
			_month.id = 'month';
			_month.maxChars = 2;
			_month.restrict = '0-9';
			_month.addEventListener(KeyboardEvent.KEY_UP, timeKeyPressHandler);
			_month.addEventListener(FocusEvent.FOCUS_IN, inputFocusHandler);						
			addChild(_month);			
			
			_days = new TextInput();
			_days.id = 'days';
			_days.maxChars = 2;
			_days.restrict = '0-9';
			_days.addEventListener(KeyboardEvent.KEY_UP, timeKeyPressHandler);
			_days.addEventListener(FocusEvent.FOCUS_IN, inputFocusHandler);						
			addChild(_days);
			
			_year = new TextInput();
			_year.id = 'year';
			_year.maxChars = 4;
			_year.restrict = '0-9';
			_year.addEventListener(KeyboardEvent.KEY_UP, timeKeyPressHandler);
			_year.addEventListener(FocusEvent.FOCUS_IN, inputFocusHandler);	
			_year.addEventListener(FocusEvent.FOCUS_OUT, function():void { _yearPrevKey = ''; });					
			addChild(_year);	
			
			_bkslash1 = new Text();
			_bkslash1.text = '/';
			addChild(_bkslash1);		
			
			_bkslash2 = new Text();
			_bkslash2.text = '/';
			addChild(_bkslash2);	
			
			_tz = new clearDropDown();
			_tz.dataProvider = tzArrayCol;
			_tz.id = 'tz';
			_tz.selectedIndex = 7;
			_tz.showDropDown = false;
			_tz.setStyle('fontWeight', getStyle('fontWeight'));
			addChild(_tz);
		}
		
		private function updateDateTimeByIncrement(increment:Number=0, element:String=null):void
		{
			if(increment != 0){
				switch (element) {
					case 'hours' :
						_now.setUTCHours(_now.getUTCHours() + increment);
						//_now = new Date(_now.getUTCFullYear(), _now.getUTCMonth(), _now.getUTCDate(), 
						//				_now.getUTCHours() + increment, _now.getUTCMinutes(), _now.getUTCSeconds());
					break;
					case 'mins' :
						_now.setUTCMinutes(_now.getUTCMinutes() + increment);
						//_now = new Date(_now.getUTCFullYear(), _now.getUTCMonth(), _now.getUTCDate(), 
						//				_now.getUTCHours(), _now.getUTCMinutes() + increment, _now.getUTCSeconds());
					break;					
					case 'ampm' :
						_now.setUTCHours(_now.getUTCHours() + (increment * 12));
						//_now = new Date(_now.getUTCFullYear(), _now.getUTCMonth(), _now.getUTCDate(), 
						//				_now.getUTCHours() + (increment * 12), _now.getUTCMinutes(), _now.getUTCSeconds());
					break;					
					case 'days' :
						_now.setUTCDate(_now.getUTCDate() + increment);
						//_now = new Date(_now.getUTCFullYear(), _now.getUTCMonth(), _now.getUTCDate() + increment, 
						//				_now.getUTCHours(), _now.getUTCMinutes(), _now.getUTCSeconds());
					break;	
					case 'month' :
						_now.setUTCMonth(_now.getUTCMonth() + increment);
						//_now = new Date(_now.getUTCFullYear(), _now.getUTCMonth() + increment, _now.getUTCDate(), 
						//				_now.getUTCHours(), _now.getUTCMinutes(), _now.getUTCSeconds());
					break;					
					case 'year' :
						_now.setUTCFullYear(_now.getUTCFullYear() + increment);
						//_now = new Date(_now.getUTCFullYear() + increment, _now.getUTCMonth() + increment, _now.getUTCDate(), 
						//				_now.getUTCHours(), _now.getUTCMinutes(), _now.getUTCSeconds());
					break;					
				}
				
			}

			//Logger.info('UpdateTimeByIncrement', _now.getTime().toString(), _now.toUTCString());
			
			_hours.text	= makeNumberDouble( _now.getUTCHours() > 12 ? _now.getUTCHours() - 12 : _now.getUTCHours() == 0 ? 12 : _now.getUTCHours() );
			_mins.text 	= makeNumberDouble(_now.getUTCMinutes());
			_ampm.text 	= _now.getUTCHours() > 12 ? 'PM' : 'AM';
			_days.text 	= makeNumberDouble(_now.getUTCDate());
			_month.text	= makeNumberDouble(_now.getUTCMonth() + 1);
			_year.text 	= _now.getUTCFullYear().toString();
		}

		private function updateDateTime(action:String):void
		{
			switch(action){
				case 'year' :
					_now.setUTCFullYear(parseInt(_year.text));
				break;
				case 'month' :
					_now.setUTCMonth(parseInt(_month.text) - 1);
				break;
				case 'days' :
					_now.setUTCDate(parseInt(_days.text));
				break;
				case 'hours' :
					var hour:int = _ampm.text == 'PM' ? parseInt(_hours.text) + 12 : parseInt(_hours.text);
					_now.setUTCHours(hour);
				break;
				case 'mins' :
					_now.setUTCMinutes(parseInt(_mins.text));
				break;				
			}		
			//Logger.info('UpdateTime', _now.toUTCString());
		}
		
		private function setStyles():void
		{
			var _elements:Array = new Array(_hours, _mins, _ampm, _days, _month, _year, _tz);
			
			_elements.forEach( function(item:*, index:int, array:Array):void {
				item.setStyle('paddingLeft', 0);
				item.setStyle('paddingRight', 0);
				item.setStyle('borderStyle', 'none');
				item.setStyle('backgroundAlpha', 0);
				item.setStyle('focusAlpha', 0);
			});
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			setStyles();
			updateDateTimeByIncrement();
			
			var _horizontalGap:Number = 0;
			var mText:TextLineMetrics;
			
			_hours.setActualSize(20, this.height);			
			_hours.move(getStyle('paddingLeft'),0);
			
			_colon.setActualSize(4,this.height);
			mText = _hours.measureText('00');
			_colon.move(_hours.x + mText.width, 0);
			
			_mins.setActualSize(20, this.height);	
			mText = _colon.measureText(_colon.text);					
			_mins.move(_colon.x + mText.width, 0);
			
			_ampm.setActualSize(24, this.height);
			mText = _mins.measureText('00');								
			_ampm.move(_mins.x + mText.width +2, 0);

			_month.setActualSize(20, this.height);			
			mText = _ampm.measureText('AM');																				
			_month.move(_ampm.x + mText.width + 5, 0);
			
			_bkslash1.setActualSize(4,this.height);
			mText = _month.measureText('00');																	
			_bkslash1.move(_month.x + mText.width, 0);
			
			_days.setActualSize(20, this.height);
			mText = _ampm.measureText(_bkslash1.text);														
			_days.move(_bkslash1.x + mText.width, 0);
			
			_bkslash2.setActualSize(4,this.height);
			mText = _days.measureText('00');																				
			_bkslash2.move(_days.x + mText.width, 0);
			
			_year.setActualSize(35, this.height);			
			mText = _bkslash2.measureText(_bkslash2.text);																				
			_year.move(_bkslash2.x + mText.width, 0);									

			_tz.setActualSize(this.width - _year.x - _year.width - 10, this.height);			
			_tz.move(_year.x + _year.width + 2, 1);									
		}

		private function clearDateTimeFocusInHandler(e:FocusEvent):void
		{
			// shows the box and sets the text colour
			setStyle('borderStyle', 'none');
			setStyle('backgroundAlpha', 1);
			// adds dropshadow to the input so it looks like it jumps out of the page
			this.filters = [dropshadowFilter()];
		}

		private function clearDateTimeFocusOutHandler(e:FocusEvent):void
		{
			// hides the box
			setStyle('borderStyle', 'none');
			setStyle('backgroundAlpha', 0);
			// removes the dropshadow
			this.filters = [];
		}
		
		private function inputFocusHandler(e:FocusEvent):void
		{
			e.currentTarget.setSelection(0, e.currentTarget.maxChars);
		}
		
		private function timeKeyPressHandler(e:KeyboardEvent):void
		{
			var boxText:Number = 0;
			var increment:Number = 0;
			var daysInMonth:Number = getDaysInMonth();
			
			e.currentTarget.setSelection(0, e.currentTarget.maxChars);
			
			switch(e.keyCode){
				case Keyboard.UP :
					increment = 1;
				break;
				case Keyboard.DOWN :
					increment = -1;
				break;
				case Keyboard.TAB :
					return;
				break;
				default :
					increment = 0;
				break;
			}
			
			if(increment != 0) {
				boxText = parseInt(e.currentTarget.text) + increment;
				
				switch(e.currentTarget.id) {
					case 'hours' :
						boxText = boxText > 12 ? 1 : boxText < 1 ? 12 : boxText;
					break;
					case 'mins' :
						boxText = boxText > 59 ? 0 : boxText < 0 ? 59 : boxText;
					break;
					case 'days' :
						boxText = boxText > daysInMonth ? 1 : boxText < 1 ? getDaysInMonth(true) : boxText;
					break;
					case 'month' :
						boxText = boxText > 12 ? 1 : boxText < 1 ? 12 : boxText;
					break;
					case 'year' :
						boxText = boxText < 2000 ? 2000 : boxText;
					break;				
				}
				
				updateDateTimeByIncrement(increment, e.currentTarget.id);
				
				e.currentTarget.text = makeNumberDouble(boxText);	
				
			} else {
				
				var currText:String = '';
				var enteredNum:String = String.fromCharCode(e.charCode);
				var newNum:String = '';
				var updateFlag:Boolean = true;
				
				if(parseInt(enteredNum) >= 0 && parseInt(enteredNum) < 10){

					switch(e.currentTarget.id) {
						case 'hours' :
							var hour:int = _ampm.text == 'PM' ? _now.getUTCHours() - 12 : _now.getUTCHours();
							hour  = hour < 0 ? 0 : hour;
							currText = makeNumberDouble(hour);
							newNum = enteredNum.length == 2 ? currText : currText.substr(1,1) + enteredNum;
							newNum = parseInt(newNum) < 13 ? newNum : makeNumberDouble(parseInt(enteredNum));
							e.currentTarget.text = newNum;
						break;
						case 'mins' :
							currText = makeNumberDouble(_now.getUTCMinutes());
							newNum = enteredNum.length == 2 ? currText : currText.substr(1,1) + enteredNum;
							newNum = parseInt(newNum) < 59 ? newNum : makeNumberDouble(parseInt(enteredNum));
							e.currentTarget.text = newNum;
						break;
						case 'days' :
							currText = makeNumberDouble(_now.getUTCDate());
							newNum = enteredNum.length == 2 ? currText : currText.substr(1,1) + enteredNum;
							newNum = parseInt(newNum) < daysInMonth ? newNum : makeNumberDouble(parseInt(enteredNum));
							e.currentTarget.text = newNum;
						break;
						case 'month' :
							currText = makeNumberDouble(_now.getUTCMonth());
							newNum = enteredNum.length == 2 ? currText : currText.substr(1,1) + enteredNum;
							newNum = parseInt(newNum) < 13 ? newNum : makeNumberDouble(parseInt(enteredNum));
							e.currentTarget.text = newNum;
						break;
						case 'year' :
							newNum = _yearPrevKey + enteredNum;
							if(newNum.length < 4){
								updateFlag = false;
								e.currentTarget.text = _yearPrevKey + enteredNum;
								_yearPrevKey += enteredNum
							} else if (parseInt(enteredNum) == _now.getUTCFullYear()) {
								updateFlag = false;
								e.currentTarget.text = enteredNum;
								_yearPrevKey += enteredNum
							} else {
								newNum = parseInt(newNum) < 2000 ? '2000' : newNum;
								e.currentTarget.text = newNum;
								_yearPrevKey = '';
							}
							_yearPrevKey = _yearPrevKey.length > 4 ? _yearPrevKey.substr(0,4) : _yearPrevKey;
						break;				
					}
					
					if(updateFlag)		
						updateDateTime(e.currentTarget.id);
						
				}

			}
		}
		
		private function ampmKeyPressHandler(e:KeyboardEvent):void
		{			
			e.currentTarget.setSelection(0, e.currentTarget.maxChars);
			
			switch(e.keyCode){
				case Keyboard.DOWN :
				case Keyboard.UP :
					e.currentTarget.text = e.currentTarget.text == 'PM' ? 'AM' : 'PM';
				break;	
				case 65 :
					e.currentTarget.text = 'AM';
				break;
				case 80 :
					e.currentTarget.text = 'PM';
				break;	
				case Keyboard.TAB :
					return;
				break;
				default :
					e.currentTarget.text = 'PM';
					return;
				break;			
			}
			
			updateDateTime('hours');
		}
		
		
		private function makeNumberDouble(num:Number):String
		{
			if(num < 10){
				return '0' + num.toString();
			} else {
				return  num.toString();
			}
		}
		
		private function getDaysInMonth(prev:Boolean=false):Number
		{
			var _check:Date;
			if(prev){
				_check = new Date(_now.getFullYear(), _now.getMonth()-1, 27, 
											_now.getHours(), _now.getMinutes(), _now.getSeconds());	
			} else {
				_check = new Date(_now.getFullYear(), _now.getMonth(), 27, 
											_now.getHours(), _now.getMinutes(), _now.getSeconds());	
			}
										
			while(_check.getDate() > 1){
				_check = new Date(_check.getFullYear(), _check.getMonth(), _check.getDate() + 1, 
											_check.getHours(), _check.getMinutes(), _check.getSeconds());	
			}		

			_check = new Date(_check.getFullYear(), _check.getMonth(), _check.getDate() - 1, 
										_check.getHours(), _check.getMinutes(), _check.getSeconds());	
			
			return _check.getDate();
		}
		
		private function timezoneList():void
		{
			timezones = new Object();
			tzArrayCol.addItem({ 'value' : '-12', 'label' :'Enitwetok, Kwajalien' });
			tzArrayCol.addItem({ 'value' : '-11', 'label' :'Nome, Midway Island, Samoa' });			
			tzArrayCol.addItem({ 'value' : '-10', 'label' :'Hawaii' });			
			tzArrayCol.addItem({ 'value' : '-9', 'label' :'Alaska' });			
			tzArrayCol.addItem({ 'value' : '-8', 'label' :'Pacific' });	
			tzArrayCol.addItem({ 'value' : '-7', 'label' :'Mountain' });
			tzArrayCol.addItem({ 'value' : '-6', 'label' :'Central' });
			tzArrayCol.addItem({ 'value' : '-5', 'label' :'Eastern' });
			tzArrayCol.addItem({ 'value' : '-4', 'label' :'Atlantic' });
			tzArrayCol.addItem({ 'value' : '-3.5', 'label' :'Newfoundland' });
			tzArrayCol.addItem({ 'value' : '-3', 'label' :'Brazil, Buenos Aires, Georgetown, Falkland Is.' });
			tzArrayCol.addItem({ 'value' : '-2', 'label' :'Mid-Atlantic, Ascention Is., St Helena' });
			tzArrayCol.addItem({ 'value' : '-1', 'label' :'Azores, Cape Verde Islands' });
			tzArrayCol.addItem({ 'value' : '0', 'label' :'(UTC) Casablanca, Dublin, Edinburgh, London, Lisbon, Monrovia' });
			tzArrayCol.addItem({ 'value' : '1', 'label' :'Berlin, Brussels, Copenhagen, Madrid, Paris, Rome' });
			tzArrayCol.addItem({ 'value' : '2', 'label' :'Kaliningrad, South Africa, Warsaw' });
			tzArrayCol.addItem({ 'value' : '3', 'label' :'Baghdad, Riyadh, Moscow, Nairobi' });
			tzArrayCol.addItem({ 'value' : '3.5', 'label' :'Tehran' });
			tzArrayCol.addItem({ 'value' : '4', 'label' :'Adu Dhabi, Baku, Muscat, Tbilisi' });
			tzArrayCol.addItem({ 'value' : '4.5', 'label' :'Kabul' });
			tzArrayCol.addItem({ 'value' : '5', 'label' :'Islamabad, Karachi, Tashkent' });
			tzArrayCol.addItem({ 'value' : '5.5', 'label' :'Bombay, Calcutta, Madras, New Delhi' });
			tzArrayCol.addItem({ 'value' : '6', 'label' :'Almaty, Colomba, Dhakra' });
			tzArrayCol.addItem({ 'value' : '7', 'label' :'Bangkok, Hanoi, Jakarta' });
			tzArrayCol.addItem({ 'value' : '8', 'label' :'Beijing, Hong Kong, Perth, Singapore, Taipei' });
			tzArrayCol.addItem({ 'value' : '9', 'label' :'Osaka, Sapporo, Seoul, Tokyo, Yakutsk' });
			tzArrayCol.addItem({ 'value' : '9.5', 'label' :'Adelaide, Darwin' });
			tzArrayCol.addItem({ 'value' : '10', 'label' :'Sydney, Melbourne' });
			tzArrayCol.addItem({ 'value' : '11', 'label' :'Magadan, New Caledonia, Solomon Islands' });
			tzArrayCol.addItem({ 'value' : '12', 'label' :'Auckland, Wellington, Fiji, Marshall Island' });
													
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