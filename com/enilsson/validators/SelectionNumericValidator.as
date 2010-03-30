package com.enilsson.validators
{
	import mx.formatters.NumberFormatter;
	import mx.validators.NumberValidator;

	public class SelectionNumericValidator extends NumberValidator
	{
		public function SelectionNumericValidator()
		{
			super();
		}
		
		/**
		 * @private
		 */
		private var _selectionSource:Object;
		
		/**
		 * Get the selection source for the validation
		 */
		public function get selectionSource ():Object
		{
			return _selectionSource
		}
		
		public function set selectionSource ( value:Object ):void
		{
			_selectionSource = value;
		}
		
		public var selectionSourceProperty:String;
		
		/**
		 * @private
		 */
		private var _validationSource:Array;
		
		/**
		 * Get the array of validation choices that will be set by the selection source
		 */
		public function get validationSource ():Array
		{
			return _validationSource;
		}
		
		public function set validationSource ( value:Array ):void
		{
			_validationSource = value;
		}
		
		public var fieldLabel:String;
		
		
		override protected function doValidation(value:Object):Array
		{
			var selIndex:int = ( ! selectionSource || selectionSource[selectionSourceProperty] < 0 ) ? 0 : selectionSource[selectionSourceProperty];
			
			if( validationSource != null && validationSource.length > selIndex + 1 ) {
				minValue = validationSource[selIndex].minValue;
				maxValue = validationSource[selIndex].maxValue;
			}
			
			var nf:NumberFormatter = new NumberFormatter();
			
			lowerThanMinError = fieldLabel + ' has to be greater than ' + nf.format(minValue);
			exceedsMaxError = fieldLabel + ' can not be greater than ' + nf.format(maxValue);			
			
			return super.doValidation( value );
		}
		
	}
}