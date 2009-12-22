package com.enilsson.controls
{
	import com.enilsson.events.enPaginationEvent;
	
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.controls.LinkButton;
	import mx.controls.Text;
	
	[Event(name="linkClick", type="com.enilsson.events.enPaginationEvent")]

	public class enPagination extends HBox
	{
		private var _numRows:int;
		private var _currPage:int;
		private var _rowsPerPage:int;
		
		public function enPagination()
		{
			super();
			
			setStyle('verticalAlign', 'middle');
			setStyle('horizontalGap', 1);
			setStyle('paddingTop', 0);
			setStyle('paddingBottom', 0);
			setStyle('paddingLeft', 0);
			setStyle('paddingRight', 0);	
		}
		
		public function createLinks(numRows:int, currPage:int, rowsPerPage:int=200, numLinks:int=5):void
		{
			this.visible = false;
			
			removeAllChildren();
			
			_numRows = numRows;
			_currPage = currPage;
			_rowsPerPage = rowsPerPage;
			
			if(numRows > 0) {
				var finalPage:int = Math.round(_numRows/_rowsPerPage);
				numLinks = finalPage < numLinks ? finalPage : numLinks;
				var middleInt:int = Math.ceil(numLinks/2);
				var startInt:int = currPage > middleInt ? currPage - middleInt + 1 : 1;
				startInt = currPage > finalPage - numLinks + 1 ? finalPage - numLinks + 1 : startInt;
				
				var startLink:LinkButton = new LinkButton();
				startLink.label = '<<';
				startLink.styleName = this;
				startLink.toolTip = 'Jump to the start';
				startLink.addEventListener(MouseEvent.CLICK, clickHandler);
				addChild(startLink);
				if(currPage == 1){ startLink.enabled = false; }
			}
			
			var prevLink:LinkButton = new LinkButton();
			prevLink.label = '<';
			prevLink.setStyle('paddingRight',3);
			prevLink.toolTip = 'Previous page';
			prevLink.styleName = this;
			prevLink.addEventListener(MouseEvent.CLICK, clickHandler);			
			addChild(prevLink);	
			if(currPage == 1){ prevLink.enabled = false; }	

			if(numRows > 0) {
				if(startInt > 1){
					var startDots:Text = new Text();
					startDots.text = '...';
					addChild(startDots);				
				}
	
				for(var i:int=startInt; i<(numLinks+startInt); i++){
					var pageLink:LinkButton = new LinkButton();
					pageLink.styleName = this;
					pageLink.label = i.toString();
					pageLink.addEventListener(MouseEvent.CLICK, clickHandler);
					if(currPage == i){ pageLink.enabled = false; }
					addChild(pageLink);
				}			
	
				if(currPage < finalPage - numLinks + 1){
					var endDots:Text = new Text();
					endDots.text = '...';
					addChild(endDots);				
				}
			}

			var nextLink:LinkButton = new LinkButton();
			nextLink.label = '>';
			nextLink.setStyle('paddingLeft',2);
			nextLink.toolTip = 'Next page';
			nextLink.styleName = this;
			nextLink.addEventListener(MouseEvent.CLICK, clickHandler);
			if(currPage == finalPage){ nextLink.enabled = false; }
			addChild(nextLink);
			
			if(numRows > 0) {
				var endLink:LinkButton = new LinkButton();
				endLink.label = '>>';
				endLink.toolTip = 'Jump to the end';
				endLink.styleName = this;
				endLink.addEventListener(MouseEvent.CLICK, clickHandler);			
				if(currPage == finalPage){ endLink.enabled = false; }
				addChild(endLink);
			}	
			
			this.visible = true;					
		}

		private function clickHandler(e:MouseEvent):void
		{
			var action:int = 0;
			
			switch(e.currentTarget.label){
				case '<<' : 
					action = 1;
				break;
				case '<' :
					action = _currPage - 1;
				break;
				case '>' :
					action = _currPage + 1;
				break;
				case '>>' :
					action = Math.round(_numRows/_rowsPerPage);
				break;	
				default :
					action = parseInt(e.currentTarget.label);
				break;			
			}
			
			this.dispatchEvent(new enPaginationEvent(enPaginationEvent.PAGE_ACTION, action));
		}

	}

}