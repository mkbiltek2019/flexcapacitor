
package com.flexcapacitor.services {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.utils.getTimer;
	
	
	/**
	 * The event that is dispatched on results. 
	 * */
	[Event(name="result", type="com.flexcapacitor.services.WPServiceEvent")]
	
	/**
	 * The event that is dispatched on fault. 
	 * */
	[Event(name="fault", type="com.flexcapacitor.services.WPServiceEvent")]
	
	/**
	 * The base class for WPService that is used to get and save data from WordPress.
	 * For examples, look at the WPService class.<br/><br/>
	 * 
	 * This class works with the JSON API plugin for WordPress. <br/><br/>
	 * 
	 * Notes:<br/><br/>
	 * 
	 * Be sure WordPress auto formatting is off - this automatically adds Paragraph tags around your content. This is called wpautop. <br/>
	 * Also be sure fancy quotes is off - it automatically adds curly quotes when it encounters them in your content.<br/>
	 * There are plugins out there that will remove WP autoformatting<br/>
	 * There are plugins that will interfere with the JSON results as well<br/><br/>
	 * 
	 * Alternatively, save data to custom fields.<br/><br/>
	 * 
	 * Error #1132: Invalid JSON parse input.<br/>
	 * - check the text property of the event to see the original source. <br/><br/>
	 * 
	 * If you can't update or create posts be sure that the user is 
	 * logged in with Editor or Author permissions
	 * and check if the Posts option is enabled in the JSON-API settings page. <br/>
	 * 
	 * See the WPService class for example code. 
	 * 
	 * @see WPService
	 * @see WPAttachmentService
	 * */
	public class WPServiceBase extends EventDispatcher implements IWPService {
		
		/**
		 * Constructor
		 * */
		public function WPServiceBase(target:IEventDispatcher=null) {
			super(target);
			
			if (loader==null) {
				loader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.TEXT;
				addEventListeners(loader);
			}
			
			if (request==null) {
				request = new URLRequest();
			}
			
		}
		
		/**
		 * Constants
		 * */
		public static const RESULT:String = "result";
		public static const FAULT:String = "fault";
		
		/**
		 * Error occured. There are various types of errors that can occur.
		 * There is a network error where the network is down, there is URL error,
		 * where we have an incorrect URL, there is service error, where the 
		 * site is down, there is a incorrect parameters error where we are missing
		 * data needed by the API and there is error where we don't find what we're 
		 * looking for, such as post is deleted. 
		 * */
		[Bindable]
		public var errorOccured:Boolean;
		
		/**
		 * Error event.
		 * */
		[Bindable]
		public var errorEvent:Event;
		
		/**
		 * Error message.
		 * */
		[Bindable]
		public var errorMessage:String;
		
		/**
		 * URLLoader to communicate with the server
		 * */
		public var loader:URLLoader;
		
		/**
		 * Use navigateToURL instead of URLLoader. Opens in a new window.
		 * @see #windowName
		 * */
		public var useNavigateToURL:Boolean;
		
		/**
		 * Name of window when using navigateToURL option
		 * @see #useNavigateToURL
		 * */
		public var windowName:String;
		
		/**
		 * URLRequest to communicate with the server
		 * */
		public var request:URLRequest;
		
		/**
		 * Content type.  
		 * Set this to define the URLRequest content type.
		 * */
		public var contentType:String;
		
		/**
		 * Detects multisite and updates the site after login is successful
		 * */
		public var updateSitePathOnLogin:Boolean = true;

		private var _host:String;

		/**
		 * URL to Wordpress blog. For example, http://www.domain.com
		 * If the site is multisite then set the site variable. 
		 * 
		 * Make sure the last character is a "/" if not using permalinks. 
		 * 
		 * @see site
		 * @see sites
		 * @see usePermalink
		 * */
		public function get host():String
		{
			return _host;
		}

		/**
		 * @private
		 */
		public function set host(url:String):void
		{
			_host = url;
		}


		/**
		 * Path to API when using permalink. For example,
		 * if permalink is set to true and the path to the API is, http://www.domain.com/api/, 
		 * the permlinkPath would be "api/". No slash before the value. 
		 * @see usePermalink
		 * @see sites
		 * @see host
		 * */
		public var permalinkPath:String = "api/";

		public var originalSite:String = "";

		private var _site:String = "";

		/**
		 * Site of Wordpress blog when using multisite. For example,
		 * in the URL, http://www.radii8.com/blog/mysite, the site is "/mysite/".
		 * Add slashes before and after value. 
		 * @see sites
		 * @see host
		 * @see usePermalink
		 * */
		public function get site():String {
			return _site;
		}

		/**
		 * @private
		 */
		public function set site(value:String):void {
			_site = value;
		}

		
		/**
		 * Array of sites when using multisite domain.
		 * @see site
		 * @see host
		 * */
		public var sites:Array = [];
		
		private var _url:String;

		/**
		 * URL to call. Prepends the host to the value passed in. 
		 * Also sets the request.data to null so we don't have
		 * to do this on every call. 
		 * 
		 * If you set usePermalinks to true the syntax will be "api/controller/method" 
		 * versus "?json=controller/method" in the URL. 
		 * 
		 * For example, when usePermalinks is enabled the URL would be something like,
		 * "http://www.mysite.com/blog/api/user/get_logged_in". When set to false the URL 
		 * would be something like, "http://www.mysite.com/blog/?json=user/get_logged_in". 
		 * @see sendURL
		 * */
		public function get url():String {
			return _url;
		}

		/**
		 * @private
		 */
		public function set url(value:String):void {
			var path:String = "";
			var separator:String = "";
			
			// permalinks look like http://www.mysite.com/blog/api/user/get_logged_in
			if (usePermalinks) {
				path = permalinkPath.lastIndexOf("/")==permalinkPath.length-1 ? permalinkPath : permalinkPath + "/";
				value = value.replace(/&/, "?"); // replace first & with ?
				value = path + value;
			}
			else {
				// default looks like http://www.mysite.com/blog/?json=user/get_logged_in
				value = value.replace(/\?/, "&"); // replace first ? since we will be using it
				if (value.indexOf("?json=")==-1) {
					value = "?json=" + value;
				}
				
				// add separator before query - otherwise POST variables are not sent
				if (host.charAt(host.length-1)!="/" && site=="") {
					separator = "/";
				}
			}
			
			_url = host + separator + site + value;
			
			if (request) {
				request.url = _url;
				request.data = null;
			}
			
			if (contentType) {
				request.contentType = contentType;
			}
		}
		
		/**
		 * Specifies to use the syntax "api/controller/method" versus "?json=controller/method"
		 * in the URL. For example, when enabled the URL would be something like,
		 * "http://www.mysite.com/blog/api/user/get_logged_in". When set to false the URL 
		 * would be something like, "http://www.mysite.com/blog/?json=user/get_logged_in". 
		 * */
		public var usePermalinks:Boolean;
		
		public var time:int;
		
		public var parseTime:int;

		public var responseTime:int;
		
		public var updateToken:String;
		
		public var createToken:String;
		
		protected var uploadPending:Boolean;
		
		protected var updatePending:Boolean;
		
		protected var createPending:Boolean;
		
		protected var deletePending:Boolean;
		
		/**
		 * Data returned from the server converted to a JSON object 
		 * or null if result could not be converted to JSON.
		 * */
		[Bindable]
		public var data:Object;
		
		/**
		 * Data returned from the server as string
		 * */
		[Bindable]
		public var results:String;
		
		/**
		 * Data to save to the server. Flash will convert the 
		 * parameters object to a string if the method type is set to GET.
		 * */
		public var parameters:URLVariables;
		
		/**
		 * ID of post to save to
		 * */
		public var id:String;
		
		/**
		 * Call being made
		 * */
		public var call:String;
		
		/**
		 * Indicates if a call is in progress
		 * */
		[Bindable]
		public var inProgress:Boolean;
		
		/**
		 * Call method where you specify the url. Used for testing custom URL. 
		 * 
		 * url - url to call
		 * method - "GET" or "POST"
		 * post - object to send to the server. you should use URLVariables for post 
		 * @see query
		 * */
		public function sendURL(url:String, method:String = "GET", data:Object = null):void {
			call = WPServiceEvent.SEND_URL;
			request.method = method;
			request.data = data;
			request.url = url;
			load(request);
		}
		
		/**
		 * Call method where you manually specify a controller, a method and parameters
		 * query - list of additional get parameters. for example, "&count=10&category=news"
		 * post - an object to send to the server.
		 * 
<pre>
var galleryService:WPService = new WPService();
galleryService.host = "http://www.example.com/blog";
galleryService.addEventListener(WPServiceBase.RESULT, galleryResultsHandler, false, 0, true);
galleryService.addEventListener(WPServiceBase.FAULT, galleryFaultHandler, false, 0, true);

var parameters:URLVariables = new URLVariables();
parameters.search = "cats";

wpSaveService.send("Gallery", "getResults", null, parameters);
</pre>
		 * @see query
		 * */
		public function send(controller:String = "core", method:String = "get_recent_posts", query:String="", post:Object = null):void {
			if (query==null) query = "";
			
			url = controller + "/" + method + query;
			
			request.method = URLRequestMethod.POST;
			request.data = post;
			request.url = url;
			load(request);
		}
		
		/**
		 * Call method where you manually specify everything in the query including controller, method and parameters
		 * query - list of additional get parameters. for example, "?json=posts/get_recent_posts&count=10"
		 * post - object to send to the server. 
		 * 
		 * @see send
		 * */
		public function query(query:String="?json=1", post:Object = null):void {
			url = query;
			request.method = URLRequestMethod.POST;
			request.data = post;
			request.url = url;
			load(request);
		}
		
		/**
		 * Load request. We wrap the load call to cancel previous operations.
		 * */
		public function load(request:URLRequest = null):void {
			
			// launch in a new window - not a common use case 
			if (useNavigateToURL) {
				navigateToURL(request, windowName);
				return;
			}
			
			try {
				// close call if open
				if (loader) {
					loader.close();
				}
			}
			catch (e:Error) {
				// we don't care
				//trace("loader not in progress");
			}
			
			errorOccured = false;
			errorMessage = null;
			
			loader.load(request);
		}
	
		/**
		 * Fault handler
		 * */
		public function onFault(event:Event):void {
			var serviceEvent:WPServiceEvent = new WPServiceEvent(WPServiceEvent.FAULT);
			var errorText:String = "";
			
			if (event is WPServiceEvent && WPServiceEvent(event).faultEvent) {
				errorText = "text" in WPServiceEvent(event).faultEvent ? Object(WPServiceEvent(event).faultEvent).text : "";
				errorText = "message" in WPServiceEvent(event).faultEvent ? Object(WPServiceEvent(event).faultEvent).message : errorText;
			}
			
			if (event is IOErrorEvent) {
				errorText = IOErrorEvent(event).text;
			}
			
			serviceEvent.call = call;
			serviceEvent.faultEvent = event;
			serviceEvent.hasError = true;
			serviceEvent.errorMessage = errorText;
			errorOccured = true;
			errorMessage = errorText;
			errorEvent = event;
			inProgress = false;
			createPending = false;
			updatePending = false;
			uploadPending = false;
			deletePending = false;
			dispatchEvent(serviceEvent);
		}
		
		/**
		 * Result handler
		 * */
		public function onResult(data:Object, event:Event = null):void {
			var result:String = data as String;
			var serviceEvent:WPServiceEvent;
			var currentTime:int;
			var json:Object;
			var token:String;
			var anotherCallToGo:Boolean;
			var profile:Boolean;
			var error:Boolean;
			var tokenFound:Boolean;
			
			profile ? responseTime = getTimer() - time :-3;
			
			serviceEvent = new WPServiceEvent(WPServiceEvent.RESULT);
			serviceEvent.call = call;
			serviceEvent.text = result;
			serviceEvent.resultEvent = event;
			serviceEvent.successful = true;
			
			try {
				profile ? currentTime = getTimer():-0;
				json = JSON.parse(result);
				profile ? parseTime = getTimer()- currentTime:-(1);
			}
			catch (e:Error) {
				// Error #1132: Invalid JSON parse input.
				serviceEvent.hasError = true;
				serviceEvent.resultEvent = event;
				serviceEvent.parseError = e;
				serviceEvent.data = result;
				serviceEvent.message = "Parse result error";
				serviceEvent.successful = false;
				
				errorOccured = true;
				errorMessage = event.toString();
				errorEvent = event;
				
				inProgress = false;
				createPending = false;
				updatePending = false;
				uploadPending = false;
				deletePending = false;
				
				dispatchEvent(serviceEvent);
				
				return;
			}
		
			if (json==null) {
				serviceEvent.message = "JSON object is null";
				
				errorOccured = true;
				errorMessage = event.toString();
				errorEvent = event;
				serviceEvent.successful = false;
			}
			
			// token call
			if (createPending || updatePending || uploadPending || deletePending) {
				if (json && json is Object && "nonce" in json) {
					token = json.nonce;
					tokenFound = true;
				}
			}
			
			serviceEvent.data = json;
			
			if (json && json is Object && "status" in json && json.status=="error") {
				error = true;
				serviceEvent.hasError = true;
				serviceEvent.message = json.error;//"Update token error";
				errorOccured = true;
				errorMessage = event.toString();
				errorEvent = event;
				serviceEvent.successful = false;
				//dispatchEvent(serviceEvent);
				//return;
			}
			else if (updatePending && tokenFound) {
				updatePost(token);
				anotherCallToGo = true;
			}
			else if (createPending && tokenFound) {
				createPost(token);
				anotherCallToGo = true;
			}
			else if (deletePending && tokenFound) {
				deletePost(token);
				anotherCallToGo = true;
			}
			else if (uploadPending && tokenFound) {
				uploadAttachment(token);
				anotherCallToGo = true;
			}
			
			if (call==WPServiceEvent.LOGIN_USER) {
				if (json && json is Object && json.blogs) {
					
					for each (var blog:Object in json.blogs) {
						sites.push(blog);
					}
					
					if (sites.length>0) {
						var possibleSite:String = sites[0].siteurl;
						
						if (updateSitePathOnLogin) {
							originalSite = site;
							site = sites[0].path;
						}
					}
				}
			}
			
			if (call==WPServiceEvent.LOGOUT_USER) {
				/*if (json && json is Object && json.blogs) {
					
					for each (var blog:Object in json.blogs) {
						sites.push(blog);
					}
					
					if (sites.length>0) {
						var possibleSite:String = sites[0].siteurl;
						
						if (updateSitePathOnLogin) {
							originalSite = site;
							site = sites[0].path;
						}
					}
				}*/
				
				if (updateSitePathOnLogin && originalSite && site != originalSite) {
					site = originalSite;
				}
				sites = [];
			}
			
			inProgress = false;
			createPending = false;
			updatePending = false;
			uploadPending = false;
			deletePending = false;
			
			if (!anotherCallToGo) {
				dispatchEvent(serviceEvent);
			}
		}
		
		/**
		 * Creates a post. Stub method.
		 * */
		public function createPost(currentToken:String = null):void {
			inProgress = true;
		}
		
		/**
		 * Updates a post. Stub method.
		 * */
		public function updatePost(currentToken:String = null):void {
			inProgress = true;
		}
		
		/**
		 * Deletes a post. Stub method.
		 * */
		public function deletePost(currentToken:String = null):void {
			inProgress = true;
		}
		
		/**
		 * Uploads an attachment. Stub method.
		 * */
		public function uploadAttachment(currentToken:String = null):void {
			inProgress = true;
		}
		
		/**
		 * Save
		 * */
		public function save(data:URLVariables = null):void {
			inProgress = true;
		}
		
		
		/**
		 * Add event listeners to the URLLoader instance
		 * */
		protected function addEventListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
            dispatcher.addEventListener(Event.OPEN, openHandler, false, 0, true);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler, false, 0, true);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
        }
		
		/**
		 * Remove event listeners from URLLoader instance.
		 * */
		protected function removeEventListeners(dispatcher:IEventDispatcher):void {
            dispatcher.removeEventListener(Event.COMPLETE, completeHandler);
            dispatcher.removeEventListener(Event.OPEN, openHandler);
            dispatcher.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * URL Loader complete
		 * */
		protected function completeHandler(event:Event):void {
			//ObjectUtil.toString(event.currentTarget);
			onResult(loader.data, event);
		}

		/**
		 * 
		 * */
        protected function openHandler(event:Event):void {
            //trace("openHandler: " + event);
        }

		/**
		 * 
		 * */
        protected function progressHandler(event:ProgressEvent):void {
            //trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
        }

		/**
		 * 
		 * */
        protected function httpStatusHandler(event:HTTPStatusEvent):void {
           // trace("httpStatusHandler: " + event);
        }
		
		/**
		 * IO Error handler
		 * */
		protected function ioErrorHandler(event:IOErrorEvent):void {
			onFault(event);
		}
		
		/**
		 * Security Error handler
		 * */
		protected function securityErrorHandler(event:SecurityErrorEvent):void {
			onFault(event);
		}
	}
}