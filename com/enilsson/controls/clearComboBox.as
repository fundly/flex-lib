package com.enilsson.controls
{
	import flash.display.Shape;
	
	import mx.controls.ComboBase;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.IDataRenderer;

	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextLineMetrics;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import mx.collections.ArrayCollection;
	import mx.collections.CursorBookmark;
	import mx.controls.dataGridClasses.DataGridListData;
	import mx.controls.listClasses.BaseListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.controls.listClasses.ListBase;
	import mx.controls.listClasses.ListData;
	import mx.core.ClassFactory;
	import mx.core.FlexVersion;
	import mx.core.EdgeMetrics;
	import mx.core.IDataRenderer;
	import mx.core.IFactory;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.core.UIComponentGlobals;
	import mx.core.mx_internal;
	import mx.effects.Tween;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.DropdownEvent;
	import mx.events.FlexEvent;
	import mx.events.FlexMouseEvent;
	import mx.events.ListEvent;
	import mx.events.ScrollEvent;
	import mx.events.ScrollEventDetail;
	import mx.managers.PopUpManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.styles.StyleProxy;
	
	import org.osflash.thunderbolt.Logger;
	
	use namespace mx_internal;
	
	[Style(name="paddingTop", type="Number", format="Length", inherit="no")]
	[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]
	[Style(name="paddingLeft", type="Number", format="Length", inherit="no")]
	[Style(name="paddingRight", type="Number", format="Length", inherit="no")]
	
	public class clearComboBox extends ComboBase implements IDataRenderer, IDropInListItemRenderer, IListItemRenderer
	{
	
		private var gutter:Number = 3;
		private var t1:Shape;
		private var t2:Shape;	
	
		public function clearComboBox()
		{
			super();
		}

	    private var selectedItemSet:Boolean;
	    private var _data:Object;
	
	    [Bindable("dataChange")]
	    [Inspectable(environment="none")]
	
	    public function get data():Object
	    {
	        return _data;
	    }
	
	    /**
	     *  @private
	     */
	    public function set data(value:Object):void
	    {
	        var newSelectedItem:*;
	
	        _data = value;
	
	        if (_listData && _listData is DataGridListData)
	            newSelectedItem = _data[DataGridListData(_listData).dataField];
	        else if (_listData is ListData && ListData(_listData).labelField in _data)
	            newSelectedItem = _data[ListData(_listData).labelField];
	        else
	            newSelectedItem = _data;
	
	        if (newSelectedItem !== undefined && !selectedItemSet)
	        {
	            selectedItem = newSelectedItem;
	            selectedItemSet = false;
	        }
	
	        dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
	    }
	
	    //----------------------------------
	    //  listData
	    //----------------------------------
	
	    /**
	     *  @private
	     *  Storage for the listData property.
	     */
	    private var _listData:BaseListData;
	
	    [Bindable("dataChange")]
	    [Inspectable(environment="none")]
	
	    /**
	     *  When a component is used as a drop-in item renderer or drop-in item 
	     *  editor, Flex initializes the <code>listData</code> property of the 
	     *  component with the appropriate data from the List control. The 
	     *  component can then use the <code>listData</code> property and the 
	     *  <code>data</code> property to display the appropriate information 
	     *  as a drop-in item renderer or drop-in item editor.
	     *
	     *  <p>You do not set this property in MXML or ActionScript; Flex sets it 
	     *  when the component
	     *  is used as a drop-in item renderer or drop-in item editor.</p>
	     *
	     *  @see mx.controls.listClasses.IDropInListItemRenderer
	     */
	    public function get listData():BaseListData
	    {
	        return _listData;
	    }
	
	    /**
	     *  @private
	     */
	    public function set listData(value:BaseListData):void
	    {
	        _listData = value;
	    }

	    override public function styleChanged(styleProp:String):void
	    {
	        //destroyDropdown();
	        
	      	super.styleChanged(styleProp);
	    }
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			downArrowButton.visible = false;
			border.visible = false;
			
			textInput.setStyle('borderStyle', 'none');
			textInput.setStyle('backgroundAlpha', 0);
			textInput.setStyle('focusAlpha', 0);
			textInput.setStyle('paddingLeft', getStyle('paddingLeft'));
			textInput.setStyle('fontWeight', getStyle('fontWeight'));
			
			
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(height > 0){
				drawArrows();
			}
			Logger.info('Dims', width, height);
			
		}

		private function drawArrows():void
		{
			if(t1){ return; }
				
			var triangleHeight:uint = 6;
			var rightSide:Number = width - gutter;
			var bottom:Number = height - gutter;
			
			t1 = new Shape();
			t1.graphics.beginFill(0x262626);
			t1.graphics.moveTo(rightSide - triangleHeight/2, gutter);
			t1.graphics.lineTo(rightSide, triangleHeight + gutter);
			t1.graphics.lineTo(rightSide - triangleHeight, triangleHeight + gutter);
			t1.graphics.lineTo(rightSide - triangleHeight/2, gutter);
			addChild(t1);	

			t2 = new Shape();
			t2.graphics.beginFill(0x262626);
			t2.graphics.moveTo(rightSide - triangleHeight, bottom - triangleHeight);
			t2.graphics.lineTo(rightSide, bottom - triangleHeight);
			t2.graphics.lineTo(rightSide - triangleHeight/2, bottom);
			t2.graphics.lineTo(rightSide - triangleHeight, bottom - triangleHeight);
			addChild(t2);	
		}


		//----------------------------------
	    //  dropDownStyleFilters
	    //----------------------------------
	
	    /**
	     *  The set of styles to pass from the ComboBox to the dropDown.
	     *  Styles in the dropDownStyleName style will override these styles.
	     *  @see mx.styles.StyleProxy
	     *  @review
	     */
		protected function get dropDownStyleFilters():Object
		{
	    	return null;
	    }


	    private var _dropdown:ListBase;

	    /**
	     *  @private
	     */
	    mx_internal function hasDropdown():Boolean
	    {
	        return _dropdown != null;
	    }

	    /**
	     *  @private
	     */

		
	}
}