package com.enilsson.graphics.skins
{
	import mx.core.UIComponent;
	import mx.skins.halo.ScrollTrackSkin;

	public class PaginatorTrackSkin extends ScrollTrackSkin
	{
		public function PaginatorTrackSkin()
		{
			super();
		}

		override protected function updateDisplayList(w:Number, h:Number):void
		{
            super.updateDisplayList(w, h);
            
            var scrollComponent:UIComponent = this.parent as UIComponent;
            //left/top
            scrollComponent.getChildAt(1).visible = false;
            scrollComponent.getChildAt(1).height = 0;
            //right/bottom
            scrollComponent.getChildAt(3).visible = false;
            scrollComponent.getChildAt(3).height = 0;
        }

		
	}
}