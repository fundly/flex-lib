package com.enilsson.graphics
{
	import flash.display.Shape;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osflash.thunderbolt.Logger;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;

	public class animateLine extends UIComponent
	{
		public function animateLine()
		{
			super();
		}

		private var _timeInterval:Number;
		private var _linePath:ArrayCollection;
		private var _timerIter:Number = 0;
		private var _frameRate:Number = 24;
		private var _circle:Shape;

		private var _lineColor:uint = 0xFFFFFF;
		public function set lineColor(value:uint):void
		{
			_lineColor = value;
		}
		public function get lineColor():uint
		{
			return _lineThickness;
		}		

		private var _lineThickness:Number = 2;
		public function set lineThickness(value:Number):void
		{
			_lineThickness = value;
		}
		public function get lineThickness():Number
		{
			return _lineThickness;
		}

		private var _duration:Number = 1000;		
		public function set duration(value:Number):void
		{	
			_duration = value * 1000;	
		}
		public function get duration():Number
		{
			return _duration/1000;
		}

		private var _cornerRadius:Number = 4;		
		public function set cornerRadius(value:Number):void
		{	
			_cornerRadius = value;	
		}
		public function get cornerRadius():Number
		{
			return _cornerRadius;
		}		

		private var _circleSize:Number;
		public function set circleSize(value:Number):void
		{	
			_circleSize = value;	
		}
		public function get circleSize():Number
		{
			return _circleSize;
		}		

		private var _endCircle:Boolean = true;		
		public function set endCircle(value:Boolean):void
		{	
			_endCircle = value;	
		}
		public function get endCircle():Boolean
		{
			return _endCircle;
		}		
		
		/**
		 * @private
		 * Generates the number of points that an idealised path would
		 * take if there were no concessions to framerate
		 */
		private function getNumberOfPoints(broadPath:Object):Number
		{
			var numberOfPoints:Number = 0;
			// loop through the path pairs and determine number of pixel jumps
			for(var i:Number=0; i<broadPath.length-1; i++){
				var xMove:Number = broadPath[i+1][0] - broadPath[i][0];
				var yMove:Number = broadPath[i+1][1] - broadPath[i][1];
				var range:Number = xMove + yMove;
				numberOfPoints += Math.abs(range);
			}
			numberOfPoints++;
			return numberOfPoints;	
		}
		
		/**
		 * @private
		 * Takes the array of corner points and a pixel length of each step
		 * and makes an array of points out of it
		 */
		private function generateLinePath(broadPath:Object, pixelStep:Number=1):void
		{
			// Broad path is the start, any corners and the end in 2D points
			var pathPairs:Object = new ArrayCollection();
			_linePath = new ArrayCollection();
			// split the broad path into a series of pairs of points
			for(var i:Number=0; i<broadPath.length-1; i++){
				pathPairs.addItem({ 
									'first' : {x:broadPath[i][0], y:broadPath[i][1]}, 
									'second' : {x:broadPath[i+1][0], y:broadPath[i+1][1]} 
								});
			}
			// loop through the path pairs and build a pixel by pixel path
			for(var t:Number=0; t<pathPairs.length; t++){
				var pt:Object = pathPairs[t];
				// work out how far the next corner is away in both x and y
				var xMove:Number = pt.second.x - pt.first.x;
				var yMove:Number = pt.second.y - pt.first.y;
				// determine the pixel movement of the step
				var range:Number = xMove + yMove;
				// determine the direction of the movement
				var direction:Number = range/Math.abs(range);
				// determine the number of steps to complete the range moving by the step size
				var steps:Number = Math.round(Math.abs(range)/pixelStep);
				// loop through the steps and create the points
				for(var s:Number=0; s<steps; s++){
					var newX:Number = xMove == 0 ? pt.first.x : pt.first.x + (s * pixelStep * direction);
					var newY:Number = yMove == 0 ? pt.first.y : pt.first.y + (s * pixelStep * direction);
					_linePath.addItem([newX, newY]);
				}
			}
			_linePath.addItem([pt.second.x, pt.second.y]);	
		}
		
		
		public function playForward(linePath:Object):void
		{
			// if there is no line path defined stop the animation
			if(!linePath) return;
			// get the number of points of the ideal path
			var _numberOfPoints:Number = getNumberOfPoints(linePath);
			// set the min time interval based on the default frame rate of flash player
			var _minTimeInterval:Number = Math.floor(1000/_frameRate);
			// set the animation pixel step, based on the ideal situation (ie the framerate is acceptable)
			var _pixelStep:Number = 1;
			// set the timer interval
			_timeInterval = Math.round((_duration)/_numberOfPoints);
			// if the time interval drops below the min frame rate, adjust it
			if(_timeInterval < _minTimeInterval){
				_timeInterval = _minTimeInterval;
				_pixelStep = Math.round(_numberOfPoints /Math.round(_duration/_timeInterval));
			}
			// generate the line path from the inputted path markers
			generateLinePath(linePath, _pixelStep);
			// initialise the line
			graphics.lineStyle(_lineThickness,_lineColor);
			// move the graphics pointer to the first spot
			graphics.moveTo(_linePath[0][0], _linePath[0][1]);
			// set the iteration counter
			_timerIter = 0;
			// initialise the timer
			var t:Timer = new Timer(_timeInterval, _linePath.length-1);
			t.start();
			// add the event listener for each timer step
			t.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
				graphics.lineTo(_linePath[_timerIter][0], _linePath[_timerIter][1]);	
				_timerIter++;
			});
			// add the event listener for the completed step
			t.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
				graphics.lineTo(_linePath[_linePath.length-1][0], _linePath[_linePath.length-1][1]);	
				if(_endCircle){
					growCircle();
				}
			});

		}
		
		public function playReverse(onComplete:Function=null):void
		{
			// set the iteration counter
			_timerIter = 0;
			// initialise the timer
			var t:Timer = new Timer(_timeInterval, _linePath.length-1);
			t.start();
			// add the event listener for each timer step
			t.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
				if(_timerIter == 0){
					if(_endCircle){
						removeChild(_circle);
					}
				}
				graphics.clear();
				graphics.lineStyle(_lineThickness,_lineColor);
				graphics.moveTo(_linePath[0][0], _linePath[0][1]);
				for(var i:Number=0; i<_linePath.length-_timerIter-1; i++){
					graphics.lineTo(_linePath[i][0], _linePath[i][1]);
				}
				_timerIter++;
			});
			// add the event listener for the completed step
			t.addEventListener(TimerEvent.TIMER_COMPLETE, function():void {
				if(onComplete()){
					onComplete();
				}
			});
		}
		
		private function growCircle():void
		{
			var lastIter:Number = _timerIter;
			_circle = new Shape();
			var _radius:Number = !_circleSize ? _lineThickness * 1.5 : Math.round(_circleSize/2);
			
			_circle.graphics.beginFill(_lineColor);
			_circle.graphics.lineStyle(_lineThickness,_lineColor);
			_circle.graphics.drawCircle(_linePath[lastIter][0], _linePath[lastIter][1], _radius);
			_circle.graphics.endFill();
			addChild(_circle);
		}
		
	}
}