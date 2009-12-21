package com.enilsson.utils
{
	import com.enilsson.utils.buildform.PWDValidator;
	import com.enilsson.validators.ComboRequiredValidator;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.net.SharedObject;
	import flash.text.TextLineMetrics;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.containers.ViewStack;
	import mx.controls.DataGrid;
	import mx.core.Container;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	import mx.utils.StringUtil;
	import mx.validators.CreditCardValidator;
	import mx.validators.CurrencyValidator;
	import mx.validators.DateValidator;
	import mx.validators.EmailValidator;
	import mx.validators.NumberValidator;
	import mx.validators.PhoneNumberValidator;
	import mx.validators.RegExpValidator;
	import mx.validators.SocialSecurityValidator;
	import mx.validators.StringValidator;
	import mx.validators.ZipCodeValidator;
	
	public class eNilssonUtils
	{	
		/**
		 * Set a variable of the flash stage that can be used for any methods
		 */
		private static var _stage:Stage;
		static internal function set stage(value:Stage):void 
		{
			if ( _stage ) {
				throw new Error("stage already registered");
			}
			_stage = value;
		}
		static internal function get stage():Stage 
		{
			return _stage;
		}
		
		public function eNilssonUtils()
		{
		}

		/**
		 * Function for cleaning a string to URL friendly characters
		 * Direct port from CodeIgniter (www.codeigniter.com)
		 * Author: Rick Ellis 
		 */
		public static function urlTitle(str:String, separator:String = 'dash'):String
		{
			var search:String;
			var replace:String;
			if (separator == 'dash'){
				search	= '_';
				replace	= '-';
			} else {
				search	= '-';
				replace	= '_';
			}

			str = stripHtmlTags(str.toLowerCase());
			
			str = str.replace(search, replace);
			str = str.replace(new RegExp("\s+", "g"), replace);
			str = str.replace(new RegExp("[^a-z0-9]", "g"), replace);
			str = str.replace(new RegExp(replace + "+", "g"), replace);
			str = str.replace(new RegExp(replace + "$", "g"), '');
			str = str.replace(new RegExp("^" + replace, "g"), '');
			
			return StringUtil.trim(str);
		}
		
		
		/**
		 * Function for cleaning a file name to a friendly format
		 */
		public static function niceFileName(str:String, separator:String = 'underscore'):String
		{
			// get the file extension
			var dotPt:int = str.lastIndexOf('.');
			var fileExt:String = str.substr(dotPt+1);
			
			// get the filename
			var filename:String = str.substr(0, dotPt);

			var search:String;
			var replace:String;
			if (separator == 'dash'){
				search	= '_';
				replace	= '-';
			} else {
				search	= '-';
				replace	= '_';
			}
			
			filename = filename.toLowerCase();
			
			filename = filename.replace(search, replace);
			//filename = filename.replace(new RegExp("\s+", "g"), replace);
			filename = filename.replace(new RegExp("[^a-z0-9]", "g"), replace);
			str = str.replace(new RegExp(replace + "+", "g"), replace);
			str = str.replace(new RegExp(replace + "$", "g"), '');
			str = str.replace(new RegExp("^" + replace, "g"), '');
			
			return StringUtil.trim(filename + '.' + fileExt);			
		}
		
		/**
		 * Function for removing tags from a string
		 * Author: Andrei Ionescu (http://www.flexer.info/2008/04/08/strip-html-tags-with-allowable-tags/) 
		 */
		public static function stripHtmlTags(html:String, tags:String = null):String
		{
			// if there are no tags to keep remove everything...
		    if(tags == null){
		    	var tagsPattern:RegExp = new RegExp("<(.|\n)+?>");
		    	return html.replace(tagsPattern,'');		    	
		    }
		    
		    var tagsToBeKept:Array = new Array();
		    if (tags.length > 0)
		        tagsToBeKept = tags.split(new RegExp("\\s*,\\s*"));
		 
		    var tagsToKeep:Array = new Array();
		    for (var i:int = 0; i < tagsToBeKept.length; i++)
		    {
		        if (tagsToBeKept[i] != null && tagsToBeKept[i] != "")
		            tagsToKeep.push(tagsToBeKept[i]);
		    }
		 
		    var toBeRemoved:Array = new Array();
		    var tagRegExp:RegExp = new RegExp("<([^>\\s]+)(\\s[^>]+)*>", "g");
		 
		    var foundedStrings:Array = html.match(tagRegExp);
		    for (i = 0; i < foundedStrings.length; i++)
		    {
		        var tagFlag:Boolean = false;
		        if (tagsToKeep != null)
		        {
		            for (var j:int = 0; j < tagsToKeep.length; j++)
		            {
		                var tmpRegExp:RegExp = new RegExp("<\/?" + tagsToKeep[j] + "[^<>]*?>", "i");
		                var tmpStr:String = foundedStrings[i] as String;
		                if (tmpStr.search(tmpRegExp) != -1)
		                    tagFlag = true;
		            }
		        }
		        if (!tagFlag)
		            toBeRemoved.push(foundedStrings[i]);
		    }
		    for (i = 0; i < toBeRemoved.length; i++)
		    {
		        var tmpRE:RegExp = new RegExp("([\+\*\$\/])","g");
		        var tmpRemRE:RegExp = new RegExp((toBeRemoved[i] as String).replace(tmpRE, "\\$1"),"g");
		        html = html.replace(tmpRemRE, "");
		    }
		    return html;
		}
		
		/**
		 * Utility function to strip all tags from a string
		 * Similar to the native PHP function
		 */
		public static function stripTags(str:String): String 
		{
			if(str == null) return str;	
			
			var regex:RegExp = new RegExp("(<.*?>)|(</.*?>)", "g");
			str = str.replace(regex, "");
			return str;
		}

		/**
		 * Utility function to uppercase the first letter of each word in a string
		 */
		public static function ucwords(str:String):String
		{
			var ucStr:String = new String();
			var strArray:Array = str.split(' ');
			for(var i:String in strArray){
				ucStr += strArray[i].substr(0,1).toUpperCase() + strArray[i].substr(1).toLowerCase() + ' ';
			}
			return StringUtil.trim(ucStr);
		}
		
		/**
		 *  Utility function to limit a string to a set number of words
		 */
		public static function wordLimiter(str:String, n:Number, tail:String='...'):String
		{
			if (str.length < n){ return str; }
			var words:Array = str.split(' ');
			if (words.length <= n) { return str; }
			str = '';
			for (var i:Number = 0; i<n; i++) { str += words[i] + ' '; }
			return StringUtil.trim(str) + tail;
		}
		
		/**
		 * Utility function to limit a string and add tail
		 */
		public static function charLimiter(str:String, length:Number, tail:String='...'):String
		{
			var strLen:Number = str.length;
			if(strLen > length){
				return str.substr(0, length) + tail;
			} else {
				return str.substr(0, length);
			}
		}

		/**
		 * Utility function for getting a DOM element
		 * Similar to the many JS functions of the same name
		 */
		public static function $(object:String,container:DisplayObjectContainer = null):* 
		{
			if(container == null){ return null; }
			
		    for (var i:uint=0; i < container.numChildren; i++) {
		        var child:DisplayObject = container.getChildAt(i);
		        
		        if (child.name== object) {
		        	return child; 
		        }
		
		        if (container.getChildAt(i) is DisplayObjectContainer) {
		           var obj:* = $(object,DisplayObjectContainer(child));
		           if (obj is DisplayObject) {
		           	 return obj;
		           }
		        }
		    }
		    
		    return false;
		}
		
		
		/**
		 * Utility function for retrieving an array of elements with the same styleName
		 * Similar to similar JS functions of the same name
		 */
		public static function $$(styleName:String, containerObj:Object=null):Array
		{
			var container:Object = containerObj || _stage;
			
			var elements:Array = new Array();

		    for (var i:uint=0; i < container.numChildren; i++) {
		    	var child:* = container.getChildAt(i);
		    	
		    	if(!child.hasOwnProperty('styleName')){ continue; }
		    	
		    	if(child.styleName == styleName){
		    		elements.push(child);
		    	}			
		    	
		    	if(!child.hasOwnProperty('numChildren')){ continue; }
		    	
		    	if(child.numChildren > 0){
		    		elements = $$(styleName, child);
		    	}
		    }
		    
		    return elements;
		}
		
		/**
		 * Utility function to return serialized object of form values from a container
		 * Similar to the Javascript function of the same name from Prototype.js (www.prototypejs.org)
		 * Author: James Nicol, www.enilsson.com, May 2008
		 */
		public static function formSerialize(container:DisplayObjectContainer, paramObj:Object=null):Object
		{
			if(!paramObj){ paramObj = new Object(); }
			
			if(container == null){ return paramObj; }
			
		    for (var i:uint=0; i < container.numChildren; i++) {
		        var child:* = container.getChildAt(i);
		        
		        if(!child.hasOwnProperty('className')){ continue; }
		        if(!child.hasOwnProperty('id')){ continue; }
				if(!child.hasOwnProperty('numChildren')){ continue; }
		        
		        switch(child.className){
		        	case 'enAutoComplete' :
		        	case 'clearTextArea' :
		        	case 'clearTextInput' :
		        	case 'TextArea' :
		        	case 'TextInput' :
		        	case 'DateField' :
		        		paramObj[child.id] = child.text;
		        	break;
		        	case 'clearDropDown' :
		        	case 'ComboBox' :
		        		paramObj[child.id] = child.selectedItem.value;
		        	break;
		        	case 'CheckBox' :
		        		paramObj[child.id] = child.selected;
		        	break;
		        	case 'RadioButton' :
		        		if(child.selected){
		        			paramObj[child.groupName] = child.value;
		        		}
		        	break;
		        	default :
				        if(child.numChildren > 0){
				        	paramObj = formSerialize(child, paramObj);
				        }
		        	break;
		        }
		    }
		    
		    return paramObj;
		}

		/**
		 * Convert any single dimensional XML array into a multidimensional one
		 * AS like to convert a one element 2D array into a 1D array, very annoying...
		 * Author: James Nicol (www.enilsson.com)
		 */
		public static function makeMD(data:Object):Object
		{
			var mdObj:Object = new Object();
			
			if(data.item){
				if(typeof(data.item[0]) == 'object'){
					mdObj = data;
				} else {
					mdObj['item'] = new Array(data.item);
				}	
			} else {
				mdObj['item'] = new Array(data);
			}
			
			return mdObj;
		}	
		

		/**
		 * Parse an XML data object into array collection for a datagrid or list container
		 * Author: James Nicol (www.enilsson.com)
		 */
		public static function parseDataForDG(data:Object, dg:*):void
		{
			if(!data){ return; }
			var dpData:ArrayCollection = new ArrayCollection();
			if(typeof(data.item[0]) == 'object'){
				for(var i:String in data){
					var item:Object = new Object();
					for(var t:String in data.item[i]){
						item[t] = data.item[i][t];
					}
					dpData.addItem(item);
				}
				dg.dataProvider = dpData;
			} else {
				dpData.addItem(data.item);
				dg.dataProvider = dpData;
			}
		}
		
		/**
		 * Parse an AMF data object into array collection for a datagrid or list container
		 * Author: James Nicol (www.enilsson.com)
		 */
		public static function parseAMFDataForDG(data:Object, dg:* = null):*
		{
			if(!data){ return; }
			var dpData:ArrayCollection = new ArrayCollection();
			if(typeof(data['1']) == 'object')
			{
				for(var i:String in data)
				{
					for(var j:String in data[i])
					{
						if (data[i][j] is String) {
							data[i][j] = convert_entities(data[i][j]);
						}
						if(int(data[i][j]) != 0){
							data[i][j] = int(data[i][j]);
						}
						
						if (typeof(data[i][j]) == "object")
						{
							data[i][j] = parseAMFDataForDG(data[i][j]);
						}
					}
					dpData.addItem(data[i]);
				}
			} else {
				for(var t:String in data)
				{
					if (data[t] is String) {
						data[t] = convert_entities(data[t]);
					}
					if(int(data[t]) != 0){
						data[t] = int(data[t]);
					}
					if (typeof(data[t]) == "object")
					{
						data[t] = parseAMFDataForDG(data[t]);
					}
				}
				dpData.addItem(data);
			}
			if (dg == null) {
				return dpData;
			} else {
				dg.dataProvider = dpData;
			}

		}		
		
		/**
		 * Clean strings of XML/HTML entities
		 */	
		public static function convert_entities(str:String):String
		{
			if(str == null){ return str; }
			
			var search:Array =  new Array('&lsquo;', '&rsquo;', '&ldquo;', '&rdquo;', '&ndash;', '&mdash;', '&amp;', '&#039;', '&#39;','&quot;','&#8230;','&nbsp;');  
			var replace:Array = new Array("'", "'", '"', '"', '-', '-', '&', "'", "'", '"', '...',' '); 		
			var regex:RegExp;
			
			// search once to clear any ampersand conversions
			regex = new RegExp( '&amp;', 'g');
			str = str.replace( regex, '&' );	

			// search once more
			for( var i:int=0; i<search.length; i++ )
			{
				regex = new RegExp( search[i], 'g');
				str = str.replace( regex, replace[i] );
			}	
					
			return str;
		}

		
		/**
		 * Set the selected index of a combo box or variant by a string
		 * Author: James Nicol (www.enilsson.com)
		 */
		public static function setComboBoxIndex(cb:*, value:String):void
		{
			for(var i:String in cb.dataProvider){
				if(cb.dataProvider[i].value == value){
					cb.selectedIndex = parseInt(i);
				}	
			}
		}
		
		/**
		 * Set the width of a dataGrid column or all columns based on the 
		 * width of the text in each cell
		 */
		public static function resizeColumn(dg:DataGrid, columnIndex:int=-1, maxWidth:int=-1):void
		{
			// set some variables
			var data:Object = dg.dataProvider;
			var maxCellWidth:int = 0;
			var dataField:String;
			var cell:TextLineMetrics;
			var cellPadding:int = 12;
			// either resize all the columns or just one
			if(columnIndex == -1){
				for(var j:int=0; j<dg.columnCount; j++){
					dataField = dg.columns[j].dataField;
					maxCellWidth = 0;
					for ( var i:String in data){
						cell = dg.measureText(data[i][dataField]);
						maxCellWidth = cell.width > maxCellWidth ? cell.width : maxCellWidth;		
					}
					if(maxWidth > -1){
						dg.columns[j].width = (maxCellWidth + cellPadding) > maxWidth ? maxWidth : maxCellWidth + cellPadding;
					} else {
						dg.columns[j].width = maxCellWidth + cellPadding;	
					}
				}		
			} else {
				dataField = dg.columns[columnIndex].dataField;
				maxCellWidth = 0;
				for ( var k:String in data){
					cell = dg.measureText(data[k][dataField]);
					maxCellWidth = cell.width > maxCellWidth ? cell.width : maxCellWidth;		
				}
				if(maxWidth > -1){
					dg.columns[columnIndex].width = (maxCellWidth + cellPadding) > maxWidth ? maxWidth : maxCellWidth + cellPadding;
				} else {
					dg.columns[columnIndex].width = maxCellWidth + cellPadding;	
				}
			}
		}		
		
		
		/**
		 * Use shared object to write data to the browser cookie
		 */
		public static function writeCookie(type:String, text:String, nameSpace:String='enilsson'):void
		{
			var sharedObj:SharedObject = SharedObject.getLocal(nameSpace);
			if(sharedObj.data[type] == null){
				sharedObj.data[type] = text;
			} else {
				sharedObj.data[type] += ',' + text;
			}
			sharedObj.flush();	
		}

		/**
		 * Use shared object to read data from the browser cookie
		 */		
		public static function readCookie(type:String, nameSpace:String='enilsson'):String
		{
			var sharedObj:SharedObject = SharedObject.getLocal(nameSpace);
			return sharedObj.data[type];
		}

		/**
		 * Clear the browser cookie
		 */				
		public static function clearCookie(type:String, nameSpace:String='enilsson'):void
		{
			var sharedObj:SharedObject = SharedObject.getLocal(nameSpace);
			sharedObj.data[type] = null;
			sharedObj.flush();				
		}
		
		/**
		 * Flash the browser cookie
		 */				
		public static function flashCookie(type:String, nameSpace:String='enilsson'):String
		{
			var sharedObj:SharedObject = SharedObject.getLocal(nameSpace);
			var cookie:String = sharedObj.data[type];
			
			sharedObj.data[type] = null;
			sharedObj.flush();
			
			return cookie;				
		}
		
		/**
		 * Function to add validators to a field, needs to be nested in a Form > FormItem layout
		 * Author: Rafael Cardoso, www.enilsson.com, December 2007
		 */

		public static function setFieldValidator(rule:String, id:Object, formValidate:Array, options:Object=null):Array
		{
			var validation:Object = id.parent;
			
			switch(rule)
			{
				case 'phone':
			 		var phoneValidator:PhoneNumberValidator = new PhoneNumberValidator();
	                phoneValidator.source = id;
	                phoneValidator.property = "text";
					phoneValidator.required = validation.required === true ? true: false;
					phoneValidator.requiredFieldError = validation.label + " is required";
					formValidate.push({'validator':phoneValidator,'source':id,'fieldname':id.name, 'rule':rule});	                
   				break;
				case 'email':
				 	var emailValidator:EmailValidator = new EmailValidator();
					emailValidator.source = id;
					emailValidator.property = "text"; 		
					emailValidator.required = validation.required === true ? true: false;	
					emailValidator.requiredFieldError = validation.label + " is required";
	                formValidate.push({'validator':emailValidator,'source':id,'fieldname':id.name, 'rule':rule});	                
				break;
				case 'currency':
					var curValidator:CurrencyValidator = new CurrencyValidator();
					curValidator.source = id;
					curValidator.property = "text";
					curValidator.required = validation.required === true ? true: false;
					curValidator.requiredFieldError = validation.label + " is required";
	                formValidate.push({'validator':curValidator,'source':id,'fieldname':id.name, 'rule':rule});	                
				break;
				case 'number':
					var nv:NumberValidator = new NumberValidator();
	                nv.source = id;
	                nv.property = "text";
					nv.required = validation.required === true ? true: false;	
					nv.requiredFieldError = validation.label + " is required";
	                formValidate.push({'validator':nv,'source':id,'fieldname':id.name, 'rule':rule});	                
				break;
				case 'socialsecurity':
					var ss:SocialSecurityValidator = new SocialSecurityValidator();
					ss.source = id;
					ss.property = "text";
					ss.required = validation.required === true ? true: false;
					ss.requiredFieldError = validation.label + " is required";
	                formValidate.push({'validator':ss,'source':id,'fieldname':id.name, 'rule':rule});	                
				break;
				case 'zip':
					var zipValidator:ZipCodeValidator = new ZipCodeValidator();
					zipValidator.source = id;
					zipValidator.property = "text";
					zipValidator.required = validation.required === true ? true: false;
					zipValidator.requiredFieldError = validation.label + " is required";
	                formValidate.push({'validator':zipValidator,'source':id,'fieldname':id.name, 'rule':rule});	                
				break;
				case 'date':
					var dtv:DateValidator = new DateValidator();
					dtv.source = id;
					dtv.inputFormat = "dd/mm/yyyy";
					dtv.property = "text";
					dtv.required = validation.required === true ? true: false;
					dtv.requiredFieldError = validation.label + " is required";
	                formValidate.push({'validator':dtv,'source':id,'fieldname':id.name, 'rule':rule});	                
				break;
				case 'creditcard':
					if(!options.cardTypeSource){
						return formValidate;
					}				
					var ccv:CreditCardValidator = new CreditCardValidator();
					ccv.cardNumberSource = id;
					ccv.cardNumberProperty = "text";
					ccv.cardTypeSource = options.cardTypeSource;
					ccv.cardTypeProperty = options.cardTypeProperty;
					ccv.required = validation.required === true ? true: false;
					ccv.requiredFieldError = validation.label + " is required";
	                formValidate.push({'validator':ccv,'source':id,'fieldname':id.name, 'rule':rule});	                
				break;
				case 'required':
					var sValidator:StringValidator = new StringValidator();
					sValidator.source = id;
					sValidator.property = "text"
					sValidator.required = true;
					if (options != null) {
						if (options.hasOwnProperty('minLength')) {
							sValidator.minLength = options.minLength;
						}
					}
					sValidator.requiredFieldError = validation.label + " is required";
	                formValidate.push({'validator':sValidator,'source':id,'fieldname':id.name, 'rule':rule});
				break;
				case 'comborequired' :
					var cValidator:ComboRequiredValidator = new ComboRequiredValidator();
					cValidator.source = id;
					cValidator.minValue = 0;
					cValidator.property = "selectedIndex";
					cValidator.lowerThanMinError = validation.label + " is required";
	                formValidate.push({'validator':cValidator,'source':id,'fieldname':id.name,'rule':rule});						
				break;
				case 'regExString' :
					var reValidator:RegExpValidator = new RegExpValidator();
					reValidator.source = id;
					reValidator.property = 'text';
					reValidator.required = true;
					reValidator.requiredFieldError = validation.label + " is required";
					reValidator.expression = options.expression;
					reValidator.noMatchError = options.noMatchError;
					reValidator.flags = options.flags;				
	                formValidate.push({
	                	'validator':reValidator, 
	                	'source':id,
	                	'fieldname':id.name, 
	                	'rule':rule
	                });
				break;
				case 'password_conf':
					var pwdValidator:PWDValidator = new PWDValidator();
					pwdValidator.source = id;
					pwdValidator.required = false;
					pwdValidator.match = options.match;
					pwdValidator.property = "text";
		            formValidate.push({
		            	'validator':pwdValidator,
		            	'source':id,
		            	'fieldname':id.name,
		            	'rule':rule
		            });
				break;
			}
			return formValidate;
		}

		// Looks through the views in the stack to find one whose id matches,
		// then switches to it. This will fire the the ViewStack's change event.
		public static function switchView(vstack:ViewStack, viewId:String):void
		{
		 	var container:Container = Container(vstack.getChildByName(viewId));
		    if (container != null) {
		        vstack.selectedChild = container;
		    }
		}

		public static function serialize(dataObject:*):String 
		{
			var byteArray : ByteArray = new ByteArray();
			byteArray.writeObject( dataObject );

			var base64En:Base64Encoder = new Base64Encoder();
			base64En.encodeBytes(byteArray);
			
			return base64En.toString();
		}	
		public static function unserialize(str:String):* 
		{
		    var base64Dec:Base64Decoder = new Base64Decoder();
		    base64Dec.decode(str);
		
		    var byteArr:ByteArray = base64Dec.toByteArray();
		    
		    return byteArr.readObject();
	   	}
	   	
		public static  function cleanATag(str:String):String
	    {
	        var pattern:RegExp;
	        var str:String;
	        
	         pattern = /<A HREF/gi;
	        str = str.replace(pattern, "<a href");
	        pattern = /<\/A>/gi;
	        str = str.replace(pattern, "<\/a>");
	        pattern= /TARGET="_blank"/gi;
	        str = str.replace(pattern, "rel=\"external\" ");   
	        
	        return str;
	    }
	    public static  function cleanHTML(str:String):String
	    {
	        var pattern:RegExp;
	        var str:String;

	        pattern = /COLOR=\"(.*?)\"/gi;
	        str = str.replace(pattern, "color:$1;");
	        pattern = /SIZE=\"(.*?)\"/gi;
	        str = str.replace(pattern, "font-size:$1px;");
	        pattern = /FACE=\"(.*?)\"/gi;
	        str = str.replace(pattern, "font-family:$1;");
	        pattern = /ALIGN=\"(.*?)\"/gi;
	        str = str.replace(pattern, "text-align:$1;");
	        
	        //format <font> tag
	        pattern = /<FONT STYLE/gi;
	        str = str.replace(pattern, "<font style");
	        pattern = /<\/FONT.*?>/gi;
	        str = str.replace(pattern, "<\/font>");
	        
	        //format <p> tag
	        pattern = /<P STYLE/gi;
	        str = str.replace(pattern, "<p style");
	        pattern = /<\/P>/gi;
	        str = str.replace(pattern, "<\/p>");
	        
	        //format <li> tag
	        pattern= /<LI>/gi;
	        str = str.replace(pattern, "<li>");
	        pattern= /<\/LI>/gi;
	        str = str.replace(pattern, "</li>");
	        
	        //format <ul> tag
	        pattern= /<UL>/gi;
	        str = str.replace(pattern, "<ul>");
	        pattern= /<\/UL>/gi;
	        str = str.replace(pattern, "</ul>");
	
	   
	
	
	        //format alignment in styles tag
	        pattern = /text-align: RIGHT/gi;
	        str = str.replace(pattern, "text-align:right");
	        pattern = /text-align: LEFT/gi;
	        str = str.replace(pattern, "text-align:left");
	        pattern = /text-align: CENTER/gi;
	        str = str.replace(pattern, "text-align:center");
	        pattern = /text-align: JUSTIFY/gi;
	        str = str.replace(pattern, "text-align:justify");
	        
	        //format <a> tag
	        
	        //created a seperate function that way i can override it, and
	        //put in my own stuff in the class that is extending it.
	        //i could do this with all of the tags, but for now all i need is the 
	        //a href tag.
	        str = cleanATag(str);
	        
	        pattern = /<I>/gi;
	        str = str.replace(pattern, "<em>");
	        pattern = /<\/I>/gi;
	        str = str.replace(pattern, "</em>");
	        pattern = /<B>/gi;
	        str = str.replace(pattern, "<strong>");
	        pattern = /<\/B>/gi;
	        str = str.replace(pattern, "</strong>");
	        pattern = /<U>/gi;
	        str = str.replace(pattern, "<u>");
	        pattern = /<\/U>/gi;
	        str = str.replace(pattern, "</u>");
	        
	        //this is to fix a bug
	        //for some reason there is a u tag showing up? wtf
	        pattern = /<U\/>/gi;
	        str = str.replace(pattern, "");
	        
	        pattern = /<p(.*?)><font(.*?)\/><\/p>/gi;
			str = str.replace(pattern,"<p>&nbsp;</p>");			
	
	        return str;
	    }
	    
	    public static  function rteToHtml(str:String):String 
	    {
	        // Create XML document
	        var xml:XML = XML("<BODY>"+str+"</BODY>");
	
	        // temporary
	        var t1:XML;
	        var t2:XML;
	        
	        // Remove all TEXTFORMAT
	        for( t1 = xml..TEXTFORMAT[0]; t1 != null; t1 = xml..TEXTFORMAT[0] ) {
	            t1.parent().replace( t1.childIndex(), t1.children() );
	        }
	        
	        // Find all ALIGN
	        for each ( t1 in xml..@ALIGN ) {
	            t2 = t1.parent();
	            t2.@STYLE = "text-align: " + t1 + "; " + t2.@STYLE;
	            delete t2.@ALIGN;
	        }
	         
	        // Find all FACE
	        for each ( t1 in xml..@FACE ) {
	            t2 = t1.parent();
	            t2.@STYLE = "font-family: " + t1 + "; " + t2.@STYLE;
	            delete t2.@FACE;
	        }
	        
	        // Find all SIZE 
	        for each ( t1 in xml..@SIZE ) {
	            t2 = t1.parent();
	            t2.@STYLE = "font-size: " + t1 + "px; " + t2.@STYLE;
	            delete t2.@SIZE;
	        }
	
	        // Find all COLOR 
	        for each ( t1 in xml..@COLOR ) {
	            t2 = t1.parent();
	            t2.@STYLE = "color: " + t1 + "; " + t2.@STYLE;
	            delete t2.@COLOR;
	        }
	        
	        // Find all LETTERSPACING 
	        for each ( t1 in xml..@LETTERSPACING ) {
	            t2 = t1.parent();
	            t2.@STYLE = "letter-spacing: " + t1 + "px; " + t2.@STYLE;
	            delete t2.@LETTERSPACING;
	        }
	        
	        // Find all KERNING
	        for each ( t1 in xml..@KERNING ) {
	            t2 = t1.parent();
	            // ? css 
	            delete t2.@KERNING;
	        }
	        
	        return cleanHTML(xml.children().toXMLString());
	    }    
	
	    public static  function cleanRteHTML(str:String, allowedAttr:Array=null):String 
	    {
	        // set the default attributes allowed
	        if(allowedAttr == null)
	        	allowedAttr = new Array('COLOR', 'ALIGN');
	        
	        // Create XML document
	        var xml:XML = XML("<BODY>"+str+"</BODY>");
	
	        // temporary
	        var t1:XML;
	        var t2:XML;
	        
	        // Remove all TEXTFORMAT
	        for( t1 = xml..TEXTFORMAT[0]; t1 != null; t1 = xml..TEXTFORMAT[0] ) 
	        {
	            t1.parent().replace( t1.childIndex(), t1.children() );
	        }
	        
	        // Find all ALIGN
	        if(allowedAttr.indexOf('ALIGN') == -1)
	        {
		        for each ( t1 in xml..@ALIGN ) 
		        {
		            t2 = t1.parent();
		            delete t2.@ALIGN;
		        }
	        }
	         
	        // Find all FACE
	        if(allowedAttr.indexOf('FACE') == -1)
	        {
	        	for each ( t1 in xml..@FACE ) 
		        {
		            t2 = t1.parent();
		            delete t2.@FACE;
		        }
	        }
	        
	        // Find all SIZE 
	        if(allowedAttr.indexOf('SIZE') == -1)
	        {
		        for each ( t1 in xml..@SIZE ) 
		        {
		            t2 = t1.parent();
		            delete t2.@SIZE;
		        }
	        }
	
	        // Find all COLOR 
	        if(allowedAttr.indexOf('COLOR') == -1)
	        {	        
		        for each ( t1 in xml..@COLOR ) {
		            t2 = t1.parent();
		            delete t2.@COLOR;
		        }
	        }
	        
	        // Find all LETTERSPACING 
	        if(allowedAttr.indexOf('LETTERSPACING') == -1)
	        {
		        for each ( t1 in xml..@LETTERSPACING ) {
		            t2 = t1.parent();
		            delete t2.@LETTERSPACING;
		        }
	        }
	        
	        // Find all KERNING
	        if(allowedAttr.indexOf('KERNING') == -1)
	        {
		        for each ( t1 in xml..@KERNING ) {
		            t2 = t1.parent();
		            delete t2.@KERNING;
		        }
	        }
	        
	        // Remove any carriage returns and tabs and double or more spaces
	        var xmlString:String = xml.children().toString();   
	        xmlString = xmlString.replace(new RegExp("[\n\r\t]","g"),"");
	        xmlString = xmlString.replace(new RegExp("( ){2,}","g")," ");
	        
	        return xmlString;
	    }    
		

		public static  function safeBitCheck(num:Number,comparison:Number):Boolean
		{
		  if(num < 2147483647 ) {
		      return (num & comparison)==comparison;
		  } else {
		      var binNumber:String = strrev(base_convert(num,10,2));
		      var binComparison:String = strrev(base_convert(comparison,10,2));
		      for(var i:uint=0; i<binComparison.length; i++ ) {
		          if( binNumber.length < i || (binComparison.charAt(i)==="1" && binNumber.charAt(i)==="0") ) {
		              return false;
		          }
		      }
		      return true;
		  }
		}
		
		public static  function strrev(str:String):String {
  			return str.split("").reverse().join("");
		}

		public static  function base_convert(num:Number, frombase:Number, tobase:Number):String {  
			return parseInt(num+'', frombase+0).toString(tobase+0);  
		}  
  

		public static function canvasDS(distance:Number = 5, strength:Number = 0.65, blurX:Number = 8, blurY:Number = 8, angle:Number = 90, color:Number = 0x000000, alpha:Number = 1):DropShadowFilter 
		{
		    var quality:Number 		= BitmapFilterQuality.LOW;
		    var inner:Boolean 		= false;
		    var knockout:Boolean 	= false;

		    return new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout);
		}
	}
}