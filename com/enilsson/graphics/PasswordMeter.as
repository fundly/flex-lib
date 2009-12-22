package com.enilsson.graphics
{
    import flash.display.Graphics;
    import flash.geom.Matrix;
    
    import mx.containers.VBox;
    import mx.controls.ProgressBar;
    import mx.controls.Label;
    
	
	public class PasswordMeter extends ProgressBar
	{
        
        private var intScore:int;
        private var percentage:int;
        
        [Bindable]
        private var strVerdict:String = "";            
        
        private var box:VBox = new VBox();

        public function PasswordMeter() : void 
        {
        	mode = "manual";
            setStyle("trackHeight",10);
            label = strVerdict; 
        }

        private var _text:String;

        [Bindable]
        public function set text(value:String) : void 
        {
        	_text = value;
        	
            var passwd:String = value;
            
            intScore   = 0
            strVerdict = "Weak"

            // PASSWORD LENGTH
            if (passwd.length<5)                           // length 4 or less
                intScore = (intScore+3)                
            else if (passwd.length>4 && passwd.length<8)   // length between 5 and 7
                intScore = (intScore+6)
            else if (passwd.length>7 && passwd.length<16)  // length between 8 and 15
                intScore = (intScore+15)
            else if (passwd.length>15)                     // length 16 or more
                intScore = (intScore+18)
            
            // LETTERS
            if (passwd.match(/[a-z]/))                     // [verified] at least one lower case letter
                intScore = (intScore+3)
            if (passwd.match(/[A-Z]/))                     // [verified] at least one upper case letter
                intScore = (intScore+7)
            
            // NUMBERS
            if (passwd.match(/\d+/))                       // [verified] at least one number
                intScore = (intScore+7)
            if (passwd.match(/(\d.*\d)/))                       // [verified] at least one number
                intScore = (intScore+9)
            if (passwd.match(/(\d.*\d.*\d)/))              // [verified] at least three numbers
                intScore = (intScore+10)
             
            // SPECIAL CHARACTERS
            if (passwd.match(/[!,@#$%^&*?_~]/))             // [verified] at least one special character
                intScore = (intScore+8)
            if (passwd.match(/([!,@#$%^&*?_~].*[!,@#$%^&*?_~])/)) // [verified] at least two special characters
                intScore = (intScore+8)
             
            // COMBINATIONS
            if (passwd.match(/[a-z]/) && passwd.match(/[A-Z]/)) // [verified] both upper and lower case
                intScore = (intScore+4)
            if (passwd.match(/\d/) && passwd.match(/\D/)) // [verified] both letters and numbers
                intScore = (intScore+4)
             
            // [Verified] Upper Letters, Lower Letters, numbers and special characters
            if (passwd.match(/[a-z]/) && passwd.match(/[A-Z]/) && passwd.match(/\d/) && passwd.match(/[!,@#$%^&*?_~]/))
                intScore = (intScore+5)
            
            if(intScore < 16) {
               strVerdict = "Very Weak"
               percentage = 20;
            }
            else if (intScore > 15 && intScore < 25) {
               strVerdict = "Weak"
               percentage = 40;
            }
            else if (intScore > 24 && intScore < 35) {
               strVerdict = "Medium"
               percentage = 60;
            }
            else if (intScore > 34 && intScore < 45) {
               strVerdict = "Strong"
               percentage = 80;
            }
            else {
               strVerdict = "Very Strong"
               percentage = 100;
            }    
            
     		if ((passwd.length < this.minLength) && (passwd.length > 0)) {
                strVerdict ="Too short";
                percentage = 15;
            } 
            
            if (passwd.length == 0) {
            	percentage = 1;
            	strVerdict = "";
            	visible = false;	
            } else {
            	visible = true;
            }
            
            
            
            label = strVerdict;            
            this.setProgress(percentage,100); 
        }
        
        public function get text() : String {
            return _text;
        }
        
		private var _minLength : uint = 8;
		
		[Bindable]
        public function set minLength(value:uint) : void {
           _minLength = value;
        }

        public function get minLength() : uint {
            return _minLength;
        }

        override protected function createChildren():void 
        {
            super.createChildren();                
            
            this.addChild(box);
        }
        
        
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
        {
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			    
			 if(percentComplete < 21 )
                 this.setStyle("barColor","red");
             else if(percentComplete < 41 )
                 this.setStyle("barColor","#F1900E");
             else if(percentComplete < 61 )
                 this.setStyle("barColor","yellow");
             else if(percentComplete < 81 )
                 this.setStyle("barColor","#00FF33");
             else            
                 this.setStyle("barColor","green");     
             
              var trackHeight:Number = getStyle("trackHeight");
        }
	}
}