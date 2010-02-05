
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2007 Enilsson and its licensors.
// All Rights Reserved.
// Author: Rafael Cardoso (rafael.cardoso@enilsson.com)
//
////////////////////////////////////////////////////////////////////////////////

package com.enilsson.utils.buildform
{
   	import com.enilsson.containers.MultiColumnForm;
   	import com.enilsson.utils.EDateUtil;
   	
   	import flash.display.DisplayObjectContainer;
   	import flash.events.Event;
   	import flash.events.FocusEvent;
   	import flash.events.MouseEvent;
   	import flash.net.URLVariables;
   	
   	import mx.collections.ArrayCollection;
   	import mx.containers.FormItem;
   	import mx.containers.HBox;
   	import mx.controls.ComboBox;
   	import mx.controls.DateField;
   	import mx.controls.Label;
   	import mx.controls.List;
   	import mx.controls.Text;
   	import mx.controls.TextArea;
   	import mx.controls.TextInput;
   	import mx.core.UIComponent;
   	import mx.events.DragEvent;
   	import mx.events.ValidationResultEvent;
   	import mx.formatters.NumberFormatter;
   	import mx.managers.DragManager;
   	import mx.utils.ObjectUtil;
   	import mx.utils.StringUtil;
   	import mx.validators.*;
   	
   	import org.osflash.thunderbolt.Logger;

	public class BuildForm extends UIComponent
	{
		public var formValidate:Array = new Array();
		public var formVariables:URLVariables = new URLVariables();		
		public var listeners:Array = new Array();
		public var listeners_obj:Array = new Array();
		
		private var formProperties:Array = new Array();
		
		public var fieldNotValid:*;
		
		public var formItems:ArrayCollection = new ArrayCollection();

		
	    //--------------------------------------------------------------------------
	    //
	    //  Constructor
	    //
	    //--------------------------------------------------------------------------
	
	    /**
	     *  Constructor.
	     */
		public function BuildForm():void
		{
			super();
		}

	    //----------------------------------
	    //  Create Fields/Form
	    //----------------------------------

		
		public function exclude(container:*,fields:Array):void 
		{
			formProperties.push({'container':container,'action':'exclude','fields':fields});
		}
		
		public function selected(container:*,fields:Array):void 
		{
			formProperties.push({'container':container,'action':'selected','fields':fields});
		}
		
		public function complete(container:*):void 
		{
			formProperties.push({'container':container,'action':'complete'});
		}

		public function exclude_groups(container:*, groups:Array,fields:Object = null):void 
		{
			formProperties.push({'group':true,'container':container,'action':'exclude','groups':groups,'fields':fields});
		}
		
		public function selected_groups(container:*, groups:Array,fields:Object = null):void 
		{
			formProperties.push({'group':true,'container':container,'action':'selected','groups':groups,'fields':fields});
		}
		
		public function complete_groups(container:*,fields:Object = null):void 
		{
			formProperties.push({'group':true,'container':container,'action':'complete','fields':fields});
		}
		
		public function build():void
		{
			Logger.info('BUILDING FORM AGAIN...');
			
			formValidate = new Array();
			
			for (var index:String in formProperties)
			{
				// container
				var obj:* = formProperties[index].container;
				
				// clear the container
				obj.removeAllChildren();
				
				var frmContainer:MultiColumnForm;
				
				if (formProperties[index].group) {
					frmContainer = buildFormGroups(index);
				} else {
					frmContainer = buildFormFields(index);
				}
				
				obj.addChild(frmContainer);
			}

			dispatchEvent(new BuildFormEvent("ADDED_TO_STAGE", frmContainer));
			
			isFormValid(false);
		}
	   		
		private function buildFormFields(index:String):MultiColumnForm 
		{
			Logger.info('building fields');
			
			// create the form
			var frmContainer:MultiColumnForm = new MultiColumnForm();
			frmContainer.percentWidth = 100;
			frmContainer.numColumns = this._numColumns;
			frmContainer.maxHeight = this.maxHeight;
			
			// build the form
			for(var i:String in layoutProvider.fields)
			{
				var field:Object = layoutProvider.fields[i];
				
				if (dataProvider != null) {
					field.value = dataProvider[field.fieldname];
				} else {
					field.value = ((field.default != "undefined") ? field.default : dataProvider[field.fieldname]);
				}
				
				if (((field.display) && (field.display = "none"))	|| (field.type == "hidden")) {
					continue;
				}
		
				switch (formProperties[index].action) 
				{
					case 'exclude':
						if (formProperties[index].fields.indexOf(field.fieldname) != -1) {
							continue;
						}
					break;
					case 'selected':
						if (formProperties[index].fields.indexOf(field.fieldname) == -1) {
							continue
						}
					break;
					
				}
				frmContainer.addChild(form_switch(field));
			}
			return frmContainer;		
		}

		private function buildFormGroups(index:String):MultiColumnForm 
		{
			if(_debug){ Logger.info('fields',ObjectUtil.toString(dataProvider)); }
			
			// create the form
			var frmContainer:MultiColumnForm = new MultiColumnForm();
			frmContainer.percentWidth = 100;
			frmContainer.numColumns = this._numColumns;
			frmContainer.maxHeight = this.maxHeight;					
			// build the form
			for(var i:String in layoutProvider.field_groups)
			{
				var group:Number = Number(i);
				var group_label:String = layoutProvider.field_groups[i];

				switch (formProperties[index].action) 
				{
					case 'exclude':
						if (formProperties[index].groups.indexOf(group) != -1) {
							continue;
						}
					break;
					case 'selected':
						if (formProperties[index].groups.indexOf(group) == -1) {
							continue;
						}
					break;
				}
				
				var lb:Label = new Label();
				lb.text = group_label;
				lb.styleName = 'groupLabel'; 
				frmContainer.addChild(lb);
				
				for(var ii:String in layoutProvider.fields)
				{
					var field:Object = layoutProvider.fields[ii];
					
					field.default = dataProvider[field.fieldname];
					
					if (((field.display) && (field.display = "none"))	|| (field.type == "none")) {
						continue;
					}
					
					if ((formProperties[index].fields != null) && (formProperties[index].fields[group])) 
					{
						switch (formProperties[index].fields[group].action) 
						{
							case 'exclude':
								if (formProperties[index].fields[group].fields.indexOf(field.fieldname) != -1) {
									continue;
								}
							break;
							case 'selected':
								if (formProperties[index].fields[group].fields.indexOf(field.fieldname) == -1) {
									continue;
								}
							break;
						}
					}
											
					if ((field.group) && (field.group == group)) {
						frmContainer.addChild(form_switch(field));
					}	
				}
			}
			return frmContainer;		
		}
		
		
		
	    //----------------------------------
	    //  FIELDS
	    //----------------------------------

		private function form_switch(item:Object):FormItem
		{
			// create the horizontal box
            var fitem:FormItem = new FormItem();
            fitem.label= (item.label ? item.label : item.fieldname);
            fitem.styleName = "fitemLabel";
            
            fitem.name = "fitem_"+item.fieldname;
            
            if(_formLabelWidth){ 
            	fitem.setStyle('labelWidth', _formLabelWidth);
            }
            
            if (item.rules) {
            	fitem.required = (item.rules.match("required") ? true : false);
            	if (fitem.required == true) {
	            	fitem.styleName = "requiredLabel";
	            }
            }
            
            if(_formWidth){
            	fitem.width = _formWidth;
            } else {
            	fitem.percentWidth = 100;
            }

			var pattern:RegExp = /\[(.*?)]/g;
			var type:String = item.type.replace(pattern,"");
			
			formVariables[item.fieldname] = "";
			
			switch(type)
			{
				case 'text':
				case 'number':
				case 'numeric':
				case 'money' :
				case 'currency':
				case 'initials':
				case 'credit_card':
				case 'password':
					if (textonly) 
					{
						var txt:Text = new Text();
						txt.text = item.value;
						txt.id = item.fieldname;
						txt.name = item.fieldname;
						txt.styleName = "txtOnly";
						fitem.addChild(txt);
						formItems.addItem({'id':txt,'fieldname':item.fieldname, 'type':type});
					} 
					else 
					{
						var input:TextInput = new TextInput();
						input.id = item.fieldname;
						input.name = item.fieldname;
						input.styleName = _formItemStyle;
						input.displayAsPassword = (item.type == "password") ? true : false;
						if(_formItemWidth){
							input.width = _formItemWidth;
						} else {
							input.percentWidth = 100;	
						}
						
						if (item.width) input.width = item.width;
						if (item.height) input.height = item.height;
	
						if (item.rules) {
							var num:RegExp = /max_length\[\d{1,3}\]/g;
							var max:* = item.rules.match(num);
							if (max[0] != undefined) input.maxChars = max[0].replace("max_length[","").replace("]","");
						}
						
						input.addEventListener(Event.CHANGE,function(event:Event):void { 
							formVariables[item.fieldname] = input.text; 
							dispatchEvent(new BuildFormEvent("DATA_CHANGE"));					
						});
						input.addEventListener(FocusEvent.FOCUS_OUT,function(event:FocusEvent):void {
							validateField(input); 
							event.target.text = StringUtil.trim(event.target.text);
						});
						fitem.addChild(input);
						
						if ((item.value) &&  (type != "password")) {
							formVariables[item.fieldname] = item.value;
							input.text = item.value;
						}
						
						if ((type == 'money') || (type == 'currency')){
						  	var nf:NumberFormatter = new NumberFormatter();
							nf.precision = 2;
							nf.thousandsSeparatorTo = ',';
						  	input.text = nf.format(input.text);
						}
	
						// Validate
						setFieldValidator(input,item);
	
						// Add Custom Event if exists
						addEvent(input,item.fieldname);
				
						// save the item added to the variable
						formItems.addItem({'id':input,'fieldname':item.fieldname, 'type':type});
					}
										
				break;	
				case 'longtext':
				
					if (textonly) 
					{
						var txtArea:Text = new Text();
						txtArea.text = item.value;
						txtArea.name = item.fieldname;
						txtArea.id = item.fieldname;
						txtArea.styleName = "txtOnly";
						fitem.addChild(txtArea);

						// save the item added to the variable
						formItems.addItem({'id':txtArea,'fieldname':item.fieldname, 'type':type});
					} 
					else 
					{
						var longtext:TextArea = new TextArea();
						longtext.id = item.fieldname;
						longtext.name = item.fieldname;
						longtext.styleName = _formItemStyle;
						if(_formItemWidth){
							longtext.width = _formItemWidth;
						} else {
							longtext.percentWidth = 100;
						}
	
						if (item.width) longtext.width = item.width;
						if (item.height) longtext.height = item.height;
	
						longtext.addEventListener(Event.CHANGE,function(event:Event):void { 
							dispatchEvent(new BuildFormEvent("DATA_CHANGE"));
							formVariables[item.fieldname] = longtext.text;  
						});
						longtext.addEventListener(FocusEvent.FOCUS_OUT,function(event:FocusEvent):void { 
							validateField(longtext);
							event.target.text = StringUtil.trim(event.target.text);
						});
	
						fitem.addChild(longtext);
	
						// Add Custom Event if exists
						addEvent(longtext,item.fieldname);
	
						if ((item.value))  
						{
							longtext.text = item.value;
							formVariables[item.fieldname] = item.value;	
						}
	
						// Validate
						setFieldValidator(longtext,item);
	
	
						// save the item added to the variable
						formItems.addItem({'id':longtext,'fieldname':item.fieldname, 'type':type});

					}
				break;
				case 'dropdown':
					if (textonly) 
					{
						var txtDrop:Text = new Text();
						for(var k:String in item.source)
						{
							if (k == item.value) {
								txtDrop.text = item.source[k];
							}
						}
						txtDrop.name = item.fieldname;
						txtDrop.id = item.fieldname;
						txtDrop.styleName = "txtOnly";
						fitem.addChild(txtDrop);

						// save the item added to the variable
						formItems.addItem({'id':txtDrop,'fieldname':item.fieldname, 'type':type});
					} 
					else 
					{
						var dp:*;
						var def:String = "0";
						
						if ((item.source is Array) && (typeof(item.source[0]) == "object")) 
						{
							dp = new Array();
							dp = item.source;
							for (var ci:String in dp) 
							{
								if (dp[ci].value == item.value)
								{
									def = ci;
									break;
								}
							}
						} 
						else 
						{
							dp =  new ArrayCollection();
							var x:Number = 0;
							
							for(var v:String in item.source)
							{	
								dp.addItem({'label':item.source[v],'value':v});
								if (v == item.value) {
									def = String(x);
								}
								x++;
							}
						}
							
	
						var combo:ComboBox = new ComboBox();
						combo.id = item.fieldname;
						combo.name = item.fieldname;
						combo.styleName = _formItemStyle;
						combo.dataProvider = dp;
						combo.useHandCursor = true;
						combo.buttonMode = true;
						if(_formItemWidth){
							combo.width = _formItemWidth;
						} else {
							combo.percentWidth = 100;
						}
	
						if (item.width) combo.width = item.width;
						if (item.height) combo.height = item.height;
	
						combo.addEventListener(Event.CHANGE,function(event:Event):void { 
							dispatchEvent(new BuildFormEvent("DATA_CHANGE"));
							formVariables[item.fieldname] = combo.selectedItem.value;
							validateField(combo);  
						});

						// Add Custom Event if exists
						addEvent(combo,item.fieldname);

						if (item.value)  
						{
							combo.selectedIndex = Number(def);
							formVariables[item.fieldname] = item.value;
						}
	
						fitem.addChild(combo);						
	
						// Validate
						setFieldValidator(combo,item);
	
						// save the item added to the variable
						formItems.addItem({'id':combo,'fieldname':item.fieldname, 'type':type});
					}
				break;	
				case 'boolean':
					if (textonly) 
					{
						var txtBool:Text = new Text();
						txtBool.text = ((item.value == 0) ? 'No': 'Yes');
						txtBool.name = item.fieldname;
						txtBool.id = item.fieldname;
						txtBool.styleName = "txtOnly";
						fitem.addChild(txtBool);

						// save the item added to the variable
						formItems.addItem({'id':txtBool,'fieldname':item.fieldname, 'type':type});
					} 
					else 
					{
						var choices:Array = new Array();
						choices[0] = {'label':"No",'value':0};
						choices[1] = {'label':"Yes",'value':1};
						
						var bool:ComboBox = new ComboBox();
						bool.id = item.fieldname;
						bool.name = item.fieldname;
						bool.styleName = _formItemStyle;
						bool.dataProvider = choices;
						bool.width = (item.width) ? item.width : 100;
						
						if (item.height) combo.height = item.height;
	
						bool.buttonMode = true;
						bool.useHandCursor = true;
						
	
						// Add Custom Event if exists
						addEvent(bool,item.fieldname);

						if (item.value) 	{
							bool.selectedIndex = item.value ? item.value : 0; 
						}
						
						formVariables[item.fieldname] = bool.selectedIndex;
						
						bool.addEventListener(Event.CHANGE,function(event:Event):void { 
							dispatchEvent(new BuildFormEvent("DATA_CHANGE"));
							formVariables[item.fieldname] = bool.selectedItem.value;  
						});
						fitem.addChild(bool);

						// save the item added to the variable
						formItems.addItem({'id':bool,'fieldname':item.fieldname, 'type':type});
					}
				break;	
				case 'date':

					if (textonly) 
					{
						var txtDate:Text = new Text();
						txtDate.text = item.value;
						txtDate.name = item.fieldname;
						txtDate.id = item.fieldname;
						txtDate.styleName = "txtOnly";
						fitem.addChild(txtDate);

						// save the item added to the variable
						formItems.addItem({'id':txtDate,'fieldname':item.fieldname, 'type':type});
					} 
					else 
					{
						var df:DateField = new DateField();
						df.name = item.fieldname;
						df.id = item.fieldname;
						df.styleName = _formItemStyle;
						df.yearNavigationEnabled = true;
						if(item.value > 0){
							df.selectedDate = EDateUtil.timestampToLocalDate( item.value ); 
						} else {	
							if(item.today){ df.selectedDate = new Date(); }
						}
						if(_formItemWidth){
							df.width = _formItemWidth;
						} else {
							df.percentWidth = 100;
						}
	
						if (item.width) df.width = item.width;
						if (item.height) df.height = item.height;
	
						var ft:RegExp = /\[(.*?)]/g;
						var ft_string:String = item.type.match(ft);
						df.formatString = (ft_string ? ft_string.replace("]","").replace("[","").toUpperCase()  : "MM/DD/YYYY");
	
						df.addEventListener(Event.CHANGE,function(event:Event):void { 
							dispatchEvent(new BuildFormEvent("DATA_CHANGE"));
							formVariables[item.fieldname] = EDateUtil.localDateToTimestamp( df.selectedDate );
						});
						df.addEventListener(FocusEvent.FOCUS_OUT,function(event:FocusEvent):void { validateField(df); });

						// Add Custom Event if exists
						addEvent(df,item.fieldname);
						
						if (item.value)  {
							//df.data = item.value;
							formVariables[item.fieldname] = item.value;						
						} else {
							if(item.today){
								formVariables[item.fieldname] = (df.selectedDate.getMonth()+1).toString() + '/' + df.selectedDate.getDate() + '/' + df.selectedDate.getFullYear();
							}
						}
	
						fitem.addChild(df);
						
						// Validate
						setFieldValidator(df,item);
	

						// save the item added to the variable
						formItems.addItem({'id':df,'fieldname':item.fieldname, 'type':type});
					}
				break;	
				case 'multiselect':
					var dumm:ArrayCollection = new ArrayCollection(['Test1','Test2','Test3']);
					var hhbox:HBox = new HBox();
					hhbox.percentWidth = 100;
					
					var list1:List = new List();
					list1.percentWidth = 50;
					list1.dataProvider = dumm;
					list1.allowMultipleSelection = true;
					list1.dropEnabled = true;
					list1.dragEnabled = true;
					list1.dragMoveEnabled = true;
					list1.setStyle("alternatingItemColors",["#FFFFFF", "#EEEEEE"]);
					list1.name = item.fieldname + '_source';
					list1.id = item.fieldname + '_source';

					list1.addEventListener(DragEvent.DRAG_DROP,function(e:DragEvent):void 
					{
						e.currentTarget.hideDropFeedback(e);
					});

					list1.addEventListener(DragEvent.DRAG_OVER,function(e:DragEvent):void 
					{
						if (e.target.id.replace('_source','') == List(e.dragInitiator).id.replace('_source','')) 
						{
							e.currentTarget.showDropFeedback(e);
							DragManager.showFeedback(DragManager.MOVE);
						} 
						else 
						{
							e.currentTarget.hideDropFeedback(e);
							e.preventDefault();
						}
					});
					
					list1.addEventListener(DragEvent.DRAG_EXIT,function(e:DragEvent):void {
						e.currentTarget.hideDropFeedback(e);
					});
			
					
					var list2:List = new List();
					list2.percentWidth = 50;
					list2.dataProvider = new ArrayCollection();
					list2.allowMultipleSelection = true;
					list2.dropEnabled = true;
					list2.dragEnabled = true;
					list2.dragMoveEnabled = true;
					list2.setStyle("alternatingItemColors",["#FFFFFF", "#EEEEEE"]);
					list2.name = item.fieldname;
					list2.id = item.fieldname;
					list2.addEventListener(DragEvent.DRAG_DROP,function(e:DragEvent):void 
					{
						e.currentTarget.hideDropFeedback(e);
					});

					list2.addEventListener(DragEvent.DRAG_OVER,function(e:DragEvent):void 
					{
						
						
						if (e.target.id == List(e.dragInitiator).id.replace('_source','')) 
						{
							e.currentTarget.showDropFeedback(e);
							DragManager.showFeedback(DragManager.MOVE);
						} 
						else 
						{
							e.currentTarget.hideDropFeedback(e);
							e.preventDefault();
						}
					});
					
					list2.addEventListener(DragEvent.DRAG_EXIT,function(e:DragEvent):void {
						e.currentTarget.hideDropFeedback(e);
					});
					
					hhbox.addChild(list1);
					hhbox.addChild(list2);
					
					fitem.addChild(hhbox);
					
				break;
			}	
			
			return fitem;
		}
			
	    //----------------------------------
	    //  VALIDATORS
	    //----------------------------------
		
		private function setFieldValidator(id:Object,validation:Object, match:TextInput = null):void
		{
			if (!validation.rules) {
				return;
			}			
			
			var rules:Array = validation.rules.split("|");
			
			for (var i:String in rules)
			{
				var pattern:RegExp = /\[(.*?)]/g;
				var rule:String	 = rules[i].replace(pattern,"");
				
				switch(rule)
				{
					case 'phone':
				 		var phoneValidator:PhoneNumberValidator = new PhoneNumberValidator();
		                phoneValidator.source = id;
		                phoneValidator.property = "text";
						phoneValidator.required = ((validation.rules.match("required")) ? true: false );
						phoneValidator.requiredFieldError = validation.label + " is required";
						formValidate.push({'validator':phoneValidator,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
   					break;
					case 'valid_email':
					case 'email':
					 	var emailValidator:EmailValidator = new EmailValidator();
						emailValidator.source = id;
						emailValidator.property = "text"; 		
						emailValidator.required = ((validation.rules.match("required")) ? true: false );	
						emailValidator.requiredFieldError = validation.label + " is required";
		                formValidate.push({'validator':emailValidator,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
					break;
					case 'currency':
						var curValidator:CurrencyValidator = new CurrencyValidator();
						curValidator.source = id;
						curValidator.property = "text";
						curValidator.required = ((validation.rules.match("required")) ? true: false );
						curValidator.requiredFieldError = validation.label + " is required";
		                formValidate.push({'validator':curValidator,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
					break;
					case 'number':
					case 'alpha_numeric':
						var nv:NumberValidator = new NumberValidator();
		                nv.source = id;
		                nv.property = "text";
						nv.required = ((validation.rules.match("required")) ? true: false );	
						nv.requiredFieldError = validation.label + " is required";
		                formValidate.push({'validator':nv,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
					break;
					case 'socialsecurity':
						var ss:SocialSecurityValidator = new SocialSecurityValidator();
						ss.source = id;
						ss.property = "text";
						ss.required = ((validation.rules.match("required")) ? true: false );
						ss.requiredFieldError = validation.label + " is required";
		                formValidate.push({'validator':ss,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
					break;
					case 'zip':
					case 'zipcode':
						var zipValidator:ZipCodeValidator = new ZipCodeValidator();
						zipValidator.source = id;
						zipValidator.property = "text";
						zipValidator.required = ((validation.rules.match("required")) ? true: false );
						zipValidator.requiredFieldError = validation.label + " is required";
		                formValidate.push({'validator':zipValidator,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
					break;
					case 'date':
						var dtv:DateValidator = new DateValidator();
						dtv.source = id;
						dtv.inputFormat = "dd/mm/yyyy";
						dtv.property = "text";
						dtv.required = ((validation.rules.match("required")) ? true: false );
						dtv.requiredFieldError = validation.label + " is required";
		                formValidate.push({'validator':dtv,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
					break;
					case 'creditcard':

					break;
					case 'required':
						if (id is ComboBox) {
							var cValidator:ComboValidator = new ComboValidator();
							cValidator.source = id;
							cValidator.property = "selectedIndex";
							cValidator.required = true;
							cValidator.requiredFieldError = validation.label + " is required";
			                formValidate.push({'validator':cValidator,'source':id,'fieldname':validation.fieldname,'rule':rule});						} 
						else 
						{
							var sValidator:StringValidator = new StringValidator();
							sValidator.source = id;
							sValidator.property = "text"
							sValidator.required = true;
							sValidator.requiredFieldError = validation.label + " is required";
			                formValidate.push({'validator':sValidator,'source':id,'fieldname':validation.fieldname,'rule':rule});
			   			}
					break;
					case 'pwd_conf':
					case 'password_conf':
						if (match != null) 
						{
							var pwdValidator:PWDValidator = new PWDValidator();
							pwdValidator.source = id;
							pwdValidator.required = false;
							pwdValidator.match = match;
							pwdValidator.property = "text";
			                formValidate.push({'validator':pwdValidator,'source':id,'fieldname':validation.fieldname,'rule':rule});
			   			}
					break;
				}
			}
		}
  

		public function isFormValid(verbose:Boolean = true):Boolean
		{
			var isInvalid:Boolean = false;
			for(var i:String in formValidate)
			{
				if (
					(notvalidate.indexOf(formValidate[i].fieldname) != -1)  ||  (notvalidate.indexOf('all') != -1)
					&&
					(validate.indexOf(formValidate[i].fieldname) == -1)
					) {
					continue;
				}
				
				if(_debug){ Logger.info('checking...', formValidate[i].source.toString()) }
				
				var vResult:ValidationResultEvent = formValidate[i].validator.validate(null,!verbose);
				if (vResult.type==ValidationResultEvent.INVALID) {

					if (!isInvalid){
						setValidationFocus(formValidate[i].source,false);
						fieldNotValid = formValidate[i].source;
						isInvalid = true;
					}
				}
			}
			
			if (isInvalid) {
				dispatchEvent(new BuildFormEvent("INVALID_FORM"));
			} else {
				dispatchEvent(new BuildFormEvent("VALID_FORM"));
			}
			
			// tells if the form is valid or not
			isValidForm  = !isInvalid;
			
			return !isInvalid;	
		}			

		private function validateField(source:Object):Boolean
		{
			isFormValid(false);
			for(var i:String in formValidate)
			{
				if (
					(notvalidate.indexOf(formValidate[i].fieldname) != -1)  ||  (notvalidate.indexOf('all') != -1)
					&&
					(validate.indexOf(formValidate[i].fieldname) == -1)
					) {

					continue;
				}
				
				if (formValidate[i].source == source) // find the source and get its details to validate
				{
					var vResult:ValidationResultEvent = formValidate[i].validator.validate();
					if (vResult.type==ValidationResultEvent.INVALID) {
							setValidationFocus(formValidate[i].source);
							return false;
					}else {
						source.errorString = '';
					}
				}
			}
			
			return true;
		}
		
		
		private function setValidationFocus(formObject:Object, setFocus:Boolean = false):void
		{
			if (setFocus) {
				formObject.setFocus();
			}
			
			formObject.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
		}
  		//----------------------------------
	    //  dont validate
	    //----------------------------------
	
	    /**
	     *  @private
	     *  fields that are not going to be validate.
	     */
		private var _notvalidate:Array = new Array();

	   	public function get notvalidate():Array
	    {
	        return _notvalidate;
	    }
	
	    public function set notvalidate(value:Array):void
	    {
			_notvalidate = value;	
	    }

	    //----------------------------------
	    //  validate
	    //----------------------------------
	
	    /**
	     *  @private
	     *  fields that are going to be validate.
	     */
		private var _validate:Array = new Array();

	   	public function get validate():Array
	    {
	        return _validate;
	    }
	
	    public function set validate(value:Array):void
	    {
			_validate = value;	
	    }

    	//----------------------------------
	    //  EVENTS
	    //----------------------------------

		public function addCustomEventListener(obj:String, evt:*, func:Function):void
		{
			listeners.push({'object':obj,'evt':evt,'func':func});
			listeners_obj.push(obj);
		}
		
		private function addEvent(obj:*, fieldname:String):void
		{
			var pos:Number = listeners_obj.indexOf(fieldname);
			if (pos != -1)
			{
				for (var i:* in listeners)
				{
					if (listeners[i].object == fieldname)
					{
						obj.addEventListener(listeners[i].evt, listeners[i].func);
					}
				}
			}
		}
		
		public function reset():void 
		{
			dataProvider = null;
		}
		
	    //----------------------------------
	    //  debug function
	    //----------------------------------
		public function debug(... args):void 
		{
			for(var i:uint = 0; i< args.length;i++) 
			{
				if ((args[i] is ArrayCollection) || (args[i] is Object) || (args[i] is DisplayObjectContainer)) {
					args[i] = ObjectUtil.toString(args[i],null,[]);
				}
			}
			Logger.debug('debug',args);	
		}

		private var _debug:Boolean = false;
		
		public function set debugMode(value:Boolean):void
	    {
			_debug = value;		
	    }
		

	    //----------------------------------
	    //  Form item style name
	    //----------------------------------
	
	    /**
	     *  @private
	     *  id of the object.
	     */
		private var _formItemStyle:String = 'formInput';

	   	public function get formItemStyle():String
	    {
	        return _formItemStyle;
	    }
	
	    public function set formItemStyle(value:String):void
	    {
			_formItemStyle = value;		
	    }

		private var _formLabelWidth:Number = 120;
	
	    public function set formLabelWidth(value:Number):void
	    {
			_formLabelWidth = value;		
	    }
	    
		private var _formWidth:Number;
	    public function set formWidth(value:Number):void
	    {
			_formWidth = value;
	    }

		private var _formItemWidth:Number = 180;
	    public function set formItemWidth(value:Number):void
	    {
			_formItemWidth = value;
	    }

	    //----------------------------------
	    //  layout
	    //----------------------------------
	
	    /**
	     *  @private
	     *  layout
	     */
	    public var layoutLoaded:Boolean = false;
	    
		private var _layoutProvider:Object;

	   	public function get layoutProvider():Object
	    {
	        return _layoutProvider;
	    }
		
	    public function set layoutProvider(value:Object):void
	    {
			_layoutProvider = value;

			if (layoutLoaded) {
				build();
			}
	    }

	    /**
	     *  @private
	     *  number of columns the form should have
	     */	    
		private var _numColumns:int = 1;

	   	public function get numColumns():int
	    {
	        return _numColumns;
	    }
	
	    public function set numColumns(value:int):void
	    {
			_numColumns = value;
	    }	    


	    //----------------------------------
	    //  textonly
	    //----------------------------------
	
	    /**
	     *  @private
	     *  fields on textonly mode
	     */
		private var _textonly:Boolean = false;

	   	public function get textonly():Boolean
	    {
	        return _textonly;
	    }
	
	    public function set textonly(value:Boolean):void
	    {
			_textonly = value;	
	    }	    

	
	    /**
	     *  @private
	     *  data Provider
	     */
		private var _dataProvider:Object = null;

		[Bindable(event="dataProviderChange")]
	   	public function get dataProvider():Object
	    {
	        return _dataProvider;
	    }
	    
	    public function set dataProvider(value:Object):void
	    {
			_dataProvider = value;
			dispatchEvent( new Event( "dataProviderChange" ) );

			if (layoutLoaded) {
				build();
			}
	    }
	    
	    /**
	     *  @private
	     *  isValid checks if the form is valid or not
	     */
		private var _isValidForm:Boolean = false;

		[Bindable(event="isValidChange")]
	   	public function get isValidForm():Boolean
	    {
	        return _isValidForm;
	    }
	    
	    public function set isValidForm(value:Boolean):void
	    {
			_isValidForm = value;
			dispatchEvent( new Event( "isValidChange" ) );
	    }
	    	    
	    	    
	    private function $(fieldname:String):*
	    {
	    	for (var i:uint = 0; i<formItems.length;i++)
	    	{
	    		if (formItems.getItemAt(i).fieldname == fieldname) {
	    			return formItems.getItemAt(i).id;
	    		}	
	    	}
	    	return null;	
	    }
	}
}	