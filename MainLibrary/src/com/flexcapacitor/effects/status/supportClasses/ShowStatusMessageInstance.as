

package com.flexcapacitor.effects.status.supportClasses {
	import com.flexcapacitor.effects.status.ShowStatusMessage;
	import com.flexcapacitor.effects.supportClasses.ActionEffectInstance;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.core.ClassFactory;
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.managers.ISystemManager;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	
	/**
	 * @copy ShowStatusMessage
	 * */
	public class ShowStatusMessageInstance extends ActionEffectInstance {
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 * */
		public function ShowStatusMessageInstance(target:Object) {
			super(target);
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		public var messageBox:IFlexDisplayObject;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 * */
		override public function play():void { 
			super.play();
			
			var action:ShowStatusMessage = ShowStatusMessage(effect);
			var statusMessageClass:Class = action.statusMessageClass;
			var statusMessageProperties:Object = action.statusMessageProperties;
			var keepReference:Boolean = action.keepReference;
			var moveToNextEffectImmediately:Boolean = action.moveToNextEffectImmediately;
			var textAlignment:String = action.textAlignment;
			var location:String = action.location;
			var parent:Sprite = action.parentView;
			var useObjectUtilToString:Boolean = action.useObjectUtilToString;
			var message:String = action.message;
			var matchDurationToTextContent:Boolean = action.matchDurationToTextContent;
			var statusMessage:IStatusMessage;
			var minimumDuration:int = action.minimumDuration;
			var maximumDuration:int = action.maximumDuration;
			var factory:ClassFactory;
			var position:Number;
			
			///////////////////////////////////////////////////////////
			// Verify we have everything we need before going forward
			///////////////////////////////////////////////////////////
			
			// we do
			
			
			///////////////////////////////////////////////////////////
			// Continue with action
			///////////////////////////////////////////////////////////
			
			if (action.locationPosition) {
				position = action.locationPosition;
			}
			else if (location=="center") {
				position = ShowStatusMessage.CENTER;
			}
			else if (location=="top") {
				position = ShowStatusMessage.TOP;
			}
			else if (location=="bottom") {
				position = ShowStatusMessage.BOTTOM;
			}
			
			factory = new ClassFactory(statusMessageClass);
			factory.properties = statusMessageProperties;
			
			messageBox = factory.newInstance();
			statusMessage = messageBox as IStatusMessage;
			
			
			if (action.data) {
				if (message==null) {
					message = ""; 
				}
				else {
					message += "\n";
				}
				
				if (action.data is String) {
					message += action.data;
				}
				else if (useObjectUtilToString) {
					message += ObjectUtil.toString(action.data);
				}
				else {
					message += action.data + "";
				}
			}
			
			if (message==null) {
				message = "";
			}
			
			if (action.data==null && action.showNullData) {
				message += ". Data is null.";
			}
			
			if (statusMessage) {
				statusMessage.message = message;
				statusMessage.textAlignment = textAlignment;
				statusMessage.duration = action.doNotClose ? -1 : action.duration;
				statusMessage.fadeInDuration = action.fadeInDuration;
				statusMessage.showBusyIndicator = action.showBusyIcon;
				statusMessage.title = action.title;
			}
			
			if (matchDurationToTextContent && !action.doNotClose) {
				var wordCount:int = message.split(" ").length;
				var matchedDuration:int = wordCount * action.durationPerWord;
				matchedDuration = matchedDuration<minimumDuration ? minimumDuration : matchedDuration;
				matchedDuration = matchedDuration>maximumDuration ? maximumDuration : matchedDuration;
				statusMessage.duration = matchedDuration;
			}
			
			if (!parent) {
				var systemManager:ISystemManager = ISystemManager(FlexGlobals.topLevelApplication.systemManager);
				
				// no types so no dependencies
				var marshallPlanSystemManager:Object = systemManager.getImplementation("mx.managers.IMarshallPlanSystemManager");
				
				if (marshallPlanSystemManager && marshallPlanSystemManager.useSWFBridge()) {
					parent = Sprite(systemManager.getSandboxRoot());
				}
				else {
					parent = Sprite(FlexGlobals.topLevelApplication);
				}
			}
			
			PopUpManager.addPopUp(IFlexDisplayObject(messageBox), parent, action.modal);
			PopUpManager.centerPopUp(IFlexDisplayObject(messageBox));
			
			IFlexDisplayObject(messageBox).y = parent.height*position - IFlexDisplayObject(messageBox).height/2;
			
			if (action.closeHandler!=null) {
				IEventDispatcher(messageBox).addEventListener(Event.CLOSE, action.closeHandler, false, 0, true);
				IEventDispatcher(messageBox).addEventListener(MouseEvent.CLICK, action.closeHandler, false, 0, true);
			}
			else {
				IEventDispatcher(messageBox).addEventListener(Event.CLOSE, closeHandler, false, 0, true);
				IEventDispatcher(messageBox).addEventListener(MouseEvent.CLICK, closeHandler, false, 0, true);				
			}
			
			//messageBox = StatusManager.show(action.message, action.doNotClose ? -1 : action.duration, 
			//					action.showBusyIcon, action.parentView, action.modal, position);
			
			// and call finish there if requested
			
			if (keepReference) {
				action.statusMessagePopUp = messageBox;
			}
			
			///////////////////////////////////////////////////////////
			// Finish the effect
			///////////////////////////////////////////////////////////
			
			// we let the effect duration run until it is done
			if (moveToNextEffectImmediately) {
				finish();
			}
			else {
				// do we need this because it should last the duration anyway?
				//waitForHandlers(); 
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * This is called at the end of the animation
		 * */
		override public function onTweenEnd(value:Object):void  {
			super.onTweenEnd(value);
			var action:ShowStatusMessage = ShowStatusMessage(effect);
			var moveToNextEffectImmediately:Boolean = action.moveToNextEffectImmediately;
			
			removeListeners();
			close();
			restorePreviousDuration();
			
			///////////////////////////////////////////////////////////
			// Finish the effect
			///////////////////////////////////////////////////////////

			// we did not move to the next effect earlier so we finish now
			if (!moveToNextEffectImmediately) {
				finish();
			}
		}
		
		/**
		 * Removes the view from the display
		 * */
		public function closeHandler(event:Event):void {
			var action:ShowStatusMessage = ShowStatusMessage(effect);
			var moveToNextEffectImmediately:Boolean = action.moveToNextEffectImmediately;
			
			removeListeners();
			close();
			restorePreviousDuration();
			
			///////////////////////////////////////////////////////////
			// Finish the effect
			///////////////////////////////////////////////////////////
			end(); // end the tween effect if running

			// we did not move to the next effect earlier so we finish now
			if (!moveToNextEffectImmediately) {
				finish();
			}
		}
		
		/**
		 * Closes the message box
		 * */
		public function close():void {
			if (messageBox) {
				PopUpManager.removePopUp(messageBox);
			}
		}
		
		private function removeListeners():void {
			var action:ShowStatusMessage = ShowStatusMessage(effect);
			
			if (action.closeHandler!=null) {
				messageBox.removeEventListener(Event.CLOSE, action.closeHandler);
				messageBox.removeEventListener(MouseEvent.CLICK, action.closeHandler);
			}
			else {
				messageBox.removeEventListener(Event.CLOSE, closeHandler);
				messageBox.removeEventListener(MouseEvent.CLICK, closeHandler);				
			}
		}
		
	}
}