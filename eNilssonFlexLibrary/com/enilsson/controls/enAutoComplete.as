package com.enilsson.controls
{
import com.enilsson.events.autoCompleteEvent;
import com.enilsson.graphics.Spinner;
import com.enilsson.graphics.enCloseBtn;
import com.enilsson.utils.ajax.*;

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.BitmapFilterQuality;
import flash.filters.DropShadowFilter;
import flash.ui.Keyboard;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.ComboBox;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.ListEvent;

use namespace mx_internal;

[Style(name="defaultColor", type="uint", format="Color", inherit="no")]

[Event(name="typedTextChange", type="flash.events.Event")]

[Exclude(name="editable", kind="property")]

public class enAutoComplete extends ComboBox
{
	private var cursorPosition:Number=0;
	private var prevIndex:Number = -1;
	private var removeHighlight:Boolean = false;	
	private var showDropdown:Boolean=false;
	private var showingDropdown:Boolean=false;
	private var tempCollection:Object;
	private var dropdownClosed:Boolean=true;
	private var spinner:Spinner;
	private var clearBtn:enCloseBtn;
	private var prevCursorPos:Number=0;
	private var _lastKeyPress:Number=0;
	private var _timerLookup:Boolean = false;
	private var _init:Boolean = true;


	public function enAutoComplete()
	{
		super();
		
	    // make ComboBox look like a normal text field
	    editable = true;
	    setStyle("arrowButtonWidth",0);
		setStyle("fontWeight","normal");
		setStyle("cornerRadius",0);
		setStyle("paddingLeft",0);
		setStyle("paddingRight",0);
		setStyle('focusAlpha', 0);
		rowCount = 7;	
		
		this.addEventListener(ListEvent.CHANGE, showMask);
	}

	/**
	 * Get and set the url to be used in the AJAX callback
	 */
	private var _url:String;
	public function set url(value:String):void
	{
		_url = value;				
	}			
	public function get url():String
	{
		return _url;				
	}				

	/**
	 * Get and set the class method to be used in the AJAX callback
	 */	
	private var _method:String = '';
	public function set method(value:String):void
	{
		_method = value;				
	}				
	public function get method():String
	{
		return _method;				
	}	
	
	/**
	 * Get and set the class source to be used in the AJAX callback
	 */	
	private var _source:String = '';
	public function set source(value:String):void
	{
		_source = value;				
	}				
	public function get source():String
	{
		return _source;				
	}								

	/**
	 * The number of characters input before the callback is made
	 */
	private var _charLimit:Number = 2;
	public function set charLimit(value:Number):void
	{
		_charLimit = value;				
	}			
	public function get charLimit():Number
	{
		return _charLimit;				
	}				

	/**
	 * Limit the number of search results returned
	 */
	private var _searchLimit:Number = 100;
	public function set searchLimit(value:Number):void
	{
		_searchLimit = value;				
	}			
	public function get searchLimit():Number
	{
		return _searchLimit;				
	}				

	/**
	 * The time between keypresses before a callback search is made
	 */	
	private var _keyPressInterval:Number = 500;
	public function set keyPressInterval(value:Number):void
	{
		_keyPressInterval = value;				
	}			
	public function get keyPressInterval():Number
	{
		return _keyPressInterval;				
	}				

	/**
	 * Set the component background to nothing
	 */
	private var _clearBG:Boolean = false;
	public function set clearBG(value:Boolean):void
	{
		_clearBG = value;				
	}			
	
	/**
	 * The default value of the input if nothing is selected
	 */
	private var _defaultString:String = 'None';
	public function set defaultString(value:String):void
	{
		_defaultString = value;				
	}				
	public function get defaultString():String
	{
		return _defaultString;				
	}								
	
	/**
	 * Use a mask string when selecting items from the dropdown, giving a different item in the input box
	 */
	private var _useMask:Boolean = false;
	public function set useMask(value:Boolean):void
	{
		_useMask = value;				
	}	
	public function get useMask():Boolean
	{
		return _useMask;				
	}				
	
	/**
	 * Set the transport type of the AJAX call
	 */
	private var _ajaxType:String = 'amf';
	public function set ajaxType(value:String):void
	{
		_ajaxType = value;
	}			
	public function get ajaxType():String
	{
		return _ajaxType;				
	}	
	
	/**
	 * Set the component to debug mode
	 */
	private var _debug:Boolean = false;
	public function set debugMode(value:Boolean):void
	{
		_debug = value;				
	}	
	public function get debugMode():Boolean
	{
		return _debug;				
	}				
								

	public function setCursor():void
	{
		this.setFocus();
		typedText = '';
		textInput.setSelection(1, 1);
	}

 	override public function set editable(value:Boolean):void
	{
	    //This is done to prevent user from resetting the value to false
	    super.editable = true;
	}
	
 	override public function set dataProvider(value:Object):void
	{
		super.dataProvider = value;
		tempCollection = value;
	}

	private var _typedText:String="";
	private var typedTextChanged:Boolean;

	[Bindable("typedTextChange")]
	[Inspectable(category="Data")]
	
	public function get typedText():String
	{
	    return _typedText;
	}
	public function set typedText(input:String):void
	{
	    _typedText = input;
	    typedTextChanged = true;
			
	    invalidateProperties();
		invalidateDisplayList();
		dispatchEvent(new Event("typedTextChange"));
	}

	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
	    super.updateDisplayList(unscaledWidth, unscaledHeight);
	    
	    clearBtn.size = textInput.height - 4;
	    clearBtn.crossSize = textInput.height - 18;
	    spinner.size = textInput.height - 6;
	    clearBtn.move((textInput.width - (textInput.height - 2) - 2), 2);
	    spinner.move((textInput.width - (textInput.height - 6) - spinner.size - 9), 3);

		if(_clearBG){
			setStyle('borderStyle', 'none');
			setStyle('backgroundAlpha', 0);
			setStyle('focusAlpha', 0);
			setStyle('paddingLeft', 4);
		}
	    
	    var now:Date = new Date();

		//An UP "keydown" event on the top-most item in the drop 
		//down list otherwise changes the text in the text field to ""
  	    if(selectedIndex == -1)
	    	textInput.text = typedText;

		// if the dropdown exists
	    if(dropdown)
		{
			// the text input has changed
		    if(typedTextChanged)
			{
				// if the length of text is longer than the character limit get the autocomplete source
				// and show the selection box
			    if(typedText.length > _charLimit){
			    	if(collection.length == 0){
			    		// if no data has been return check to see if the user is still typing
						//Logger.info('Key Press',now.getTime(), _lastKeyPress, _keyPressInterval, (now.getTime() - _lastKeyPress));
						if((now.getTime() - _lastKeyPress) > _keyPressInterval){
							// if the time between presses is beyond the limit run the search
							lookupData();
						} else {
							// if the time is less then run a timed search
							timerLookup();
						}
						_lastKeyPress = now.getTime();
			    	} else {
			    		_lastKeyPress = 0;
			    		lookupData();
			    	}
			    } else {
				    textInput.text = _typedText;
				    removeHighlight = false;
				    if(collection.length > 0){
					    dataProvider = new ArrayCollection();
						_collectionReset = true;
				    }
					if(dropdown.visible){
						super.close();
			    		showDropdown = false;
					}
					textInput.setSelection(_typedText.length, _typedText.length);
			    }
			    _lastKeyPress = now.getTime();
			}
		    else if(typedText) {
				textInput.setSelection(_typedText.length,textInput.text.length);
		    }

		}

	}

	/**
	 * @private
	 * Run the data lookup when the user stops typing
	 */
	private function timerLookup():void
	{
		if(_timerLookup){ return; }
		_timerLookup = true;
		//Logger.info('timer lookup',_lastKeyPress, _keyPressInterval);
		var t:Timer = new Timer(_keyPressInterval,1);
		t.start();
		t.addEventListener(TimerEvent.TIMER, function(evt:TimerEvent):void {
			//Logger.info('Run Lookup via Timer!', _typedText.length);
			_timerLookup = false;
			lookupData();
		});
	}

	override protected function commitProperties():void
	{
	    super.commitProperties();
	
  	    if(!dropdown)
			selectedIndex=-1;
  			
	    if(dropdown)
		{
		    if(typedTextChanged)
		    {
			    cursorPosition = textInput.selectionBeginIndex;

			    //In case there are no suggestions there is no need to show the dropdown
  			    if(collection.length < 0 || typedText==""|| typedText==null)
  			    {
  			    	textInput.text = _defaultString;
  			    	dropdownClosed=true;
			    	showDropdown=false;
			    	clearBtn.visible = false;
  			    } else {
					showDropdown = true;
					//selectedIndex = 0;
					clearBtn.visible = true;
 		    	}
 		
 		
 		    }
		}
	}

	override protected function createChildren():void
	{
	    super.createChildren();

		downArrowButton.visible = false;
	    
	    spinner = new Spinner();
	    spinner.tickWidth = 2;
	    spinner.setStyle('tickColor', '#33332D');
	    spinner.visible = false;
	    textInput.addChild(spinner);
	    
	    clearBtn = new enCloseBtn();
	    clearBtn.dropShadow = false;
	    clearBtn.backgroundColor =  0xbebebe;
	    clearBtn.rollOverAlpha = 1;
	    clearBtn.toolTip = 'Clear search';
	    clearBtn.visible = false;
	    clearBtn.addEventListener(MouseEvent.CLICK, clearData);
	    textInput.addChild(clearBtn);
	}		

	override protected function measure():void
	{
	    super.measure();
	    measuredWidth = mx.core.UIComponent.DEFAULT_MEASURED_WIDTH;
	}		

	override protected function textInput_changeHandler(event:Event):void
	{
	    super.textInput_changeHandler(event);
	    
	    //Stores the text typed by the user in a variable
		typedText=text;
	}

	private var _returnFunction:Function;
	private var _returnFnSet:Boolean = false;
	public function set returnFunction(value:Function):void
	{
		_returnFunction = value;
		_returnFnSet = true;
	}

	override protected function keyDownHandler(event:KeyboardEvent):void
	{
	    super.keyDownHandler(event);

	    //Logger.info('KDH Typed Text', event.keyCode);

	    if(!event.ctrlKey)
		{   
		    //An UP "keydown" event on the top-most item in the drop-down
		    //or an ESCAPE "keydown" event should change the text in text
		    // field to original text
		    if(event.keyCode == Keyboard.UP && prevIndex==0)
			{
	 		    textInput.text = _typedText;
			    textInput.setSelection(textInput.text.length, textInput.text.length);
			    selectedIndex = -1; 
			}
			else if(event.keyCode == Keyboard.SHIFT){
				// clear data if shift is pressed with the entire field highlighted
			    if(textInput.selectionBeginIndex == 0){
			    	clearData();
			    }
			}
		    else if(event.keyCode==Keyboard.ESCAPE && showingDropdown)
			{
	 		    textInput.text = _typedText;
			    textInput.setSelection(textInput.text.length, textInput.text.length);
			    showingDropdown = false;
			    dropdownClosed = true;
			}
			else if (event.keyCode==Keyboard.ENTER) {
				if(_returnFnSet){
					_returnFunction();	
				}
			}
			else if(event.keyCode==Keyboard.BACKSPACE || event.keyCode==Keyboard.DELETE) {
	 		    textInput.text = _typedText;
			    textInput.setSelection(_typedText.length, _typedText.length);
			    if(textInput.selectionBeginIndex < _charLimit){
			    	clearData();
			    }
			    super.close();
			    selectedIndex = -1;
		 	}
	 	} else {
		    if(event.ctrlKey && event.keyCode==Keyboard.UP) {
		    	dropdownClosed=true;
		    }
	 	}
	 	
	 	if((prevCursorPos - textInput.selectionBeginIndex) >= _charLimit){
			dataProvider = new ArrayCollection();
			_collectionReset = true;
	 	}
	 	
 	    prevIndex = selectedIndex;
 	    prevCursorPos = textInput.selectionBeginIndex;
	}

	override protected function focusInHandler(event:FocusEvent):void
	{
		super.focusInHandler(event);
		
		if(selectedIndex < 0){
			textInput.text = '';
		}

		textInput.setStyle('color', 0x000000);		
		
		if(_clearBG){
			textInput.setStyle('borderStyle', 'none');
			textInput.setStyle('backgroundAlpha', 1);			
			clearBtn.visible = textInput.length > 0;
		}
		
		textInput.filters = [dropshadowFilter()];
	}

	override protected function focusOutHandler(event:FocusEvent):void
	{
		super.focusOutHandler(event);

		if(selectedIndex < 0){
			textInput.text = _defaultString;
			textInput.setStyle('color', getStyle('defaultColor'));
		}
		
		if(_clearBG){
			textInput.setStyle('backgroundAlpha', 0);
			
			spinner.visible = false;
			clearBtn.visible = false;
		}
		
		textInput.filters = [];
		
		if(_useMask){
			textInput.text = this.selectedItem.mask;
		}
	}

	private function showMask(e:ListEvent):void
	{
		if(_useMask){
			if(this.selectedItem){
				textInput.text = this.selectedItem.mask;
			}
		}
	}

	private var _filterFunction:Function = defaultFilterFunction;
	private var filterFunctionChanged:Boolean = true;

	[Bindable("filterFunctionChange")]
	[Inspectable(category="General")]

	public function get filterFunction():Function
	{
		return _filterFunction;
	}

	public function set filterFunction(value:Function):void
	{
		//An empty filterFunction is allowed but not a null filterFunction
		if(value!=null)
		{
			_filterFunction = value;
			filterFunctionChanged = true;

			invalidateProperties();
			invalidateDisplayList();
	
			dispatchEvent(new Event("filterFunctionChange"));
		}
		else
			_filterFunction = defaultFilterFunction;
	}

	private function defaultFilterFunction(element:*, text:String):Boolean 
	{
	    var label:String = itemToLabel(element);
	    return (label.toLowerCase().substring(0,text.length) == text.toLowerCase());
	}

 	private function templateFilterFunction(element:*):Boolean 
	{
		var flag:Boolean=false;
		if(filterFunction!=null)
			flag=filterFunction(element,typedText);
		return flag;
	}

	private var _collectionSet:Boolean = false;
	private var _collectionReset:Boolean = false;

	public function clearData(e:MouseEvent=null):void
	{
		dataProvider = new ArrayCollection();
		_collectionReset = true;
		typedText = '';
		textInput.text = '';
		invalidateProperties();
		invalidateDisplayList();
		_lastKeyPress = 0;	
	}

	private function lookupData():void
	{
		// if there are not enough characters for a sensible search
		if(_typedText.length < _charLimit){ return; }
		// if the collection has all the possible values for the search term just filter the existing data
		if(_collectionSet && !_collectionReset && collection.length < _searchLimit){ 
			dataProvider = tempCollection;
	 		collection.filterFunction = templateFilterFunction;
			collection.refresh();
			if(collection.length == 0){
				_typedText = _typedText.substr(0,_typedText.length-1);
				lookupData();
			} else {
				//selectedIndex = -1;
				selectedIndex = collection.length == 1 ? 0 : -1;
				handleACData();
			}
			return;
		}
		// show the activity spinner
		spinner.visible = true;
		// place the typed text in the box so it doesnt disappear while the data is loading
		textInput.text = _typedText;
		textInput.setSelection(_typedText.length,_typedText.length);
		// set the form variables
		var fv:Object = new Object();
		fv['searchTerm'] = _typedText;
		// get the data and process the dataGrids and lists
		var ajax:enAJAX = new enAJAX({
			'type' : _ajaxType,
			'url' : _url,
			'method' : _method,
			'source' : _source,
			'params' : fv,
			'useTimeOut' : false,
			'debug' : _debug,
			'onComplete' : function(e:enAJAXevent):void {
				var data:Object = e.data;
				if(!data){ 
					spinner.visible = false;
					return; 
				}
				var dpData:ArrayCollection = new ArrayCollection;
				if(typeof(data[0]) == 'object'){
					for(var i:String in data){
						var item:Object = new Object();
						for(var t:String in data[i]){
							item[t] = data[i][t];
						}
						item['value'] = item.id;
						item['label'] = item.text;
						dpData.addItem(item);
					}
					selectedIndex = -1;
				} else {
					data['value'] = data.id;
					data['label'] = data.text;
					dpData.addItem(data);
					// selectedIndex = -1; 
					selectedIndex = _collectionReset ? -1 : 0;
				}
				dataProvider = dpData;
				collection.refresh();
				handleACData();
				spinner.visible = false;
				_collectionSet = true;
				_collectionReset = false;

				dispatchEvent(new autoCompleteEvent('searchComplete', data));
			}
		});
	}

	private function handleACData():void
	{
		// the text input has changed
	    if(typedTextChanged) {
			//Logger.info('handleACData',_typedText,selectedIndex);
	  	    if(typedText.length > _charLimit && showDropdown && typedText!="" && !removeHighlight) {
				if(selectedIndex == -1){
					textInput.text = _typedText;
					textInput.setSelection(cursorPosition, cursorPosition);
					removeHighlight = false;
				} else {
					var label:String = itemToLabel(collection[0]);
					var index:Number =  label.toLowerCase().indexOf(_typedText.toLowerCase());
					if(index==0) {
					    textInput.text = _typedText+label.substr(_typedText.length);
					    textInput.setSelection(textInput.text.length,_typedText.length);
					} else {
					    textInput.text = _typedText;
					    textInput.setSelection(cursorPosition, cursorPosition);
					    removeHighlight = false;
					}
				}
			} else {
			    textInput.text = _typedText;
			    textInput.setSelection(cursorPosition, cursorPosition);
			    removeHighlight = false;
			}
		    typedTextChanged= false;
		    
		} else if(typedText) {
	    	//Sets the selection when user navigates the suggestion list through
	    	//arrows keys.
			textInput.setSelection(_typedText.length,textInput.text.length);
		}
				
 	    if(showDropdown && !dropdown.visible) {
 	    	//This is needed to control the open duration of the dropdown
 	    	super.open();
	    	showDropdown = false;
 	    	showingDropdown = true;

 	    	if(dropdownClosed)
	 	    	dropdownClosed=false;
 	    }
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