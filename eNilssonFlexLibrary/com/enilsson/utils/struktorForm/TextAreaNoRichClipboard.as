package com.enilsson.utils.struktorForm
{
	import mx.controls.TextArea;

	public class TextAreaNoRichClipboard extends TextArea
	{
		public function TextAreaNoRichClipboard()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			if(textField)
				textField.useRichTextClipboard = false;
		}
	}
}