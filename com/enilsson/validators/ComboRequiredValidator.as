package com.enilsson.validators
{
	import mx.validators.NumberValidator;

	public class ComboRequiredValidator extends NumberValidator
	{
		public function ComboRequiredValidator()
		{
			super();
		}

		override protected function doValidation(value:Object):Array
		{
			// if the combobox is editable, and there has been data entered then return no error
			if(source.editable && source.text != source.prompt && source.selectedIndex == -1)
			{
				return new Array();
			}
			// if not then validate
			else
			{	
				minValue = 0;
				property = 'selectedIndex';
				
				return super.doValidation( value );
			}
		}
		
	}
}