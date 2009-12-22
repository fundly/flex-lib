package com.enilsson.controls
{
	import com.enilsson.graphics.enDropShadows;
	
	import mx.controls.Image;
	import mx.controls.TextInput;

	public class SearchBox extends TextInput
	{
		[Embed(source="../assets/images/search.png")] 
		[Bindable]
		private var _searchIcon:Class; 
		
		public function SearchBox()
		{
			super();
			
			setStyle('cornerRadius', 11);
			setStyle('borderStyle', 'solid');
			setStyle('borderColor', '#FFFFFF');
			setStyle('paddingLeft', 5);
			setStyle('paddingRight', 30);
			
			var img:Image = new Image();
			img.source = _searchIcon;
			addChild(img);
			
			this.filters = [com.enilsson.graphics.enDropShadows.tightDS()];
		}
		
	}
}