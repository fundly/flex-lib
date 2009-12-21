package com.enilsson.validators
{
	import mx.utils.ObjectUtil;
	import mx.validators.RegExpValidationResult;
	import mx.validators.RegExpValidator;
	import mx.validators.ValidationResult;
	
	public class VariableMatchRegExValidator extends RegExpValidator
	{
		public function VariableMatchRegExValidator()
		{
			super();
		}
		
		public var validAction:String = 'match';

	    override protected function doValidation(value:Object):Array
	    {
	        var results:Array = [];
	        
	        // Return if there are errors
	        // or if the required property is set to <code>false</code> and length is 0.
	        var val:String = value ? String(value) : "";
	        if (results.length > 0 || ((val.length == 0) && !required))
	            return results;
	
	        return validateRegExpression(value);
	    }

		public function set errorMsg(value:String):void
		{
			noMatchError = value;
		}

	    /** 
	     *  @private
	     *  Storage for the expression property.
	     */     
	    private var _expression:String;
	    
	    [Inspectable(category="General")]
	
	    /**
	     *  The regular expression to use for validation. 
	     */
	    override public function get expression():String
	    {
	        return _expression;
	    }
	        
	    /** 
	     *  @private
	     */     
	    override public function set expression(value:String):void
	    {
	        if (_expression != value)
	        {
	            _expression = value;
	
	            createRegExp();
	        }
	    }

	    /** 
	     *  @private
	     *  Storage for the flags property.
	     */     
	    private var _flags:String;
	    
	    [Inspectable(category="General", defaultValue="null")]
	
	    /**
	     *  The regular expression flags to use when matching.
	     */
	    override public function get flags():String
	    {
	        return _flags;
	    }
	    
	    /** 
	     *  @private
	     */     
	   	override public function set flags(value:String):void
	    {
	        if (_flags != value)
	        {
	            _flags = value;
	
	            createRegExp();
	        }
	    }
		
		private var regExp:RegExp;
	    private function createRegExp():void
	    {
	        regExp = new RegExp(_expression, flags);
	    }
		
	    /**
	     *  @private 
	     *  Performs validation on the validator
	     */     
	    private function validateRegExpression(value:Object):Array
	    {
	        var results:Array = [];

	        if (regExp && _expression != "")
	        {
	            var result:Object = regExp.exec(String(value));
	            if (regExp.global)
	            {
	                while (result != null) 
	                {
	                    results.push(new RegExpValidationResult(
	                        false, null, "", "", result[0],
	                        result.index, result.slice(1)));
	                    result = regExp.exec(String(value));
	                }
	            }
	            else if (result != null)
	            {
	                results.push(new RegExpValidationResult(
	                    false, null, "", "", result[0],
	                    result.index, result.slice(1)));                
	            }   
	            
	            // show error if the exp doesnt match
	            if (results.length == 0 && validAction == 'match')
	            {
	                results.push(new ValidationResult( true, null, "noMatch", noMatchError));
	            }
	            
	            // show error if the exp does match
	            if (results.length > 0 && validAction != 'match')
	            {
					results = [];	            	
	                results.push(new ValidationResult(true, null, "noMatch", noMatchError));
	            }
	        }
	        else
	        {
	            results.push(new ValidationResult(
	                true, null, "noExpression",
	                noExpressionError));
	        }
	        
	        return results;
	    }
		
	}
}