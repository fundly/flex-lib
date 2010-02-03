package com.enilsson.utils.struktorForm
{
	import com.enilsson.containers.MultiColumnForm;
	import com.enilsson.controls.AutoCompleteSearch;
	import com.enilsson.controls.ExpirationDate;
	import com.enilsson.controls.LookupInput;
	import com.enilsson.controls.StackableFormItem;
	import com.enilsson.controls.TimeStepper;
	import com.enilsson.utils.buildform.PWDValidator;
	import com.enilsson.validators.AutoCompleteValidator;
	import com.enilsson.validators.ComboRequiredValidator;
	import com.enilsson.validators.DateFieldValidator;
	import com.enilsson.validators.ExpirationDateValidator;
	import com.enilsson.validators.LookupInputValidator;
	import com.enilsson.validators.SelectionNumericValidator;
	import com.enilsson.validators.TimeValidator;
	import com.enilsson.validators.VariableMatchRegExValidator;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.DateField;
	import mx.controls.Label;
	import mx.controls.List;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.events.ValidationResultEvent;
	import mx.formatters.NumberFormatter;
	import mx.managers.DragManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	import mx.validators.CreditCardValidator;
	import mx.validators.CurrencyValidator;
	import mx.validators.DateValidator;
	import mx.validators.EmailValidator;
	import mx.validators.NumberValidator;
	import mx.validators.PhoneNumberValidator;
	import mx.validators.SocialSecurityValidator;
	import mx.validators.StringValidator;
	import mx.validators.ZipCodeValidator;
	
	import org.osflash.thunderbolt.Logger;

	[Style(name="formInputStyleName", type="String", inherit="no")]
	[Style(name="formItemStyleName", type="String", inherit="no")]
	[Style(name="formInputWidth", type="Number", inherit="no")]	
	[Style(name="formLabelWidth", type="Number", inherit="no")]
	[Style(name="requiredLabelStyleName", type="String", inherit="no")]
	[Style(name="textOnlyStyleName", type="String", inherit="no")]	
	[Style(name="groupLabelStyleName", type="String", inherit="no")]
	[Style(name="stackFormItems", type="Boolean", inherit="no")]
	[Style(name="rteStyleName", type="String", inherit="no")]
	[Style(name="fileLinkButtonStyleName", type="String", inherit="no")]
	
	[Event(name="formValid", type="flash.events.Event")]
	[Event(name="formInvalid", type="flash.events.Event")]
	[Event(name="isValidChanged", type="flash.events.Event")]
	[Event(name="formBuildComplete", type="flash.events.Event")]
	[Event(name="dataChange", type="flash.events.Event")]

	public class StruktorForm extends MultiColumnForm
	{
		private static var classInitialized:Boolean = false;

		private static function initializeClass():void
		{
			StyleManager.registerSizeInvalidatingStyle("formInputWidth");
		}

		public function StruktorForm()
		{
			super();
	
			if (!classInitialized)
			{
				initializeClass();
				classInitialized = true;
			}

			setStyle('paddingTop', 5);
			
			setStyles();
		}

		private function setStyles():void
		{
			if (!StyleManager.getStyleDeclaration("StruktorForm"))
			{
				var componentLayoutStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
				componentLayoutStyles.defaultFactory = function():void
				{
					this.formInputStyleName = 'formInputStyleName',
					this.formLabelStyleName = 'formItemStyleName',
					this.formInputWidth = 150,
					this.formLabelWidth = 100,
					this.requiredLabelStyleName = 'requiredLabelStyleName',
					this.textOnlyStyleName = 'textOnlyStyleName',
					this.groupLabelStyleName = 'groupLabelStyleName',
					this.stackFormItems = false,
					this.rteStyleName = 'rteStyleName',
					this.fileLinkButtonStyleName = 'fileLinkButtonStyleName'
				}
				StyleManager.setStyleDeclaration("StruktorForm", componentLayoutStyles, true);
			}
		}

		private var updateFormInputWidth:Boolean;
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			if(updateFormInputWidth)
			{
				for each ( var field:Object in _fields )
				{
					field.width = getStyle('formInputWidth');
				}
				updateFormInputWidth = false;
			}
		}

		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);

			if (!styleProp ||
				styleProp == "styleName" ||
				StyleManager.isSizeInvalidatingStyle(styleProp))
			{
				updateFormInputWidth = true;
			}
		}

		/**
		 * Attach the layout data to the component
		 */
		private var _layout:Object;
		public function set layoutProvider(value:Object):void
		{
			if(_debug) Logger.info('Set LayoutProvider', ObjectUtil.toString(value));
			
			_layout = value;
			
			_allFields = new Array();
			for each ( var field:Object in value.fields )
				_allFields.push(field.fieldname);
			
			// build the form
			invalidateForm();
		}
		public function get layoutProvider():Object
		{
			return _layout;
		}
		
		/**
		 * Add values to the form elements
		 */
		private var _data:Object;
		public function set dataProvider(value:Object):void
		{
			if(_debug) Logger.info('Set DataProvider', ObjectUtil.toString(value));

			_data = value;
			invalidateForm();
		}
		public function get dataProvider():Object
		{
			return _data;
		}

	    /**
	     *  Display in textonly mode
	     */
		private var _textonly:Boolean = false;
	    public function set textonly(value:Boolean):void
	    {
			_textonly = value;	
	    }	    
	   	public function get textonly():Boolean
	    {
	        return _textonly;
	    }

		/**
		 * List of selected fields to display in the form
		 */
		private var _selectedFields:Array;
		public function set selectedFields(value:Array):void
		{
			_selectedFields = value;
			invalidateForm(true);
		}
		public function get selectedFields():Array
		{
			return _selectedFields;
		}		

		/**
		 * List of selected groups to display in the form
		 */
		private var _selectedGroups:Array;
		public function set selectedGroups(value:Array):void
		{
			_selectedGroups = value;
			invalidateForm(true);
		}
		public function get selectedGroups():Array
		{
			return _selectedGroups;
		}		

		/**
		 * List of excluded fields NOT to display in the form
		 */
		private var _excludedFields:Array;
		public function set excludedFields(value:Array):void
		{
			_excludedFields = value;		
			invalidateForm(true);
		}
		public function get excludedFields():Array
		{
			return _excludedFields;
		}	
		
		/**
		 * List of excluded groups NOT to display in the form
		 */
		private var _excludedGroups:Array;
		public function set excludedGroups(value:Array):void
		{
			_excludedGroups = value;	
			invalidateForm(true);
		}
		public function get excludedGroups():Array
		{
			return _excludedGroups;
		}		
		
		/**
		 * Show or hide the group labels
		 */
		private var _groupLabels:Boolean = true;
		public function set groupLabels ( value:Boolean ):void
		{
			_groupLabels = value;
		}	
		
		/**
		 * Bindable variable to show if the form is currently valid
		 */
		private var _isValid:Boolean = false; 
		public function set isValid(value:Boolean):void
		{	
			_isValid = value;
			
			if(_debug) Logger.info('isValidChanged Event', _isValid);
			
			dispatchEvent( new Event('isValidChanged') );
		}	
		[Bindable(event="isValidChanged")]			
		public function get isValid():Boolean
		{
			return _isValid;
		}	
		
		/**
		 * Return all the fields that have failed validation
		 */
		private var _invalidFields:Array;
		[Bindable(event="isValidChanged")]
		public function get invalidFields():Array
		{
			var fields:Array = new Array();
			for ( var i:String in _invalidFields)
			{
				if(fields.indexOf(_invalidFields[i].field) > -1)
					_invalidFields.splice(i,1);
				else
					fields.push(_invalidFields[i].field);
			}
			return _invalidFields;
		}
		
		/**
		 * ListCollection of the form items, their field names and the values
		 */
		private var _formVariables:Object = new Object();
		public function set formVariables(value:Object):void
		{
			for(var i:String in value)
				_formVariables[i] = value[i];
			
			dispatchEvent( new Event('dataChange') );
		}
		[Bindable(event="dataChange")]
		public function get formVariables():Object
		{
			return _formVariables;
		}

		/**
		 * Set the component to run in debug mode
		 */
		private var _debug:Boolean = false;
		
		[Inspectable( type="Boolean" )]		
		public function set debugMode(value:Boolean):void
	    {
			_debug = value;		
	    }


	    /**
	     *  @public
	     *  Clear all fields 
	     */
	    private var clear:Boolean;
		public function set clearForm( value:Boolean ):void
		{
			if ( !value ) return;
			
			if(_debug) Logger.info('Clear Form');
			
			// wipe the variables
			_formVariables = new Object();
			this.data = null;
			
			// force a rebuild on the form
			invalidateForm( true );
		}

		/**
		 * Return an array of all the fieldnames for this table
		 */
		private var _allFields:Array;
		[Bindable(event="formBuildComplete")]
		public function get allFields():Array
		{
			return _allFields;
		}
		
		/**
		 * Return an array of all the fieldnames included in this form
		 */
		[Bindable(event="formBuildComplete")]
		public function get fieldNames():Array
		{
			return _fieldNames;
		}
		
		/**
		 * Return a field from the form, useful for data binding operations
		 */
		public function getField(fieldName:String):*
		{
			// if there is nothing in the form return null
			if(numChildren == 0)
				return null;
			
			// loop through the validator array and grab the appropriate input
			for ( var i:String in _fields)
			{
				if(i == fieldName)
					return _fields[i];
			}
			
			return null;
		}

		/**
		 * Return the layout information for one field by its name
		 */
		public function getFieldLayout(fieldName:String):Object
		{
			// if there is nothing in the form return null
			if(numChildren == 0)
				return null;
			
			// loop through the validator array and grab the appropriate layout object
			for ( var i:String in layoutProvider.fields)
			{
				var field:Object = layoutProvider.fields[i];
				if(field.fieldname == fieldName)
					return field;
			}
			
			return null;
		}
		
		/**
		 * Get the first field in the form
		 */
		public function get firstField():*
		{
			// if there is nothing in the form return null
			if(numChildren == 0)
				return null;

			for( var i:int=0; i < fieldNames.length; i++ )
			{
				var layoutObj:Object = getFieldLayout( fieldNames[i] );
				
				if ( layoutObj.type != 'hidden' )
					return _fields[fieldNames[i]];
			}

			return null;
		}
		
		/**
		 * Get the last field in the form
		 */
		public function get lastField():*
		{
			// if there is nothing in the form return null
			if(numChildren == 0)
				return null;
				
			for( var i:int = fieldNames.length - 1; i >= 0; i-- )
			{
				var layoutObj:Object = getFieldLayout( fieldNames[i] );
				
				if ( layoutObj.type != 'hidden' )
					return _fields[fieldNames[i]];
			}

			return null;
		}		
		
		/**
		 * Run the form validation
		 */
		public function runValidation():void
		{
			this.isFormValid(true);
		}


		/**
		 * Add values to the form elements
		 */
		private var _onChange:Function = null;
		public function set onChange(value:Function):void
		{
			if(_debug) Logger.info('on Change');

			_onChange = value;
			invalidateForm();
		}
		public function get onChange():Function
		{
			return _onChange;
		}

		/**
		 * Set a flag to validate fields on keypress
		 */
		private var _validateOnKeyPress:Boolean = false;
		public function set validateOnKeyPress(value:Boolean):void
		{
			_validateOnKeyPress = value;
		}
		public function get validateOnKeyPress():Boolean
		{
			return _validateOnKeyPress;
		}
		
		/**
		 * Set a flag to validate fields when they are updated via actionScript
		 */
		private var _validateOnValueCommit:Boolean = true;
		public function set validateOnValueCommit(value:Boolean):void
		{
			_validateOnValueCommit = value;
		}
		public function get validateOnValueCommit():Boolean
		{
			return _validateOnValueCommit;
		}		


	// ---------
	// Private Functions
	// ---------

		/**
		 * Clear the form and rebuild the children
		 */
		private function invalidateForm( rebuild:Boolean = false ):void
		{
			// some debugging
			if(_debug) Logger.info('Invalidate Form', rebuild);	

			// do nothing if there is no layout assigned yet
			if(!_layout)
				return
			
			// do nothing if the form has been built once and there is no data yet
			if(!rebuild)
				if(numChildren > 0 && _data.length == 0) 
					return;
			
			// clear the form stage
			removeAllChildren();
			
			// some debugging
			if(_debug) Logger.info('Form Pre Build', this.numChildren);			
			
			// run the build routine
			build();
			
			// some debugging
			if(_debug) Logger.info('Form Built', this.numChildren);
			
			// fire an event to say the form build is done
			if(numChildren > 0)
				dispatchEvent( new Event( 'formBuildComplete', true ) );
			
			// fire the validation routine to send a value to the valid binding
			isValid = isFormValid(false);	
		}
		
		/**
		 * Build the form items from the assigned layout
		 */
		private var _fields:Array = new Array();
		private var _fieldNames:Array = new Array();			 
		private function build():void
		{			
			// some debugging
			if(_debug) Logger.info('Build Function', _selectedGroups, _excludedGroups, _selectedFields, _excludedFields);
			
			// clear the form variables
			_formVariables = new Object();
			_formValidate = new Array();
			_fields = new Array();
			_fieldNames = new Array();
			clearBindings();
			
			// if there is data there add the primary key as a variable
			if(_data)
				_formVariables[_layout.primary_key] = _data[_layout.primary_key];
			
			// if there are groups listed build with them in mind	
			if(_excludedGroups || _selectedGroups)
				buildGroups();
				
			// if not build field by field
			else
				buildFields();
				
			formVariables = _formVariables;
		}
		
		
		/**
		 * Loop through each of the fields and build them according to the structure file
		 */
		private function buildFields():void
		{
           	// some debugging
           	if(_debug) Logger.info('Build Fields', ObjectUtil.toString(_selectedFields), ObjectUtil.toString(_excludedFields));

			// if there are selected fields order them as they appear in the property
			if(_selectedFields)
			{
				for( var jj:int = (_selectedFields.length-1); jj > -1;  jj-- )
				{
					for (var j:int=0; j < _layout.fields.length; j++)
					{
						if(_layout.fields[j].fieldname == _selectedFields[jj])
							_layout.fields.unshift(_layout.fields.splice(j, 1)[0]);
					}
				}
			}

			// build the form
			for(var i:String in _layout.fields)
			{
				// grab the field object
				var field:Object = _layout.fields[i];
				
				// if the field has no properties then continue
				if(!field.hasOwnProperty('label') || !field.hasOwnProperty('type') || !field.hasOwnProperty('rules'))
					continue;
				
				// add the data to the field
				if(_data == null)
					field.value = '';
				else
					field.value = _data[field.fieldname];
				
				// dont show if the layout says not to display
				if( field.hasOwnProperty('display') )
					if(field.display === false)
						continue;

				// only show fields from the selected list
				if(_selectedFields)
					if(_selectedFields.indexOf(field.fieldname) == -1)
						continue;					

				// dont show if fields are excluded
				if(_excludedFields)
					if(_excludedFields.indexOf(field.fieldname) != -1)
						continue;					

				// build the form item and add it to the form
				addChild(formSwitch(field));
			}
		}
		
		
		/**
		 * Loop through the listed groups and build the form according to the structure file
		 */
		private function buildGroups():void
		{
			if(_debug) Logger.info('Build Groups');
           	
			for(var i:String in _layout.field_groups)
			{
				var group:Number = Number(i);
				var group_label:String = _layout.field_groups[i];

				if(_selectedGroups)
					if(_selectedGroups.indexOf(group) == -1)
						continue;
				
				if(_excludedGroups)
					if(_excludedGroups.indexOf(group) != -1)
						continue;
				
				if(_groupLabels)
				{
					var lb:Label = new Label();
					lb.text = group_label;
					lb.styleName = getStyle('groupLabelStyleName'); 
					addChild(lb);
				}
				
				for each (var field:Object in _layout.fields)
				{										
					// if the field has no properties then continue
					if(!field.hasOwnProperty('label') || !field.hasOwnProperty('type') || !field.hasOwnProperty('rules'))
						continue;

					// if the group id is present and equals the listed group proceed
					if( field.hasOwnProperty('group') )
					{
						if(Number(field.group) != group) 
							continue;
					}
					else
						continue;
					
					if(_data == null)
						field.value = '';
					else
						field.value = _data[field.fieldname];
					
					if( field.hasOwnProperty('display') )
						if(field.display === false)
							continue;
					
					if(_selectedFields)
						if(_selectedFields.indexOf(field.fieldname) == -1)
							continue;					

					if(_excludedFields)
						if(_excludedFields.indexOf(field.fieldname) != -1)
							continue;					
											
					addChild(formSwitch(field));
				}
			}
		}
		
		/**
		 * Create a single form item and its validators
		 */
		private function formSwitch(value:Object):*
		{
            var fitem:StackableFormItem = new StackableFormItem();
            fitem.stacked = getStyle('stackFormItems');
            fitem.label= value.label ? value.label : value.fieldname;
            fitem.id = 'fItem_'+value.fieldname;
            fitem.name = 'fItem_'+value.fieldname;
            fitem.styleName = getStyle('formItemStyleName');
			fitem.setStyle('labelWidth', getStyle('formLabelWidth'));
			fitem.percentWidth = 100;
			fitem.direction = 'horizontal';
           
            if (value.rules) 
            {
            	fitem.required = value.rules.match("required") ? true : false;
            	if(fitem.required)
		            fitem.styleName = getStyle('requiredLabelStyleName');
            }

			var pattern:RegExp = /\[(.*?)]/g;
			var type:String = value.type.replace(pattern,"");
			
			var validatableField : UIComponent;
		
			if (value.info) fitem.info = value.info;
			
			_formVariables[value.fieldname] = "";
			_fieldNames.push(value.fieldname);

			switch(type)
			{
				case 'hidden':
					// create a hidden Text who's FormItem is invisible and not included in the form's layout.
					var hiddenTxt : Text = new Text();
					hiddenTxt.id = value.fieldname;
					hiddenTxt.name = value.fieldname;
					fitem.visible = false;
					fitem.includeInLayout = false;
					fitem.height = 0;
					
					if(_data) {
						if( value.default && !_data[value.fieldname] )
							_formVariables[value.fieldname] = value.default;
						else
							_formVariables[value.fieldname] = _data[value.fieldname];
					}
					else
						_formVariables[value.fieldname] = value.default;
						
					hiddenTxt.text = _formVariables[value.fieldname]; 
					
					hiddenTxt.addEventListener(FlexEvent.VALUE_COMMIT, function(e:FlexEvent):void {
						_formVariables[value.fieldname] = e.currentTarget.text;							
						formVariables = _formVariables;
					});
					
					fitem.addChild(hiddenTxt);
					_fields[value.fieldname] = hiddenTxt;
				break;
				
				case 'text':
				case 'number':
				case 'numeric':
				case 'money' :
				case 'currency':
				case 'initials':
				case 'credit_card':
				case 'password':
				
					if (_textonly) 
					{
						var txt:Text = new Text();
						txt.text = value.value;
						txt.styleName = getStyle('textOnlyStyleName');
						fitem.addChild(txt);
					} 
					else 
					{
						var input:TextInput = new TextInput();
						input.id = value.fieldname;
						input.name = value.fieldname;
						input.styleName = getStyle('formInputStyleName');
						input.displayAsPassword = (value.type == "password") ? true : false;
						input.width = getStyle('formInputWidth');

						if(value.hasOwnProperty('editable'))
							input.editable = value.editable == 1;

						if (value.rules) 
						{
							var num:RegExp = /max_length\[\d{1,3}\]/g;
							var max:* = value.rules.match(num);
							if (max[0] != undefined) input.maxChars = max[0].replace("max_length[","").replace("]","");
						}
						
						// register and validate on keypresses
						input.addEventListener(KeyboardEvent.KEY_UP,function(e:KeyboardEvent):void { 
							// set the form variables depending on what type of text field it is
							if(type == 'money' || type == 'currency')
								_formVariables[value.fieldname] = parseFloat(e.currentTarget.text.replace(/\,/g,''));
							else
								_formVariables[value.fieldname] = StringUtil.trim(e.currentTarget.text); 
							
							formVariables = _formVariables;
							
							if (_onChange != null) onChange();
							
							// on validate on key press if requested
							if( _validateOnKeyPress ) validateField(e.currentTarget); 
						});
						
						// validate on focus out
						input.addEventListener(FocusEvent.FOCUS_OUT,function(e:FocusEvent):void { 
							e.currentTarget.text = StringUtil.trim(e.currentTarget.text);
							validateField(e.currentTarget);							
						});

						// register and validate on when the field is altered via actionscript
						input.addEventListener(FlexEvent.VALUE_COMMIT, function(e:FlexEvent):void {
							if(type == 'money' || type == 'currency')
								_formVariables[value.fieldname] = e.currentTarget.text == '' ? 0 : parseFloat(e.currentTarget.text.replace(/\,/g,''));
							else
								_formVariables[value.fieldname] = e.currentTarget.text; 
							
							formVariables = _formVariables;
							
							if(e.currentTarget.text != '')
								if(this._validateOnValueCommit)
									validateField(e.currentTarget);
							else
								e.currentTarget.errorString = '';
							
							if (_onChange != null) onChange();
						});
						
						if ((value.value) && !clear && (type != "password")) 
						{
							_formVariables[value.fieldname] = value.value;
							input.text = value.value;
						}
						
						if ((type == 'money') || (type == 'currency') || (type == 'number'))
						{
						  	var nf:NumberFormatter = new NumberFormatter();
							nf.precision = 2;
							nf.thousandsSeparatorTo = ',';
						  	input.text = nf.format(input.text);
						  	input.restrict = "/0-9\,\.\-";
						}
						
						if (type == 'credit_card')
						  	input.restrict = "/0-9";
	
						fitem.addChild(input);
							
						setFieldValidator(input,value);
						validatableField = input;
				
						_fields[value.fieldname] = input;						
					}
										
				break;	
				case 'autocomplete':
				
					if (_textonly) 
					{
						var acTxt:Text = new Text();
						acTxt.text = value.value;
						acTxt.styleName = getStyle('textOnlyStyleName');
						fitem.addChild(acTxt);
					} 
					else 
					{
						var acdp:*;
						
						if(value.source)
						{
							if (value.source is Array) 
							{
								acdp = new Array();
								acdp = value.source;
							}
							else
							{
								acdp =  new ArrayCollection();
								
								for(var acv:String in value.source)
								{	
									acdp.addItem({'label':value.source[acv],'value':acv});
								}
							}
						}
						
						var acInput:AutoCompleteSearch = new AutoCompleteSearch();
						acInput.id = value.fieldname;
						acInput.name = value.fieldname;
						acInput.styleName = getStyle('formInputStyleName');
						acInput.width = getStyle('formInputWidth');
						
						if (acdp)  
						{
							acInput.dataProvider = acdp;
							acInput.selectedIndex = 0;
							acInput.typedText = acdp[0].label;
							_formVariables[value.fieldname] = acInput.selectedItem.value;
						}
						
						if(value.defaultString)
							acInput.defaultString = value.defaultString;
						
						acInput.addEventListener(FocusEvent.FOCUS_OUT,function(e:FocusEvent):void { 
							validateField(acInput); 
							e.currentTarget.text = StringUtil.trim(e.currentTarget.text);
							
							if(e.currentTarget.hasOwnProperty('selectedItem'))
							{
								if(e.currentTarget.selectedItem.hasOwnProperty('value'))
									_formVariables[value.fieldname] = e.currentTarget.selectedItem.value;
								else
									_formVariables[value.fieldname] = null;
							}
							else
								_formVariables[value.fieldname] = null;
								 
							formVariables = _formVariables;

							if (_onChange != null) onChange();
						});
						
						if ((value.value) && !clear) 
						{
							_formVariables[value.fieldname] = value.value;
							acInput.text = value.label;
						}
	
						fitem.addChild(acInput);
						
						setFieldValidator(acInput,value);
						validatableField = acInput;
				
						_fields[value.fieldname] = acInput;						
					}	
								
				break;
				case 'file_link' :
				
					if (_textonly) 
					{
						var flTxt:Text = new Text();
						flTxt.text = value.value;
						flTxt.styleName = getStyle('textOnlyStyleName');
						fitem.addChild(flTxt);
					} 
					else 
					{
						var flBox:HBox = new HBox();
						flBox.id = value.fieldname;
						flBox.name = value.fieldname;
						flBox.width = getStyle('formInputWidth');
						flBox.setStyle('horizontalGap', 2);
						flBox.setStyle('verticalAlign', 'middle');
						
						var flInput:TextInput = new TextInput();
						flInput.percentWidth = 100;
						flInput.tabEnabled = false;
						flInput.styleName = getStyle('formInputStyleName');
						flBox.addChild(flInput);	
						
						var flButton:Button = new Button();
						flButton.label = 'Browse';
						flButton.tabEnabled = false;
						flButton.styleName = getStyle('fileLinkButtonStyleName');
						flBox.addChild(flButton);					

						flInput.addEventListener(FlexEvent.VALUE_COMMIT, function(e:Event):void { 
							_formVariables[value.fieldname] = e.currentTarget.text;
							formVariables = _formVariables;
							validateField(e.currentTarget); 
						});

						if ((value.value) && !clear) 
						{
							_formVariables[value.fieldname] = value.value;
							flInput.text = value.value;
						}
	
						fitem.addChild(flBox);
						
						setFieldValidator(flInput,value);
						validatableField = flInput;
				
						_fields[value.fieldname] = flInput;	
					}					
				
				break;
				case 'lookup':
				
					if (_textonly) 
					{
						var luTxt:Text = new Text();
						luTxt.text = value.value;
						luTxt.styleName = getStyle('textOnlyStyleName');
						fitem.addChild(luTxt);
					} 
					else 
					{
						var lookup:LookupInput = new LookupInput();
						lookup.id = value.fieldname;
						lookup.name = value.fieldname;
						lookup.styleName = getStyle('formInputStyleName');
						lookup.width = getStyle('formInputWidth');						

						if(_debug) Logger.info('Build Lookup', value.default, value.value);

						if(value.default && (typeof(value.value) == 'undefined' || value.value == ''))
							lookup.setData = value.default;
						else
							lookup.dataValue = value.value;
						
						lookup.addEventListener('dataValueChanged',function(event:Event):void {
							if(_debug) Logger.info('CHANGED',lookup.dataValue,value.fieldname); 
							_formVariables[value.fieldname] = lookup.dataValue; 
							formVariables = _formVariables;
						});
						
						lookup.addEventListener(FocusEvent.FOCUS_OUT,function(event:FocusEvent):void { 
							validateField(lookup); 
							if (_onChange != null) onChange();
						});
						
						fitem.addChild(lookup);
							
						setFieldValidator(lookup,value);
						validatableField = lookup;
				
						_fields[value.fieldname] = lookup;						
					}
										
				break;	
				case 'longtext':
				
					if (textonly) 
					{
						var txtArea:Text = new Text();
						txtArea.text = value.value;
						txtArea.styleName = getStyle('textOnlyStyleName');
						fitem.addChild(txtArea);
					} 
					else 
					{
						var longtext:TextArea = new TextArea();
						longtext.id = value.fieldname;
						longtext.name = value.fieldname;
						longtext.styleName = getStyle('formInputStyleName');
						longtext.width = getStyle('formInputWidth');
						longtext.height = value.height;
						fitem.addChild(longtext);

						if(value.hasOwnProperty('editable'))
							longtext.editable = value.editable == 1;

						longtext.addEventListener(KeyboardEvent.KEY_UP,function(e:KeyboardEvent):void { 
							formVariables[value.fieldname] = e.currentTarget.text;  
							
							if (_onChange != null) onChange();
						});

						longtext.addEventListener(FlexEvent.VALUE_COMMIT, function(e:FlexEvent):void { 
							formVariables[value.fieldname] = e.currentTarget.text;  
							
							if(this._validateOnValueCommit)
								validateField(e.currentTarget);
							
							if (_onChange != null) onChange();
						});
						
						longtext.addEventListener(FocusEvent.FOCUS_OUT,function(e:FocusEvent):void { 
							validateField(e.currentTarget);
							e.currentTarget.text = StringUtil.trim(e.currentTarget.text);
						});						
	
						if (value.rules) 
						{
							var ltNum:RegExp = /max_length\[\d{1,3}\]/g;
							var ltMax:* = value.rules.match(ltNum);
							if (ltMax[0] != undefined) longtext.maxChars = ltMax[0].replace("max_length[","").replace("]","");
						}
	
						if ((value.value) && !clear)  
						{
							longtext.text = value.value;
							_formVariables[value.fieldname] = value.value;	
						}
						
						setFieldValidator(longtext,value);
						validatableField = longtext;

						_fields[value.fieldname] = longtext;						
					}
				break;
				case 'dropdown':
					if (_textonly) 
					{
						var txtDrop:Text = new Text();
						for(var k:String in value.source)
						{
							if (k == value.value) {
								txtDrop.text = value.source[k];
							}
						}
						txtDrop.styleName = getStyle('textOnlyStyleName');
						fitem.addChild(txtDrop);
					} 
					else 
					{
						var dp:*;
						var def:String = "0";
						
						if ((value.source is Array) && (typeof(value.source[0]) == "object")) 
						{
							dp = new Array();
							dp = value.source;
							for (var ci:String in dp) 
							{
								if (dp[ci].value == value.value)
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
							
							for(var v:String in value.source)
							{	
								dp.addItem({'label':value.source[v],'value':v});
								if (v == value.value) {
									def = String(x);
								}
								x++;
							}
						}
	
						var combo:ComboBox = new ComboBox();
						combo.id = value.fieldname;
						combo.name = value.fieldname;
						combo.styleName = getStyle('formInputStyleName');
						combo.dataProvider = dp;
						combo.useHandCursor = true;
						combo.buttonMode = true;
						combo.width = getStyle('formInputWidth');
						
						if(value.hasOwnProperty('editable'))
							combo.editable = value.editable == 1;
						
						if(value.hasOwnProperty('prompt')) 
						{
							combo.prompt = value.prompt;
							combo.selectedIndex = -1;
						}
						else
						{
							combo.selectedIndex = 0;
							
							if(value.hasOwnProperty('editable'))
								formVariables[value.fieldname] = value.editable == 1 ? combo.text : combo.selectedItem.value;
							else	
								formVariables[value.fieldname] = combo.selectedItem.value;
						}
							
						if(value.value == undefined) value.value = '';
						
						if (value.value != '')
						{
							combo.selectedIndex = Number(def);
							
							if(value.hasOwnProperty('editable'))
								formVariables[value.fieldname] = value.editable == 1 ? combo.text : combo.selectedItem.value;
							else	
								formVariables[value.fieldname] = combo.selectedItem.value;
						}
	
						combo.addEventListener(Event.CHANGE,function(event:Event):void { 
							if(value.hasOwnProperty('editable'))
								formVariables[value.fieldname] = value.editable == 1 ? combo.text : combo.selectedItem.value;
							else
								formVariables[value.fieldname] = combo.selectedItem ? combo.selectedItem.value : null;
							
							dispatchEvent( new Event("dataChange") );
							validateField( event.currentTarget );  

							if (_onChange != null) onChange();
						});
						
						combo.addEventListener(FlexEvent.VALUE_COMMIT, function(e:FlexEvent):void {
							if(e.currentTarget.selectedIndex < 0) return;
							
							if(this._validateOnValueCommit)
								_formVariables[e.currentTarget.id] = e.currentTarget.selectedItem.value;
							
							if (_onChange != null) onChange();
						});
	
						fitem.addChild(combo);						
						
						setFieldValidator(combo,value);
						validatableField = combo;
						
						_fields[value.fieldname] = combo;	
						
						if( combo.selectedIndex > -1 ) validateField(combo);					
					}
				break;	
				case 'boolean':
					if (_textonly) 
					{
						var txtBool:Text = new Text();
						txtBool.text = ((value.value == 0) ? 'No': 'Yes');
						txtBool.styleName = getStyle('textOnlyStyleName');
						fitem.addChild(txtBool);
					} 
					else 
					{
						var choices:Array = new Array();
						choices[0] = {'label':"No",'value':0};
						choices[1] = {'label':"Yes",'value':1};
						
						var bool:ComboBox = new ComboBox();
						bool.id = value.fieldname;
						bool.name = value.fieldname;
						bool.styleName = getStyle('formInputStyleName');
						bool.dataProvider = choices;
						bool.maxWidth = getStyle('formInputWidth');
	
						bool.buttonMode = true;
						bool.useHandCursor = true;
						
						if (value.value)
							bool.selectedIndex = value.value ? value.value : 0; 
						else
							bool.selectedIndex = 1;
						
						_formVariables[value.fieldname] = bool.selectedIndex;
						formVariables = _formVariables;
						
						bool.addEventListener(Event.CHANGE,function(event:Event):void { 
							_formVariables[value.fieldname] = bool.selectedItem.value;  
							formVariables = _formVariables;

							if (_onChange != null) onChange();
						});
						
 						bool.addEventListener(FlexEvent.VALUE_COMMIT, function(e:FlexEvent):void { 
							_formVariables[value.fieldname] = e.currentTarget.selectedItem.value;  
							formVariables = _formVariables;

							if (_onChange != null) onChange();
						});
						
						fitem.addChild(bool);
						
						_fields[value.fieldname] = bool;
					}
				break;	
				case 'date':
					if (_textonly) 
					{
						var txtDate:Text = new Text();
						txtDate.text = value.value;
						txtDate.styleName = getStyle('textOnlyStyleName');
						fitem.addChild(txtDate);
					} 
					else 
					{
						var df:DateField = new DateField();
						df.name = value.fieldname;
						df.id = value.fieldname;
						df.styleName = getStyle('formInputStyleName');
						df.yearNavigationEnabled = true;
						df.width = getStyle('formInputWidth');
						fitem.addChild(df);

						if(value.value > 0)
							df.selectedDate = new Date(value.value * 1000);
						else 
							if(value.hasOwnProperty('today'))
								df.selectedDate = new Date();
								
						if(value.dateRange)
						{
							var range:Object = new Object();
							if(value.dateRange.fromDate)
							{
								var fromDate:Date = new Date(String(value.dateRange.fromDate));
								range.rangeStart = fromDate;
							}
							if(value.dateRange.toDate)
							{
								var toDate:Date = new Date(String(value.dateRange.toDate));
								range.rangeEnd = toDate;
							}
							df.selectableRange = range;
						}

						var ft:RegExp = /\[(.*?)]/g;
						var ft_string:String = value.type.match(ft);
						df.formatString = (ft_string ? ft_string.replace("]","").replace("[","").toUpperCase()  : "MM/DD/YYYY");
	
						df.addEventListener(Event.CHANGE,function(e:Event):void { 
							formVariables[value.fieldname] = (e.currentTarget.selectedDate.getTime()/1000);

							if (_onChange != null) onChange();
						});
						
						df.addEventListener(FocusEvent.FOCUS_OUT,function(e:FocusEvent):void { 
							validateField(e.currentTarget); 
						});
						
						if ((value.value) && !clear)  
							_formVariables[value.fieldname] = (df.selectedDate.getTime()/1000);
						else 
							if(value.today)
								_formVariables[value.fieldname] = (df.selectedDate.getTime()/1000);
														
						setFieldValidator(df,value);
						validatableField = df;
						
						_fields[value.fieldname] = df;
					}
				break;	
				case 'utc_date':
					if (_textonly) 
					{
						var txtDate2:Text = new Text();
						txtDate2.text = value.value;
						txtDate2.styleName = getStyle('textOnlyStyleName');
						fitem.addChild(txtDate2);
					} 
					else 
					{
						var df2:DateField = new DateField();
						df2.name = value.fieldname;
						df2.id = value.fieldname;
						df2.styleName = getStyle('formInputStyleName');
						df2.yearNavigationEnabled = true;
						df2.width = getStyle('formInputWidth');
						fitem.addChild(df2);

						var utcDate:Date;
						var localDate:Date;

						// If value exists, prepopulate the datefield with the local datetime converted from UTC timestamp
						if(value.value > 0)
							{
								utcDate = new Date(value.value * 1000);
								localDate = new Date( utcDate.getUTCFullYear(), utcDate.getUTCMonth(), utcDate.getUTCDate() );
								df2.selectedDate = localDate;
							}
						else 
							if(value.today)
							{
								var today:Date = new Date();
								// Set selected date as midnight today, local time
								df2.selectedDate = today;
							}
						if(value.dateRange)
						{
							var range2:Object = new Object();
							if(value.dateRange.fromDate)
							{
								var fromDate2:Date = new Date(String(value.dateRange.fromDate));
								range2.rangeStart = fromDate2;
							}
							if(value.dateRange.toDate)
							{
								var toDate2:Date = new Date(String(value.dateRange.toDate));
								range2.rangeEnd = toDate2;
							}
							df2.selectableRange = range2;
						}

						var ft2:RegExp = /\[(.*?)]/g;
						var ft_string2:String = value.type.match(ft2);
						df2.formatString = (ft_string2 ? ft_string2.replace("]","").replace("[","").toUpperCase()  : "MM/DD/YYYY");
	
						df2.addEventListener(Event.CHANGE,function(e:Event):void {
							// Convert DateField's local date to UTC date
							var localDate:Date = e.currentTarget.selectedDate;
							utcDate = new Date( Date.UTC( localDate.getFullYear(), localDate.getMonth(), localDate.getDate() ) );

							formVariables[value.fieldname] = (utcDate.getTime()/1000);

							if (_onChange != null) onChange();
						});
						
						df2.addEventListener(FocusEvent.FOCUS_OUT,function(e:FocusEvent):void { 
							validateField(e.currentTarget); 
						});
						
						if ((value.value) && !clear)
						{
							// Convert DateField's local date to UTC date
							localDate = df2.selectedDate;
							utcDate = new Date( Date.UTC( localDate.getFullYear(), localDate.getMonth(), localDate.getDate() ) );

							_formVariables[value.fieldname] = (utcDate.getTime()/1000);
						}
						else 
							if(value.today)
							{
								// Convert DateField's local date to UTC date
								localDate = df2.selectedDate;
								utcDate = new Date( Date.UTC( localDate.getFullYear(), localDate.getMonth(), localDate.getDate() ) );
	
								_formVariables[value.fieldname] = (utcDate.getTime()/1000);
							}

						setFieldValidator(df2,value);
						validatableField = df2;
						
						_fields[value.fieldname] = df2;
					}
				break;	
				case 'expiration_date' :
					if (_textonly) 
					{
						var txtExp:Text = new Text();
						txtExp.text = value.value;
						txtExp.styleName = getStyle('textOnlyStyleName');
						fitem.addChild(txtExp);
					} 
					else 
					{
						var exp:ExpirationDate = new ExpirationDate();
 						exp.name = value.fieldname;
						exp.id = value.fieldname;
						exp.styleName = getStyle('formInputStyleName');
 						exp.width = getStyle('formInputWidth');
 						if ( value.hasOwnProperty('monthFormat') ) exp.monthFormat = value.months;
 						if ( value.hasOwnProperty('yearsAhead') ) exp.yearsAhead = Number(value.years);
 						if ( value.hasOwnProperty('separator') ) exp.separator = value.separator;
						fitem.addChild(exp);
						
						exp.addEventListener('dataChange', function(e:Event):void { 
							formVariables[value.fieldname] = e.currentTarget.date;
						});
						
						setFieldValidator(exp,value);
						validatableField = exp;
						
						_fields[value.fieldname] = exp;
					}					
				break;
				case 'time' :
					if (_textonly) 
					{
						var txtTime:Text = new Text();
						txtTime.text = value.value;
						txtTime.styleName = getStyle('textOnlyStyleName');
						fitem.addChild(txtTime);
					} 
					else 
					{
						var timeS:TimeStepper = new TimeStepper();
						timeS.name = value.fieldname;
						timeS.id = value.fieldname;
						timeS.styleName = getStyle('formInputStyleName');
						timeS.width = getStyle('formInputWidth');
						if(value.value > 0)
						{
							timeS.timestamp = value.value;
						}

						fitem.addChild(timeS);

						timeS.addEventListener('dataChange', function(e:Event):void { 
							formVariables[value.fieldname] = e.currentTarget.timestamp;
						});

						setFieldValidator(timeS,value);
						validatableField = timeS;

						timeS.addEventListener(FocusEvent.FOCUS_OUT,function(e:FocusEvent):void { 
							validateField(e.currentTarget);
						});

						if ((value.value) && !clear)  
						{
							_formVariables[value.fieldname] = value.value;	
						}

						_fields[value.fieldname] = timeS;
					}
				break;
				case 'editor' :
					if (textonly) 
					{
						var rteArea:Text = new Text();
						rteArea.htmlText = ConvertRTEText.fromXHtml(value.value);
						rteArea.styleName = getStyle('textOnlyStyleName');
						fitem.addChild(rteArea);
					} 
					else 
					{
						var rte:RTENoRichClipboard = new RTENoRichClipboard();
						rte.id = value.fieldname;
						rte.name = value.fieldname;
						rte.styleName = getStyle('rteStyleName');
						rte.width = getStyle('formInputWidth');
						rte.showToolTips = true;
						fitem.addChild(rte);
						
						// if there are listed buttons remove the none listed
						if(value.buttons)
						{
							var btns:Array = value.buttons.split('|');
							
							if(btns.indexOf('fontFamilyCombo') == -1) rte.toolbar.removeChildAt(rte.toolbar.getChildIndex(rte.fontFamilyCombo));
							if(btns.indexOf('fontSizeCombo') == -1) rte.toolbar.removeChildAt(rte.toolbar.getChildIndex(rte.fontSizeCombo));
							
							if(btns.indexOf('boldButton') == -1) rte.toolBar2.removeChildAt(rte.toolBar2.getChildIndex(rte.boldButton));
							if(btns.indexOf('italicButton') == -1) rte.toolBar2.removeChildAt(rte.toolBar2.getChildIndex(rte.italicButton));
							if(btns.indexOf('underlineButton') == -1) rte.toolBar2.removeChildAt(rte.toolBar2.getChildIndex(rte.underlineButton));
							
							if(btns.indexOf('colorPicker') == -1) rte.toolbar.removeChildAt(rte.toolbar.getChildIndex(rte.colorPicker));		
							
							if(btns.indexOf('bulletButton') == -1) rte.alignButtons.removeChildAt(rte.alignButtons.getChildIndex(rte.bulletButton));
							if(btns.indexOf('linkTextInput') == -1) rte.toolbar.removeChild(rte.linkTextInput);
						}

						rte.addEventListener(FlexEvent.VALUE_COMMIT,function(e:Event):void { 
							formVariables[value.fieldname] = ConvertRTEText.toXHtml(e.currentTarget.htmlText);
						});
						
						rte.addEventListener(FocusEvent.FOCUS_OUT,function(e:FocusEvent):void { 
							validateField(e.currentTarget);
						});						
	
						if ((value.value) && !clear)  
						{
							rte.htmlText = ConvertRTEText.fromXHtml(value.value);
							_formVariables[value.fieldname] = value.value;	
						}
						
						setFieldValidator(rte,value);
						validatableField = rte;

						_fields[value.fieldname] = rte;						
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
					list1.name = value.fieldname + '_source';
					list1.id = value.fieldname + '_source';

					list1.addEventListener(DragEvent.DRAG_DROP,function(e:DragEvent):void {
						e.currentTarget.hideDropFeedback(e);
					});

					list1.addEventListener(DragEvent.DRAG_OVER,function(e:DragEvent):void {
						
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
					list2.name = value.fieldname;
					list2.id = value.fieldname;
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
					
					_fields[value.fieldname] = hhbox;
					
				break;
			}	

			// apply a databinding to the form item (or field) if needed
            if( value.hasOwnProperty('dataBinding') )
            {
            	var w:ChangeWatcher = 	bindSetterWithProperties( 
						            		dataBindingSetter, 
						            		value, 
						            		getField(value.dataBinding.host), 
						            		value.dataBinding.chain 
						            	);
				_changeWatchers.push(w);
            }
            
            // check if the current field has been assigned to the validatableField varaible. If so, add
            // a listener for FOCUS_IN events so that a tooltip can be shown if there was an error on that field.
            if(validatableField) {
            	validatableField.addEventListener( FocusEvent.FOCUS_IN, function( e : FocusEvent ) : void {
            		var c : UIComponent = e.currentTarget as UIComponent;
            		if(c.errorString && c.errorString.length > 0) {
            			setValidationFocus(c);
            		}
            	});
            	validatableField.addEventListener( FocusEvent.FOCUS_OUT, function( e : FocusEvent ) : void {
            		var c : UIComponent = e.currentTarget as UIComponent;
            		removeValidationFocus(c);
            	});
            }		
			
			return fitem;
		}


		/**
		 * Binds a setter function to a bindable property or property chain. Pass through the dataBinding variables aswell
		 */
	    private function bindSetterWithProperties(setter:Function, variables:Object, 
	    						host:Object, chain:Object, commitOnly:Boolean = false):ChangeWatcher
	    {
	        var w:ChangeWatcher = ChangeWatcher.watch(host, chain, null, commitOnly);
	        
	        if (w != null)
	        {
	            var invoke:Function = function(event:*):void
	            {
	                setter( w.getValue(), variables );
	            };
	            w.setHandler(invoke);
	            invoke(null);
	        }
	        
	        return w;
	    }		
		
		/**
		 * Handle the logic of the databinding setter function
		 */
		private function dataBindingSetter( chain:*, v:Object ):void
		{
			// set the result of the binding
			var result:int = 0;
			if( v.dataBinding.operator == '=')
				result = chain == v.dataBinding.value ? 0 : 1;
			else if ( v.dataBinding.operator == '!=' )
				result = chain != v.dataBinding.value ? 0 : 1;
			
			// set the field to be affected
			var field:* = getField(v.fieldname);
			
			// set whether it is the field or form item that is affected
			var site:*;
			if( v.dataBinding.site == 'field' )
				site = field;
			else
				site = field.parent;
			
			// loop through the properties listed to be affected
			for ( var prop:String in v.dataBinding.properties )
			{
				var action:Object = v.dataBinding.properties[prop];
				site[prop] = action[result];
				
				// readjust the validation fields if the prop is 'required'
				if( prop == 'required' )
				{
					var rules:Array = v.rules.split("|");
					var reqIndex:int = rules.indexOf('required');
				
					if( result == 1 && reqIndex > -1 )
						delete rules[reqIndex];
 					else if( result == 0 && reqIndex == -1) 
 						rules.push('required');
					
					v.rules  = '';
						
					for ( var i:int=0; i < rules.length; i++)
						if(typeof(rules[i]) != 'undefined')
							v.rules += i == 0 ? rules[i] : '|' + rules[i];

					setFieldValidator( field, v );										
					validateField ( field, true );
				}
			}
		}
		
		/**
		 * Clear the array of changewatchers so the databindings can be added from scratch
		 */
		private var _changeWatchers:Array;
		private function clearBindings():void
		{
			for each ( var w:ChangeWatcher in _changeWatchers )
				w.unwatch();
				
			_changeWatchers = new Array();
		}
				
		
		/**
		 * Set the fields validation according to the rules in the layout
		 */
		private var _formValidate:Array = new Array();
		private function setFieldValidator(id:Object, validation:Object, match:TextInput = null):void
		{
			if (!validation.rules) {
				return;
			}			
			
			var rules:Array = validation.rules.split("|");
			
			// clear any rules for that field (this is necessary as the validation can change with bindings)
			for ( var t:int = 0; t <  _formValidate.length; t++ )
				if(_formValidate[t].fieldname == validation.fieldname)
					_formValidate.splice(t);

			// loop through each rule and assign the appropriate validator			
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
						_formValidate.push({'validator':phoneValidator,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
   					break;
					case 'valid_email':
					case 'email':
					 	var emailValidator:EmailValidator = new EmailValidator();
						emailValidator.source = id;
						emailValidator.property = "text"; 		
						emailValidator.required = ((validation.rules.match("required")) ? true: false );	
						emailValidator.requiredFieldError = validation.label + " is required";
		                _formValidate.push({'validator':emailValidator,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
					break;
					case 'currency':
						var curValidator:CurrencyValidator = new CurrencyValidator();
						curValidator.source = id;
						curValidator.property = "text";
		                if(validation.hasOwnProperty('minValue')) 
		                {
		                	curValidator.lowerThanMinError = validation.label + ' has to be greater than $' + validation.minValue;
		                	curValidator.minValue = parseFloat(validation.minValue);
		                }
		                if(validation.hasOwnProperty('maxValue'))
		                {
		                	curValidator.exceedsMaxError = validation.label + ' can not be greater than $' + validation.maxValue;
		                	curValidator.maxValue = parseFloat(validation.maxValue);
		                }						
						curValidator.required = ((validation.rules.match("required")) ? true: false );
						curValidator.requiredFieldError = validation.label + " is required";
		                _formValidate.push({'validator':curValidator,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
					break;
					case 'number':
					case 'numeric' :
					case 'alpha_numeric':
						var nv:NumberValidator = new NumberValidator();
		                nv.source = id;
		                nv.property = "text";
		                if(validation.hasOwnProperty('minValue')) 
		                {
		                	nv.lowerThanMinError = validation.label + ' has to be greater than ' + validation.minValue;
		                	nv.minValue = parseFloat(validation.minValue);
		                }
		                if(validation.hasOwnProperty('maxValue'))
		                {
		                	nv.exceedsMaxError = validation.label + ' can not be greater than ' + validation.maxValue;
		                	nv.maxValue = parseFloat(validation.maxValue);
		                }
						nv.required = ((validation.rules.match("required")) ? true: false );	
						nv.requiredFieldError = validation.label + " is required";
		                _formValidate.push({'validator':nv,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
					break;
					case 'socialsecurity':
						var ss:SocialSecurityValidator = new SocialSecurityValidator();
						ss.source = id;
						ss.property = "text";
						ss.required = ((validation.rules.match("required")) ? true: false );
						ss.requiredFieldError = validation.label + " is required";
		                _formValidate.push({'validator':ss,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
					break;
					case 'zip':
					case 'zipcode':
						var zipValidator:ZipCodeValidator = new ZipCodeValidator();
						zipValidator.source = id;
						zipValidator.property = "text";
						zipValidator.required = ((validation.rules.match("required")) ? true: false );
						zipValidator.requiredFieldError = validation.label + " is required";
		                _formValidate.push({'validator':zipValidator,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
					break;
					case 'date':
						var dtv:DateValidator = new DateValidator();
						dtv.source = id;
						dtv.inputFormat = validation.dateFormat ? validation.dateFormat : "mm/dd/yyyy";
						dtv.property = "text";
						dtv.required = validation.rules.match("required") ? true : false;
						dtv.requiredFieldError = validation.label + " is required";
		                _formValidate.push({'validator':dtv,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
					break;
					case 'datefield':
						var dfv:DateFieldValidator = new DateFieldValidator();
		                dfv.source = id;
		                dfv.property = "selectedDate";
						dfv.required = ((validation.rules.match("required")) ? true: false );	
						dfv.requiredFieldError = validation.label + " is required";
		                _formValidate.push({'validator':dfv,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
					break;
					case 'lookup' :
						var luv:LookupInputValidator = new LookupInputValidator();
		                luv.source = id;
		                luv.property = "dataValue";
						luv.required = ((validation.rules.match("required")) ? true: false );	
						luv.requiredFieldError = validation.label + " is required";
		                _formValidate.push({'validator':luv,'source':id,'fieldname':validation.fieldname,'rule':rule});	                
					break;
					case 'credit_card':
					case 'creditcard':
						if(!validation.cardTypeSource) return;	
						
						var ccv:CreditCardValidator = new CreditCardValidator();
						ccv.cardNumberSource = id;
						ccv.cardNumberProperty = "text";
						ccv.cardTypeSource = getField(validation.cardTypeSource) as ComboBox;
						ccv.cardTypeProperty = 'value';
						ccv.required = validation.rules.match("required") ? true : false;
						ccv.requiredFieldError = validation.label + " is required";
		                _formValidate.push({ 'validator' : ccv, 'source' : id, 'fieldname' : validation.fieldname, 'rule' : rule });	                								
					break;
					case 'required':					
						if (id.className == 'ComboBox') 
						{
							var cValidator:ComboRequiredValidator = new ComboRequiredValidator();
							cValidator.source = id;
							cValidator.minValue = 0;
							cValidator.property = "selectedIndex";
							cValidator.lowerThanMinError = validation.label + " is required";
			                _formValidate.push({'validator':cValidator,'source':id,'fieldname':validation.fieldname,'rule':rule});						
			            } 
			            else if(id.className == 'AutoCompleteSearch')
			            {
							var acValidator:AutoCompleteValidator = new AutoCompleteValidator();
							acValidator.source = id;
							acValidator.property = "selectedIndex";
							acValidator.required = true;
							acValidator.requiredFieldError = validation.label + " is required";
			                _formValidate.push({'validator':acValidator,'source':id,'fieldname':validation.fieldname,'rule':rule});						
			            }
						else if ((id.className == 'TextInput' || id.className == 'TextArea') && (rules.indexOf('credit_card') == -1))
						{
							var sValidator:StringValidator = new StringValidator();
							sValidator.source = id;
							sValidator.property = "text"
							sValidator.required = true;
							sValidator.requiredFieldError = validation.label + " is required";
			           		_formValidate.push({'validator':sValidator,'source':id,'fieldname':validation.fieldname,'rule':rule});
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
			                _formValidate.push({'validator':pwdValidator,'source':id,'fieldname':validation.fieldname,'rule':rule});
			   			}
					break;
					case 'selection_numeric' :
						if(validation.hasOwnProperty('validationSource'))
						{
							var snv:SelectionNumericValidator = new SelectionNumericValidator();
							snv.selectionSourceProperty = 'selectedIndex';
							snv.selectionSource = getField(validation.selectionSource) as ComboBox;
							snv.validationSource = validation.validationSource;
			                snv.source = id;
			                snv.property = "text";
							snv.fieldLabel = validation.label;
			                _formValidate.push({ 'validator':snv, 'source':id, 'fieldname':validation.fieldname, 'rule':rule });	                
						}
					break;
					case 'regex' :
						if(validation.hasOwnProperty('regex'))
						{
							var rv:VariableMatchRegExValidator = new VariableMatchRegExValidator();
							rv.source = id;
							rv.property = 'text';
							rv.errorMsg = validation.regex.errorMsg;
							rv.expression = validation.regex.expression;
							rv.flags = validation.regex.flags,
							rv.validAction = 'noMatch';
							_formValidate.push({ 'validator':rv, 'source':id, 'fieldname':validation.fieldname, 'rule':rule });
						}
					break;
					case 'expiration_date' :
						var expV:ExpirationDateValidator = new ExpirationDateValidator();
						expV.source = id;
						expV.property = 'date';
						expV.requiredFieldError = validation.label + " is required";
						_formValidate.push({ 'validator':expV, 'source':id, 'fieldname':validation.fieldname, 'rule':rule });
					break;
					case 'time' :
						var timeV:TimeValidator = new TimeValidator();
						timeV.source = id;
						timeV.property = 'timestamp';
						timeV.requiredFieldError = validation.label + " is required";
						_formValidate.push({ 'validator':timeV, 'source':id, 'fieldname':validation.fieldname, 'rule':rule });
					break;
				}
			}
		}
		
		/**
		 * Live form validation
		 */
		private function isFormValid(verbose:Boolean = true):Boolean
		{
			_invalidFields = new Array();
			var invalidIsFocused : Boolean = false;
			for(var i:String in _formValidate)
			{				
				var vResult:ValidationResultEvent = _formValidate[i].validator.validate(null,!verbose);
				
				var comp : UIComponent = _formValidate[i].source as UIComponent;
				

				if (vResult.type==ValidationResultEvent.INVALID) 
				{
					_invalidFields.push({
						'field' : _formValidate[i].fieldname, 
						'message' : vResult.message,
						'value' : _formValidate[i].source.text
					});
					
					if( !invalidIsFocused && comp ) {
						setValidationFocus(comp,false);
						invalidIsFocused = true;
					}
				}
			}

			this.isValid = !invalidIsFocused;
			
			if (!isValid) 
				dispatchEvent( new Event('formInvalid') );
			else 
				dispatchEvent( new Event('formValid') );
			
			return this.isValid;	
		}
		
		/**
		 * Validate a single form item
		 */
		private function validateField( source:Object, verbose:Boolean = false ):Boolean
		{
			isFormValid(false);
			
			for(var i:String in _formValidate)
			{
				if (_formValidate[i].source.id == source.id)
				{					
					var vResult:ValidationResultEvent = _formValidate[i].validator.validate( null, verbose );
					
					if (vResult.type==ValidationResultEvent.INVALID) 
					{
						setValidationFocus(_formValidate[i].source as UIComponent);
						return false;
					}
				}
			}
			
			return true;
		}

		/**
		 * If a field fails validation give it focus and launch the error tooltip
		 */
		private function setValidationFocus(formObject:UIComponent, setFocus:Boolean = false):void
		{
			if(	formObject && 
				formObject.initialized &&
				formObject.parentDocument &&
				formObject.parentDocument.visible )
			{
				if (setFocus) 
					formObject.setFocus();
				
				callLater( function() : void {
					formObject.dispatchEvent( new MouseEvent( MouseEvent.MOUSE_OVER ) ); 
				} );
			}
		}
		private function removeValidationFocus(formObject:UIComponent):void {
			if(formObject && formObject.initialized) {
				callLater( function() : void {
					formObject.dispatchEvent( new MouseEvent( MouseEvent.MOUSE_OUT ) ); 
				} );
			}
		}
	}
}