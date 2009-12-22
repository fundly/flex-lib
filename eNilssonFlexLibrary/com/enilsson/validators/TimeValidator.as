package com.enilsson.validators
{
	import mx.events.ValidationResultEvent;
	import mx.validators.ValidationResult;
	import mx.validators.Validator;

	public class TimeValidator extends Validator
	{
        private var results:Array;
        private var validationResult:ValidationResultEvent;

		public function TimeValidator()
		{
			super();
		}
		
		private var _invalidTimeError:String = 'Invalid Time!';
		public function set invalidTimeError(value:String):void
		{
			_invalidTimeError = value != null ?
								value :
								'Invalid Time!';
		}
		public function get invalidTimeError():String
		{
			return _invalidTimeError;
		}

		static public function validateTimeString(validator:TimeValidator, value:Object, baseField:String):Array
		{
			var results:Array = [];

			// if today's date is past the last valid date
			if(value < 0 || value > 24 * 60 * 60)
			{
				results.push(new ValidationResult(
					true, baseField, "invalidTimeError",
					validator.invalidTimeError));
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
				return TimeValidator.validateTimeString(this, value, null);
		}
	}
}