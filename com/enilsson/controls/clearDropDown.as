package com.enilsson.controls
{

import flash.display.Shape;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.text.TextLineMetrics;

import mx.controls.Button;
import mx.controls.ComboBox;
import mx.controls.listClasses.ListBase;
import mx.core.mx_internal;
import mx.events.ListEvent;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;

use namespace mx_internal;

[Style(name="arrowColor",type="uint",format="Color",inherit="no")]
[Style(name="standardTextColor",type="uint",format="Color",inherit="no")]
[Style(name="noSelectionTextColor",type="uint",format="Color",inherit="no")]
[Style(name="triangleHeight", type="Number", inherit="no")]

public class clearDropDown extends ComboBox
{
	private var gutter:Number = 4;
	private var _arrows:Boolean = false;
	private var t1:Shape;
	private var t2:Shape;
	private var arrowBtn:Button;
	private var _dropDown:ListBase;	
	private var _showDropDown:Boolean = true;	
	private var _defaultTextColor:uint;
	
	public function clearDropDown()
	{
		super();
		
		setStyle('focusAlpha', 0);
		setStyle('paddingBottom',2);
		setStyle('openDuration',0);
		setStyle('closeDuration',0);
		
		setStyles();
		
		this.addEventListener(MouseEvent.CLICK, clickHandler);
		this.addEventListener(ListEvent.CHANGE, moveArrows);
		this.addEventListener('collectionChange', dataChangeHandler);
	}
	
	private function setStyles():void
	{
		if (!StyleManager.getStyleDeclaration("clearDropDown")) {
            var componentLayoutStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
            componentLayoutStyles.defaultFactory = function():void {
				this.arrowColor = 0x666666,
				this.standardTextColor = 0x666666,
				this.noSelectionTextColor = 0xCCCCCC,
				this.triangleHeight = 4
            }
            StyleManager.setStyleDeclaration("clearDropDown", componentLayoutStyles, true);
        }
	}
	
	override protected function createChildren():void
	{
		super.createChildren();
		
		border.visible = false;
		downArrowButton.visible = false;

		textInput.setStyle('borderStyle', 'none');		
		textInput.setStyle('backgroundAlpha', 0);
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		if(selectedIndex < 0){
			textInput.text = 'None';
			textInput.setStyle('color', getStyle('noSelectionTextColor'));
		} else {
			textInput.setStyle('color',getStyle('standardTextColor'));
		}
		
		if(height > 0 && textInput.textWidth > 0){
			drawArrows();	
		}
	}
	
	private function dataChangeHandler(event:Event):void
	{
		this.invalidateDisplayList();
	}
	
	private function clickHandler(event:MouseEvent):void
	{
		// get the dropdown from the extended ComboBox class
		_dropDown = super.dropdown;
    	// open it
		super.open();
		if(_showDropDown){
			// if the dropdown is too stay open move it up so it covers the textInput			
        	var sel:int = _dropDown.selectedIndex;
       		var htMove:Number = sel > 1 ? 2 : 1;
			_dropDown.move(_dropDown.x, _dropDown.y - (height * htMove) + 4);
		} else {
			// or close it and highlight the text
			super.close();
			textInput.setFocus();
			textInput.setSelection(0, textInput.text.length);
		}	    	
	}
    
    override protected function focusInHandler(event:FocusEvent):void
    {	
		// get the dropdown from the extended ComboBox class
		_dropDown = super.dropdown;
    	// open it
		super.open();
		if(_showDropDown){
			// if the dropdown is too stay open move it up so it covers the textInput			
        	var sel:int = _dropDown.selectedIndex;
       		var htMove:Number = sel > 1 ? 2 : 1;
			_dropDown.move(_dropDown.x, _dropDown.y - (height * htMove) + 4);
		} else {
			// or close it and highlight the text
			super.close();
			textInput.setFocus();
			textInput.setSelection(0, textInput.text.length);
		}	    	
 		// run the focus handler as normal
 		super.focusInHandler(event);
    }
    
    /**
    * @private
    * Remove the arrows and redraw
    */
    private function moveArrows(e:ListEvent=null):void 
    {
    	if(t1){
	    	textInput.removeChild(t1);
	    	textInput.removeChild(t2);
	    	textInput.removeChild(arrowBtn);
	    	_arrows = false;
	    	drawArrows();
	    }
    }

    /**
    * @private
    * Draw the arrows based on the width the textInput
    */
	private function drawArrows():void
	{			
		// only run this if they have not already been drawn
		if(_arrows){
			return;
		}
		// adjust the text highlight as needed
		if(!_showDropDown){
			textInput.setSelection(0, textInput.text.length);
		}	    	
		// grab the dimensions of the text as the input needs to be a couple of cycles behind
		var mText:TextLineMetrics = textInput.measureText(textInput.text);
		// set the dimensions of the arrows
		var triangleHeight:uint = getStyle('triangleHeight');
		var rightSide:Number = mText.width > textInput.width ? textInput.width + 15 : mText.width + 15;
		rightSide = rightSide < 50 ? 50 : rightSide;
		var top:Number = 2;
		var bottom:Number = mText.height;
		// draw the upper triangle
		t1 = new Shape();
		textInput.addChild(t1);	
		t1.graphics.beginFill(getStyle('textColor'));
		t1.graphics.moveTo(rightSide - triangleHeight/2, top);
		t1.graphics.lineTo(rightSide, triangleHeight + top);
		t1.graphics.lineTo(rightSide - triangleHeight, triangleHeight + top);
		t1.graphics.lineTo(rightSide - triangleHeight/2, top);
		// draw the lower triangle
		t2 = new Shape();
		textInput.addChild(t2);
		t2.graphics.beginFill(getStyle('textColor'));
		t2.graphics.moveTo(rightSide - triangleHeight, bottom - triangleHeight);
		t2.graphics.lineTo(rightSide, bottom - triangleHeight);
		t2.graphics.lineTo(rightSide - triangleHeight/2, bottom);
		t2.graphics.lineTo(rightSide - triangleHeight, bottom - triangleHeight);
		// draw a clear button over the top so it can be clicked
		arrowBtn = new Button();
		arrowBtn.width = triangleHeight * 2 + gutter - 2;
		arrowBtn.height = height;
		arrowBtn.setStyle('cornerRadius', 0);
		arrowBtn.alpha = 0;
		arrowBtn.move(width - arrowBtn.width,0);
		textInput.addChild(arrowBtn);
		arrowBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { 
			e.stopPropagation();
			if(isShowingDropdown){
				close();
			} else {
				open();
			} 
		});	
		// set the flag so this is only run once
		_arrows = true;
	}

	public function set showDropDown(value:Boolean):void
	{
		_showDropDown = value;
		
		this.invalidateDisplayList();
	}

    override public function set selectedIndex(value:int):void
    {
        super.selectedIndex = value;

		moveArrows();
    }

}

}