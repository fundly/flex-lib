// Paginator component
// Original: WAIPaginator, http://www.darklump.co.uk/blog/?p=112
// Adapted by James Nicol, www.enilsson.com, September 2008

package com.enilsson.controls
{
	
import com.enilsson.events.PaginatorEvent;

import flash.events.MouseEvent;

import mx.containers.Canvas;
import mx.containers.HBox;
import mx.containers.VBox;
import mx.controls.Button;
import mx.controls.HScrollBar;
import mx.effects.Move;
import mx.events.EffectEvent;
import mx.events.ScrollEvent;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;
import mx.utils.ObjectUtil;

import org.osflash.thunderbolt.Logger;

[Style(name="nextBtnStyleName", type="String", inherit="no")]
[Style(name="prevBtnStyleName", type="String", inherit="no")]
[Style(name="pageLinkStyleName", type="String", inherit="no")]
[Style(name="scrollerStyleName", type="String", inherit="no")]

[Event(name="pageChange", type="com.enilsson.events.PaginatorEvent")]
[Event(name="newPage", type="com.enilsson.events.PaginatorEvent")]
[Event(name="selectedIndexChanged", type="flash.events.Event")]

public class Paginator extends HBox
{
	private var _prevBtn:Button;
	private var _nextBtn:Button;
	private var _pageHolder:VBox;
	private var _linksScrollBox:Canvas;
	private var _pageLinks:HBox;
	private var _scroller:HScrollBar;
	private var _selectedBtn:Button;		
	
	public function Paginator()
	{
		super();

		setStyles();
		createPaginator();
	}	
	
	private function setStyles():void
	{
		if (!StyleManager.getStyleDeclaration("Paginator")) {
            var PaginatorStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
            PaginatorStyles.defaultFactory = function():void {
				this.nextBtnStyleName = 'nextBtnStyleName';
				this.prevBtnStyleName = 'prevBtnStyleName';
				this.pageLinkStyleName = 'pageLinkStyleName';
				this.scrollerStyleName = 'scrollerStyleName';
            }
            StyleManager.setStyleDeclaration("Paginator", PaginatorStyles, true);
        }
	}
	
	/**
	 * Layout all the component elements
	 */
	private function createPaginator():void
	{
		// add the previous button
		_prevBtn = new Button();
		_prevBtn.label = _prevLabel;
		_prevBtn.styleName = getStyle('prevBtnStyleName');
		_prevBtn.addEventListener(MouseEvent.CLICK, nudgeHandler);
		addChild(_prevBtn);
		// add the holding box for the page links and the scroller
		_pageHolder = new VBox();
		_pageHolder.setStyle('verticalGap',2);
		_pageHolder.horizontalScrollPolicy = 'off';
		addChild(_pageHolder);
		// add a box for the page links holder and the scroller
		_linksScrollBox = new Canvas();
		_linksScrollBox.horizontalScrollPolicy = 'off';
		_pageHolder.addChild(_linksScrollBox);
		// add the holding box for all the page links		
		_pageLinks = new HBox();
		_pageLinks.setStyle('horizontalGap',0);
		_linksScrollBox.addChild(_pageLinks);
		// add the scroller
		_scroller = new HScrollBar();
		_scroller.percentWidth = 100;
		_scroller.minScrollPosition = 0;
		_scroller.styleName = getStyle('scrollerStyleName');
		_pageHolder.addChild(_scroller);
		// add the next button
		_nextBtn = new Button();
		_nextBtn.label = _nextLabel;
		_nextBtn.styleName = getStyle('nextBtnStyleName');
		_nextBtn.addEventListener(MouseEvent.CLICK, nudgeHandler);		
		addChild(_nextBtn);		
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		if(_prevBtn)
		{
			var numBtns:int = _rangeCount > _pages ? _pages :  _rangeCount;
			_pageHolder.width = numBtns*_btnWidth + (numBtns-1)*_pageLinks.getStyle('horizontalGap');
			_linksScrollBox.width = _pageHolder.width;
			_pageLinks.width = _pageLinks.numChildren * _btnWidth;
			
			_prevBtn.height = _btnHeight;
			_nextBtn.height = _btnHeight;			
		}
	}


	/**
	 * @ Private
	 * Called when parameters that effect number of pages are changed
	 **/
	private function update():void
	{
		// calculate the number of page links to create
		_pages = Math.ceil(itemsTotal/itemsPerPage);
		
		// do nothing if the num of pages has not been set yet
		if(_pages == 0){ return; }
		
		// clear all the page links currently in place
		_pageLinks.removeAllChildren();
		if(_debug){ Logger.info('Pages', _pages, itemsTotal, itemsPerPage); }
		
		// loop through the number of pages and create the links
		for ( var i:int=0; i<_pages; i++ )
		{
			// create the page link button			
			var btn:Button = new Button();
			btn.width=_btnWidth;
			btn.height=_btnHeight;
        	btn.label=String(i+1) as String;
        	btn.data=i;
        	btn.addEventListener(MouseEvent.CLICK, pageClickHandler);
        	btn.styleName = getStyle('pageLinkStyleName');
			// the button to the page links box
			_pageLinks.addChildAt(btn, i);
		}
		
		// assign some stylenames
		_prevBtn.styleName = getStyle('prevBtnStyleName');
		_nextBtn.styleName = getStyle('nextBtnStyleName');
		
		// some deugging
		if(_debug) Logger.info('Page Links', ObjectUtil.toString(_pageLinks.measuredWidth));
	 	
	 	// Set some variables on the scroller
	 	_scroller.styleName = getStyle('scrollerStyleName');
	 	_scroller.invalidateDisplayList();
	 	_scroller.maxScrollPosition = _pages - rangeCount;
	 	_scroller.lineScrollSize = _btnWidth;
	 	_scroller.pageSize = rangeCount;
	 	_scroller.pageScrollSize = rangeCount - 1; 
		_scroller.scrollPosition = -(_pageLinks.x / _btnWidth);
		_scroller.includeInLayout = _pages > rangeCount;
		_scroller.addEventListener(ScrollEvent.SCROLL, scrollHandler);
		_scroller.addEventListener(MouseEvent.MOUSE_UP, scrollerMouseUpHandler);	 	
	 	
	 	// set the selected index
	 	selectedIndex = Math.min(selectedIndex, _pages-1);

	 	// force updateDisplayList() to run
	 	this.invalidateDisplayList();
	}


	/**
	 * Page Click Event Handler
	 */	
    private function pageClickHandler(e:Event):void
    {
        if(_debug) Logger.info('PageClick Handler');
        
        var btn:Button = e.currentTarget as Button;
        selectedIndex = btn.data as int;
        
        newPageEvent(btn.data as int);
    }

    /**
	 * Next/Previous Click Event Handler
	 */	
    private function nudgeHandler(e:MouseEvent):void
    {
    	if(_debug) Logger.info('Nudge Handler');
    	
    	switch (e.target)
    	{
    		case _prevBtn:
        		if (selectedIndex > 0) --selectedIndex;
        	break;
    		case _nextBtn:
    			if (selectedIndex < _pages - 1) ++selectedIndex;
    		break;
    	}
    	
    	newPageEvent(selectedIndex);
    }
    
    /**
    * Dispatch a New Page event
    */
    private function newPageEvent(n:int):void
    {
		var evt:PaginatorEvent = new PaginatorEvent (PaginatorEvent.NEW_PAGE, true);
		evt.index = n;
		evt.itemsPerPage = itemsPerPage;
		evt.itemsTotal = itemsTotal;
		dispatchEvent(evt);    	  	
    }

    /**
	 * Scroll Event Handler
	 */	
    private function scrollHandler(e:ScrollEvent):void
    {
    	if(_debug) Logger.info('ScrollHandler', e.detail, e.position.toString());
    	
    	// if Scroll Track is clicked, wait till mouse up event
    	// else scroll Thumb gets jumpy
    	if (e.detail == "pageLeft" || e.detail == "pageRight") 
    	{
    		scrollTrackMouseDown = true;
    		return;
   		}
        movePage(-(e.position * _btnWidth));
    }


    /**
	 * fixes a issues that makes the scrollThumb jump around with
	 * clicking the scrollTrack
	 */	
	private var scrollTrackMouseDown:Boolean = false; 
    private function scrollerMouseUpHandler(e:MouseEvent):void
    {
    	if (scrollTrackMouseDown) 
    	{
    		scrollTrackMouseDown = false;
    		movePage(-Math.round(_scroller.scrollPosition * _btnWidth));
   		}
    }

    /**
	 * tween page button view
	 */	
    private function movePage(xPos:int):void
    {        	
    	// make sure move doesn't go past max range
    	var max: int =  -(_pageLinks.width -(rangeCount * _btnWidth));
    	if (xPos < max) xPos = max;

    	// make sure move doesn't go past 0
    	xPos = Math.min(0, xPos);
    	
    	var pageMove:Move = new Move();
    	
    	pageMove.target = _pageLinks;
        pageMove.end();
        pageMove.xTo = xPos; 
        pageMove.play();
        pageMove.addEventListener(EffectEvent.EFFECT_END, function():void {
        	_scroller.scrollPosition = -(_pageLinks.x / _btnWidth);
        });
        
        if(_debug){ Logger.info('PageLinks Dimensions', _pageLinks.width); }
    }

	/**
	 * The selected page index 
	 */	
	private var _selectedIndex:int = 0; 
	public function set selectedIndex (n:int):void
	{
		n = Math.max(0, n);
		// make sure Component is initialized or it throws an error
		if (this.initialized)
		{
			// set selected button
			if (_pageLinks.numChildren > 0)
			{
				var btn:Button = _pageLinks.getChildAt(n) as Button;
	            if(_selectedBtn != null)_selectedBtn.selected = false;
	            _selectedBtn = btn;
	            _selectedBtn.selected = true;
			}
            // if appropriate center selected button
            var halfRange:int = Math.round(rangeCount/2);
            if (n < halfRange -1)
            {
            	movePage(0);
            }
            else if (n > (_pages - halfRange))          
			{
				movePage(-(_pages - rangeCount) * _btnWidth);
			} 
			else
			{
				movePage( -Math.round((n+1) * _btnWidth) + (halfRange * _btnWidth));
			}
			// disable/enable next/previous buttons if selectedIndex is first or last page
			_prevBtn.enabled = (n == 0 || _pageLinks.numChildren == 0) ? false : true;
			_nextBtn.enabled = (n == _pages-1) ? false : true;
			
			// dispatch a PaginatorEvent					
			var evt:PaginatorEvent = new PaginatorEvent (PaginatorEvent.PAGE_CHANGE, true);
			evt.index = n;
			evt.itemsPerPage = itemsPerPage;
			evt.itemsTotal = itemsTotal;
			dispatchEvent(evt);
   		}

   		// store selected index
        _selectedIndex = n;	
        
        dispatchEvent( new Event('selectedIndexChanged') );
	}

	[Bindable(event="selectedIndexChanged")]
	public function get selectedIndex ():int
	{
		return _selectedIndex;
	}


	/**
	 * How many page buttons to display 
	 */
	private var _rangeCount:int = 0;	
	[Bindable]
	public function set rangeCount (value:int):void
	{
		_rangeCount = value;
		_scroller.maxScrollPosition = pages - rangeCount;
		_scroller.scrollPosition = Math.min(_scroller.scrollPosition, _scroller.maxScrollPosition);
		movePage(-Math.round(_scroller.scrollPosition * _btnWidth));
		
		invalidateDisplayList();
	}
	public function get rangeCount ():int
	{
		return _rangeCount;
	}


	/**
	 * currently read only. Maybe there's a usecase for setting pages dynamically?
	 */	
	[Bindable]
	private var _pages:int;	 
	
	public function get pages ():int
	{
		return _pages;
	}

	/**
	 * how many list items per page 
	 */	
	private var _itemsPerPage:int = 0
	public function set itemsPerPage (n:int):void
	{
		if (n == itemsPerPage) return;
		_itemsPerPage = n;
		update();
	}		
	public function get itemsPerPage ():int
	{
		return _itemsPerPage;
	}

	/**
	 * Total amount of items to navigate 
	 */
	private var _itemsTotal:int = 0;	 
	public function set itemsTotal (n:int):void
	{
		if (n == itemsTotal) return;
		_itemsTotal = n;
		update();
	}
	public function get itemsTotal ():int
	{
		return _itemsTotal;
	}

    /**
     *  @private
     *  Set or get the height of the buttons
     */
	private var _btnHeight:int = 30;
   	public function get buttonHeight():int
    {
        return _btnHeight;
    }
    public function set buttonHeight(value:int):void
    {
		_btnHeight = value;	
    }		

    /**
     *  @private
     *  Set or get the width of the page link buttons
     */
	private var _btnWidth:int = 26;
   	public function get pageLinkButtonWidth():int
    {
        return _btnWidth;
    }
    public function set pageLinkButtonWidth(value:int):void
    {
		_btnWidth = value;
		
		invalidateDisplayList();	
    }		

    /**
     *  @private
     *  Set or get the label for the Previous Btn
     */
	private var _prevLabel:String = 'Prev';
   	public function get prevLabel():String
    {
        return _prevLabel;
    }
    public function set prevLabel(value:String):void
    {
		_prevLabel = value;	
    }		
	
    /**
     *  @private
     *  Set or get the label for the Next Btn
     */
	private var _nextLabel:String = 'Next';
   	public function get nextLabel():String
    {
        return _nextLabel;
    }
    public function set nextLabel(value:String):void
    {
		_nextLabel = value;	
    }	

	private var _debug:Boolean = false;
	public function set debugMode(value:Boolean):void
	{
		_debug = value;
	}	
	
}
	
}