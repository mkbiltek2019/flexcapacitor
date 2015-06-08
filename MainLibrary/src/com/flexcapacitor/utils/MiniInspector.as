package com.flexcapacitor.utils {
	
	import flash.debugger.enterDebugger;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.JointStyle;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayList;
	import mx.controls.ToolTip;
	import mx.core.EventPriority;
	import mx.core.FlexGlobals;
	import mx.core.FlexSprite;
	import mx.core.IFlexDisplayObject;
	import mx.core.IFlexModule;
	import mx.core.IFlexModuleFactory;
	import mx.core.IMXMLObject;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.graphics.BitmapFill;
	import mx.graphics.BitmapFillMode;
	import mx.graphics.SolidColorStroke;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.logging.targets.TraceTarget;
	import mx.managers.ISystemManager;
	import mx.managers.PopUpManager;
	import mx.managers.SystemManager;
	import mx.managers.SystemRawChildrenList;
	import mx.managers.ToolTipManager;
	import mx.styles.CSSCondition;
	import mx.styles.CSSConditionKind;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.IAdvancedStyleClient;
	import mx.styles.IStyleClient;
	import mx.styles.IStyleManager2;
	import mx.styles.StyleManager;
	import mx.utils.ArrayUtil;
	import mx.utils.NameUtil;
	import mx.utils.ObjectUtil;
	
	import spark.components.Application;
	import spark.components.Group;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.components.WindowedApplication;
	import spark.primitives.Rect;
	
	/**
	 * Dispatched when pressing the ALT key. Use to get the target under the mouse or the lastComponentItem.
	 * */
	[Event(name="click", type="flash.events.MouseEvent")]
	
	/**
	 * This class allows you to display information about the visual element you click on 
	 * at runtime and get or set properties or styles of that instance at runtime.<br/><br/> 
	 *  
	 * • You can also manually fade in and out a bitmap image for comparing a mockup image 
	 * with the runtime layout.<br/>
	 * • You can also get the CSS heirarchy and style information of a visual element <br/>
	 * • You can get the font family, font embedding and font device information. <br/>
	 * • You can get the color under the mouse.<br/>
	 * • You can show a ruler at runtime and get size and angle information with it. <br/><br/>
	 * 
	 * Please read through all of the documentation in this class to 
	 * save yourself time debugging.<br/><br/> 
	 *
	 * To get started click anywhere on the application while pressing the CTRL / COMMAND key and
	 * information about the object under the mouse (that is also in the component tree excluding the skin) will be written to the console
	 * and the object will be outlined in the app. After a few seconds the next object
	 * in the component tree, which is the owner or parent of the currently selected object will be selected. 
	 * Click on the component again to stop from moving to the next object in the heirarchy. 
	 * You can click on the area to the left of the outline label to stop the automatic selection of the next object
	 * in the hierarchy. Note: When moving to the next object no information will be written to 
	 * the console like the first object you clicked on.  
	 * 
	 * The information output to the console includes a way to find the object in Eclipse.
	 * It will create a search pattern using a regular expression that will locate instance and 
	 * show you the document the object is defined in. You use this pattern in conjunction with 
	 * the Eclipse Search in Files dialog.<br/><br/>
	 *
	 * Click anywhere on the application while pressing CTRL / CMD + SHIFT key and
	 * information about the object under the mouse (that is in the component tree OR in the skin or display list) will be 
	 * written to the console and the object will be outlined in the app.<br/><br/>
	 *
	 * Adding the ALT key to the above keyboard shortcuts will cause you to enter the debugger
	 * during a click event to inspect the properties and values of the item you clicked.
	 * You can click on an element, find it and then step into it's click handler method.<br/><br/>
	 * 
	 * <b>Mini Inspector Usage</b><br/>
	 * Add the class to the declarations tag usually in the root application like so,<br/><br/>
	 *
 * <pre>
 * &lt;fx:Declarations>
 * 	 &lt;utils:MiniInspector/>
 * &lt;/fx:Declarations>
 * </pre>
	 * 
	 * <b>To select a display object or UI component</b><br/><br/>
	 * Hold down COMMAND and CLICK on the component with your mouse.
	 * This will select the UIComponent in the component tree and show an outline around it. 
	 * Press SHIFT + COMMAND + CLICK to select a sub-component of a UIComponent on the display list. 
	 * The difference is the Component tree should match your MXML project exactly while a display object
	 * may be part of a skin of a UIComponent and is not necessarily part of the component tree. <br/><br/>
	 * Pressing CMD+CLICK or SHIFT+CMD+CLICK will also output the location of the visual element 
	 * in the console. You can use this information to find the instance of the element. <br/><br/>
	 * 
	 * <b>To get or set the property or style of a display object or UI component</b><br/><br/>
	 * Hold down COMMAND+CLICK or SHIFT+COMMAND+CLICK to select the component and then click the label 
	 * above the component with your mouse. This will show two text fields. The first is the 
	 * property or style. Type the name of the property or style in the first field and press enter. 
	 * This will retrieve the value and place it in the second text field. To change or update
	 * the property or style value, type the new value in the second text field and press enter. 
	 * You can type in colors using a color name or hexidecimal value such as, "red", "#FF0000" or "0xFF0000".
	 * You can also set the value to null or undefined. Just type in the word "undefined" without the quotes. 
	 *
	 * <b>To use find in files:<b><br/><br/>
	 * • COMMAND+CLICK or COMMAND+SHIFT+CLICK on an visual element (UIComponent) at runtime. This writes a RegEx pattern to the console. 
	 * • Open the Search in Files dialog (CTRL + H)<br/>
	 * • Copy the pattern from the console and paste it into the search text input<br/>
	 * • Select Regular Expression checkbox in the dialog if it's not selected already<br/>
	 * • Select Current Workspace or Project option in the dialog if it's not selected already<br/>
	 * • Click the Search button.<br/>
	 * • Double click on the search results. It will open the document containing the item you clicked on.<br/>
	 *
	 * Note: If it has an ID it will find it quickly. If it doesn't it will narrow it down and in most cases still find it. 
	 * <br/><br/>
	 *
	 * <b>To use the image fade in fade out:</b><br/><br/>
	 *
	 * • Add an image to your component for example, <br/>
	 * &lt;s:BitmapImage id="image" source="mockup.png" /><br/><br/>
	 * • Set the background image property to the image like so, <br/>
	 * &lt;utils:MiniInspector backgroundImage="{image}"/><br/><br/>
	 * • Run the application<br/>
	 * • While holding COMMAND / CTRL scroll the mouse wheel up or down. 
	 * This will fade the image in and out allowing you to compare the actual layout
	 * with the bitmap image screenshot.<br/><br/>
	 *
	 * <b>To use the ruler:<b><br/><br/>
	 * • Set showRuler to true: 
 * <pre>
 * &lt;fx:Declarations>
 * 	 &lt;utils:MiniInspector showRuler="true"/>
 * &lt;/fx:Declarations>
 * </pre>
	 * • Hold down the COMMAND / CTRL key and press the mouse button down and drag.<br/>
	 * • Drag drag left, right, up or down.<br/>
	 * A ruler and tool tip will be shown with length, width, height and angle of the line.<br/>
	 * • Hold the SHIFT key to lock the ruler to vertical or horizontal position.<br/>
	 * • Release the SHIFT and COMMAND to stop showing the ruler.<br/><br/>
	 * NOTE: If the app has tool tips itself it is possible it will remove the ruler tool tip and
	 * show it's own. To prevent this disable the areas where the app shows it's tool tips or
	 * output the coordinates to the console with the output ruler values to the console setting.<br/>
	 * 
	 * <b>NOTES:</b><br/>
	 * 
	 * If two outlines show up check that there are not two instances 
	 * of this class in use. You can check the document property of this
	 * class to see where an instance is declared.<br/><br/>
	 * 
	 * There are more features than described here. Please read through the properties and 
	 * documentation in this class.<br/><br/>
	 * 
	 * More information at https://github.com/monkeypunch3/flexcapacitor
	 * Please send feature requests and bug reports. 
	 * */
	public class MiniInspector extends EventDispatcher implements IMXMLObject {
		
		
		public static const DEFAULT_FACTORY:String = "Theme Type Declaration";
		public static const FACTORY_FUNCTION:String = "Type Declaration";
		public static const OVERRIDE:String = "Inline";
		
		public static const MOUSE_DOWN_OUTSIDE:String = "mouseDownOutside";
		
		private var _alpha:Number;
		private var _enabled:Boolean = true;
		private var _backgroundImage:IVisualElement;
		
		/**
		 * Message to output to the console
		 **/
		public var message:String = "";
		
		/**
		 * Flag indicating if the url starts with "http"
		 * */
		public var isOnServer:Boolean;
		
		/**
		 * Shows styles from the "global" type declaration
		 *
		 * @see #showUniversalStyles
		 * @see #showStyleInheritanceInformation
		 * */
		public var showGlobalStyles:Boolean;
		
		/**
		 * Shows styles from the "*" type declaration
		 *
		 * @see #showGlobalStyles
		 * @see #showStyleInheritanceInformation
		 * */
		public var showUniversalStyles:Boolean;
		
		/**
		 * Minimum and maximumn amount of space to show style name in console in style name lookup
		 * */
		public var minimumStyleNamePadding:int = 35;
		
		/**
		 * Shows style inheritance information
		 *
		 * @see #showUniversalStyles
		 * @see #showGlobalStyles
		 * */
		public var showStyleInheritanceInformation:Boolean;
		
		/**
		 * Show embedded fonts information. 
		 * 
		 * Note: When on mobile remember that StageTextArea and StageTextInput
		 * skins do not allow embedded fonts. Use Spark mobile TextSkins instead.
		 * @see includeEmbeddedFontDetails
		 * */
		public var showEmbeddedFontInformation:Boolean;
		
		/**
		 * Show device fonts information
		 * @see includeEmbeddedFontDetails
		 * @see showEmbeddedFontInformation
		 * */
		public var showDeviceFontInformation:Boolean;
		
		/**
		 * Checks if a font family is embedded when showing style information
		 * @see showEmbeddedFontInformation
		 * @see showEmbeddedFontInformation
		 * */
		public var includeEmbeddedFontDetails:Boolean = true;
		
		/**
		 * Show all style declarations
		 * @see showStyleInheritanceInformation
		 * */
		public var showAllStyleDeclarations:Boolean;
		
		/**
		 * Shows color under the mouse
		 * */
		public var showColorUnderMouse:Boolean;
		
		/**
		 * Shows a ruler when dragging. Set this value to true 
		 * and press and hold the COMMAND / CTRL key, the mouse down
		 * button and then move the mouse. 
		 * @see requireCTRLKey
		 * */
		public var showRuler:Boolean;
		
		/**
		 * Shows the ruler values in the console when ruler is active
		 * */
		public var showRulerValuesInConsole:Boolean;
		
		/**
		 * Shows display object information instead of component information
		 * Does not work at this time
		 * */
		public var showDisplayObjectInformation:Boolean = true;
		
		/**
		 * Shows the boundries of elements in the component tree
		 * */
		public var showDisplayObjectOutlines:Boolean = true;
		
		/**
		 * Point of origin when using ruler
		 **/
		public var rulerStartingPoint:Point;
		
		/**
		 * Pop up when using ruler
		 * @see rulerColor
		 **/
		public var rulerPopUp:UIComponent;
		
		/**
		 * Color of the ruler line. Default is black
		 **/
		public var rulerColor:Number = 0x000000;
		
		/**
		 * Tooltip when using popup
		 **/
		public var toolTipPopUp:ToolTip;
		
		/**
		 * Recreate ruler tooltip if needed. If an app has tool tips 
		 * it will destroy the current tool tip we are using for the ruler.
		 * Setting this to true takes back the tool tip. 
		 **/
		public var recreateToolTipIfNeeded:Boolean = true;
		
		/**
		 * Minimum tool tip width
		 * */
		public var minToolTipWidth:int = 70;
		
		/**
		 * Space before some output text
		 * */
		public var prespace:String = "  ";
		
		/**
		 * Show document information
		 * */
		public var showDocument:Boolean = true;
		
		/**
		 * Show parent document information
		 * */
		public var showParentDocument:Boolean = true;
		
		/**
		 * Show regular expression search pattern in console when checking target.
		 * This is used to find the target in Eclipse.
		 * Copy the value and paste it into the Find or Search window with RegExp option checked.
		 * */
		public var showSearchPattern:Boolean = true;
		
		/**
		 * Shows the path of the target clicked excluding components in the skin.
		 * This shows the path from the component to the root component.
		 *
		 * For example, if you click a label in a skin the path will start from
		 * the component that owns the button not the button itself.
		 *
		 * Example:
		 * Button > Group > Application
		 *
		 * @see showHeirarchy
		 * */
		public var showHeirarchy:Boolean = true;
		
		/**
		 * Show the path from the target up the display list or component display list
		 * in an ascending order. Default is true.
		 * */
		public var showHeirarchyAscending:Boolean = true;
		
		/**
		 * Includes ID in the component path. For example,
		 * Button.myButton > Group > Group.container > Application.MyApplication
		 * 
		 * @see pathFormat
		 * */
		public var includeIDinPath:Boolean = true;
		
		/**
		 * The format when formatting the ID in the component path. For example,
		 * format1 - Button#myButton
		 * format2 - Button.myButton 
		 * format3 - myButton::Button
		 * */
		[Inspectable(enumeration="format1,format2,format3")]
		public var pathFormat:String = "format1";
		
		/**
		 * The separator in the component path. Default is " > ". For example,  
		 * Button.myButton > Group > Group.container > Application.MyApplication
		 * */
		public var componentPathSeparator:String = " > ";
		
		/**
		 * Shows divider markers in the console when checking the target
		 * */
		public var showConsoleDividerMarks:Boolean = true;
		
		/**
		 * Divider markers in the console when checking the target
		 * */
		public var dividerMarks:String = "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
		
		/**
		 * Shows footer divider markers in the console when checking the target
		 * */
		public var showFooterConsoleDividerMarks:Boolean;
		
		/**
		 * Sets the alpha of the background image
		 * @see backgroundImage
		 * */
		public var backgroundImageAlpha:Number;
		
		/**
		 * Amount of alpha to change when scrolling the mouse wheel
		 *
		 * @see backgroundImage
		 * @see backgroundImageAlpha
		 * */
		public var mouseWheelDelta:int;
		
		/**
		 * When an visual element is set and this option is enabled
		 * and when the shift key is pressed scrolling up or down on the
		 * mouse wheel will increase or decrease the transparency of the
		 * background image
		 *
		 * @see backgroundImage
		 * @see backgroundImageAlpha
		 * */
		public var enableBackgroundCrossFade:Boolean = true;
		
		/**
		 * The amount to add to the mouse wheel delta to fade up or down the
		 * transparency of the background image.
		 * For example, if the delta is 4 and the multiplier is 10 then the amount
		 * to add to the alpha value is .4 since 4/10.
		 * Default is 20.
		 *
		 * @see backgroundImage
		 * @see backgroundImageAlpha
		 * @see mouseWheelDelta
		 * */
		public var multiplier:int = 20;
		
		/**
		 * Reference to the document set automatically when declared in MXML.
		 * If this class isn't declared in MXML then it is not set.
		 * You must set this manually if you want the path of the target to work
		 * when checking the target.
		 * */
		public var document:Object;
		
		/**
		 * ID of the reference to the document set automatically when declared in MXML.
		 * If this isn't declared in MXML then it is not set.
		 * */
		public var documentID:String;
		
		/**
		 * Flags used to set the "dot all" property to on for multiline support in Eclipse.
		 * Default value is "(?s)".
		 * */
		public var regExpSearchFlags:String = "(?s)";
		
		/**
		 * Last item selected in the component
		 **/
		public var lastComponentItem:ComponentItem;
		
		/**
		 * Current clicked on target
		 **/
		[Bindable]
		public var target:Object
		
		/**
		 * Current display object in the pop up display outline
		 **/
		[Bindable]
		public var currentPopUpTarget:Object
		
		
		/**
		 * Set this to false to test on touch screen device. 
		 * */
		public var requireCTRLKey:Boolean = true;

		/**
		 *
		 **/
		public function MiniInspector() {
			var rootDisplay:DisplayObject = SystemManager.getSWFRoot(this);
			
			isOnServer = rootDisplay.loaderInfo.url.indexOf("http")==0 ? true : false;
			
			debug = true;
			
			addMouseHandler();
		}
		
		/**
		 * 
		 **/
		public function initialized(document:Object, id:String):void {
			this.document = document;
			this.documentID = id;
		}
		
		/**
		 * Set this to an image or visual element on the stage. At runtime hold the COMMAND key and
		 * scroll the mouse wheel up or down to fade the element in or out.
		 * */
		public function get backgroundImage():IVisualElement {
			return _backgroundImage;
		}
		
		public function set backgroundImage(value:IVisualElement):void {
			_backgroundImage = value;
			
			// this does something
			if (_backgroundImage) {
				swfRoot.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, true, 0, true);
			}
			else {
				swfRoot.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, true);
			}
			
		}
		
		/**
		 * Enables or disables this class
		 * */
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void {
			_enabled = value;
			
			addMouseHandler(value);
		}
		
		protected function addMouseHandler(value:Boolean = true):void {
			
			if (value) {
				swfRoot.addEventListener(MouseEvent.CLICK, handleClick, true, EventPriority.CURSOR_MANAGEMENT, true);
				swfRoot.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, true, EventPriority.CURSOR_MANAGEMENT, true);
			}
			else {
				swfRoot.removeEventListener(MouseEvent.CLICK, handleClick, true);
				swfRoot.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, true);
			}
		}
		
		/**
		 * Adds handlers for ruler tool
		 **/
		protected function addRulerHandlers(value:Boolean = true, event:MouseEvent = null):void {
			
			if (value) {
				swfRoot.addEventListener(MouseEvent.MOUSE_MOVE, mouseRulerMoveHandler, true, EventPriority.CURSOR_MANAGEMENT, true);
				swfRoot.addEventListener(MouseEvent.MOUSE_UP, mouseRulerUpHandler, true, EventPriority.CURSOR_MANAGEMENT, true);
				
				rulerStartingPoint = new Point(event.stageX, event.stageY);
				
				if (rulerPopUp==null) {
					rulerPopUp = new UIComponent();
				}
				else {
					if (rulerPopUp.isPopUp) {
						PopUpManager.removePopUp(rulerPopUp);
					}
					
					if (toolTipPopUp && toolTipPopUp.stage) {
						ToolTipManager.destroyToolTip(toolTipPopUp);
						ToolTipManager.currentToolTip = null;
						toolTipPopUp = null;
					}
				}
			}
			else {
				swfRoot.removeEventListener(MouseEvent.MOUSE_MOVE, mouseRulerMoveHandler, true);
				swfRoot.removeEventListener(MouseEvent.MOUSE_UP, mouseRulerUpHandler, true);
				
				if (rulerPopUp.isPopUp) {
					PopUpManager.removePopUp(rulerPopUp);
				}
				
				if (toolTipPopUp && toolTipPopUp.stage) {
					ToolTipManager.destroyToolTip(toolTipPopUp);
					ToolTipManager.currentToolTip = null;
					toolTipPopUp = null;
				}
			}
		}
		
		private var _swfRoot:IEventDispatcher;

		public function get swfRoot():IEventDispatcher {
			return SystemManager.getSWFRoot(this);
		}

		public function set swfRoot(value:IEventDispatcher):void {
			_swfRoot = value;
		}

		
		protected function mouseRulerMoveHandler(event:MouseEvent):void {
			var message:String;
			
			if (!rulerPopUp.stage) {
				PopUpManager.addPopUp(rulerPopUp, SystemManager.getSWFRoot(this));
				createRulerToolTip(event.stageX, event.stageY);
			}
			
			rulerPopUp.graphics.clear();
			rulerPopUp.graphics.lineStyle(1, rulerColor);
			
			var distance:Number;
			var targetX:int = event.stageX;
			var targetY:int = event.stageY;
			var startX:int = rulerStartingPoint.x;
			var startY:int = rulerStartingPoint.y;
			var deltaX:Number = Number(Number(targetX - startX).toFixed(1));
			var deltaY:Number = Number(Number(targetY - startY).toFixed(1));
			
			// This may not be correct. Or we may want to show an alternative degree unit
			//var angleInDegrees:int = Math.abs(Math.atan2(deltaY, deltaX) * 180 / Math.PI);
			var angleInDegrees:int = -(Math.atan2(deltaY, deltaX) * 180 / Math.PI);
			var sign:int = angleInDegrees<0 ? -1 : 1;
			var angle2:int = Math.atan2(-deltaY, -deltaX) * 180 / Math.PI - 90;
			angle2 = angle2 < 0 ? 360 + angle2 : angle2;
			
			distance = Math.max(Math.abs(startX-targetX), Math.abs(startY-targetY));
			distance = Number(distance.toFixed(1));
			
			if (event.shiftKey) {
				//angleInDegrees = Math.abs(angleInDegrees);
				var includeAngles:Boolean = false;
				
				if (includeAngles) {
					if (angleInDegrees>=0 && angleInDegrees<=26) {
						targetY = rulerStartingPoint.y;
						angleInDegrees = 0;
					}
					else if (angleInDegrees>=26 && angleInDegrees<=63) {
						targetX = startX + distance;
						targetY = startY + -distance;
						angleInDegrees = 45;
					}
					else if (angleInDegrees>=63 && angleInDegrees<=116) {
						targetX = startX;
						angleInDegrees = 90;
					}
					else if (angleInDegrees>=116 && angleInDegrees<=154) {
						targetX = startX + -distance;
						targetY = startY + -distance;
						angleInDegrees = 135;
					}
					else if (angleInDegrees>=154 && angleInDegrees<=180) {
						targetY = startY;
						angleInDegrees = 180;
					}
					else if (angleInDegrees<=0 && angleInDegrees>=-26) {
						targetY = startY;
						angleInDegrees = 0;
					}
					else if (angleInDegrees<=-26 && angleInDegrees>=-63) {
						targetX = startX + distance;
						targetY = startY + distance;
						angleInDegrees = -45;
					}
					else if (angleInDegrees<=-63 && angleInDegrees>=-116) {
						targetX = startX;
						angleInDegrees = -90;
					}
					else if (angleInDegrees<=-116 && angleInDegrees>=-154) {
						targetX = startX + -distance;
						targetY = startY + distance;
						angleInDegrees = -135;
					}
					else if (angleInDegrees<=-154 && angleInDegrees>=-180) {
						targetY = startY;
						angleInDegrees = -180;
					}
				}
				else {
					
					if (angleInDegrees>=0 && angleInDegrees<=45) {
						targetY = startY;
						angleInDegrees = 0;
						angle2 = 90;
					}
					else if (angleInDegrees>=45 && angleInDegrees<=135) {
						targetX = startX;
						angleInDegrees = 90;
						angle2 = 0;
					}
					else if (angleInDegrees>=135 && angleInDegrees<=180) {
						targetY = startY;
						angleInDegrees = 180;
						angle2 = 270;
					}
					else if (angleInDegrees<=0 && angleInDegrees>=-45) {
						targetY = startY;
						angleInDegrees = 0;
						angle2 = 90;
					}
					else if (angleInDegrees<=-45 && angleInDegrees>=-135) {
						targetX = startX;
						angleInDegrees = -90;
						angle2 = 180;
					}
					else if (angleInDegrees<=-135 && angleInDegrees>=-180) {
						targetY = startY;
						angleInDegrees = -180;
						angle2 = 270;
					}
				}
			}
			
			rulerPopUp.graphics.moveTo(startX, startY);
			rulerPopUp.graphics.lineTo(targetX, targetY);
			
			//message = "" + distance + "px";
			message = "x:" + deltaX + " y:" + deltaY;
			//message += "\nx:" + targetX + ",y:" + targetY;
			message += "\n" + angle2 + "°" + "  " + angleInDegrees + "°";
			
			if (ToolTipManager.currentToolTip || recreateToolTipIfNeeded) {
				
				if (!ToolTipManager.currentToolTip && recreateToolTipIfNeeded) {
					createRulerToolTip(event.stageX, event.stageY);
				}
				
				ToolTipManager.currentToolTip.x = targetX+5;
				ToolTipManager.currentToolTip.y = targetY;
				toolTipPopUp.text = message;
			}
			
			if (showRulerValuesInConsole) {
				logger.log(LogEventLevel.INFO, message);
			}
			
		}
		
		protected function mouseRulerUpHandler(event:MouseEvent):void
		{
			addRulerHandlers(false, event);
		}
		
		/**
		 * Creates a tool tip and sets the toolTipPopUp property
		 * */
		public function createRulerToolTip(x:Number, y:Number):void {
			toolTipPopUp = ToolTipManager.createToolTip("", x, y) as ToolTip;
			toolTipPopUp.minWidth = minToolTipWidth;
			ToolTipManager.currentToolTip = toolTipPopUp;
		}
		
		
		/**
		 * Click handler added to stage
		 * We only check the target if the ctrl key is down
		 * If the shift key is down also then we enter the debugger
		 * Press step into to bring the debugger to the check target method
		 * In that method you can check details in the target property
		 * */
		protected function handleClick(event:MouseEvent):void {
			
			if (enabled) {
				if (!requireCTRLKey || event.ctrlKey) {
					// we are intercepting this event so we can inspect the target
					// stop the event propagation
					
					// we don't stop the propagation on touch devices so you can navigate the application
					if (requireCTRLKey) {
						event.stopImmediatePropagation();
					}
					checkTarget(event.target, event);
				}
			}
		}
		
		/**
		 * Check if dragging for ruler
		 * */
		protected function handleMouseDown(event:MouseEvent):void {
			
			if (enabled && showRuler) {
				if (!requireCTRLKey || event.ctrlKey) {
					// we are intercepting this event so we can inspect the target
					// stop the event propagation
					
					// we don't stop the propagation on touch devices so you can navigate the application
					if (requireCTRLKey) {
						event.stopImmediatePropagation();
					}
					
					addRulerHandlers(true, event);
				}
			}
		}
		
		/**
		 * Handler to increase or decrease the transparency of a visual element
		 * on a mouse wheel scroll event
		 * */
		protected function mouseWheelHandler(event:MouseEvent):void {
			
			if (enabled && enableBackgroundCrossFade && backgroundImage) {
				if (event.shiftKey || event.ctrlKey) {
					mouseWheelDelta = event.delta;
					_alpha = backgroundImage.alpha;
					
					_alpha = _alpha + mouseWheelDelta/multiplier;
					_alpha = _alpha>1?1:_alpha<0?0:_alpha;
					
					backgroundImage.alpha = _alpha;
					
					// prevent scrolling higher up the line
					event.stopImmediatePropagation();
				}
			}
		}
		
		/**
		 * Gets the current target and traces it to the console
		 * */
		public function checkTarget(mouseTarget:Object, event:MouseEvent):void {
			var rootComponent:ComponentItem = document ? createComponentTreeFromElement(document) : createComponentTreeFromElement(FlexGlobals.topLevelApplication);
			var rootSystemManagerTree:ComponentItem = createComponentTreeFromElement(FlexGlobals.topLevelApplication.systemManager);
			var componentItem:ComponentItem = getFirstParentComponentItemFromComponentTreeByDisplayObject(DisplayObject(mouseTarget), rootComponent);
			var displayTarget:DisplayObject = mouseTarget as DisplayObject; // original clicked on item as reported by the mouse event
			// first component found to own the event.target that is also on the component tree
			// if the component is in a pop up we are not handling it
			var componentTarget:Object;
			var selectedTarget:Object;
			var message:String = "";
			var clearStyle:Boolean;
			// set to string so debugger allows change of values
			var property:String = "";
			var style:String = "";
			var value:String = "";
			var styles:Array;
			var currentValue:*;
			var findElementByID:String = "";
			var findElementByName:String = "";
			
			
			// if not on the component tree target may be a pop up
			if (componentItem==null) {
				componentItem = getFirstParentComponentItemFromComponentTreeByDisplayObject(DisplayObject(mouseTarget), rootSystemManagerTree)
			}
			
			componentTarget = componentItem ? componentItem.target : displayTarget;
			
			// get target
			if (event.shiftKey) {
				selectedTarget = displayTarget;
			}
			else {
				selectedTarget = componentTarget;
			}
			
			target = selectedTarget;
			
			// show target information
			if (showDisplayObjectInformation) {
				if (event.shiftKey) {
					message = getComponentDetails(componentItem.accessPath, true);
				}
				else {
					message = getComponentDetails(componentItem, false);
				}
			}
			else {
				// SHOW OPTION TO GET OBJECT IN DISPLAY LIST
				// -- NOT SUPPORTED YET
				//message = getDisplayObjectDetails(event.target);
			}
			
			// show styles
			if (showStyleInheritanceInformation) {
				if (message!="") message += "\n";
				message += getStyleDetails(selectedTarget, includeEmbeddedFontDetails);
			}
			
			// show embedded fonts
			if (showEmbeddedFontInformation) {
				if (message!="") message += "\n";
				message += getFontInformationDetails(selectedTarget);
			}
			
			// show all styles
			if (showAllStyleDeclarations) {
				if (message!="") message += "\n";
				message += getAllStyleDeclarationsDetails(selectedTarget);
			}
			
			// show color under pixel
			if (showColorUnderMouse) {
				if (message!="") message += "\n";
				message += getColorUnderMouse(event);
			}
			
			// show element boundries
			if (showDisplayObjectOutlines && !popUpIsDisplaying) {
				//if (message!="") message += "\n";
				//message += postDisplayObject(selectedTarget as DisplayObject);
				addMouseHandler(false);
				postDisplayObject(selectedTarget as DisplayObject);
			}
			
			logger.log(LogEventLevel.INFO, message);
			lastComponentItem = componentItem;
			
			// add an event listener to this class and then get the lastComponentItem
			dispatchEvent(event);
			
			
			// The purpose of this is to check the properties on the target
			if (event.altKey) {
				
				// the debugger doesn't take you here until you press step into or step over
				logger.log(LogEventLevel.INFO, "\n// Click your heels three times and step in...");
				
				// the target object contains the item you clicked on
				enterDebugger();
			}
			
			
			// TO GET OR SET VALUES SET THE PROPERTY OR STYLE VARIABLE NOW
			
			// allows you to get or set a property or style value dynamically 
			// through the IDE while debugging
			if (property) {
				
				try {
					currentValue = selectedTarget[property];
					
					selectedTarget[property] = value;
					
					currentValue = selectedTarget[property];
				}
				catch (error:Error) {
					logger.log(LogEventLevel.ERROR, "Error setting property:" + error.message);
				}
				
			}
			else if (style) {
				
				try {
					currentValue = selectedTarget.getStyle(style);
					
					// need to call clear style or allow setting undefined
					// to support
					if (value!="undefined") {
						selectedTarget.setStyle(style, value);
					}
					else if (clearStyle) {
						selectedTarget.setStyle(style, undefined);
					}
					
					currentValue = selectedTarget.getStyle(style);
				}
				catch (error:Error) {
					logger.log(LogEventLevel.ERROR, "Error setting style:" + error.message);
				}
			}
			else if (findElementByID) {
				var componentItemByID:ComponentItem = findComponentItemInParentItemByID(findElementByID, rootComponent);
				if (componentItemByID==null) {
					componentItemByID = findComponentItemInParentItemByID(findElementByID, rootSystemManagerTree);
				}
			}
			else if (findElementByName) {
				var componentItemByName:ComponentItem = findComponentItemInParentItemByName(findElementByName, rootComponent);
				if (componentItemByName==null) {
					componentItemByName = findComponentItemInParentItemByName(findElementByID, rootSystemManagerTree);
				}
			}
		}
		
		/**
		 * Get's the style inheritance
		 *
		 * Getting TextInput / TextArea pseudo conditions is experimental
		 * TextInput:normalWithPrompt etc
		 * the ordering of pseudo style declarations is still under development
		 * Also, doesn't get unqualified / unconditional styles so it will
		 * find "TextInput.myStyle" but not ".myStyle".
		 * */
		public function getStyleInheritance(styleClient:IStyleClient):Array {
			if (styleClient==null) return [];
			
			var className:String = styleClient.className;
			var targetStyleDeclarationsArray:Array = [];
			var classDeclarations:Array;
			var component:UIComponent = styleClient as UIComponent;
			var styleManager:IStyleManager2 = StyleManager.getStyleManager(component.moduleFactory);
			var styleItem:CSSStyleDeclarationItem;
			var applicationStyleManager:IStyleManager2 = Application(FlexGlobals.topLevelApplication).styleManager;
			var sortType:Array = ["name"];
			var declaration:CSSStyleDeclaration;
			var advancedStyleClient:IAdvancedStyleClient = styleClient as IAdvancedStyleClient;
			
			var hasPseudoCondition:Boolean = styleManager.hasPseudoCondition("normalWithPrompt");
			var hasAdvancedSelectors:Object = component.styleManager.hasAdvancedSelectors();
			
			
			// get style declarations
			classDeclarations = styleClient.getClassStyleDeclarations();
			
			var length:int = classDeclarations.length;
			
			
			// add pseudo selectors
			// experimental method to get TextInput / TextArea pseudo conditions
			// TextInput:normalWithPrompt etc
			// the ordering is still under development
			for (var ii:int=0;ii<length;ii++) {
				declaration = classDeclarations[ii];
				var subjects:Object = styleManager.getStyleDeclarations(declaration.subject);
				
				for (var subject:String in subjects) {
					var items:Array = ArrayUtil.toArray(subjects[subject]);
					
					for (var jj:int = 0;jj<items.length;jj++) {
						var item:CSSStyleDeclaration = items[jj];
						
						// the hard part is how to order them in???
						if (classDeclarations.indexOf(item)==-1) {
							logger.log(LogEventLevel.WARN, "Found advanced selector:" + item.mx_internal::selectorString);
							//item.setStyle("PSEUDO", ii);
							//classDeclarations.unshift(item);
							//classDeclarations.splice(ii, 0, item);
						}
					}
				}
			}
			
			classDeclarations.reverse();
			
			
			// add inline styles
			var styleDeclaration:CSSStyleDeclaration = styleClient.styleDeclaration;
			
			if (styleDeclaration) {
				classDeclarations.unshift(styleDeclaration);
			}
			
			// add global styles
			if (showGlobalStyles) {
				var globalDeclaration:CSSStyleDeclaration = styleManager.getStyleDeclaration("global");
				
				if (globalDeclaration) {
					classDeclarations.push(globalDeclaration);
				}
			}
			
			// add universal styles
			if (showUniversalStyles) {
				var universalDeclaration:CSSStyleDeclaration = styleManager.getStyleDeclaration("*");
				
				if (universalDeclaration) {
					classDeclarations.push(universalDeclaration);
				}
			}
			
			
			// feeble attempt to get rogue selectors like .myStyle
			// ie universal class selectors (or ID selectors?)
			var allSelectors:Array = styleManager.selectors;
			var styleClientMatches:Boolean;
			length = allSelectors.length;
			
			for (var aa:int;aa<length;aa++) {
				var selector:String = allSelectors[aa];
				declaration = styleManager.getStyleDeclaration(selector);
				styleClientMatches = declaration.matchesStyleClient(styleClient as IAdvancedStyleClient);
				
				if (styleClientMatches) {
					var indexOf:int = classDeclarations.indexOf(declaration);
					
					// the hard part is how to order them in???
					if (indexOf<0) {
						logger.log(LogEventLevel.WARN, "Found rogue selector:" + selector);
						//classDeclarations.unshift(declaration);
					}
				}
			}
			
			if (classDeclarations.length>0) {
				
				for (var i:int;i<classDeclarations.length;i++) {
					var overrides:Object;
					var defaultFactoryInstance:Object;
					var factoryInstance:Object;
					var selectorType:String = "";
					var conditions:Array;
					var array:Array = [];
					var outputArray:Array = [];
					var skipDuplicate:Boolean = false;
					
					declaration = classDeclarations[i];
					
					
					// this is from an mxml inline attribute being set or calling setStyle in actionscript
					if (declaration.overrides!=null) {
						styleItem = new CSSStyleDeclarationItem();
						styleItem.name = getStyleDeclarationDisplayName(declaration);
						styleItem.declaration = declaration;
						targetStyleDeclarationsArray.push(styleItem);
						styleItem.type = OVERRIDE;
						overrides = declaration.overrides;
						array = getArrayFromObject(overrides);
						array.sortOn(sortType);
						styleItem.styles = array;
					}
					
					
					
					// this is from an applications stylesheet - type declaration (optionally matched by class or id)
					if (declaration.factory!=null) {
						styleItem = new CSSStyleDeclarationItem();
						styleItem.name = getStyleDeclarationDisplayName(declaration);
						styleItem.declaration = declaration;
						targetStyleDeclarationsArray.push(styleItem);
						styleItem.type = FACTORY_FUNCTION;
						factoryInstance = new declaration.factory();
						array = getArrayFromObject(factoryInstance);
						array.sortOn(sortType);
						styleItem.styles = array;
					}
					
					// prevent duplicates where the default factory and
					// and the factory instances create the same object
					// this is a result of the way we're looking up pseudo declarations
					if (factoryInstance && declaration.defaultFactory!=null) {
						defaultFactoryInstance = new declaration.defaultFactory();
						var result:Object = ObjectUtil.compare(factoryInstance, defaultFactoryInstance);
						
						// results are the same
						if (result==0) {
							skipDuplicate = true;
						}
					}
					
					// this is from the theme defaults.css - default type declaration
					if (declaration.defaultFactory!=null && !skipDuplicate) {
						styleItem = new CSSStyleDeclarationItem();
						styleItem.name = getStyleDeclarationDisplayName(declaration);
						styleItem.declaration = declaration;
						targetStyleDeclarationsArray.push(styleItem);
						styleItem.type = DEFAULT_FACTORY;
						defaultFactoryInstance = new declaration.defaultFactory();
						array = getArrayFromObject(defaultFactoryInstance);
						array.sortOn(sortType);
						styleItem.styles = array;
					}
				}
			}
			
			
			return targetStyleDeclarationsArray;
		}
		
		private function getStyleDeclarationDisplayName(declaration:CSSStyleDeclaration, showFullPath:Boolean = false):String
		{
			var selectorType:String = "";
			var conditions:Array;
			var name:String;
			var packageName:String;
			var className:String;
			var typeSymbol:String;
			
			// get display name ie s|TextInput.MyStyle
			if (declaration.selector) {
				selectorType = declaration.selector.toString();
				
				if (!showFullPath) {
					var lastDotLocation:int = selectorType.lastIndexOf(".");
					
					if (lastDotLocation!=-1) {
						className = selectorType.substr(lastDotLocation+1);
						selectorType = className;
					}
				}
				
				
				if (declaration.selector.conditions) {
					conditions = declaration.selector.conditions;
					
					for (var i:int;i<conditions.length;i++) {
						var kind:String = CSSCondition(conditions[i]).kind;
						var value:String = CSSCondition(conditions[i]).value;
						
						if (kind==CSSConditionKind.CLASS) {
							
							if (!showFullPath) {
								lastDotLocation = declaration.selector.subject.lastIndexOf(".");
								selectorType = declaration.selector.toString();
								//selectorType = declaration.selector.subject;
								
								if (lastDotLocation!=-1) {
									className = selectorType.substr(lastDotLocation+1);
									//selectorType = className + "." + value;
									selectorType = className;
								}
								
							}
						}
						
					}
				}
			}
			else {
				selectorType = "inline";
			}
			
			return selectorType;
		}
		
		/**
		 * Wrapped to allow error handling
		 **/
		public function drawBitmapData(bitmapData:BitmapData, displayObject:DisplayObject, matrix:Matrix = null):void {
			bitmapData.draw(displayObject, matrix, null, null, null, true);
		}
		
		/**
		 * Gets the color under the mouse pointer
		 * */
		public function getColorUnderMouse(event:MouseEvent):String {
			var output:String = "";
			var temporaryBitmap:BitmapData;
			var scale:Number;
			var stageX:Number;
			var stageY:Number;
			var onApplication:Boolean = true;
			
			if (onApplication) {
				//temporaryBitmap = new BitmapData(FlexGlobals.topLevelApplication.stage.width, FlexGlobals.topLevelApplication.stage.height, false);
				temporaryBitmap = new BitmapData(FlexGlobals.topLevelApplication.width, FlexGlobals.topLevelApplication.height, false);
				
				try {
					drawBitmapData(temporaryBitmap, DisplayObject(FlexGlobals.topLevelApplication));
				}
				catch (e:Error) {
					// could not draw so it is black box
					//temporaryBitmap.draw(DisplayObject(FlexGlobals.topLevelApplication.stage));
					logger.log(LogEventLevel.ERROR, "Can't get color under mouse. " + e.message);
				}
		
				scale = FlexGlobals.topLevelApplication.applicationDPI / FlexGlobals.topLevelApplication.runtimeDPI;
				stageX = event.stageX * scale;
				stageY = event.stageY * scale;
			}
			else {// not verified
				temporaryBitmap = new BitmapData(event.target.width, event.target.height, false);
				
				try {
					drawBitmapData(temporaryBitmap, DisplayObject(event.target));
				}
				catch (e:Error) {
					// could not draw so it is black box
					//temporaryBitmap.draw(DisplayObject(FlexGlobals.topLevelApplication.stage));
					logger.log(LogEventLevel.ERROR, "Can't get color under mouse. " + e.message);
				}
				
				scale = FlexGlobals.topLevelApplication.applicationDPI / FlexGlobals.topLevelApplication.runtimeDPI;
				stageX = event.localX * scale;
				stageY = event.localY * scale;
			}
			
			var eyeDropperColorValue:uint = temporaryBitmap.getPixel(stageX, stageY);
			var value:String = displayInHex(eyeDropperColorValue);
			
			output = showConsoleDividerMarks ? "\n" + dividerMarks + "\n":"";
			output += "Color at location";
			output += showConsoleDividerMarks ? "\n" + dividerMarks + "\n":"";
			
			output += " #" + value + "\n";
			
			output += showConsoleDividerMarks && showFooterConsoleDividerMarks ? "\n" + dividerMarks + "\n" : "";
			
			return output;
		}
	
		public function extractRed(c:uint):uint {
			return (( c >> 16 ) & 0xFF);
		}
		
		public function extractGreen(c:uint):uint {
			return ( (c >> 8) & 0xFF );
		}
		
		public function extractBlue(c:uint):uint {
			return ( c & 0xFF );
		}
		
		public function combineRGB(r:uint,g:uint,b:uint):uint {
			return ( ( r << 16 ) | ( g << 8 ) | b );
		}
		
		/**
		 * Get full length hex value from uint
		 **/
		public function displayInHex(color:uint):String {
			var r:String = extractRed(color).toString(16).toUpperCase();
			var g:String = extractGreen(color).toString(16).toUpperCase();
			var b:String = extractBlue(color).toString(16).toUpperCase();
			var hs:String = "";
			var zero:String = "0";
			
			if (r.length==1) {
				r = zero.concat(r);
			}
			
			if (g.length==1) {
				g = zero.concat(g);
			}
			
			if (b.length==1) {
				b = zero.concat(b);
			}
			
			hs = r+g+b;
			
			return hs;
		}
		
		public var pupUpDisplayTime:int = 3000;
		public var popUpTimeout:int;
		public var popUpDisplayGroup:Group;
		public var popUpDisplayImage:Image;
		public var popUpBackground:Rect;
		public var popUpBorder:Rect;
		public var popUpLabel:Label;
		public var moveUpLabel:Label;
		public var popUpPropertyInput:TextInput;
		public var popUpValueInput:TextInput;
		public var popUpIsDisplaying:Boolean;
		public var popUpBackgroundTransparentGrid:Boolean = true;
		
		/**
		 * Displays an outline of the display object recursively up the component display list. 
		 **/
		public function postDisplayObject(displayTarget:DisplayObject, isOutlineDisplayed:Boolean = false, getNextParent:Boolean = true, moveToNextParentAutomatically:Boolean = true):Object {
			var systemManagerObject:Object = SystemManager.getSWFRoot(FlexGlobals.topLevelApplication);
			var scale:Number = FlexGlobals.topLevelApplication.applicationDPI / FlexGlobals.topLevelApplication.runtimeDPI;
			var lastTarget:DisplayObject;
			var isApp:Boolean;
			var targetX:Number;
			var targetY:Number;
			var container:Sprite;
			
			popUpIsDisplaying = true;
			
			// is outline and pop up displayed
			if (isOutlineDisplayed) {
				//closePopUp(target);
				lastTarget = displayTarget;
				
				if (getNextParent) {
					if ("owner" in displayTarget && Object(displayTarget).owner)  {
						displayTarget = Object(displayTarget).owner;
					}
					else {
						displayTarget = displayTarget.parent;
					}
				}
				
				//popUpDisplayImage.setChildIndex(popUpLabel, popUpDisplayImage.numChildren-1);
			}
			else {
				// pulling in spark component dependencies (this is a debug time tool not a release build tool)
				popUpDisplayGroup = new Group();
				popUpDisplayImage = new Image();
				popUpBorder = new Rect();
				popUpBorder.percentWidth = 100;
				popUpBorder.percentHeight = 100;
				popUpBorder.stroke = new SolidColorStroke(0xFF0000, 1, 1, false, "normal", JointStyle.MITER);
				
				if (popUpBackgroundTransparentGrid) {
					popUpBackground = new Rect();
					popUpBackground.percentWidth = 100;
					popUpBackground.percentHeight = 100;
					popUpBackground.fill = new BitmapFill();
					var fillSprite:Sprite = new Sprite();
					fillSprite.graphics.beginFill(0xCCCCCC,1);
					fillSprite.graphics.drawRect(0,0,10,10);
					fillSprite.graphics.beginFill(0xFFFFFF,1);
					fillSprite.graphics.drawRect(10,0,10,10);
					fillSprite.graphics.beginFill(0xFFFFFF,1);
					fillSprite.graphics.drawRect(0,10,10,10);
					fillSprite.graphics.beginFill(0xCCCCCC,1);
					fillSprite.graphics.drawRect(10,10,10,10);
					BitmapFill(popUpBackground.fill).source = fillSprite;
					BitmapFill(popUpBackground.fill).fillMode = BitmapFillMode.REPEAT;
				}
				
				moveUpLabel = new Label();
				popUpLabel = new Label();
				popUpLabel.setStyle("backgroundColor", 0xFF0000);
				popUpLabel.setStyle("color", 0xFFFFFF);
				popUpLabel.setStyle("fontWeight", "bold");
				popUpLabel.setStyle("fontSize", 12);
				popUpLabel.setStyle("paddingTop", 3);
				popUpLabel.setStyle("paddingBottom", 1);
				popUpLabel.setStyle("paddingLeft", 6);
				popUpLabel.setStyle("paddingRight", 4);
				popUpLabel.useHandCursor = true;
				popUpLabel.buttonMode = true;
				//popUpLabel.addEventListener(MouseEvent.CLICK, labelClickHandler, false, 0, true);
				
				moveUpLabel.useHandCursor = true;
				moveUpLabel.buttonMode = true;
				moveUpLabel.text = "^";
				moveUpLabel.styleName = popUpLabel;
				moveUpLabel.setStyle("fontSize", 16);
				moveUpLabel.width = 14;
				//moveUpLabel.setStyle("backgroundColor", "red");
				//moveUpLabel.setStyle("backgroundAlpha", 1);
				moveUpLabel.setStyle("paddingLeft", 2);
				moveUpLabel.setStyle("paddingRight", 0);
				
				popUpPropertyInput = new TextInput();
				popUpValueInput = new TextInput();
				
				popUpPropertyInput.width = 100;
				popUpValueInput.width = 100;
				
				popUpPropertyInput.alpha = .75;
				popUpValueInput.alpha = .75;
				popUpPropertyInput.x = 0;
				popUpValueInput.x = popUpPropertyInput.x + popUpPropertyInput.width + 5;
				popUpPropertyInput.prompt = "Property";
				popUpValueInput.prompt = "Value";
				popUpPropertyInput.setStyle("prompt", "Property");
				popUpValueInput.prompt = "Value";
				popUpPropertyInput.tabIndex = 0;
				popUpValueInput.tabIndex = 1;
				
				showInputControls(false);
				popUpPropertyInput.addEventListener(KeyboardEvent.KEY_UP, propertyInputEnterHandler, false, 0, true);
				popUpPropertyInput.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, propertyInputEnterHandler, false, 0, true);
				popUpValueInput.addEventListener(KeyboardEvent.KEY_UP, valueInputEnterHandler, false, 0, true);
				
				popUpDisplayGroup.addElement(popUpBackground);
				popUpDisplayGroup.addElement(popUpDisplayImage);
				popUpDisplayGroup.addElement(popUpBorder);
				popUpDisplayGroup.addElement(moveUpLabel);
				popUpDisplayGroup.addElement(popUpLabel);
				popUpDisplayGroup.addElement(popUpPropertyInput);
				popUpDisplayGroup.addElement(popUpValueInput);
			}
			
			
			if (isApplication(displayTarget) && getNextParent) {
				isApp = true;
				closePopUp(displayTarget);
				return null;
			}
			
			// refactor the following to updateDisplayGroup()
			currentPopUpTarget = displayTarget;
			
			container = rasterize(displayTarget);
			var name:String = displayTarget.toString();
			name = name.split(".").length ? name.split(".")[name.split(".").length-1] : name;
			
			//container.graphics.endFill();
			popUpLabel.text = name + " - " + container.width + "x" + container.height + " ";
			
			if (displayTarget is UIComponent) {
				popUpLabel.text += " (measured:" + UIComponent(displayTarget).measuredWidth+ "x" + UIComponent(displayTarget).measuredHeight + ")";
			}
			
			popUpLabel.text += " at " + container.x + "x" + container.y + " ";
			popUpDisplayImage.width = container.width;
			popUpDisplayImage.height = container.height;
			popUpDisplayGroup.width = container.width;
			popUpDisplayGroup.height = container.height;
			popUpDisplayImage.source = container;
			//popUpDisplayImage.blendMode = BlendMode.ERASE;
			
			if (isApp) {
				popUpDisplayGroup.x = 0;
				popUpDisplayGroup.y = 0;
			}
			else {
				targetX = displayTarget.localToGlobal(new Point()).x * scale;
				targetY = displayTarget.localToGlobal(new Point()).y * scale;
				popUpDisplayGroup.x = targetX;
				popUpDisplayGroup.y = targetY;
			}
			
			if (popUpLabel.height==0) { 
				popUpLabel.y = popUpDisplayGroup.y>=15 ? -15 : 0;
				moveUpLabel.y = popUpLabel.y;
			}
			else { 
				popUpLabel.y = popUpDisplayGroup.y>=15 ? -popUpLabel.height : 0;
				moveUpLabel.y = popUpLabel.y;
			}
			
			popUpLabel.x = 10;
			moveUpLabel.height = 16;
			
			
			//container.x = inspector.target.localToGlobal(new Point()).x;
			//container.y = inspector.target.localToGlobal(new Point()).y;
			
			//trace(inspector.target.localToGlobal(new Point()).x);
			//trace(inspector.target.localToGlobal(new Point()).y);
			
			// add mouse up and mouse up outside handlers for 
			DisplayObject(popUpDisplayGroup).addEventListener(MOUSE_DOWN_OUTSIDE, mouseDownOutsidePopUpHandler, false, 0, true);
			DisplayObject(systemManagerObject).addEventListener(MOUSE_DOWN_OUTSIDE, mouseDownOutsidePopUpHandler, false, 0, true);
			DisplayObject(popUpDisplayGroup).addEventListener(MouseEvent.MOUSE_UP, mouseUpPopUpHandler, true, EventPriority.CURSOR_MANAGEMENT, true);
			
			// more options could be set provided for these
			popUpDisplayGroup.setStyle("modalTransparency", .75);
			popUpDisplayGroup.setStyle("modalTransparencyBlur", 0);
			popUpDisplayGroup.setStyle("modalTransparencyColor", 0);
			popUpDisplayGroup.setStyle("modalTransparencyDuration", 0);
			
			var modalBlendMode:String = BlendMode.NORMAL;
			
			if (!isOutlineDisplayed) {
				PopUpManager.addPopUp(popUpDisplayGroup, DisplayObject(systemManagerObject), true);
				
				// ArgumentError: Error #2025: The supplied DisplayObject must be a child of the caller.
				// if popUpDisplayGroup.systemManager != systemManagerObject
				if (popUpDisplayGroup.systemManager!=systemManagerObject) {
					systemManagerObject = popUpDisplayGroup.systemManager;
				}
				
				var modalWindow:FlexSprite;
				var display:DisplayObject;
				var index:int = -1;
				var rawChildrenList:SystemRawChildrenList = systemManagerObject.rawChildren;
				
				for (var i:int=0;i<rawChildrenList.numChildren;i++) {
					display = rawChildrenList.getChildAt(i);
					
					if (display==popUpDisplayGroup) {
						index = i;
						break;
					}
				}
				
				//trace("raw children popup index:" + i);
				index = systemManagerObject.rawChildren.getChildIndex(popUpDisplayGroup);
				//trace("2 raw children popup index:" + index);
				
				if (index>=0) {
					modalWindow = systemManagerObject.rawChildren.getChildAt(index-1) as FlexSprite;
					
					if (modalWindow) {
						modalWindow.blendMode = modalBlendMode; //
					}
				}
			}
			
			if (moveToNextParentAutomatically) {// is this in the right place? refactor
				clearTimeout(popUpTimeout);
				popUpTimeout = setTimeout(getNextOrClosePopUp, pupUpDisplayTime, displayTarget, true);
			}
			else {
				clearTimeout(popUpTimeout);
			}
			
			return displayTarget;
		}
		
		public function isApplication(displayObject:Object):Boolean {
			
			if (displayObject is Application) {
				return true;
			}
			
			var definition:String = "spark.components::WindowedApplication";
			var window:Boolean = SystemManager.getSWFRoot(this).loaderInfo.applicationDomain.hasDefinition(definition);
			
			if (window && displayObject is WindowedApplication) {
				return true;
			}
			
			return false;
		}
			
		
		/**
		 * Handles when enter key is pressed in the value input
		 * */
		protected function valueInputEnterHandler(event:KeyboardEvent):void {
			if (event.keyCode==Keyboard.ENTER) {
				setPropertyOrStyle(currentPopUpTarget, popUpPropertyInput.text, popUpValueInput.text);
			}
		}
		
		/**
		 * Handles when enter key is pressed in the property input
		 * */
		protected function propertyInputEnterHandler(event:Event):void {
			if (event is KeyboardEvent) {
				if (KeyboardEvent(event).keyCode==Keyboard.ENTER) {
					getPropertyOrStyle(currentPopUpTarget, popUpPropertyInput.text);
					popUpValueInput.setFocus();
					popUpValueInput.selectAll();
				}
			}
			else if (event is FocusEvent) {
				event.preventDefault(); 
				popUpValueInput.setFocus();
				popUpValueInput.selectAll();
			}
		}
		
		/**
		 * Handles when label of pop up is clicked to show or hide the property input controls
		 * */
		protected function labelClickHandler(event:MouseEvent):void {
			showInputControls(!popUpPropertyInput.visible);
			if (popUpPropertyInput.visible) {
				popUpPropertyInput.setFocus();
			}
		}
		
		/**
		 * Get the value of the property or style on the target
		 * */
		protected function getPropertyOrStyle(target:Object, property:String):* {
			var currentValue:*;
			
			if (target && property in target) {
				
				try {
					currentValue = target[property];
					
					if (popUpValueInput) {
						popUpValueInput.text = currentValue;
					}
				}
				catch (error:Error) {
					logger.log(LogEventLevel.ERROR, "Error getting property:" + error.message);
				}
				
			}
			else if (target && property!="" && target is IStyleClient) {
				
				try {
					currentValue = target.getStyle(property);
					
					if (popUpValueInput) {
						popUpValueInput.text = currentValue;
					}
				}
				catch (error:Error) {
					logger.log(LogEventLevel.ERROR, "Error getting style:" + error.message);
				}
			}
			
			return currentValue;
		}
		
		/**
		 * Set property or style on target
		 * */
		public function setPropertyOrStyle(target:Object, property:String, value:String):void {
			var currentValue:*;
			
			if (target && property in target) {
				
				try {
					currentValue = target[property];
					
					setValue(target, property, value);
					
					currentValue = target[property];
					
					if (popUpValueInput) {
						popUpValueInput.text = currentValue;
						if ("validateNow" in target) target.validateNow();
						postDisplayObject(DisplayObject(target), true, false, false);
						FlexGlobals.topLevelApplication.callLater(postDisplayObject, [DisplayObject(target), true, false, false]);
					}
				}
				catch (error:Error) {
					logger.log(LogEventLevel.ERROR, "Error setting property:" + error.message);
				}
				
			}
			else if (target && property!="" && target is IStyleClient) {
				
				try {
					currentValue = target.getStyle(property);
					
					// need to call clear style or allow setting undefined
					// to support
					if (value!="undefined") {
						setValue(target, property, value);
					}
					else if (value=="undefined") {
						target.setStyle(property, undefined);
					}
					
					currentValue = target.getStyle(property);
					
					if (popUpValueInput) {
						popUpValueInput.text = currentValue;
						if ("validateNow" in target) target.validateNow();
						postDisplayObject(DisplayObject(target), true, false, false);
						FlexGlobals.topLevelApplication.callLater(postDisplayObject, [DisplayObject(target), true, false, false]);
					}
				}
				catch (error:Error) {
					logger.log(LogEventLevel.ERROR, "Error setting style:" + error.message);
				}
			}
		}
		
		/**
		 * Sets <code>property</code> to the value specified by 
		 * <code>value</code>. This is done by setting the property
		 * on the target if it is a property or the style on the target
		 * if it is a style.  There are some special cases handled
		 * for specific property types such as percent-based width/height
		 * and string-based color values.
		 * 
		 * NOTE: This code was copied from another area in the Flex framework
		 * There are a few areas that set values on objects
		 * SetAction
		 */
		public static function setValue(target:Object, property:String, value:Object, complexData:Boolean = false):void {
			var isStyle:Boolean = false;
			var propName:String = property;
			var val:Object = value;
			var currentValue:Object;
			
			// Handle special case of width/height values being set in terms
			// of percentages. These are handled through the percentWidth/Height
			// properties instead                
			if (property == "width" || property == "height") {
				if (value is String && value.indexOf("%") >= 0) {
					propName = property == "width" ? "percentWidth" : "percentHeight";
					val = val.slice(0, val.indexOf("%"));
				}
			}
			else {
				currentValue = getValue(target, propName);
				
				// Handle situation of turning strings into Boolean values
				if (currentValue is Boolean) {
					if (val is String)
						val = (value.toLowerCase() == "true");
				}
					// Handle turning standard string representations of colors
					// into numberic values
				else if (currentValue is Number &&
					propName.toLowerCase().indexOf("color") != -1)
				{
					var moduleFactory:IFlexModuleFactory = null;
					if (target is IFlexModule)
						moduleFactory = target.moduleFactory;
					
					val = StyleManager.getStyleManager(moduleFactory).getColorName(value);
				}
			}
			
			if (target is XML) {
				if (complexData) 
					setItemCDATA(XML(target), propName, val);
				else
					XML(target)[propName] = val;
			}
			else if (propName in target)
				target[propName] = val;
			else if ("setStyle" in target)
				target.setStyle(propName, val);
			else
				target[propName] = val;
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
		public static function getValue(target:Object, propName:String):* {
			var value:*;
			if (target is XML) {
				if (propName.indexOf("@")==0) {
					value = XML(target).attribute(propName.slice(1))[0];
					return value ? String(value) : "";
				}
				else {
					return XML(target)[propName];
				}
			}
			else if (propName in target) 
				return target[propName];
			else if (target.hasOwnProperty("getStyle"))
				return target.getStyle(propName);
			else 
				return null;
		}
		
		/**
		 * Set the item contents inside CDATA tags
		 * */
		public static function setItemCDATA(item:XML, property:String, value:Object=""):void {
			if (item) {
				if (value is String) {
					item.child(property).replace(0, wrapInCDATA(String(value)));
				}
				else if (value is XML) {
					// right now we are not doing anything special if the value is already XML
					item.child(property).replace(0, wrapInCDATA(String(value)));
				}
			}
		}
		
		
		/**
		 * Wrap text inside of CDATA tags
		 * */
		public static function wrapInCDATA(value:String):XML {
			return new XML("<![C"+"DATA[" + value + "]]>");
		}
		
		/**
		 * Show or hide the controls that let you set a property or style
		 * */
		protected function showInputControls(value:Boolean = true):void {
			popUpPropertyInput.includeInLayout = popUpPropertyInput.visible = value;
			popUpValueInput.includeInLayout = popUpValueInput.visible = value;
			popUpPropertyInput.validateNow();
			popUpPropertyInput.setFocus();
		}
		
		/**
		 * Get next parent or owner of the target or close the popup if no parent
		 **/
		public function getNextOrClosePopUp(target:DisplayObject, displayed:Boolean = false, getNextParent:Boolean = true, automaticallyMoveToNextParent:Boolean = true):Object {
			if (target.parent && !(target is SystemManager)) {
				return postDisplayObject(DisplayObject(target), displayed, getNextParent, automaticallyMoveToNextParent);
			}
			else {
				closePopUp(DisplayObject(popUpDisplayGroup));
				clearTimeout(popUpTimeout);
			}
			
			return null;
		}
		
		/**
		 * Dismisses boundries pop up outline
		 **/
		public function mouseDownOutsidePopUpHandler(event:MouseEvent):void {
			closePopUp(DisplayObject(popUpDisplayGroup));
		}
		
		/**
		 * Dismisses boundries pop up outline
		 **/
		public function mouseUpPopUpHandler(event:MouseEvent):void {
			
			if (event.ctrlKey) {
				// we are intercepting this event so we can inspect the target
				// stop the event propagation
				clearTimeout(popUpTimeout);
				checkTarget(currentPopUpTarget, event);
			}
			else {
				//if ((event.target is UITextField || event.target is RichEditableText) && 
				if ((popUpPropertyInput.owns(event.target as DisplayObject) 
					|| popUpValueInput.owns(event.target as DisplayObject)) && 
					event.currentTarget==popUpDisplayGroup) {
					clearTimeout(popUpTimeout);
					// do not close if in property text input
				}
				else if (event.target == popUpLabel) {
					clearTimeout(popUpTimeout);
					showInputControls(!popUpPropertyInput.visible);
				}
				else if (event.target == moveUpLabel) {
					clearTimeout(popUpTimeout);
					getNextOrClosePopUp(currentPopUpTarget as DisplayObject, true, true, false);
					showInputControls(false);
				}
				else {
					closePopUp(DisplayObject(popUpDisplayGroup));
				}
			}
			
			event.stopImmediatePropagation();
		}
		
		/**
		 * Creates a snapshot of the display object passed to it
		 **/
		public function rasterize(target:DisplayObject, transparentFill:Boolean = true, scaleX:Number = 1, scaleY:Number = 1, horizontalPadding:int = 0, verticalPadding:int = 0, fillColor:Number = 0x00000000):Sprite {
			//var bounds:Rectangle = target.getBounds(target);
			var bounds:Rectangle = target.getRect(target);
			var targetWidth:Number = target.width==0 ? 1 : target.width;
			var targetHeight:Number = target.height==0 ? 1 : target.height;/*
			var bounds:Rectangle = target.getBounds(target);
			var targetWidth:Number = target.width==0 ? 1 : bounds.size.x;
			var targetHeight:Number = target.height==0 ? 1 : bounds.size.y;*/
			var bitmapData:BitmapData = new BitmapData(targetWidth * scaleX, targetHeight * scaleY, transparentFill, fillColor);
			var matrix:Matrix = new Matrix();
			var container:Sprite = new Sprite();
			var bitmap:Bitmap;
			
			matrix.translate(-bounds.left, -bounds.top);
			matrix.scale(scaleX, scaleY);
			
			try {
				drawBitmapData(bitmapData, target, matrix);
			}
			catch (e:Error) {
				logger.log(LogEventLevel.ERROR, "Can't get display object outline. " + e.message);
			}
			
			bitmap = new Bitmap(bitmapData, PixelSnapping.AUTO, true);
			bitmap.x = bounds.left;
			bitmap.y = bounds.top;
			
			container.cacheAsBitmap = true;
			container.transform.matrix = target.transform.matrix;
			container.addChild(bitmap);
			
			// added to fix some clipping issues
			targetWidth = container.getBounds(container).size.x;
			targetHeight = container.getBounds(container).size.y;
			
			targetWidth = Math.max(container.getBounds(container).size.x, targetWidth);
			targetHeight = Math.max(container.getBounds(container).size.y, targetHeight);
			
			var bitmapData2:BitmapData = new BitmapData(targetWidth, targetHeight, transparentFill, fillColor);
			
			drawBitmapData(bitmapData2, container, matrix);
			
			return container;
		}
		
		/**
		 * Dismisses boundries pop up outline
		 **/
		public function closePopUp(target:DisplayObject):void {
			addMouseHandler();
			popUpIsDisplaying = false;
			clearTimeout(popUpTimeout);
			PopUpManager.removePopUp(popUpDisplayGroup as IFlexDisplayObject);
			DisplayObject(popUpDisplayGroup).removeEventListener(MOUSE_DOWN_OUTSIDE, mouseDownOutsidePopUpHandler);
			DisplayObject(FlexGlobals.topLevelApplication.systemManager).removeEventListener(MOUSE_DOWN_OUTSIDE, mouseDownOutsidePopUpHandler);
			DisplayObject(popUpDisplayGroup).removeEventListener(MouseEvent.MOUSE_UP, mouseDownOutsidePopUpHandler);
		}
		
		/**
		 * Gets all styles information
		 * */
		public function getAllStyleDeclarationsDetails(target:Object):String {
			var component:UIComponent = target as UIComponent;
			var styleManager:IStyleManager2 = StyleManager.getStyleManager(component ? component.moduleFactory: null);
			var output:String = "";
			var name:String;
			
			
			output = showConsoleDividerMarks ? "\n" + dividerMarks + "\n":"";
			output += "All Style Declarations";
			output += showConsoleDividerMarks ? "\n" + dividerMarks + "\n":"";
			
			if (component==null) {
				output += styleManager==null ? "Warning: Target is not a UIComponent. Using global style manager\n" : "";
			}
			
			var selectors:Array = styleManager.selectors;
			var length:int = selectors.length;
			
			
			for (var i:int;i<length;i++)
			{
				name = selectors[i];
				
				output += prespace + name + "\n";
			}
			
			output += showConsoleDividerMarks && showFooterConsoleDividerMarks ? "\n" + dividerMarks + "\n" : "";
			
			
			return output;
		}
		
		/**
		 * Gets details about the embedded fonts
		 * */
		public function getFontInformationDetails(target:Object):String {
			var styleItem:CSSStyleDeclarationItem;
			var component:UIComponent = target as UIComponent;
			var systemManager:ISystemManager = component ? component.systemManager : null;
			var dictionary:Dictionary = new Dictionary(true);
			var fontList:Array = Font.enumerateFonts(showDeviceFontInformation);
			var length:int = fontList.length;
			var output:String = "";
			var fontObject:Object;
			var paddedName:String;
			var name:String;
			var font:Font;
			
			
			output = showConsoleDividerMarks ? "\n" + dividerMarks + "\n":"";
			output += "Fonts";
			output += showConsoleDividerMarks ? "\n" + dividerMarks + "\n":"";
			
			if (systemManager==null && FlexGlobals.topLevelApplication.systemManager) {
				output += systemManager==null ? "Warning: Target system manager is null. Using FlexGlobals top level application system manager\n" : "";
				systemManager = FlexGlobals.topLevelApplication.systemManager;
			}
			else if (systemManager==null) {
				output += "Could not find system manager";
				return output;
			}
			
			for (var i:int;i<length;i++)
			{
				font = Font(fontList[i]);
				name = font.fontName;
				if (dictionary[name]==1) continue;
				dictionary[name] = 1;
				
				paddedName = padString(name, minimumStyleNamePadding);
				fontObject = getFontFamilyEmbedded(name, systemManager);
				
				output += prespace + paddedName;
				
				if (fontObject.embeddedCFF.length>0) {
					output += "Embedded CFF: " + fontObject.embeddedCFF.join(", ");
				}
				
				if (fontObject.embedded.length>0) {
					if (fontObject.embeddedCFF.length>0) {
						output+= "; ";
						output+= "Embedded    : ";
					}
					else {
						output+= "Embedded: ";
					}
					output += fontObject.embedded.join(", ");
				}
				
				output += "\n";
			}
			
			output += showConsoleDividerMarks && showFooterConsoleDividerMarks ? "\n" + dividerMarks + "\n" : "";
			
			
			return output;
		}
		
		
		
		/**
		 * Get's style details about the target such as font family, font weight, etc
		 * */
		public function getStyleDetails(target:Object, indicateEmbeddedFonts:Boolean = true):String {
			var styleItem:CSSStyleDeclarationItem;
			var component:UIComponent = target as UIComponent;
			var systemManager:ISystemManager = component ? component.systemManager : null;
			var output:String = "";
			var styles:Array;
			var stylesLength:int;
			var name:String;
			var value:String;
			var paddedName:String;
			var actualValue:*;
			var fontObject:Object;
			var fontWeight:String;
			var fontStyle:String;
			var fontLookup:String;
			var renderingMode:String;
			var items:Array;
			var itemsLength:int;
			
			
			output = showConsoleDividerMarks ? "\n" + dividerMarks + "\n":"";
			output += "Style Inheritance";
			output += showConsoleDividerMarks ? "\n" + dividerMarks + "\n":"";
			
			
			if (!(target as IStyleClient)) {
				output += "Target is not a style client";
				return output;
			}
			
			styles = getStyleInheritance(target as IStyleClient);
			stylesLength = styles.length;
			
			for (var i:int;i<stylesLength;i++) {
				styleItem = styles[i];
				output += styleItem.name + "\n";
				items = styleItem.styles;
				itemsLength = items.length;
				
				for (var j:int=0;j<itemsLength;j++) {
					name = items[j].name;
					paddedName = padString(items[j].name, minimumStyleNamePadding);
					value = items[j].value;
					actualValue = items[j].value;
					
					
					// check for embedded font
					if (indicateEmbeddedFonts && name=="fontFamily" && actualValue!==undefined) {
						fontObject = getFontFamilyEmbedded(value, systemManager);
						
						fontWeight = target.getStyle("fontWeight");
						fontStyle = target.getStyle("fontStyle");
						fontLookup = target.getStyle("fontLookup");
						renderingMode = target.getStyle("renderingMode");
						
						output += prespace + paddedName + "" + padString(value, Math.max(minimumStyleNamePadding, value.length+1));
						
						if (fontObject.embeddedCFF.length>0) {
							output += "EmbeddedCFF: " + fontObject.embeddedCFF.join(", ");
						}
						
						if (fontObject.embedded.length>0) {
							if (fontObject.embeddedCFF.length>0) {
								output+= "; ";
							}
							output += "Embedded: " + fontObject.embedded.join(", ");
						}
						
					}
						// check for color values
					else if (String(name).toLowerCase().indexOf("color")!=-1) {
						
						// single color
						if (!isNaN(actualValue)) {
							output += prespace + paddedName + "#" + padLeft(Number(value).toString(16), 6);;
						}
							// array of colors
						else if (actualValue && actualValue is Array && actualValue.length>0 && !isNaN(actualValue[0])) {
							for (var k:int;k<actualValue.length;k++) {
								if (!isNaN(actualValue[k])) {
									actualValue[k] = "#" + padLeft(Number(actualValue[k]).toString(16), 6);
								}
							}
							output += prespace + paddedName + "" + actualValue;
						}
							// false alarm
						else {
							output += prespace + paddedName + "" + value;
						}
						
					}
						// check for skin classes
					else if (name && value && actualValue is Class) {
						var className:String = value ? getQualifiedClassName(actualValue) : "";
						output += prespace + paddedName + "" + padString(value, minimumStyleNamePadding) + className;
					}
					else {
						if (actualValue===undefined) {
							output += prespace + paddedName + "undefined";
						}
						else {
							output += prespace + paddedName + "" + value;
						}
					}
					
					output += "\n";
				}
				
			}
			
			output += showConsoleDividerMarks && showFooterConsoleDividerMarks ? "\n" + dividerMarks + "\n" : "";
			
			
			return output;
		}
		
		/**
		 * Returns an object that contains an array of embedding information for the font with the given name.
		 * Includes embedded and embeddedCFF information. If null then the font and that style of the font
		 * are not embedded.<br/><br/>
		 * Example, <br/>
		 * <pre>
		 * var object:Object = getFontFamilyEmbedded("MyFont", myButton.systemManager);
		 * trace(object); // {embedded:[regular, italic], embeddedCFF:[regular, bold, italic, boldItalic]}
		 * </pre>
		 **/
		public function getFontFamilyEmbedded(name:String, systemManager:ISystemManager):Object {
			var textFormat:TextFormat = new TextFormat();
			var fontDescription:String = "";
			var embeddedCFF:Array = [];
			var embedded:Array = [];
			var boldItalic:Boolean;
			var regular:Boolean;
			var italic:Boolean;
			var bold:Boolean;
			
			textFormat.font = name;
			
			// check for regular
			regular = systemManager.isFontFaceEmbedded(textFormat);
			if (regular) {
				fontDescription = "regular";
				
				if (isFontFaceEmbeddedCFF(textFormat, systemManager)) {
					embeddedCFF.push(fontDescription);
				}
				if (!isFontFaceEmbeddedCFF(textFormat, systemManager)) {
					embedded.push(fontDescription);
				}
			}
			
			// check for bold
			textFormat.bold = true;
			bold = systemManager.isFontFaceEmbedded(textFormat);
			if (bold) {
				fontDescription = "bold";
				if (isFontFaceEmbeddedCFF(textFormat, systemManager)) {
					embeddedCFF.push(fontDescription);
				}
				if (!isFontFaceEmbeddedCFF(textFormat, systemManager)) {
					embedded.push(fontDescription);
				}
			}
			
			// check for bold and italic
			textFormat.italic = true;
			boldItalic = systemManager.isFontFaceEmbedded(textFormat);
			if (boldItalic) {
				fontDescription = "boldItalic";
				if (isFontFaceEmbeddedCFF(textFormat, systemManager)) {
					embeddedCFF.push(fontDescription);
				}
				if (!isFontFaceEmbeddedCFF(textFormat, systemManager)) {
					embedded.push(fontDescription);
				}
			}
			
			// check for italic
			textFormat.bold = false;
			italic = systemManager.isFontFaceEmbedded(textFormat);
			if (italic) {
				fontDescription = "italic";
				if (isFontFaceEmbeddedCFF(textFormat, systemManager)) {
					embeddedCFF.push(fontDescription);
				}
				if (!isFontFaceEmbeddedCFF(textFormat, systemManager)) {
					embedded.push(fontDescription);
				}
			}
			
			// there's probably alot of optimization that could go into this call
			// but for now we are using this
			
			return {embedded:embedded, embeddedCFF:embeddedCFF};
		}
		
		
		
		/**
		 * Checks if font is embedded and is also embeddedCFF.
		 * Does not run all methods system manager function runs.
		 */
		public function isFontFaceEmbeddedCFF(textFormat:TextFormat, systemManager:ISystemManager):Boolean
		{
			var fontName:String = textFormat.font;
			var bold:Boolean = textFormat.bold;
			var italic:Boolean = textFormat.italic;
			
			var fontList:Array = Font.enumerateFonts();
			
			var n:int = fontList.length;
			for (var i:int = 0; i < n; i++)
			{
				var font:Font = Font(fontList[i]);
				if (font.fontName == fontName)
				{
					var style:String = "regular";
					if (bold && italic)
						style = "boldItalic";
					else if (bold)
						style = "bold";
					else if (italic)
						style = "italic";
					
					if (font.fontStyle == style ) {
						if (font.fontType=="embeddedCFF") {
							return true;
						}
						else {
							return false;
						}
					}
				}
			}
			
			return false;
			
			/*if (!fontName ||
			!systemManager.embeddedFontList ||
			!systemManager.embeddedFontList[fontName])
			{
			return false;
			}
			var info:Object = systemManager.embeddedFontList[fontName];
			return !((bold && !info.bold) ||
			(italic && !info.italic) ||
			(!bold && !italic && !info.regular));*/
			
		}
		
		
		/**
		 *
		 **/
		protected function getArrayFromObject(object:Object):Array {
			var array:Array = [];
			
			for (var property:String in object) {
				var css:Object = {};
				css.name = property;
				css.value = object[property];
				array.push(css);
			}
			
			return array;
		}
		
		/**
		 * Adds a minimumn amount of spaces to a String if they don't have them.
		 * */
		private static function padString(value:String, length:int):String {
			length = length - value.length;
			
			for (var i:int;i<length;i++) {
				value += " ";
			}
			
			if (length<0) {
				value = value.substr(0, length);
			}
			return value;
		}
		
		/**
		 * The padLeft method creates a new string by concatenating enough leading
		 * pad characters to an original string to achieve a specified total length.
		 * This method enables you to specify your own padding character.
		 * */
		public static function padLeft(value:String="", digits:int = 2, character:String="0", isNumber:Boolean=false):String {
			var padding:String = "";
			var length:int = value.length;
			var position:int;
			
			if (isNumber) {
				position = value.lastIndexOf(".");
				length = position!=-1 ? digits - position : digits - length;
			}
			else {
				length = digits - length;
			}
			
			for (var i:int;i<length;i++) padding += character;
			
			return padding + value;
		}
		
		/**
		 * Get item by name
		 * Not used at the moment.
		 **/
		public function getByName(root:*, member:String):* {
			var memlist:Array = member.split('.');
			var temp:* = root;
			
			for(var i:uint = 0; i < memlist.length; i++) {
				temp = temp[memlist[i]];
			}
			return temp;
		}
		
		/**
		 * Get's details about the target such as id, type, ancestors and search pattern
		 * */
		public function getComponentDetails(componentItem:ComponentItem, includeSkinComponents:Boolean = false):String {
			var searchPattern:String;
			var message:String = "";
			var document:Object;
			var name:String;
			var out:String;
			var item:Array;
			
			
			message = showConsoleDividerMarks ? "\n" + dividerMarks + "\n":"";
			message += "Target Information";
			message += showConsoleDividerMarks ? "\n" + dividerMarks + "":"";
			
			
			// describe component
			if (componentItem.id!=null) {
				message += "\n" + componentItem.id + " is a " + componentItem.unqualifiedClassName;
			}
			if (componentItem.unqualifiedClassName!=null) {
				message += "\nThe target is an instance of " + componentItem.unqualifiedClassName;
			}
			else {
				//message += "\nThe target is an instance of " + componentItem.name;
			}
			
			
			// get document
			if (showDocument) {
				if (componentItem.documentID!=null) {
					message += "\nIt's document " + componentItem.documentID + " is a " + componentItem.documentName;
				}
				else if (componentItem.documentName!=null) {
					message += "\nIt's document is an instance of " + componentItem.documentName;
				}
				else {
					//message += "\nIt's document is an instance of " + componentItem.documentName;
				}
			}
			
			
			// get document
			if (showDocument) {
				//message += "\nIt's linked document " + getLinkedClassName(componentItem.document);
			}
			
			
			// get parent document
			if (showParentDocument) {
				
				if (componentItem.parentDocumentID!=null) {
					message += "\nIt's defined in " + componentItem.parentDocumentID + " which is a " + componentItem.parentDocumentName;
				}
				else if (componentItem.parentDocumentName!=null) {
					message += "\nIt's defined in an instance of " + componentItem.parentDocumentName;
				}
				else {
					//message += "\nIt's defined in an instance of " + componentItem.parentDocumentName;
				}
			}
			
			
			
			// show heirachy
			if (showHeirarchy) {
				out = getComponentPath(componentItem, showHeirarchyAscending, includeIDinPath);
				
				message += "\nIt's path is "+ out;
			}
			
			
			// show regexp to find in Eclipse
			if (showSearchPattern) {
				searchPattern = getRegExpSearchPattern(DisplayObject(componentItem.target), componentItem.parentDocumentName, false);
				
				if (componentItem.id && searchPattern) {
					message += "\nSearch in files with regexp " + searchPattern;
				}
				else {
					//message += "\nSearch in files with regexp \"" + searchPattern + "\"";
				}
			}
			
			
			message += showConsoleDividerMarks && showFooterConsoleDividerMarks ? "\n" + dividerMarks + "" : "";
			
			
			return message;
		}
		
		/**
		 * Gets the path up the component display list tree
		 Usage:
		 var string:String = getComponentPath(componentItem); // componentItem.instance is Button
		 trace(string); // MyApplication > Group > Group > Button
		 var string:String = getComponentPath(componentItem, true);
		 trace(string); // Button > Group > Group > MyApplication 
		 * */
		public function getComponentPath(componentItem:ComponentItem, ascending:Boolean = false, includeID:Boolean = true):String {
			var items:Array = [];
			var out:String = "";
			var temp:String = "";
			
			while (componentItem) {
				
				// we don't want to add id to application because it just becomes MyApp.MyApp
				if (includeID && componentItem.id && !(isApplication(componentItem.target))) {
					//items.push(componentItem.id + ":" + componentItem.name);
					
					if (pathFormat=="format1") {
						items.push(componentItem.unqualifiedClassName + "#" + componentItem.id); 
					}
					else if (pathFormat=="format2") {
						items.push(componentItem.unqualifiedClassName + "." + componentItem.id); 
					}
					else if (pathFormat=="format3") {
						items.push(componentItem.id + "::" + componentItem.unqualifiedClassName); 
					}
				}
				else {
					items.push(componentItem.unqualifiedClassName);
				}
				
				componentItem = componentItem.parent;
			}
			
			out = ascending ? items.join(componentPathSeparator) : items.reverse().join(componentPathSeparator);
			
			return out;
		}
		
		/**
		 * Get qualified class name of the target object
		 * */
		public function getQualifiedClassName(element:Object):String {
			var name:String = flash.utils.getQualifiedClassName(element);
			return name;
		}
		
		/**
		 * Get qualified class name of the target object
		 * */
		public function getLinkedClassName(element:Object):String {
			var name:String = flash.utils.getQualifiedClassName(element);
			var output:String = "";
			output += "(" + name.replace("::",".") + ".as:1)";
			//output += "\n(" + name.replace("::",".") + ".mxml)";
			output += "\n(" + name.replace("::",".") + ".mxml:1)";
			/*output += "\nftp://" + name.replace("::",".") + ".mxml";
			output += "\nhttp://" + name.replace("::",".") + ".mxml";
			output += "\n(" + name.replace("::",".") + ".java:12)";
			output += "\n./" + name.replace("::",".") + ".mxml";
			output += "\n../" + name.replace("::",".") + ".mxml";*/
			return output;
		}
		
		/**
		 * Creates a component tree starting at the given element.
		 * Element being visual element like an Application, UIComponent or Rect.
		 * */
		public function createComponentTreeFromElement(element:Object, parentItem:ComponentItem = null, depth:int = 0):ComponentItem {
			var item:ComponentItem;
			var childElement:IVisualElement;
			
			
			if (!parentItem) {
				parentItem = new ComponentItem(element);
				parentItem.children = new ArrayList();
				return createComponentTreeFromElement(element, parentItem);
			}
			
			
			// check for IVisualElementContainers and add their child elements
			if (element is IVisualElementContainer) {
				var visualElementContainer:IVisualElementContainer = IVisualElementContainer(element);
				var length:int = visualElementContainer.numElements;
				
				for (var i:int;i<length;i++) {
					childElement = visualElementContainer.getElementAt(i);
					item = new ComponentItem(childElement);
					item.parent = parentItem;
					
					parentItem.children.addItem(item);
					
					if (childElement is IVisualElementContainer && IVisualElementContainer(childElement).numElements>0) {
						item.children = new ArrayList();
						createComponentTreeFromElement(childElement, item, depth + 1);
					}
					
					
				}
			}
			
			return parentItem;
		}
		
		/**
		 * Given a component item tree and a target (most likely a UIComponent or display object)
		 * we walk down through the component tree (parentItem and parentItem.children)
		 * and find a match where the target matches the stored ComponentItem instance property.
		 *
		 * Note: the component tree is created by createComponentTreeFromElement();
		 * parentItem could be the root component tree object such as the Application or child group or container component
		 *
		 * Call getComponentItemFromComponentTreeByDisplayObject
		 * */
		private function findComponentItemInParentItemByElement(target:Object, parentItem:ComponentItem, depth:int = 0):ComponentItem {
			var length:int = parentItem.children ? parentItem.children.length : 0;
			var possibleItem:ComponentItem;
			var itemFound:Boolean;
			
			if (target==parentItem.target) {
				return parentItem;
			}
			
			for (var i:int; i < length; i++) {
				var item:ComponentItem = parentItem.children.getItemAt(i) as ComponentItem;
				
				if (item && item.target==target) {
					itemFound = true;
					break;
				}
				
				if (item.children) {
					possibleItem = findComponentItemInParentItemByElement(target, item, depth + 1);
					
					if (possibleItem) {
						itemFound = true;
						item = possibleItem;
						break;
					}
				}
				
			}
			
			if (itemFound) return item;
			
			return null;
		}
		
		/**
		 * Given a component item tree and an element name
		 * we walk down through the component tree (parentItem and parentItem.children)
		 * and find a match where the target matches the stored ComponentItem name property.
		 *
		 * Note: the component tree is created by createComponentTreeFromElement();
		 * parentItem could be the root component tree object such as the Application or child group or container component
		 *
		 * */
		private function findComponentItemInParentItemByName(name:String, parentItem:ComponentItem, depth:int = 0):ComponentItem {
			var length:int = parentItem.children ? parentItem.children.length : 0;
			var possibleItem:ComponentItem;
			var itemFound:Boolean;
			
			if (name==parentItem.target.name) {
				return parentItem;
			}
			
			for (var i:int; i < length; i++) {
				var item:ComponentItem = parentItem.children.getItemAt(i) as ComponentItem;
				
				if (item && "name" in item.target && item.target.name==name) {
					itemFound = true;
					break;
				}
				
				if (item.children) {
					possibleItem = findComponentItemInParentItemByName(name, item, depth + 1);
					
					if (possibleItem) {
						itemFound = true;
						item = possibleItem;
						break;
					}
				}
				
			}
			
			if (itemFound) return item;
			
			return null;
		}
		
		/**
		 * Given a component item tree and an element name
		 * we walk down through the component tree (parentItem and parentItem.children)
		 * and find a match where the target matches the stored ComponentItem id property.
		 *
		 * Note: the component tree is created by createComponentTreeFromElement();
		 * parentItem could be the root component tree object such as the Application or child group or container component
		 *
		 * */
		private function findComponentItemInParentItemByID(id:String, parentItem:ComponentItem, depth:int = 0):ComponentItem {
			var length:int = parentItem.children ? parentItem.children.length : 0;
			var possibleItem:ComponentItem;
			var itemFound:Boolean;
			
			if (id==parentItem.target.id) {
				return parentItem;
			}
			
			for (var i:int; i < length; i++) {
				var item:ComponentItem = parentItem.children.getItemAt(i) as ComponentItem;
				
				if (item && "id" in item.target && item.target.id==id) {
					itemFound = true;
					break;
				}
				
				if (item.children) {
					possibleItem = findComponentItemInParentItemByID(id, item, depth + 1);
					
					if (possibleItem) {
						itemFound = true;
						item = possibleItem;
						break;
					}
				}
				
			}
			
			if (itemFound) return item;
			
			return null;
		}
		
		/**
		 * Find the component that owns the display object
		 * AND is also on the component tree
		 * This method continues to walk up the display list / component tree until
		 * it finds a component that owns the original display object then returns that component item
		 * The findComponentItemInParentItemByElement returns null
		 * if it does not find the item in the given component tree
		 * If it does not find the owner of the display object it will keep a reference to it in the
		 * target property on the access path instance.
		 * */
		public function getFirstParentComponentItemFromComponentTreeByDisplayObject(displayObject:DisplayObject, componentTree:ComponentItem):ComponentItem {
			var componentItem:ComponentItem;
			var displayPath:Array = [];
			var item:ComponentItem;
			
			
			// find the owner of a visual element that is also on the component tree
			while (displayObject) {
				componentItem = findComponentItemInParentItemByElement(displayObject, componentTree);
				
				if (componentItem) {
					if (displayPath.length>0) {
						componentItem.accessPath = displayPath[0];
						componentItem.subTarget = (displayPath[0] as ComponentItem).target;
					}
					else {
						componentItem.accessPath = componentItem;
					}
					return componentItem;
				}
				else {
					
					// accessPath
					item = new ComponentItem(displayObject);
					
					if (displayPath.length>0) {
						displayPath[displayPath.length-1].parent = item;
					}
					
					displayPath.push(item);
					
					
					// if we are here the display object is probably in a skin
					// if so we could create a tree / path until we get to the component item
					// something like displayObjectItem in the third argument
					// it would be accessPath
					if ("owner" in displayObject && displayObject['owner']!=null) {
						displayObject = Object(displayObject).owner as DisplayObjectContainer;
					}
					else {
						displayObject = displayObject.parent;
					}
					
				}
			}
			
			return componentItem;
		}
		
		/**
		 * With the given target it returns a regexp pattern that can be used to find it in the document, project or workspace
		 * If isScript is true it attempts to returns a pattern to find the exact instance in AS3
		 * The MXML pattern will find the instance with that ID. If the instance doesn't have an ID it will create a regexp that will narrow it down.
		 *
		 * NOTE: Press CTRL + H to open the Search in Files dialog, paste the value in, check regular expression and press Find.
		 * */
		public function getRegExpSearchPattern(target:DisplayObject, parentDocumentName:String = "", isScript:Boolean = false):String {
			var id:String = getIdentifier(target);
			var className:String = NameUtil.getUnqualifiedClassName(target);
			var applicationName:String;
			var pattern:String;
			var scriptPattern:String;
			
			if (id == null) {
				if (parentDocumentName) {
					applicationName = NameUtil.getUnqualifiedClassName(FlexGlobals.topLevelApplication);
					
					if (applicationName==parentDocumentName) {
						parentDocumentName = getSuperClassName(FlexGlobals.topLevelApplication);
					}
					
					// this finds the document tag then the tag name so something like Group ... :Button
					// the (?! is a positive look ahead. it matches a group after the main expression
					pattern = regExpSearchFlags + "(?!:" + parentDocumentName + "(.)*:):" + className + " ";
					
				}
				return pattern;
			}
			else {
				pattern = className + "(.*)id\\s?=\\s?[\"|']" + id + "[\"|']";
				scriptPattern = id + ".addEventListener";
			}
			
			
			if (isScript) {
				return scriptPattern;
			}
			
			return pattern;
		}
		
		/**
		 * Gets the ID of the target object
		 * returns null if no ID is specified
		 * */
		public function getIdentifier(element:Object):String {
			var id:String;
			
			if (element && "id" in element) {
				id = element.id;
			}
			return id;
		}
		
		/**
		 * Get super class name of the target object
		 * */
		public function getSuperClassName(element:Object):String {
			var name:String = flash.utils.getQualifiedSuperclassName(element);
			if (name && name.indexOf("::")) {
				name = name.split("::")[name.split("::").length-1]; // i'm sure theres a better way to do this
			}
			
			return name;
		}
		
		

        // =========================================================================================
        // Debug mode
        // =========================================================================================

		/**
		 * The state of the debug mode.
		 * */
        protected var _debug:Boolean;

		/**
		 * The target for the logger.
		 * */
        protected var logTarget:TraceTarget;

		/**
		 * The class logger.
		 * */
        protected var logger:ILogger = Log.getLogger("WebView");
		
		/**
		 * Displays a JavaScript alert and issues an WebViewEvent.Result event with 
		 * the response from a JavaScript call. 
		 * */
        public var runTestScript:Boolean;
		
		/**
		 * Get the state of the debug mode.
		 * */
        public function get debug():Boolean
        {
            return _debug;
        }

		/**
		 * Set the state of the debug mode.
		 * */
        public function set debug(value:Boolean):void
        {
            if (value == debug) {
                return;
			}

            if (value)
            {
                if (!logTarget)
                {
                    logTarget = new TraceTarget();
                    logTarget.includeLevel = true;
                    logTarget.includeTime = true;
                    logTarget.level = LogEventLevel.ALL;
                    logTarget.filters = ["WebView"];
                }
				
                logTarget.addLogger(logger);
            }
            else
            {
                if (logTarget) {
                    logTarget.removeLogger(logger);
				}
            }

            _debug=value;
        }
	}
}


import flash.utils.getQualifiedClassName;

import mx.collections.ArrayList;
import mx.styles.CSSStyleDeclaration;
import mx.utils.NameUtil;

/**
 * Describes the display object
 * */
class ComponentItem {
	
	
	public function ComponentItem(element:Object = null):void {
		
		if (element) {
			target = element;
			subTarget = element;
			className = getQualifiedClassName(element);
			unqualifiedClassName = NameUtil.getUnqualifiedClassName(element);
			id = "id" in element && element.id!=null ? element.id : null;
			name = "name" in element && element.name!=null ? element.name : null;
			
			document = "document" in element ? element.document : null;
			documentClassName = getQualifiedClassName(document);
			documentName = document ? NameUtil.getUnqualifiedClassName(document) : null;
			documentID = document && "id" in document && document.id!=null ? document.id : null;
			
			parentDocument = "parentDocument" in element ? element.parentDocument : null;
			parentDocumentClassName = getQualifiedClassName(parentDocument);
			parentDocumentName = parentDocument ? NameUtil.getUnqualifiedClassName(parentDocument) : null;
			parentDocumentID = parentDocument && "id" in parentDocument && parentDocument.id!=null ? parentDocument.id : null;
		}
	}
	
	/**
	 * ID
	 * */
	public var id:String;
	
	/**
	 * Name
	 * */
	public var name:String;
	
	/**
	 * Unqualified class name
	 * */
	public var unqualifiedClassName:String;
	
	/**
	 * Qualified class name
	 * */
	public var className:String;
	
	/**
	 * Instance of component.
	 * */
	public var target:Object;
	
	/**
	 * Original target from MouseEvent target event. Sometimes this is a sub component or skin part of an actual component.
	 * */
	public var subTarget:Object;
	
	/**
	 * Component that owns MouseEvent target event
	 * */
	public var componentTarget:Object;
	
	/**
	 * Document instance
	 * */
	public var document:Object;
	
	/**
	 * Document name
	 * */
	public var documentName:String;
	
	/**
	 * Document class name
	 * */
	public var documentClassName:String;
	
	/**
	 * Document ID
	 * */
	public var documentID:String;
	
	/**
	 * Parent document instance
	 * */
	public var parentDocument:Object;
	
	/**
	 * Document name
	 * */
	public var parentDocumentName:String;
	
	/**
	 * Document class name
	 * */
	public var parentDocumentClassName:String;
	
	/**
	 * Document ID
	 * */
	public var parentDocumentID:String;
	
	/**
	 * Children. Optional.
	 * Used for display in heiarchy view such as Tree.
	 * */
	public var children:ArrayList;
	
	/**
	 * Parent
	 * */
	public var parent:ComponentItem;
	
	/**
	 * Accessed path from display object event to component.
	 * Used when determining the display object that was clicked
	 * */
	public var accessPath:ComponentItem;
	
}


/**
 * Describes the display object
 * */
class CSSStyleDeclarationItem extends CSSStyleDeclaration {
	/**
	 *
	 **/
	public function CSSStyleDeclarationItem(element:Object = null):void {}
	/**
	 *
	 **/
	public var name:String;
	/**
	 *
	 **/
	public var declaration:CSSStyleDeclaration;
	/**
	 *
	 **/
	public var styles:Array;
	/**
	 *
	 **/
	public var type:String;
	
}