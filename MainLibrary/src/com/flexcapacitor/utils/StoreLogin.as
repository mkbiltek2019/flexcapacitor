package com.flexcapacitor.utils
{
	import flash.external.ExternalInterface;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * Allows Flash to take part in password storage and retrieval systems.
	 * http://www.judahfrangipane.com/blog/2012/10/12/auto-login-in-flash-and-flex/<br/><br/>
	 * 
	 * Add this to your HTML page:
	 * 
	 * 
	 * <pre>
&lt;form id="bridgeForm" action="#" target="loginframe" autocomplete="on" style="display:none">
        &lt;input type="text" name="username" id="username" />
        &lt;input type="password" name="password" id="password"/>
&lt;/form>

&lt;iframe id="loginframe" name="loginframe" src="blankpage.html" style="display:none">&lt;/iframe>
		</pre>
	 **/
	public class StoreLogin {
		
		/**
		 * ID of the form element
		 **/
		public static var FORM_ID:String = "bridgeForm";
		
		/**
		 * ID of the username element
		 **/
		public static var USERNAME_ID:String = "username";
		
		/**
		 * ID of the password element
		 **/
		public static var PASSWORD_ID:String = "password";
		
		/**
		 * Message when script was not written to the page
		 * */
		public static const SCRIPT_ERROR:String = "The script was not written to the page. See notes.";
		
		/**
		 * Message when form was not found on the page
		 * */
		public static const FORM_ERROR:String = "The form is not on the page. Make sure there is a form on the page with the same ID as in FORM_ID. See notes.";
		
		/**
		 * Constructor
		 * */
		public function StoreLogin() {
			
		}
		
		/**
		 * Gives a moment to set flash back to focus 
		 **/
		private var timeout:int;
		
		/**
		 * If true the script and the form are both on the page
		 **/
		[Bindable]
		public static var initialized:Boolean;
		
		/**
		 * If true the form is found on the page
		 **/
		[Bindable]
		public static var formExists:Boolean;
		
		/**
		 * If true script was written to the page
		 **/
		[Bindable]
		public static var scriptExists:Boolean;
		
		/**
		 * Returns true if able to read and write to the HTML page
		 **/
		public function get enabled():Boolean {
			return ExternalInterface.available;
		}
		
		/**
		 * Sets the form username and password inputs. You typically call this
		 * right before submitting the form
		 **/
		public function setFormValues(username:String, password:String):Boolean {
			var results:Boolean = ExternalInterface.call("StoreLogin.setFormValues", username, password);
			return results;
		}
		
		/**
		 * Clears the form
		 **/
		public function clearFormValues():Boolean {
			var results:Boolean = ExternalInterface.call("StoreLogin.clearFormValues");
			return results;
		}
		
		/**
		 * Gets the username and password or empty array if not set
		 **/
		public function getFormValues():Array {
			var results:Array = ExternalInterface.call("StoreLogin.getFormValues");
			return results;
		}
		
		/**
		 * Gets the username or null if not set
		 **/
		public function getUsername():String {
			var value:String = ExternalInterface.call("StoreLogin.getUsername");
			return value;
		}
		
		/**
		 * Gets the password value or null if not set
		 **/
		public function getPassword():String {
			var value:String = ExternalInterface.call("StoreLogin.getPassword");
			return value;
		}
		
		/**
		 * Has username value
		 **/
		public function isUsernameSet():Boolean
		{
			var value:String = ExternalInterface.call("StoreLogin.getUsername");
			return value!=null && value!="";
		}
		
		/**
		 * Has password value
		 **/
		public function isPasswordSet():Boolean
		{
			var value:String = ExternalInterface.call("StoreLogin.getPassword");
			return value!=null && value!="";
		}
		
		/**
		 * Submits an non-directing form request causing the browser 
		 * to show the prompt to save the login info
		 **/
		public function submitForm():Boolean
		{
			var value:String = ExternalInterface.call("StoreLogin.submitForm", FORM_ID);
			return value!=null;
		}
		
		/**
		 * Shows the form. For testing purposes
		 **/
		public function showForm():Boolean
		{
			var value:String = ExternalInterface.call("StoreLogin.showForm", FORM_ID);
			return value!=null;
		}
		
		/**
		 * Shows the form. For testing purposes
		 **/
		public function hideForm():Boolean
		{
			var value:String = ExternalInterface.call("StoreLogin.hideForm", FORM_ID);
			return value!=null;
		}
		
		/**
		 * Submits an non-directing form request causing the browser to prompt to save the login info
		 **/
		public function invokeSavePasswordPrompt():String
		{
			var value:String = ExternalInterface.call("StoreLogin.submitForm", FORM_ID);
			return value;
		}
		
		/**
		 * The same as if a user typed their name in the username field and pressed tab. 
		 * This is used when there are multiple users saved by the browser. 
		 * Triggers the browser to fill in the password field given the username.
		 **/
		public function checkForPassword(username:String = ""):String
		{
			var value:String = ExternalInterface.call("StoreLogin.checkForPassword", username);
			return value;
		}
		
		/**
		 * Sets the focus to the Flash application. 
		 * Some functions take focus away. This sets it back. 
		 * 
		 * @see checkForPassword
		 **/
		public function setFocusOnFlash():Boolean
		{
			clearTimeout(timeout);
			var value:Boolean = ExternalInterface.call("StoreLogin.setFocusOnFlash", ExternalInterface.objectID);
			return value;
		}
		
		/**
		 * Sets the focus to the Flash application. 
		 * Some functions take focus away. This sets it back. 
		 * 
		 * @see setFocusOnFlash
		 * @see checkForPassword
		 **/
		public function delayedSetFocusOnFlash(delay:int = 100):void
		{
			timeout = setTimeout(setFocusOnFlash, delay);
		}
		
		/**
		 * Inserts the form into the HTML page dynamically. This does not autofill if the page 
		 * has been created. But it will cause the the page to prompt to save password. 
		 * 
		 * It remains for testing
		 **/
		public function insertForm():Boolean
		{
			var value:Boolean = ExternalInterface.call("StoreLogin.insertForm");
			return value;
		}
		
		/**
		 * Writes our JavaScript functions to the page
		 * 
		 * Script error 
		 * - If the script is not on the page it could be that ExternalInterface is not available.
		 * - JavaScript is disabled?
		 * - Page is hosted on another domain so read / write is not allowed
		 * - The savePasswordJavaScript code contains errors 
		 * 
		 * Form Error
		 * - The form is not on the HTML page
		 * - Check that a form with name that matches the value in FORM_ID is on the page
		 **/
		public function initialize():Boolean
		{
			if (!initialized) {
				var script:String = savePasswordScript;
				formExists = confirmFormExists();
				scriptExists = confirmScriptWritten();
				
				if (!scriptExists) {
					ExternalInterface.call("eval", script);
				}
				
				scriptExists = confirmScriptWritten();
				initialized = scriptExists && formExists;
				
				if (!scriptExists) {
					throw new Error(SCRIPT_ERROR);
				}
				else if (!formExists) {
					// make sure there is a form on the page with the same ID as in FORM_ID
					throw new Error(FORM_ERROR);
				}
			}
			
			return initialized;
		}
		
		/**
		 * If true confirms the script was written to the page
		 **/
		public function confirmScriptWritten():Boolean
		{
			var value:Boolean = ExternalInterface.call("StoreLogin.scriptConfirmation");
			return value;
		}
		
		/**
		 * If true confirms then the form exists on the page
		 **/
		public function confirmFormExists():Boolean
		{
			var value:Boolean = ExternalInterface.call("StoreLogin.formExists", FORM_ID);
			return value;
		}
		
		/**
		 * Resizes the application to the height specified. 
		 * For testing purposes. May be removed.
		 * 
		 * Typical values are 500px or 70%. 
		 **/
		public function resizeApplication(value:String = "75%"):Boolean
		{
			var result:Boolean = ExternalInterface.call("StoreLogin.resizeApplication", ExternalInterface.objectID, value);
			return result;
		}
		
		/**
		 * This is written to the HTML page on load. 
		 * NOTE: Refactored code. We should now include a link on the page to StoreLogin.js. Do not use this method.
		 * 
		 * Old notes: 
		 * Note: wherever we have written explicit linebreaks we have to escape them - \n -> \\n
		 * 
		 * Getting error in Firefox Firebug console:
		 * 
		 * SyntaxError: syntax error 	
		 *    var StoreLogin = {
		 *  --^
		 * 
		 * Must convert to string first. 
		 * var string:String = LoginPrompt.loginPromptHTML;
		 * 
		 * ExternalInterface.call("eval", string);
		 * */
		public static var savePasswordScript:XML = new XML();
		
	}
}