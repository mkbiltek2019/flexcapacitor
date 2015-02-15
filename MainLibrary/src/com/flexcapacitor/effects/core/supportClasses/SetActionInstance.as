
package com.flexcapacitor.effects.core.supportClasses
{
	
	import com.flexcapacitor.effects.supportClasses.ActionEffectInstance;
	
	import mx.core.IFlexModule;
	import mx.core.IFlexModuleFactory;
	import mx.core.mx_internal;
	import mx.styles.IStyleClient;
	import mx.styles.StyleManager;
	
	use namespace mx_internal;
	
	/**
	 *  @copy SetAction
	 */  
	public class SetActionInstance extends ActionEffectInstance
	{
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *
		 *  @param target The Object to animate with this effect.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function SetActionInstance(target:Object)
		{
			super(target);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Indicates whether the effect has been played (<code>true</code>), 
		 *  or not (<code>false</code>). 
		 *
		 *  <p>The <code>play()</code> method sets this property to 
		 *  <code>true</code> after the effect plays;
		 *  you do not set it directly.</p> 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		protected var playedAction:Boolean = false;
		
		/**
		 *  @private
		 */
		private var _startValue:*;
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Returns the starting state value that was saved by the
		 *  <code>saveStartValue()</code> method.
		 *
		 *  @return Returns the starting state value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		protected function getStartValue():*
		{
			return _startValue;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		
		/**
		 *  @private
		 */
		override public function end():void
		{
			if (!playedAction)
				play();
			
			super.end();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  property
		//----------------------------------
		
		/** 
		 *  @copy spark.effects.SetAction#property
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var property:String;
		
		/** 
		 *  @copy spark.effects.SetAction#property
		 *  
		 *  @see property
		 */
		public var subProperty:String;
		
		//----------------------------------
		//  value
		//----------------------------------
		
		/** 
		 *  Storage for the value property.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		private var _value:*;
		
		/** 
		 *  @copy spark.effects.SetAction#value
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get value():*
		{
			var val:*;
			
			if (playReversed)
			{
				val = getStartValue();
				if (val !== undefined)
					return val;
			}
			
			return _value;
		}
		
		/** 
		 *  @private
		 */
		public function set value(val:*):void
		{
			_value = val;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function play():void
		{
			// Dispatch an effectStart event from the target.
			super.play();    
			
			
			///////////////////////////////////////////////////////////
			// Verify we have everything we need before going forward
			///////////////////////////////////////////////////////////
			
			if (validate) {
				
				if (target==null) {
					errorMessage = "The target cannot be null";
					dispatchErrorEvent(errorMessage);
				}
				
				// check if target property exists on target - does not check if style exists
				/*else if (property && !(property in target)) {
					errorMessage = "The '" + property + "' property does not exist on the target object";
					dispatchErrorEvent(errorMessage);
					
					// check if sub property exists on target
					if (subProperty && !(subProperty in target[property])) {
						errorMessage = "The '" + subProperty + "' sub property does not exist on the target." + property + " object";
						dispatchErrorEvent(errorMessage);
					}
				}*/
				
				// we need to check if the property or style exists to do
				
			}
			
			
			///////////////////////////////////////////////////////////
			// Continue with action
			///////////////////////////////////////////////////////////
			
			// Don't save the value if we are playing in reverse.
			if (!playReversed) {
				_startValue = saveStartValue();
			}
			
			playedAction = true;
			
			
			if (value === undefined && propertyChanges)
			{
				if (property in propertyChanges.end &&
					propertyChanges.start[property] != propertyChanges.end[property])
					value = propertyChanges.end[property];
			}
			
			if (value !== undefined) {
				setValue(property, value);
			}
			
			///////////////////////////////////////////////////////////
			// Finish the effect
			///////////////////////////////////////////////////////////
			finishRepeat();
		}
		
		/**
		 * Sets <code>property</code> to the value specified by 
		 * <code>value</code>. This is done by setting the property
		 * on the target if it is a property or the style on the target
		 * if it is a style.  There are some special cases handled
		 * for specific property types such as percent-based width/height
		 * and string-based color values.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		private function setValue(property:String, value:Object):void
		{
			var isStyle:Boolean = false;
			var propName:String = property;
			var val:Object = value;
			var newTarget:Object;
			
			
			if (subProperty) {
				if (propName in target) {
					newTarget = target[propName];
				}
				else {
					newTarget = target.getStyle(propName);
				}
			}
			else {
				newTarget = target;
			}
			
			// Handle special case of width/height values being set in terms
			// of percentages. These are handled through the percentWidth/Height
			// properties instead                
			if (property == "width" || property == "height")
			{
				if (value is String && value.indexOf("%") >= 0)
				{
					propName = property == "width" ? "percentWidth" : "percentHeight";
					val = val.slice(0, val.indexOf("%"));
				}
			}
			else
			{
				var currentVal:Object = getValue(propName, subProperty);
				// Handle situation of turning strings into Boolean values
				if (currentVal is Boolean)
				{
					if (val is String)
						val = (value.toLowerCase() == "true");
				}
					// Handle turning standard string representations of colors
					// into numberic values
				else if (currentVal is Number &&
					propName.toLowerCase().indexOf("color") != -1)
				{
					var moduleFactory:IFlexModuleFactory = null;
					if (newTarget is IFlexModule)
						moduleFactory = newTarget.moduleFactory;
					
					val = StyleManager.getStyleManager(moduleFactory).getColorName(value);
				}
			}
			
			if (subProperty) {
				if (subProperty in newTarget) {
					newTarget[subProperty] = val;
				}
				else {
					newTarget.setStyle(subProperty, val);
				}
			}
			else {
				if (propName in target) {
					target[propName] = val;
				}
				else {
					target.setStyle(propName, val);
				}
			}
		}
		
		/**
		 * Gets the current value of propName, whether it is a 
		 * property or a style on the target.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		private function getValue(propName:String, subProperty:String = null):* {
			
			if (subProperty) {
				// get property property
				if (propName in target && subProperty in target[propName]) {
					return target[propName][subProperty];
				}
				else {
					// get property style
					if (propName in target) {
						return target[propName].getStyle(propName);
					}
					// get style property
					else if (target.getStyle(propName) && subProperty in target.getStyle(propName)) {
						return target.getStyle(propName)[subProperty];
					}
					// get style style
					else if (target.getStyle(propName) && target.getStyle(propName) is IStyleClient) {
						return target.getStyle(propName).getStyle(subProperty);
					}
				}
			}
			else {
				if (propName in target) {
					return target[propName];
				}
				else {
					return target.getStyle(propName);
				}
			}
		}
		
		/** 
		 *  @private
		 */
		protected function saveStartValue():*
		{
			if (property != null)
			{
				try
				{
					return getValue(property, subProperty);
				}
				catch(e:Error)
				{
					// Do nothing. Let us return undefined.
				}
			}
			return undefined;
		}
	}
	
}
