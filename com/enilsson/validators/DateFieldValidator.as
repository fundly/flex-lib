package com.enilsson.validators
{
	import mx.events.ValidationResultEvent;
	import mx.validators.ValidationResult;
	import mx.validators.Validator;

	public class DateFieldValidator extends Validator
	{
		// Define Array for the return value of doValidation().
        private var results:Array;
        private var validationResult:ValidationResultEvent;
		
		public function DateFieldValidator()
		{
			super();
		}
		
		override protected function doValidation(value:Object):Array
		{
			var results:Array = super.doValidation(value);
			
			// Return if there are errors or if the required property is set to false and length is 0.
			var val:Number = value ? Number(value) : 0;
			if (val > 0 && !required) 
			{
				return results;
			} 
			else 
			{
				if (required && val == 0) 
				{
					results.push(new ValidationResult(true, null, "requiredFieldError", requiredFieldError));
					return results;
				} 
				else 
				{
					source.errorString = null;		
				}							   
			}
			
			return results;
		}
		
	}
}