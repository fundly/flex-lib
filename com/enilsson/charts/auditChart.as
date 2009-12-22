 /**
 * All computational source code, intellectual property or other works 
 * contained herein are deemed Public Domain as per the Creative 
 * Commons Public Domain license.
 * 
 * http://creativecommons.org/licenses/publicdomain/
 * 
 * Author : Rafael Cardoso
 * Date: 20/07/2008
 * Reference : http://www.enilsson.com/
 * 
 * 
 **/
 
package com.enilsson.charts
{
	
	import com.enilsson.utils.ajax.enAJAX;
	import com.enilsson.utils.ajax.enAJAXevent;
	
	import mx.charts.AreaChart;
	import mx.charts.BarChart;
	import mx.charts.CategoryAxis;
	import mx.charts.ColumnChart;
	import mx.charts.Legend;
	import mx.charts.LineChart;
	import mx.charts.LinearAxis;
	import mx.charts.PieChart;
	import mx.charts.effects.SeriesInterpolate;
	import mx.charts.effects.SeriesSlide;
	import mx.charts.series.AreaSeries;
	import mx.charts.series.BarSeries;
	import mx.charts.series.ColumnSeries;
	import mx.charts.series.LineSeries;
	import mx.charts.series.PieSeries;
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Label;
	import mx.managers.PopUpManager;

    
	public class auditChart extends Canvas
	{
        public var chartdata:Object = new Object();
        public var isLoaded:Boolean = false;
        private var reload:Boolean = false;
        
        private var xchart:*;
        private var cache:Array = new Array;

		private var loadingBox:HBox = null; 
		
		private var vbox:VBox = null;
		private var tbox:HBox = new HBox();
		private var lb:Label = new Label();
		
        public function auditChart()
		{
			super();
			
			addEventListener(auditChartEvent.DATA_LOADED,displayChart);
   		}
	    /**
	     *  @private
	     */
	    override protected function updateDisplayList(unscaledWidth:Number,
	                                                  unscaledHeight:Number):void
	    {
	        super.updateDisplayList(unscaledWidth, unscaledHeight);

			// Load the chart data
			if ((url) && (!isLoaded)) {
				loadChart();
			}
    	}

	  	public function createLoading():void
    	{
			loadingBox = new HBox();
			loadingBox.styleName = "loadingBox";
			loadingBox.setStyle("horizontalCenter",0);
			loadingBox.setStyle("verticalCenter",0);
			var lb2:Label = new Label();
			lb2.text = "Loading...";
			loadingBox.addChild(lb2);
			addChild(loadingBox);
    	}
    	
    	public function showLoading(show:Boolean):void
    	{
    		if (loadingBox == null) {
    			createLoading();
    		}
    		
    		if (show) 
    		{
      			loadingBox.alpha = 100;
    			loadingBox.visible = true;
    		} 
    		else 
    		{
    			loadingBox.alpha = 0;
    			loadingBox.visible = false;
    		}
    	}

    	public function reloadChart():void
    	{
    		reload = true;
			
    		chartdata = new Object();
    		loadChart();
    	}
	   		
   		private function loadChart():void 
   		{
   			isLoaded = true;
			showLoading(true);
   			if (cache[userid]) 
   			{
   				chartdata = cache[userid];
				dispatchEvent(new auditChartEvent("DATA_LOADED"));
	   		} 
	   		else
	   		 {
				var ajax:enAJAX = new enAJAX({
					'url' : url,
					'method' : 'histogram',
					'source' : 'struktor.audit',
					'params' : [gaptype, userid,null,action],
					'useTimeOut' : false,
					'debug' : false,
					'onComplete' : function(e:enAJAXevent):void 
					{
						chartdata = e.data;
						if (gaptype == "#H") 
						{
							var found:Boolean;
							for (var i:uint = 0;i<24;i++) 
							{
								found = false;
								var hr:String = ((i>9) ? i : '0'+i);
								for (var index:String in chartdata) {
									if (chartdata[index].y == hr) {
										found = true;
									}
								}
								if (!found) {
									chartdata.push({'x':0,'y':hr});
								}
							}
							chartdata.sortOn("y", Array.NUMERIC);
						}
						
						if (userid != null) {
							cache[userid] = chartdata;
						}
						
						dispatchEvent(new auditChartEvent("DATA_LOADED"));
					}	
				});	
   			}
		}
   		
 		/**
        * add the chart choosen to staging
        **/
   		private function displayChart(evt:auditChartEvent):void 
   		{
   			if (reload) 
   			{
   				if (title) {
   					lb.text = title;
   				}
   				xchart.dataProvider = chartdata;
   				showLoading(false);
   				return;	
   			}
   			
   			removeAllChildren();
   			loadingBox = null;
   			
   			vbox = new VBox();
   			vbox.percentWidth = 100;
   			vbox.percentHeight = 100;
   			vbox.horizontalScrollPolicy = "off";
   			vbox.verticalScrollPolicy = "off";
   			vbox.styleName = "chartBox";
   			
   			
   			// Add the title
   			if (title) {
	   			tbox = new HBox();
	   			tbox.styleName = "boxTitle";
	   			tbox.percentWidth = 100;
    			tbox.setStyle("horizontalAlign","center");
		    	tbox.setStyle("horizontalCenter",0);
	   			lb = new Label();
	   			lb.text = title;
	   			tbox.addChild(lb);
	   			vbox.addChild(tbox);
   			}
           	var chartLegend:Legend = new Legend();
			
			var fieldName:String;

			switch(type) 
			{
				case 'pie':
	                
	                /* Define the effect */
	                var si:SeriesInterpolate = new SeriesInterpolate();
	                si.duration = 1000;
	                
	                /* Define pie series. */
	                var pseries:PieSeries = new PieSeries();
	                pseries.nameField = "y";
	                pseries.field = "x";
	                pseries.setStyle("labelPosition",labelPosition);
	                pseries.labelField="y";
	                pseries.setStyle("showDataEffect",si);


	                /* Define pie chart. */
	                var piechart:PieChart = new PieChart();
	                piechart.percentWidth = 100;
	                piechart.percentHeight = 100;
	                piechart.showDataTips = true;
	                piechart.series = [pseries];
	                if (dataTipFunction != null) {
	                	piechart.dataTipFunction = dataTipFunction;
	                }
	                xchart = piechart;

	
					/* hack to start the effect */
					callLater(function():void { piechart.dataProvider = chartdata;  })

	                /* Add chart to the display list. */
	                if (legend == true) 
	                {
	                	/* Create a legend */
	                	var phBox:HBox = new HBox();
	                	phBox.percentWidth = 100;
	                	phBox.percentHeight = 100;
	                	phBox.addChild(piechart);
	                	
	                	chartLegend.dataProvider = piechart;
	                	phBox.addChild(chartLegend);
	                	
	                	vbox.addChild(phBox);
	                	
	                } else {
	                	vbox.addChild(piechart);
	                }
	                addChild(vbox);
				break;
				case 'bar':
				
					/* Define the effect. */
					var ss:SeriesSlide = new SeriesSlide();
					ss.duration = 1000;
					ss.direction = "right";
					
					/* Define bar series. */
   					var arrBarSeries:Array = new Array();
   					
	                var bseries:BarSeries = new BarSeries();
	                bseries.yField = "y";
	                bseries.xField = "x";
		            bseries.displayName = "x";

		        	bseries.setStyle("showDataEffect",ss);
		        		            
		            arrBarSeries.push(bseries);
 					
	                /* Define bar chart. */
					var barchart:BarChart = new BarChart();
	                barchart.percentWidth = 100;
	                barchart.percentHeight = 100;
	                barchart.showDataTips = true;
	                barchart.series = arrBarSeries;
	                if (dataTipFunction != null) {
	                	barchart.dataTipFunction = dataTipFunction;
	                }
	                xchart = barchart;
	                
					/* hack to start the effect */
					callLater(function():void { barchart.dataProvider = chartdata  })
	    
	                /* Define horizontal category axis. */
	                var bcah:CategoryAxis = new CategoryAxis();
	                bcah.categoryField = "y";
	                if (verticalAxisTitle) {
	                	bcah.title = verticalAxisTitle;
	                }
                	barchart.verticalAxis = bcah;
	                /* Define vertical category axis. */
	                if (horizontalAxisTitle) {
		                var bcav:LinearAxis = new LinearAxis();
	                	bcav.title = horizontalAxisTitle;
		                barchart.horizontalAxis = bcav;
	                }
	                
	                /* Add chart to the display list. */
	                if (legend == true) 
	                {
	                	/* Create a legend */
	                	var bhBox:HBox = new HBox();
	                	bhBox.percentWidth = 100;
	                	bhBox.percentHeight = 100;
	                	bhBox.addChild(barchart);
	                	
	                	chartLegend.dataProvider = barchart;
	                	bhBox.addChild(chartLegend);
	                	vbox.addChild(bhBox);
	                	
	                } else {
	                	vbox.addChild(barchart);
	                }
                	addChild(vbox);
	                
		        break;
				case 'column':
					/* Define column series. */
   					var arrColumnSeries:Array = new Array();
					for(fieldName in chartdata.item[0]) 
					{
						if (fieldName == "xfield") continue; 
						
		                var cseries:ColumnSeries = new ColumnSeries();
		                cseries.yField = fieldName;
		                cseries.xField = "xfield";
			            cseries.displayName = fieldName;
			            
			            arrColumnSeries.push(cseries);
		      		}

	            
	                /* Add chart to the display list. */
					var columnchart:ColumnChart = new ColumnChart();
	                columnchart.percentWidth = 100;
	                columnchart.percentHeight = 100;
	                columnchart.showDataTips = true;
	                columnchart.series = arrColumnSeries;
					
					callLater(function():void { columnchart.dataProvider = chartdata.item  })

	                /* Define horizontal category axis. */
	                var ccah:CategoryAxis = new CategoryAxis();
	                ccah.categoryField = "xfield";
	                if (chartdata.options.horizontalAxis) {
	                	ccah.title = chartdata.options.horizontalAxis;
	                }
	                columnchart.horizontalAxis = ccah;

	                /* Define vertical category axis. */
	                if (chartdata.options.verticalAxis) {
		                var ccav:LinearAxis = new LinearAxis();
	                	ccav.title = chartdata.options.verticalAxis;
		                columnchart.verticalAxis = ccav;
	                }


	                /* Add chart to the display list. */
	                if (legend == true) 
	                {
	                	/* Create a legend */
	                	var chBox:HBox = new HBox();
	                	chBox.percentWidth = 100;
	                	chBox.percentHeight = 100;
	                	chBox.addChild(columnchart);
	                	
	                	chartLegend.dataProvider = columnchart;
	                	chBox.addChild(chartLegend);
	                	
	                	addChild(chBox);
	                	
	                } else {
	                	addChild(columnchart);
	                }

				break;
				case 'line':
					/* Define line series. */
   					var arrSeries:Array = new Array();
   					
					for(fieldName in chartdata.item[0]) 
					{
						if (fieldName == "xfield") continue; 
						
		                var lseries:LineSeries = new LineSeries();
		            	lseries.xField = "xfield";
		           	 	lseries.yField = fieldName;
			            lseries.setStyle("form","curve");
			            lseries.displayName = fieldName;
			            
			            arrSeries.push(lseries);
		      		}

	                /* Add chart to the display list. */
					var linechart:LineChart = new LineChart();
	                linechart.percentWidth = 100;
	                linechart.percentHeight = 100;
	                linechart.showDataTips = true;
	                linechart.series = arrSeries;
	                linechart.dataProvider = chartdata.item


	                /* Define horizontal category axis. */
	                var lcah:CategoryAxis = new CategoryAxis();
	                lcah.categoryField = "xfield";
	                if (chartdata.options.horizontalAxis) {
	                	lcah.title = chartdata.options.horizontalAxis;
	                }
	                linechart.horizontalAxis = lcah;

	                /* Define vertical category axis. */
	                if (chartdata.options.verticalAxis) {
		                var lcav:LinearAxis = new LinearAxis();
	                	lcav.title = chartdata.options.verticalAxis;
		                linechart.verticalAxis = lcav;
	                }
	
	                /* Add chart to the display list. */
	                if (legend == true) 
	                {
	                	/* Create a legend */
	                	var lhBox:HBox = new HBox();
	                	lhBox.percentWidth = 100;
	                	lhBox.percentHeight = 100;
	                	lhBox.addChild(linechart);
	                	
	                	chartLegend.dataProvider = linechart;
	                	lhBox.addChild(chartLegend);
	                	
	                	addChild(lhBox);
	                	
	                } else {
	                	addChild(linechart);
	                }
				break;

				case 'area':
					/* Define line series. */
   					var arrSeriesArea:Array = new Array();
					for(fieldName in chartdata.item[0]) 
					{
						if (fieldName == "xfield") continue; 
		                var aseries:AreaSeries = new AreaSeries();
		            	aseries.xField = "xfield";
		           	 	aseries.yField = fieldName;
			            aseries.setStyle("form","curve");
			            aseries.displayName = fieldName;
			            
			            arrSeriesArea.push(aseries);
		      		}

	                /* Add chart to the display list. */
					var areachart:AreaChart = new AreaChart();
	                areachart.percentWidth = 100;
	                areachart.percentHeight = 100;
	                areachart.showDataTips = true;
	                areachart.dataProvider = chartdata.item;
	                areachart.series = arrSeriesArea;

	                /* Define horizontal category axis. */
	                var acah:CategoryAxis = new CategoryAxis();
	                acah.categoryField = "xfield";
	                if (chartdata.options.horizontalAxis) {
	                	acah.title = chartdata.options.horizontalAxis;
	                }
	                areachart.horizontalAxis = acah;

	                /* Define vertical category axis. */
	                if (chartdata.options.verticalAxis) {
		                var acav:LinearAxis = new LinearAxis();
	                	acav.title = chartdata.options.verticalAxis;
		                areachart.verticalAxis = acav;
	                }
	                
	               
	                
	                /* Add chart to the display list. */
	                if (legend == true) 
	                {
	                	/* Create a legend */
	                	var ahBox:HBox = new HBox();
	                	ahBox.percentWidth = 100;
	                	ahBox.percentHeight = 100;
	                	ahBox.addChild(areachart);
	                	
	                	chartLegend.dataProvider = areachart;
	                	ahBox.addChild(chartLegend);
	                	
	                	vbox.addChild(ahBox);
	                	
	                } else {
	                	vbox.addChild(areachart);
	                }
                	
				break;
			}
   		}
		
		

		/**
        * legend?
        **/
        private var _legend:Boolean = false;

        public function set legend(value:Boolean):void {
            _legend = value;
        }
        public function get legend():Boolean {
            return _legend;    
        }

		/**
        * url that will be loaded
        **/
        private var _url:String;

        public function set url(value:String):void {
            _url = value;
        }
        public function get url():String {
            return _url;    
        }

		/**
        * chart type that will be loaded
        **/
        private var _type:String = null;

        public function set type(value:String):void {
            _type = value;
        }
        public function get type():String {
            return _type;    
        }
		/**
        * gap type that will be loaded
        **/
        private var _gaptype:String;

        public function set gaptype(value:String):void {
            _gaptype = value;
        }
        public function get gaptype():String {
            return _gaptype;    
        }

		/**
        * chart title
        **/
        private var _title:String = null;

        public function set title(value:String):void {
            _title = value;
        }
        public function get title():String {
            return _title;    
        }

		/**
        * userid that will be loaded
        **/
        private var _userid:String = null;

        public function set userid(value:String):void {
        	if (value == "-1") value = null;
            _userid = value;
        }
        public function get userid():String {
            return _userid;    
        }

		/**
        * horizontalAxisTitle
        **/
        private var _horizontalAxisTitle:String = null;

        public function set horizontalAxisTitle(value:String):void {
            _horizontalAxisTitle = value;
        }
        public function get horizontalAxisTitle():String {
            return _horizontalAxisTitle;    
        }

		/**
        * verticalAxisTitle
        **/
        private var _verticalAxisTitle:String = null;

        public function set verticalAxisTitle(value:String):void {
            _verticalAxisTitle = value;
        }
        public function get verticalAxisTitle():String {
            return _verticalAxisTitle;    
        }
        
		/**
        * action
        **/
        private var _action:String = null;

        public function set action(value:String):void {
            _action = value;
        }
        public function get action():String {
            return _action;    
        }
        
                
		/**
        * labelPosition
        **/
        private var _labelPosition:String = 'callout';

        public function set labelPosition(value:String):void {
            _labelPosition = value;
        }
        public function get labelPosition():String {
            return _labelPosition;    
        }

		/**
        * dataTipFunction
        **/
        private var _dataTipFunction:Function = null;

        public function set dataTipFunction(value:Function):void {
            _dataTipFunction = value;
        }
        public function get dataTipFunction():Function {
            return _dataTipFunction;    
        }
	}
}