package com.enilsson.vo
{
	public class ErrorVO
	{
		[Bindable] public var message:String = '';
		[Bindable] public var style:String = '';
		[Bindable] public var visible:Boolean = false;
		
		public function ErrorVO(message:String, style:String, visible:Boolean)
		{
			this.message = message;
			this.style = style;
			this.visible = visible;
		}

	}
}