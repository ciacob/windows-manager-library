package ro.ciacob.desktop.windows {
	import flash.desktop.NativeApplication;
	import flash.desktop.NotificationType;
	import flash.display.DisplayObject;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import mx.events.AIREvent;
	
	import ro.ciacob.utils.Strings;
	import ro.ciacob.utils.Time;

	public class WindowsManager extends EventDispatcher implements IWindowsManager {

		private static const MAXIMIZE_DELAY:Number = 0.3;
		private static const UID_LENGTH:int = 8;
		private static const WINDOW_IS_DESTROYED:String = 'Window you attempt to operate on was (already) destroyed.';
		private static const CANNOT_PARENT_MAIN_WINDOW:String = 'The main window cannot have a parent';

		private static var _creationCounter:int = 0;
		private var _catalogue:WindowsCatalogue;
		private var _mainWindow:String;

		public function WindowsManager() {
			_catalogue = new WindowsCatalogue;
		}



		internal function getUidByWindow (window : Window) : String {
			var availableUids : Vector.<String> = availableWindows;
			var i:int = 0;
			var numAvailWindows : int = availableUids.length;
			var uid : String;
			var record : WindowRecord;
			var testWindow : Window;
			
			for (i; i < numAvailWindows; i++) {
				uid = (availableUids[i] as String);
				record = _catalogue.lookup (uid);
				testWindow = record.window;
				if (testWindow == window) {
					return uid;
				}
			}
			return null;
		}
		
		public function get availableWindows():Vector.<String> {
			var all:Vector.<String> = Vector.<String>(_catalogue.uids);
			var notDestroyedOnly:Vector.<String> = new Vector.<String>;
			for (var i:int = 0; i < all.length; i++) {
				var uid:String = all[i];
				if (isWindowAvailable(uid)) {
					notDestroyedOnly.push(uid);
				}
			}
			notDestroyedOnly.sort(function(uidA:String, uidB:String):int {
				return (_catalogue.lookup(uidA).counter - _catalogue.lookup(uidB).counter);
			});
			return notDestroyedOnly;
		}

		public function bringWindowInFocus(uid:String):void {
			if (isWindowVisible(uid)) {
				Time.delay(0.01, function () : void {
					// Force the window to (temporarily) get in front
					var nWin : NativeWindow = _catalogue.lookup(uid).window.nativeWindow;
					if (nWin != null) {
						var origSetting : Boolean = nWin.alwaysInFront;
						nWin.alwaysInFront = false;
						nWin.alwaysInFront = true;
						nWin.alwaysInFront = origSetting;
						nWin.orderToFront();
						NativeApplication.nativeApplication.activate(nWin);
					}
					_catalogue.lookup(uid).window.activate();
				});
			} else {
				triggerWindowNotification(uid);
			}
		}
		
		/**
		 * @see IWindowsManager.alignWindows
		 */
		public function alignWindows (mobileWindowUid : String, anchorWindowUid : String, 
									  xPercent: Number = 0.5, yPercent: Number = 0.5) : void {
			if (isWindowAvailable (mobileWindowUid) && isWindowVisible (anchorWindowUid)) {
				var availableWindowIds : Array = [];
				var mobileWinRecord : WindowRecord = _catalogue.lookup(mobileWindowUid);
				var anchorWinRecord : WindowRecord = _catalogue.lookup(anchorWindowUid);
				var performAlignment : Function = function () : void {
				 	var mobileBounds : Rectangle = retrieveWindowBounds (mobileWindowUid);
				 	var anchorBounds : Rectangle = retrieveWindowBounds (anchorWindowUid);
				 	var centeredBounds : Rectangle = new Rectangle (
				 		anchorBounds.x + (anchorBounds.width - mobileBounds.width) * xPercent,
				 		anchorBounds.y + (anchorBounds.height - mobileBounds.height) * yPercent,
				 		mobileBounds.width,
				 		mobileBounds.height
				 	);				
				 	updateWindowBounds (mobileWindowUid, centeredBounds);
				};
				var executeIfReady : Function = function() : void {
				 	if (availableWindowIds.length == 2) {
				 		performAlignment();
				 	}
				};
				var reportIdAvailable : Function = function(id : String) : void {
				 	if (availableWindowIds.indexOf (id) == -1) {
				 		availableWindowIds.push (id);
				 		executeIfReady();
				 	}
				};
				([mobileWinRecord, anchorWinRecord]).forEach (
					function (winRecord:WindowRecord, ...etc) : void {
						var uid : String = winRecord.uid;
						var window : Window = winRecord.window;
						if (window.$frameCounter > 2) {
						 	reportIdAvailable (uid);
						} else {
							var onWindowReady : Function = function () : void {
								window.removeEventListener (AIREvent.WINDOW_COMPLETE, onWindowReady);
								reportIdAvailable (uid);
							}
							window.addEventListener (AIREvent.WINDOW_COMPLETE, onWindowReady);
						}
					}
				);
			}
		}

		public function createWindow (
			content : IWindowContent,
			style : uint,
			parentModal : Boolean = false,
			childOf : String = null,
			specificUID : String = null) : String {
			
			_assertNotParentingMainWindow (childOf);
			
			if (childOf == null) {
				childOf = _mainWindow;
			}

			if (_hasModalChildWindow (childOf)) {
				return null;
			}
			
			var uid:String = (specificUID || Strings.generateUniqueId (_catalogue.uids, UID_LENGTH));
			var window:Window = new Window;
			if (content != null) {
				window.addChild (DisplayObject(content));
				content.manager = this;
			}
			_catalogue.add (window, uid, style, _creationCounter++);
			var wRecord : WindowRecord = _catalogue.lookup (uid);

			if (_mainWindow == null) {
				_mainWindow = uid;
				wRecord.addEventListener(WindowRecordEvent.BLOCKING, _onMainWindowBlocked);
				wRecord.addEventListener(WindowRecordEvent.UNBLOCKING, _onMainWindowUnblocked);
				observeWindowActivity (uid, WindowActivity.DESTROY, _onMainWindowDestroyed, this);
			} else {
				
				_assertNotDestroyed (childOf);
				_catalogue.lookup (childOf).adoptChild (uid);
				wRecord.setParent (childOf);
				
				if (parentModal) {
					wRecord.setParentModal();
				}
			}
			return uid;
		}

		public function destroyWindow(uid:String):void {
			_assertNotDestroyed(uid);
			
			// If we reach down here, window exists
			if (uid == mainWindow) {
				_onMainWindowDestroyed();
			}
			
			// If we reach down here, window exists and (1) either is not the main window,
			// OR, (2) it is the main window, but all the child windows have been previously 
			// destroyed.
			var record : WindowRecord = _catalogue.lookup(uid);
			record.unObserveAll();
			var window : Window = record.window;
			window.removeAllChildren();
			
			// We also remove the window we are destroying from the list of children of its parent
			// (assuming it was parented by another window).
			var parentUid : String = record.parent;
			if (parentUid != null) {
				var parentRecord : WindowRecord = _catalogue.lookup(parentUid);
				parentRecord.orphanChild (uid);
			}
			
			window.dispatchEvent (new Event (Event.CLOSING, true, false));
			window.dispatchEvent (new Event (Event.CLOSE, true, false));
			window.close();
			record.setDestroyedFlag();
		}

		public function hasStyle(uid:String, style:uint):Boolean {
			_assertNotDestroyed(uid);
			return _catalogue.lookup(uid).hasStyleSetting(style);
		}

		public function hideWindow(uid:String):void {
			_assertNotDestroyed(uid);
			if (_catalogue.lookup(uid).isInitialized) {
				_catalogue.lookup(uid).window.minimize();
			}
		}

		public function isWindowAvailable(uid:String):Boolean {
			var ret:Boolean;
			try {
				if (!_catalogue.lookup(uid).isDestroyed) {
					ret = true;
				}
			} catch (e:Error) {
				ret = false;
			}
			return ret;
		}

		public function isWindowMaximized(uid:String):Boolean {
			_assertNotDestroyed(uid);
			return _catalogue.lookup(uid).isMaximized;
		}

		public function isWindowVisible(uid:String):Boolean {
			_assertNotDestroyed(uid);
			return _catalogue.lookup(uid).isInitialized && !_catalogue.lookup(uid).isMinimized;
		}
		
		/**
		 * Returns true is given window is a modal, that is, it "blocks" other windows.
		 */
		public function isWindowBlocking (uid : String) : Boolean {
			_assertNotDestroyed (uid);
			var windowRecord : WindowRecord = _catalogue.lookup(uid);
			return windowRecord.isInitialized && windowRecord.isCurrentlyBlocking;
		}

		final public function get mainWindow():String {
			return _mainWindow;
		}

		public function observeWindowActivity(uid:String, activity:int, callback:Function, context:Object = null):void {
			_assertNotDestroyed(uid);
			if (context == null) {
				context = {};
			}
			if (callback != null) {
				_catalogue.lookup(uid).observe(activity, callback, context);
			}
		}

		public function retrieveChildWindowsOf(uid:String = null):Vector.<String> {
			if (uid == null) {
				var allWindows:Vector.<String> = availableWindows;
				var levelZeroOnly:Vector.<String> = new Vector.<String>;
				for (var i:int = 0; i < allWindows.length; i++) {
					if (_catalogue.lookup(allWindows[i]).parent == null) {
						levelZeroOnly.push(allWindows[i]);
					}
				}
				return levelZeroOnly;
			}
			_assertNotDestroyed(uid);
			var allChildren:Vector.<String> = _catalogue.lookup(uid).children;
			var notDestroyedOnly:Vector.<String> = new Vector.<String>;
			for (var j:int = 0; j < allChildren.length; j++) {
				var someChild:String = allChildren[j];
				if (!_catalogue.lookup(someChild).isDestroyed) {
					notDestroyedOnly.push(someChild);
				}
			}
			return notDestroyedOnly;
		}

		public function retrieveWindowBounds(uid:String):Rectangle {
			_assertNotDestroyed(uid);
			var bounds : Rectangle = null;
			var record : WindowRecord = _catalogue.lookup(uid);
			var win : Window = record.window;
			if (win != null) {
				var nWin : NativeWindow = win.nativeWindow;
				if (nWin != null) {
					bounds = nWin.bounds;
				}
			}
			return bounds;
		}

		public function retrieveWindowMaxSize(uid:String):Point {
			_assertNotDestroyed(uid);
			var record : WindowRecord = _catalogue.lookup(uid);
			if (record != null) {
				return (_catalogue.lookup(uid).maxSize || null);
			}
			return null;
		}

		public function retrieveWindowMinSize(uid:String):Point {
			_assertNotDestroyed(uid);
			var record : WindowRecord = _catalogue.lookup(uid);
			if (record != null) {
				return (_catalogue.lookup(uid).minSize || null);
			}
			return null;			
		}

		public function retrieveWindowTitle(uid:String):String {
			_assertNotDestroyed(uid);
			var record : WindowRecord = _catalogue.lookup(uid);
			if (record != null) {
				if (record.hasStyleSetting(WindowStyle.HEADER)) {
					return (_catalogue.lookup(uid).window.title || null);
				}
			}
			return null;
		}
		
		public function retrieveWindowStatus(uid:String):String {
			_assertNotDestroyed(uid);
			var record : WindowRecord = _catalogue.lookup(uid);
			if (record != null) {
				if (record.hasStyleSetting(WindowStyle.FOOTER)) {
					return (_catalogue.lookup(uid).window.status || null);
				}
			}
			return null;
		}

		public function setWindowAsMaximized(uid:String):void {
			_assertNotDestroyed(uid);
			if (!_catalogue.lookup(uid).isMaximized) {
				if (isWindowVisible(uid)) {
					_catalogue.lookup(uid).window.maximize();
				} else {
					_catalogue.lookup(uid).setMaximizedPreviousState();
				}
			}
		}

		public function showWindow (uid : String) : void {
			_assertNotDestroyed(uid);
			var windowRecord : WindowRecord = _catalogue.lookup(uid);
			var $w : Window = windowRecord.window;
			if (!windowRecord.isInitialized) {
				windowRecord.addEventListener(WindowRecordEvent.WINDOW_READY, _onWindowReady);
				$w.open();
			}
			var previousState:String = windowRecord.previousState;
			if (windowRecord.isMinimized) {
				switch (previousState) {
					case NativeWindowDisplayState.NORMAL:
						$w.restore();
						Time.delay(MAXIMIZE_DELAY, function():void {
							$w.restore();
						});
						break;
					case NativeWindowDisplayState.MAXIMIZED:
						$w.maximize();
						break;
				}
			} else if (previousState == NativeWindowDisplayState.MAXIMIZED) {
				Time.delay(MAXIMIZE_DELAY, function():void {
					$w.maximize();
				});
			}
		}
		
		public function stopObservingWindowActivity(uid:String, activity:int, callback:Function):void {
			_assertNotDestroyed(uid);
			_catalogue.lookup(uid).unObserve(activity, callback);
		}

		public function triggerWindowNotification(uid:String):void {
			_assertNotDestroyed(uid);
			if (_catalogue.lookup(uid).isInitialized) {
				_catalogue.lookup(uid).window.nativeWindow.notifyUser(NotificationType.INFORMATIONAL);
			}
		}

		public function unsetWindowMaximized(uid:String):void {
			_assertNotDestroyed(uid);
			if (_catalogue.lookup(uid).isMaximized) {
				_catalogue.lookup(uid).window.nativeWindow.restore();
			} else {
				_catalogue.lookup(uid).setNormalPreviousState();
			}
		}

		public function updateWindowBounds(uid:String, bounds:Rectangle, 
			constrainToScreen:Boolean = false):void {
			_assertNotDestroyed(uid);
			var windowRecord : WindowRecord = _catalogue.lookup (uid);
			windowRecord.setNormalStateBounds(bounds, constrainToScreen);
			windowRecord.updateWindowBounds();
		}

		public function updateWindowMaxSize(uid:String, width:Number, height:Number, constrainToScreen:Boolean = false):void {
			_assertNotDestroyed(uid);
			var windowRecord : WindowRecord = _catalogue.lookup (uid);
			windowRecord.setMaxSize(new Point(width, height), constrainToScreen);
			windowRecord.updateMaxSize();
			windowRecord.updateMinSize();
		}

		public function updateWindowMinSize(uid:String, width:Number, height:Number, constrainToScreen:Boolean = false):void {
			_assertNotDestroyed(uid);
			var windowRecord : WindowRecord = _catalogue.lookup(uid);
			windowRecord.setMinSize(new Point(width, height), constrainToScreen);
			windowRecord.updateMinSize();
			windowRecord.updateMaxSize();
		}

		public function updateWindowStatus(uid:String, status:String):void {
			_assertNotDestroyed(uid);
			if (hasStyle(uid, WindowStyle.FOOTER)) {
				_catalogue.lookup(uid).window.status = status;
			}
		}

		public function updateWindowTitle(uid:String, title:String):void {
			_assertNotDestroyed(uid);
			_catalogue.lookup(uid).window.title = title;
		}

		public function get visibleWindows():Vector.<String> {
			var ret:Vector.<String> = new Vector.<String>;
			var availableWindows:Vector.<String> = availableWindows;
			for (var i:int = 0; i < availableWindows.length; i++) {
				var uid:String = availableWindows[i];
				if (!_catalogue.lookup(uid).isMinimized) {
					ret.push(uid);
				}
			}
			return ret;
		}

		private function _onWindowReady (event : WindowRecordEvent) : void {
			var windowRecord : WindowRecord = (event.target as WindowRecord);
			windowRecord.removeEventListener(WindowRecordEvent.WINDOW_READY, _onWindowReady);
			if (event.windowUid == _mainWindow) {
				dispatchEvent(new WindowsManagerEvent (WindowsManagerEvent.MAIN_WINDOW_AVAILABLE, event.nativeWindow));
			}
		}

		private function _assertNotDestroyed(uid:String):void {
			if (_catalogue.lookup(uid).isDestroyed) {
				throw(new Error(WINDOW_IS_DESTROYED));
			}
		}
		
		private function _assertNotParentingMainWindow (childOfArg : String) : void {
			if (_mainWindow == null && childOfArg != null) {
				throw (new Error (CANNOT_PARENT_MAIN_WINDOW));
			} 
		}

		/**
		 * Checks whether given parent window has any open modal children (thus preventing it
		 * from creating more).
		 */
		private function _hasModalChildWindow (parentWindowUID : String ):Boolean {
			if (parentWindowUID == null) {
				return false;
			}
			
			var ret:Boolean = false;
			var parentWindow : WindowRecord = _catalogue.lookup (parentWindowUID);
			var allChildren:Vector.<String> = parentWindow.children;
			var childUID:String;
			var childWindow : WindowRecord;
			var i:int = 0;
			var numChildren : uint = allChildren.length;
			for (i; i < numChildren; i++) {
				childUID = (allChildren[i] as String);
				childWindow = (_catalogue.lookup(childUID) as WindowRecord);
				if (!childWindow.isDestroyed && childWindow.isCurrentlyBlocking) {
					ret = true;
					break;
				}
			}
			return ret;
		}

		private function _onMainWindowDestroyed(... ignore):void {
			var wRecord : WindowRecord = _catalogue.lookup(_mainWindow);
			wRecord.removeEventListener(WindowRecordEvent.BLOCKING, _onMainWindowBlocked);
			wRecord.removeEventListener(WindowRecordEvent.UNBLOCKING, _onMainWindowUnblocked);
			var all:Vector.<String> = availableWindows;
			for (var i:int = 0; i < all.length; i++) {
				var winUid : String = (all[i] as String);
				if (winUid != _mainWindow) {
					wRecord = _catalogue.lookup (winUid);
					wRecord.unblock();
					destroyWindow (winUid);
				}
			}
			_mainWindow = null;
		}

		private function _onMainWindowBlocked (event : WindowRecordEvent) : void {
			dispatchEvent(new WindowsManagerEvent(WindowsManagerEvent.MAIN_WINDOW_BLOCKED, null));
		}

		private function _onMainWindowUnblocked (event : WindowRecordEvent) : void {
			dispatchEvent(new WindowsManagerEvent(WindowsManagerEvent.MAIN_WINDOW_UNBLOCKED, null));
		}
	}
}
