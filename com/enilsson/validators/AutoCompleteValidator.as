package com.enilsson.validators
{
 	import mx.events.ValidationResultEvent;
 	import mx.utils.ObjectUtil;
 	import mx.validators.ValidationResult;
 	import mx.validators.Validator;
 	
	public class AutoCompleteValidator extends Validator
	{
		
		// Define Array for the return value of doValidation().
        private var results:Array;
        private var validationResult:ValidationResultEvent;
        
        
        // Constructor.
        public function AutoCompleteValidator() 
        {
            super();
        }

        
		// Define the doValidation() method.
		override protected function doValidation(value:Object):Array
	    {
			var results:Array = super.doValidation(value);
			
			// Return if there are errors or if the required property is set to false and length is 0.
			var val:String = value ? String(value) : "";
			if (results.length > 0 || ((val.length == 0) && !required)) 
			{
				return results;
			} 
			else 
			{
				if (required && source.selectedIndex == -1) 
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