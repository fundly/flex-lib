package com.enilsson.validators
{
	import mx.events.ValidationResultEvent;
	import mx.validators.ValidationResult;
	import mx.validators.Validator;

	public class ExpirationDateValidator extends Validator
	{
        private var results:Array;
        private var validationResult:ValidationResultEvent;

		public function ExpirationDateValidator()
		{
			super();
		}
		
		private var _invalidDateError:String = 'The Expiration Date can not be in the past!';
		public function set invalidDateError(value:String):void
		{
			_invalidDateError = value != null ?
								value :
								'The Expiration Date can not be in the past!';
		}
		public function get invalidDateError():String
		{
			return _invalidDateError;
		}

		static public function validateExpirationDate(validator:ExpirationDateValidator, value:Object, baseField:String):Array
		{
			var results:Array = [];

			var expiryDateString:String = String ( value ); // value should be a Literal expiry date string in format "MM/YYYY"
			var month:int = expiryDateString.split('/')[0]; // Outputs literal month e.g. "01"=jan..."12"=dec
			var year:int = expiryDateString.split('/')[1]; // e.g. 2009
			var expiryDate:Date = new Date(year,month);
			var today:Date = new Date();
			
			// if today's date is past the last valid date
			if(today.getTime() > expiryDate.getTime())
			{
				results.push(new ValidationResult(
					true, baseField, "invalidDateError",
					validator.invalidDateError));
			}

			return results;
		}

		override protected function doValidation(value:Object):Array
		{
			var results:Array = super.doValidation(value);
			
			// Return if there are errors
			// or if the required property is set to false and length is 0.
			var val:String = value ? String(value) : "";
			if (results.length > 0 || ((val.length == 0) && !required))
				return results;
			else
				return ExpirationDateValidator.validateExpirationDate(this, value, null);
		}
	}
}