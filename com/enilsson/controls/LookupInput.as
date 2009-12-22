package com.enilsson.controls
{
	import com.enilsson.components.LookupSearchBox;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	import mx.controls.ComboBase;
	import mx.core.ClassFactory;
	import mx.core.FlexVersion;
	import mx.core.IFactory;
	import mx.core.UIComponentGlobals;
	import mx.core.mx_internal;
	import mx.events.DropdownEvent;
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.styles.StyleProxy;
	
	import org.osflash.thunderbolt.Logger;
	
	use namespace mx_internal;
	
	[Style(name="searchBoxStyleName", type="String", inherit="no")]
	
	[Event(name="searchStart", type="flash.events.Event")]
	[Event(name="labelSearch", type="flash.events.Event")]
	[Event(name="dataValueChanged", type="flash.events.Event")]
	[Event(name="labelChanged", type="flash.events.Event")]
	[Event(name="selectedDataChanged", type="flash.events.Event")]

	public class LookupInput extends ComboBase
	{
		[Embed (source="../assets/images/search.png")]
		private static var BTN_SKIN:Class;
		
		public function LookupInput()
		{
			super();
			
			setStyles();
		}
		
		private function setStyles():void
		{
			if (!StyleManager.getStyleDeclaration("LookupInput")) {
	            var ComponentStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
	            ComponentStyles.defaultFactory = function():void {
					this.searchBoxStyleName = 'searchBoxStyleName';
	            }
	            StyleManager.setStyleDeclaration("LookupInput", ComponentStyles, true);
	        }
		}		
		

	    private var _enabled:Boolean = true;
	    private var enabledChanged:Boolean = false;
	
	    [Bindable("enabledChanged")]
	    [Inspectable(category="General", enumeration="true,false", defaultValue="true")]
	
	    override public function get enabled():Boolean
	    {
	        return _enabled;
	    }
	    override public function set enabled(value:Boolean):void
	    {
	        if (value == _enabled)
	            return;
	
	        _enabled = value;
	        super.enabled = value;
	        enabledChanged = true;
	
	        invalidateProperties();
	    }

	    private var _dropdown:LookupSearchBox;
	    public function get dropdown():LookupSearchBox
	    {
	        return _dropdown;
	    }
	
	    private var _dropdownFactory:IFactory = new ClassFactory(LookupSearchBox);
	    [Bindable("dropdownFactoryChanged")]
	    public function get dropdownFactory():IFactory
	    {
	        return _dropdownFactory;
	    }
	    
	    /**
	    * Set the component data value
	    */
	    private var _value:Number;
	    public function set dataValue(value:Number):void
	    {
	    	if(_debug) Logger.info('Set dataValue', value);
	    	
	    	_value = value;
	    	
	    	dispatchEvent( new Event('dataValueChanged') );
	    	
	    	if (((_label == '') || (_label == null)) && (_value != 0)) {
	    		dispatchEvent( new Event('labelSearch') );
	    	}    		

	    }
	    [Bindable(event="dataValueChanged")]
	    public function get dataValue():Number
	    {
	    	return _value;
	    }
	    
	    /**
	    * Set the label string that is shown in the text box
	    */
	    private var _label:String = '';
	    public function set label(value:String):void
	    {
	    	if(_debug) Logger.info('Set Label', value);	    	
	    	
	    	_label = value;
	    	
	    	if(textInput)
	    		textInput.text = _label;
	    		
	    	dispatchEvent( new Event('labelChanged') );
	    }
	    [Bindable(event="labelChanged")]
	    public function get label():String
	    {
	    	return _label;
	    }
	    
	    
	    /**
	    * Convenience function to set both the dataValue and label at once
	    */
	    public function set setData(value:Object):void
	    {
	    	if(_debug) Logger.info('setData', value, value.hasOwnProperty('label'));
	    	
	    	if(value.hasOwnProperty('label'))
	    		label = value.label;	    		    	
	    	if(value.hasOwnProperty('value'))
	    		dataValue = value.value;
	    }
	  	[Bindable(event="setDataChanged")]
	    public function get setData():Object
	    {
	    	return { 'value' : dataValue, 'label' : label };	    	
	    }


		private var _debug:Boolean = false;
		[Inspectable( type="Boolean" )]
		public function set debugMode(value:Boolean):void
		{
			_debug = value;
		}
		public function get debugMode():Boolean
		{
			return _debug;
		} 

		/**
		 * Return the search term from the dropdown
		 */
		public function get searchTerm():String
		{
			if(_dropdown)
				return _dropdown.searchTerm;
			else
				return '';
		}

		/**
		 * Set the dataProvider for the search results list
		 */
		private var _searchDataProvider:ArrayCollection;
		public function set searchDataProvider(value:ArrayCollection):void
		{
			_searchDataProvider = value;
			
			if(_dropdown)
				_dropdown.searchDataProvider = value;
		}
		public function get searchDataProvider():ArrayCollection
		{
			return _searchDataProvider;
		}
		
		/**
		 * Set an itemRenderer for the search box dropdown
		 */
		private var _itemRenderer:ClassFactory;
		public function set itemRenderer(value:ClassFactory):void
		{
			_itemRenderer = value;
			
			if(_dropdown)
				_dropdown.listItemRenderer = value;
		}
		public function get itemRenderer():ClassFactory
		{
			return _itemRenderer;
		}
		
		/**
		 * Get and set the selected data
		 */
		private var _selectedData:Object = new Object();
		public function set selectedData(data:Object):void
		{
			_selectedData = data;
			
			dispatchEvent( new Event('selectedDataChanged') );
		}
		 [Bindable(event="selectedDataChanged")]
		public function get selectedData():Object
		{
			return _selectedData;
		}
		
		/**
		 * Reset the component
		 */
		public function clear():void
		{
			_searchDataProvider = new ArrayCollection();
			
			label = '';			
	    	dataValue = 0;
			selectedData = new Object();
		}
		
		
		/**
		 * Override the native createChildren method to add in the necessary changes
		 */
	    override protected function createChildren():void
	    {
	        super.createChildren();
	
	        createDropdown();
	
	        downArrowButton.setStyle("paddingLeft", 5);
	        downArrowButton.setStyle("paddingRight", 0);
	        downArrowButton.setStyle('skin', BTN_SKIN);
	        
	        textInput.editable = false;
	        textInput.addEventListener(TextEvent.TEXT_INPUT, textInput_textInputHandler);
	        border.visible = false;
	    }

	    override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void
	    {
	        super.updateDisplayList(unscaledWidth, unscaledHeight);
	
	        var w:Number = unscaledWidth;
	        var h:Number = unscaledHeight;
	
	        var arrowWidth:Number = downArrowButton.getExplicitOrMeasuredWidth();
	        var arrowHeight:Number = downArrowButton.getExplicitOrMeasuredHeight();
	
	        downArrowButton.setActualSize(arrowWidth, arrowHeight);
	        downArrowButton.move(w - arrowWidth, Math.round((h - arrowHeight) / 2));
	
	        textInput.setActualSize(w - arrowWidth - 2, h);
	        
	        if(textInput.text == '' && _label != '')
	        	textInput.text = _label;
	    }


		/**
		 * Routine to create the search box dropdown and apply any properties needed
		 */
		private var creatingDropdown:Boolean = false;
	    private function createDropdown():void
	    {
	        if (creatingDropdown)
	            return;
	
	        creatingDropdown = true;
	
	        _dropdown = dropdownFactory.newInstance();
	        _dropdown.focusEnabled = false;
	        _dropdown.owner = this;
	        _dropdown.moduleFactory = moduleFactory;
	        _dropdown.width = 180;
	        _dropdown.height = 200;
	        
	        if(_searchDataProvider)
		        _dropdown.searchDataProvider = _searchDataProvider;
		        
		    if(_itemRenderer)
		    	_dropdown.listItemRenderer = _itemRenderer;
	
	        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_3_0)
	            _dropdown.styleName = this;
	        else
	            _dropdown.styleName = new StyleProxy(this, {}); 
	        
	        _dropdown.visible = false;
	
	        _dropdown.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, dropdown_mouseDownOutsideHandler);
	        _dropdown.addEventListener(FlexMouseEvent.MOUSE_WHEEL_OUTSIDE, dropdown_mouseDownOutsideHandler);
	        _dropdown.addEventListener('searchStart', searchStart_handler);
	        _dropdown.addEventListener('resultsClick', resultsClick_handler);
	        
	        creatingDropdown = false;
	    }

		/**
		 * Opens the search box
		 */
	    public function open():void
	    {
	        displayDropdown(true);
	    }
	
		/**
		 * Closes the search box
		 */
	    public function close():void
	    {
	        displayDropdown(false);
	    }


		/**
		 * Function and variables to handle displaying the dropdown search box
		 */
	    private var openPos:Number = 0;
    	private var addedToPopupManager:Boolean = false;
    	mx_internal var showingDropdown:Boolean = false;
    	
	    private function displayDropdown(show:Boolean, triggerEvent:Event = null):void
	    {
	        if (!_enabled)
	            return;
	
	        if (show == showingDropdown)
	            return;
	
	        if (!addedToPopupManager)
	        {
	            addedToPopupManager = true;
	            PopUpManager.addPopUp(_dropdown, this, false);
	        }
	        else
	            PopUpManager.bringToFront(_dropdown);
	
	        var point:Point = new Point(unscaledWidth - downArrowButton.width,0);
	        point = localToGlobal(point);
	        if (show)
	        {
	            var dd:LookupSearchBox = dropdown;
	
	            point = dd.parent.globalToLocal(point);
	            dd.visible = show;
	            dd.scaleX = scaleX;
	            dd.scaleY = scaleY;
	
	            var xVal:Number = point.x;
	            var yVal:Number = point.y;
	
	            var screen:Rectangle = systemManager.screen;
	
	            if (screen.width > dd.getExplicitOrMeasuredWidth() + point.x &&
	                screen.height < dd.getExplicitOrMeasuredHeight() + point.y)
	            {
	                xVal = point.x
	                yVal = point.y - dd.getExplicitOrMeasuredHeight();
	                openPos = 1;
	            }
	            else if (screen.width < dd.getExplicitOrMeasuredWidth() + point.x &&
	                     screen.height < dd.getExplicitOrMeasuredHeight() + point.y)
	            {
	                xVal = point.x - dd.getExplicitOrMeasuredWidth() + downArrowButton.width;
	                yVal = point.y - dd.getExplicitOrMeasuredHeight();
	                openPos = 2;
	            }
	            else if (screen.width < dd.getExplicitOrMeasuredWidth() + point.x &&
	                     screen.height > dd.getExplicitOrMeasuredHeight() + point.y)
	            {
	                xVal = point.x - dd.getExplicitOrMeasuredWidth() + downArrowButton.width;
	                yVal = point.y + unscaledHeight;
	                openPos = 3;
	            }
	            else
	                openPos = 0;
	
	            UIComponentGlobals.layoutManager.validateClient(dd, true);
	            dd.move(xVal, yVal);
	            Object(dd).setActualSize(dd.getExplicitOrMeasuredWidth(),dd.getExplicitOrMeasuredHeight());
	
	        }
	        else
	        {
	            _dropdown.visible = false;
	        }
	
	        showingDropdown = show;
	
	        var event:DropdownEvent =
	            new DropdownEvent(show ? DropdownEvent.OPEN : DropdownEvent.CLOSE);
	        event.triggerEvent = triggerEvent;
	        dispatchEvent(event);
	    }

	    mx_internal function isShowingDropdown():Boolean
	    {
	        return showingDropdown;
	    }
	    
	    /**
	    * Handle when the component loses focus
	    */
	    override protected function focusOutHandler(event:FocusEvent):void
	    {
	        if (showingDropdown && event != null)
	            displayDropdown(false);
	
	        super.focusOutHandler(event);
	    }	    

	    override protected function downArrowButton_buttonDownHandler(event:FlexEvent):void
	    {
	        callLater(displayDropdown, [ !showingDropdown, event ]);

	        downArrowButton.phase = "up";
	    }

	    private function dropdown_mouseDownOutsideHandler(event:MouseEvent):void
	    {
	    	if(_debug) Logger.info('MouseDownOutside');
	    	
	        if (! hitTestPoint(event.stageX, event.stageY, true))
	            displayDropdown(false, event);
	    }

	    private function textInput_textInputHandler(event:TextEvent):void
	    {

	    }
	    
	    private function searchStart_handler(event:Event):void
	    {
	    	if(_debug) Logger.info('Search Start', _dropdown.searchTerm);
	    	
	    	dispatchEvent( new Event( 'searchStart' ) );
	    }

		private function resultsClick_handler(event:ListEvent):void
		{	    	
			label = _searchDataProvider[event.rowIndex].label;			
	    	dataValue = _searchDataProvider[event.rowIndex].value;
			selectedData = _searchDataProvider[event.rowIndex];
			
			displayDropdown(false);
			
	    	if(_debug) Logger.info('Results Click', event.rowIndex, dataValue, selectedData);			
		}
		
	}
}