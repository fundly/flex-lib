package com.enilsson.utils.buildform
{
 	import flash.events.Event;
 	
 	import mx.controls.TextInput;
 	import mx.events.ValidationResultEvent;
 	import mx.validators.StringValidator;
    	
	public class PWDValidator extends StringValidator
	{
		// Define Array for the return value of doValidation().
        private var results:Array;
        private var validationResult:ValidationResultEvent;
        
        private var errorMsg:String = "The confirmation does not match the password";
        
        // Constructor.
        public function PWDValidator() {
            super();
        }
        
        
		// Define the doValidation() method.
        override public function validate(value:Object = null,
                        suppressEvents:Boolean = false):ValidationResultEvent
        {
        	// initialize the result as "valid"
        	validationResult = new ValidationResultEvent(ValidationResultEvent.VALID);

        	if (this.match.text == "")	{
        		this.source.text = this.match.text;
        	} 
        	
        	
        	if ((this.source.text != "") && (this.match.text != ""))
        	{
        		if (this.source.text != this.match.text) 
        		{	
        			validationResult = new ValidationResultEvent(ValidationResultEvent.INVALID);
        			
        			this.maxLength = 0;
        			this.tooLongError = errorMsg;
        		}
        		else
        		{
        			this.maxLength = 255;
        			this.source.errorString = "";
        		}
        	}
        	else
        	{
       			this.maxLength = 255;
       			this.source.errorString = "";
        	} 
        	
        	
   			super.validate();
   			
   			if ((this.match.text != "") && (this.source.text == "")) {
   				this.required = true;
   				validationResult = new ValidationResultEvent(ValidationResultEvent.INVALID);
   			} else {
   				this.required = false;
   			}
   			
        	
        	return validationResult;
        }

	    //----------------------------------
	    //  field to match
	    //----------------------------------
	
	    /**
	     *  @private
	     *  fields that are not going to be validate.
	     */
		private var _match:TextInput;

	   	public function get match():TextInput
	    {
	        return _match;
	    }
	
	    public function set match(value:TextInput):void
	    {
			_match = value;	
	    }
 	}
			   	
}