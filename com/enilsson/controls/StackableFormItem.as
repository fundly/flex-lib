package com.enilsson.controls
{
	import flash.text.TextLineMetrics;
	
	import mx.containers.FormItem;
	import mx.core.IUIComponent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	[Style(name="infoBtnGap", type="Number", inherit="no")]
	[Style(name="infoBtnStyleName", type="String", inherit="no")]

	public class StackableFormItem extends FormItem
	{
		public function StackableFormItem()
		{
			super();
			
			setStyles();
		}

		private function setStyles():void
		{
			if (!StyleManager.getStyleDeclaration("StackableFormItem")) {
	            var componentLayoutStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
	            componentLayoutStyles.defaultFactory = function():void {
					this.infoBtnGap = 30,
					this.infoBtnStyleName = 'infoBtnStyleName'
	            }
	            StyleManager.setStyleDeclaration("StackableFormItem", componentLayoutStyles, true);
	        }
		}

		/**
		 * Set the component to stack the label and children
		 */
		private var _stacked:Boolean = false;
		public function get stacked():Boolean
		{
			return _stacked;
		}
		
		[Inspectable(type="Boolean")]
		public function set stacked(value:Boolean):void
		{
			_stacked = value;
			
			invalidateDisplayList();
		}
		
		/**
		 * Create the infoBtn if needed, and assign its toolTip
		 */
		private var _infoBtn:InfoBtn;
		public function set info(value:String):void
		{
			_infoBtn = new InfoBtn();
			_infoBtn.text = value;
			
			rawChildren.addChild(_infoBtn);
			
			invalidateDisplayList();
		}
		
		
		/**
		 * Display list function to override the base layout and move them to the desired positions
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(stacked)
			{
				// get some variables about the label dimensions
				var textDims:TextLineMetrics = itemLabel.measureText(label);
				var measuredLabelWidth:Number = itemLabel.getExplicitOrMeasuredWidth() + getStyle("indicatorGap");
				var styledLabelWidth:Number = getStyle('labelWidth') + getStyle("indicatorGap");
				var labelHeight:Number = textDims.height + 1;
				// set the width the component children are set from the left hand side
				var extraWidth:Number = measuredLabelWidth > styledLabelWidth ? measuredLabelWidth : styledLabelWidth;
				// set some variables for moving the display children
				var n:Number = numChildren;
        		var child:IUIComponent;
        		var componentHeight:Number = labelHeight;
				// loop through the display children and move them to the right spot
				for (var i:Number = 0; i < n; i++)
				{
					child = IUIComponent(getChildAt(i));
					
					if(child.x - extraWidth <= 0)
						child.move((child.x - extraWidth), (child.y + labelHeight));
					
					componentHeight = componentHeight + child.height > componentHeight ? componentHeight + child.height : componentHeight;
				}
				// set the new height of the component
				height = componentHeight;
				// adjust the size of the label
				itemLabel.setActualSize(textDims.width + 5, itemLabel.height);
				itemLabel.move(0,0);
				// loop through the rawchildren to alter the required indicator
				var requiredIndicator:*;
				for ( i = 0; i < this.rawChildren.numChildren; i++)
				{
					var rChild:* = this.rawChildren.getChildAt(i);

					if( rChild.name.match('FormItem_Required') !== null )
					{
						rChild.move(textDims.width + (getStyle('indicatorGap') - 5), (labelHeight/2 - rChild.height/2));
						requiredIndicator = rChild;
					}
				}
				
				if(_infoBtn)
				{
					_infoBtn.styleName = getStyle('infoBtnStyleName');
					
					_infoBtn.setActualSize(
						_infoBtn.getExplicitOrMeasuredWidth(),
						_infoBtn.getExplicitOrMeasuredHeight()
					);
					if(requiredIndicator)
					{
						_infoBtn.move(
							requiredIndicator.x + requiredIndicator.width + getStyle('indicatorGap'), 
							labelHeight/2 - _infoBtn.height/2 - 1
						);	
					}
					else
					{
						_infoBtn.move(
							textDims.width + getStyle('indicatorGap') - 5, 
							labelHeight/2 - _infoBtn.height/2 - 1
						);
					}					
				}
			}
			else
			{
				setStyle('paddingRight', getStyle('infoBtnGap'));
				
				if(_infoBtn)
				{					
					_infoBtn.styleName = getStyle('infoBtnStyleName');
					
					_infoBtn.setActualSize(
						_infoBtn.getExplicitOrMeasuredWidth(), 
						_infoBtn.getExplicitOrMeasuredHeight()
					);
					_infoBtn.move(
						width - getStyle('infoBtnGap') + _infoBtn.width/2, 
						height/2 - _infoBtn.height/2 - 1
					);					
				}
			}			
		}
	}
}