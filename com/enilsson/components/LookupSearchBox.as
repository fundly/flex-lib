package com.enilsson.components
{
	import com.enilsson.graphics.Spinner;
	
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.controls.List;
	import mx.controls.TextInput;
	import mx.core.ClassFactory;
	import mx.core.IFlexModuleFactory;
	import mx.core.IFontContextComponent;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.graphics.RectangularDropShadow;
	import mx.managers.IFocusManagerComponent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.utils.GraphicsUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	use namespace mx_internal;
	
	[Style(name="backgroundAlpha", type="Number", inherit="no")]
	[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]
	[Style(name="borderThickness", type="Number", format="Length", inherit="no")]
	[Style(name="borderColor", type="uint", format="Color", inherit="no")]
	[Style(name="cornerRadius", type="Number", format="Length", inherit="no")]
	[Style(name="headerColors", type="Array", arrayType="uint", format="Color", inherit="yes")]
	[Style(name="textInputStyleName", type="String", inherit="no")]
	[Style(name="listStyleName", type="String", inherit="no")]
	[Style(name="dropShadowEnabled", type="Boolean", inherit="no")]
	
	[Event(name="searchStart", type="flash.events.Event")]
	[Event(name="resultsClick", type="mx.events.ListEvent")]

	public class LookupSearchBox extends UIComponent implements IFocusManagerComponent, IFontContextComponent
	{
		mx_internal var background:UIComponent;
		mx_internal var border:UIComponent;
    	mx_internal var headerDisplay:UIComponent;
    	mx_internal var calHeader:UIComponent;
    	mx_internal var dropShadow:RectangularDropShadow;
    	
    	private var textInput:TextInput;
    	private var searchIcon:Image;
    	private var searchResults:List;
    	private var spinner:Spinner;
    	private var headerHeight:Number = 30;
    	private var setTextFocus:Boolean = false;

		[Embed (source="../assets/images/search.png")]
		private static var SEARCH_ICON:Class;
		
		public function LookupSearchBox()
		{
			super();
			
			setStyles();
			
			addEventListener(FlexEvent.SHOW, showHandler);
		}

		private function setStyles():void
		{
			if (!StyleManager.getStyleDeclaration("LookupSearchBox")) {
	            var ComponentStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
	            ComponentStyles.defaultFactory = function():void {
	            	this.backgroundAlpha = 1;
					this.backgroundColor = 0xFFFFFF;
					this.borderThickness = 1;
					this.borderColor = 0xB7BABC;
					this.cornerRadius = 6;
					this.headerColors = [0xE1E5EB, 0xF4F5F7];
					this.textInputStyleName = 'textInputStyleName';
					this.listStyleName = 'listStyleName';
					this.dropShadowEnabled = true;					
	            }
	            StyleManager.setStyleDeclaration("LookupSearchBox", ComponentStyles, true);
	        }
		}
		
		
		public function get fontContext():IFlexModuleFactory
		{
			return null;
		}
		public function set fontContext(moduleFactory:IFlexModuleFactory):void
		{
		}
		
		/**
		 * Apply the dataProvider to the search results
		 */
		private var _searchDataProvider:ArrayCollection;
		public function set searchDataProvider(value:ArrayCollection):void
		{
			_searchDataProvider = value;
			
			if(searchResults)
			{
				searchResults.dataProvider = value;
				spinner.visible = false;
			}
		}
		public function get searchDataProvider():ArrayCollection
		{
			return _searchDataProvider;
		}
		
		/**
		 * Return the search term as listed in the text input
		 */
		public function get searchTerm():String
		{
			return textInput.text;
		}
		
		/**
		 * Assign an itemRenderer to the search results list
		 */
		private var _listItemRenderer:ClassFactory;
		public function set listItemRenderer(value:ClassFactory):void
		{
			_listItemRenderer = value;
			
			if(searchResults)
				searchResults.itemRenderer = value;
		}
		public function get listItemRenderer():ClassFactory
		{
			return _listItemRenderer;
		}

		/**
		 * Set the component to debug mode
		 */
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
		 * Create all the necessary elements of the search box
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
	        if (!background)
	        {
	            background = new UIComponent();
	            addChild(background);
	            UIComponent(background).styleName = this;
	        }
	
	        if (!border)
	        {
	            border = new UIComponent();
	            addChild(border);
	            UIComponent(border).styleName = this;
	        }

	        if (!calHeader)
	        {
	            calHeader = new UIComponent();
	            addChild(calHeader);
	            UIComponent(calHeader).styleName = this;
	        }
	        
	        if(!textInput)
	        {
	        	textInput = new TextInput();
	        	addChild(textInput);
	        	textInput.styleName = getStyle('textInputStyleName');	
	        	textInput.addEventListener(KeyboardEvent.KEY_UP, textInput_keyHandler);  
		        textInput.setFocus();
	        }
	        
	        if(!searchIcon)
	        {
	        	searchIcon = new Image();
	        	searchIcon.source = SEARCH_ICON;
	        	searchIcon.useHandCursor = true;
	        	searchIcon.buttonMode = true;
	        	addChild(searchIcon);
	        	searchIcon.addEventListener(MouseEvent.CLICK, searchIcon_clickHandler);
	        }	        
	        
	        if(!searchResults)
	        {
	        	searchResults = new List();
	        	addChild(searchResults);
	        	searchResults.styleName = getStyle('listStyleName');
	        	searchResults.setStyle('borderStyle', 'none');
	        	searchResults.addEventListener(ListEvent.ITEM_CLICK, itemClick_handler);
	        	searchResults.variableRowHeight = true;
	        	searchResults.setStyle('alternatingItemColors', [0xFFFFFF, 0xf0f0f0]);
	
	        	if(_searchDataProvider)
		        	searchResults.dataProvider = _searchDataProvider;	
		        if(_listItemRenderer)
		        	searchResults.itemRenderer = _listItemRenderer;        	
	        }
	        
	        if(!spinner)
	        {
	        	spinner = new Spinner();
	        	addChild(spinner);
		    	spinner.tickWidth = 2;
		    	spinner.setStyle('tickColor', '#33332D');
	        	spinner.visible = false;	        	
	        }
			
			if(_debug) Logger.info('SearchBox Children Created');
		}


		/**
		 * Measure and move all the children of the component, and draw any graphics needed
		 */
	    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	    {
	        super.updateDisplayList(unscaledWidth, unscaledHeight);
	
	        var borderThickness:Number = getStyle('borderThickness');
	        var cornerRadius:Number = getStyle('cornerRadius');
	        var borderColor:Number = getStyle('borderColor');
	
	        var w:Number = unscaledWidth - borderThickness*2;
	        var h:Number = unscaledHeight - borderThickness*2;
	        
	        var siWidth:Number = searchIcon.getExplicitOrMeasuredWidth();
	        var siHeight:Number = searchIcon.getExplicitOrMeasuredHeight();
	
	        searchIcon.setActualSize(siWidth, siHeight);
	        searchIcon.move(w - siWidth - borderThickness, headerHeight/2 - siWidth/2);
	        
	        textInput.setActualSize(w - siWidth - 6, headerHeight - 6);
	        textInput.move(borderThickness + 3, borderThickness + 3);
	        
	        searchResults.setActualSize(w, h - headerHeight - cornerRadius - 1);
	        searchResults.move(borderThickness, headerHeight + borderThickness + 2);
	        
			spinner.size = textInput.height - 6;
		    spinner.move(w - siWidth - borderThickness - spinner.size - 4, headerHeight/2 - spinner.size/2 + borderThickness);

	        var g:Graphics = background.graphics;
	        g.clear();
	        g.beginFill(0xFFFFFF);
	        g.drawRoundRect(0, 0, w, h, cornerRadius * 2, cornerRadius * 2);
	        g.endFill();
	        background.$visible = true;

	        g = border.graphics;
	        g.clear();
	        g.beginFill(borderColor);
	        g.drawRoundRect(0, 0, unscaledWidth, unscaledHeight, 
	                        cornerRadius * 2, cornerRadius * 2);
	        g.endFill();
	        var bgColor:uint = StyleManager.NOT_A_COLOR;
	        bgColor = 0xFFFFFF;
	        if (bgColor == StyleManager.NOT_A_COLOR)
	            bgColor = 0xFFFFFF;
	        var bgAlpha:Number = 1;
	        bgAlpha = getStyle("backgroundAlpha");
	        g.beginFill(bgColor, bgAlpha);
	        g.drawRoundRect(borderThickness, borderThickness, w, h, 
	                        cornerRadius > 0 ? (cornerRadius - 1) * 2 : 0,
	                        cornerRadius > 0 ? (cornerRadius - 1) * 2 : 0);
	        g.endFill();
	        border.visible = true;
	
	        var headerColors:Array = getStyle("headerColors");
	        StyleManager.getColorNames(headerColors);
	
	        var calHG:Graphics = calHeader.graphics;
	        calHG.clear();
	        var matrix:Matrix = new Matrix();
	        matrix.createGradientBox(w, headerHeight, Math.PI / 2, 0, 0);
	        calHG.beginGradientFill(GradientType.LINEAR,
	                                [0xE1E5EB, 0xF4F5F7],
	                                [1.0,1.0],
	                                [ 0, 0xFF ],
	                                matrix);
	        GraphicsUtil.drawRoundRectComplex(calHG, borderThickness, borderThickness,
	            w, headerHeight, cornerRadius, cornerRadius, 0, 0);
	        calHG.endFill();
	        calHG.lineStyle(borderThickness, borderColor);
	        calHG.moveTo(borderThickness, headerHeight + borderThickness);
	        calHG.lineTo(w + borderThickness, headerHeight + borderThickness);
	
	        calHeader.$visible = true;		
	  
	        var ds:Boolean = getStyle("dropShadowEnabled");
	        graphics.clear();
	        if (ds)
	        {
	            // Calculate the angle and distance for the shadow
	            var distance:Number = 4;
	            var angle:Number = 90;
	
	            // Create a RectangularDropShadow object, set its properties, and
	            // draw the shadow
	            if (!dropShadow)
	                dropShadow = new RectangularDropShadow();
	
	            dropShadow.distance = distance;
	            dropShadow.angle = angle;
	            dropShadow.color = 0x333333;
	            dropShadow.alpha = 0.4;
	
	            dropShadow.tlRadius = cornerRadius;
	            dropShadow.trRadius = cornerRadius;
	            dropShadow.blRadius = cornerRadius;
	            dropShadow.brRadius = cornerRadius;
	
	            dropShadow.drawShadow(graphics, borderThickness, borderThickness, w, h);
	        }
	        
	        textInput.setFocus();
	        
	        if(_debug) Logger.info('Search Box Display Updated');
		}
		
		
		/**
		 * Handle what to do when the box is shown
		 */
		private function showHandler(event:FlexEvent):void
		{
			if(_debug) Logger.info('Search Box Show');
			
			if(textInput)
				textInput.setFocus();
			
			if(spinner)
				spinner.visible = false;
		}

		
		/**
		 * Dispatch an event when the user initiates a search by clicking enter in the textInput
		 */
		private function textInput_keyHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ENTER)
			{
				dispatchEvent( new Event( 'searchStart' ) );
				spinner.visible = true;
			}		
		}
		
		
		/**
		 * Dispatch an event when the user initiates a search by clicking enter in the textInput
		 */
		private function searchIcon_clickHandler(event:MouseEvent):void
		{
			dispatchEvent( new Event( 'searchStart' ) );
			spinner.visible = true;
		}
		
		/**
		 * Dispatch the item click event up to the parent
		 */
		private function itemClick_handler(event:ListEvent):void
		{
	        var e:ListEvent = new ListEvent( 'resultsClick' );        
	        e.rowIndex = event.rowIndex;
	        dispatchEvent(e);                   
		}
		
	}
}