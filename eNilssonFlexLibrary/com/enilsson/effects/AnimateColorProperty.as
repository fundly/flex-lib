/*Copyright (c) 2006 Adobe Systems Incorporated

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/
package com.enilsson.effects
{
	import mx.effects.TweenEffect;
	import mx.effects.EffectInstance;
	import com.enilsson.effects.effectClasses.AnimateColorPropertyInstance;
	import mx.effects.IEffectInstance;
	
	public class AnimateColorProperty extends TweenEffect
	{
		public var isStyle:Boolean = false;
		public var toValue:Number;
		public var property:String;
		public var fromValue:Number;			

		public function AnimateColorProperty (target:Object = null)
		{
			super(target);
			
			instanceClass = AnimateColorPropertyInstance;
		}

		override public function getAffectedProperties():Array /* of String */
		{
			return [ property ];
		}

		override protected function initInstance(instance:IEffectInstance):void
		{
			super.initInstance(instance);
			
			var animatePropertyInstance:AnimateColorPropertyInstance =
				AnimateColorPropertyInstance(instance);
	
			animatePropertyInstance.fromValue = fromValue;
			animatePropertyInstance.isStyle = isStyle;
			animatePropertyInstance.toValue = toValue;
			animatePropertyInstance.property = property;
		}	
	}
}