package ro.ciacob.desktop.windows {
	import flash.display.DisplayObject;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import mx.core.IUIComponent;
	import mx.events.AIREvent;
	import mx.events.FlexNativeWindowBoundsEvent;
	import mx.events.ResizeEvent;
	
	import ro.ciacob.utils.Objects;

	public class WindowRecord extends EventDispatcher {
		private static const ILLEGAL_MIN_SIZE:String = 'Illegal minimum size encountered. Minimum width cannot be greater than maximum width, and minimum height cannot be greater than maximum height.'

		private var _catalogue:IWindowsCatalogue;
		private var _children:Object = {};

		private var _counter:int;
		private var _displayStatesShortHistory:Array;
		private var _hasFocus:Boolean;
		private var _isApplicationModal:Boolean;

		private var _isCurrentlyBlocking:Boolean;
		private var _isDestroyed:Boolean;
		private var _isNativeWindowInitialized:Boolean;
		private var _keepMaxSizeInScreen:Boolean;
		private var _keepMinSizeInScreen:Boolean;

		private var _keepNormalBoundsInScreen:Boolean;
		private var _maxSize:Point;
		private var _minSize:Point;

		private var _mustBlockOnInitialize:Boolean;
		private var _normalStateBounds:Rectangle;
		private var _observers:Object = {};
		private var _parent:String;
		private var _style:int;
		private var _uid:String;
		private var _windowBase:Window;

		public function WindowRecord (window : Window, uid:String, style:int, counter:int) {
			_windowBase = window;
			_uid = uid;
			_style = style;
			
			var hasExplicitTransparency : Boolean = hasStyleSetting (WindowStyle.TRANSPARENT);
			var usesNativeChrome : Boolean = hasStyleSetting(WindowStyle.NATIVE);

			// We never use the standard/system chrome because it produces windows of
			// unpredictable size (due to the native chrome being drawn outside our window
			// content, while there is no reliable way of knowing that chrome's size
			// ahead of time.
			_windowBase.systemChrome = usesNativeChrome? NativeWindowSystemChrome.STANDARD :
					NativeWindowSystemChrome.NONE;
			
			// Setup window features and type
			_windowBase.showTitleBar = hasStyleSetting(WindowStyle.HEADER);
			_windowBase.showStatusBar = hasStyleSetting(WindowStyle.FOOTER);
			_windowBase.type = (hasStyleSetting (WindowStyle.TASKBAR)? 
				NativeWindowType.NORMAL :
				NativeWindowType.UTILITY);
			
			// Decide whether to use the Flex chrome, or not (if not, the application will be in
			// charge of defining its own chrome).
			//
			// IMPORTANT:
			// If we were requested to use transparency (the "WindowStyle.TRANSPARENT" style
			// was set), but we where also requested to use the Flex chrome (at least one of the
			// "WindowStyle.HEADER", "WindowStyle.FOOTER" or "WindowStyle.RESIZE" styles was 
			// also set) we will draw an opaque background beneath the content area of the
			// window. The header and footer area are left transparent, in the idea that
			// maybe the user wants to use rounded corners for his custom chrome.
			var mustUseFlexChrome : Boolean = !usesNativeChrome && (hasStyleSetting (WindowStyle.HEADER) ||
				hasStyleSetting(WindowStyle.FOOTER) || 
				hasStyleSetting (WindowStyle.RESIZE));
			if (mustUseFlexChrome) {
				_windowBase.setStyle('showFlexChrome', true);
				_windowBase.styleName ='chromeWindow';
				_windowBase.drawContentBackground = true;
			}			
			if (mustUseFlexChrome || hasExplicitTransparency) {
				_windowBase.transparent = true;
				_windowBase.setStyle('backgroundAlpha', 0);

			} else {
				_windowBase.transparent = false;
				_windowBase.setStyle('backgroundAlpha', 1);
			}
			
			// Setup window behavior
			_windowBase.minimizable = hasStyleSetting(WindowStyle.MINIMIZE);
			_windowBase.maximizable = hasStyleSetting(WindowStyle.MAXIMIZE);
			if (hasStyleSetting(WindowStyle.RESIZE)) {
				_windowBase.resizable = true;
				_windowBase.showGripper = true;
			} else {
				_windowBase.resizable = false;
				_windowBase.showGripper = false;
			}
			_windowBase.alwaysInFront = hasStyleSetting(WindowStyle.TOP);
			_counter = counter;
			
			// Hook window up
			_windowBase.addEventListener(Window.WINDOW_OPEN, _onNativeWindowInitialized);
			_initializeStatesHistory();
		}


		public function get catalogue():IWindowsCatalogue {
			return _catalogue;
		}

		public function get children():Vector.<String> {
			return Vector.<String>(Objects.getKeys(_children));
		}

		public function get counter():int {
			return _counter;
		}

		public function get hasFocus():Boolean {
			return _hasFocus;
		}

		public function hasStyleSetting(setting:int):Boolean {
			return ((_style & setting) == setting);
		}

		public function get isApplicationModal():Boolean {
			return _isApplicationModal;
		}

		public function isChildOf(parentUid:String):Boolean {
			return (_catalogue.lookup(parentUid).children.indexOf(this.uid) != -1);
		}

		public function get isCurrentlyBlocking():Boolean {
			return _isCurrentlyBlocking;
		}

		public function get isDestroyed():Boolean {
			return _isDestroyed;
		}

		public function get isInitialized():Boolean {
			return _isNativeWindowInitialized;
		}

		public function get isMaximized():Boolean {
			return (_displayStatesShortHistory[_displayStatesShortHistory.length - 1] == NativeWindowDisplayState.MAXIMIZED);
		}

		public function get isMinimized():Boolean {
			return (_displayStatesShortHistory[_displayStatesShortHistory.length - 1] == NativeWindowDisplayState.MINIMIZED);
		}

		public function get maxSize():Point {
			return _maxSize;
		}

		public function get minSize():Point {
			return _minSize;
		}

		public function get parent():String {
			return _parent;
		}

		public function get previousState():String {
			return _displayStatesShortHistory[0];
		}

		public function get uid():String {
			return _uid;
		}

		public function get window():Window {
			return _windowBase;
		}

		internal function adoptChild(uid:String):void {
			_children[uid] = uid;
			var child:WindowRecord = _catalogue.lookup(uid);
			child.setParent(this.uid);
			child.window.windowOwner = this._windowBase;
		}
		
		internal function orphanChild (uid : String) : void {
			delete _children[uid];
			var formerChild : WindowRecord = _catalogue.lookup(uid);
			formerChild.setParent (null);
			formerChild.window.windowOwner = null;
		}

		internal function block():void {
			if (_isNativeWindowInitialized) {
				_blockNow();
			} else {
				_mustBlockOnInitialize = true;
			}
		}

		internal function observe(activity:int, callback:Function, context:Object):void {
			var closure:Function;

			// NOTE:
			// If there is an application modal window blocking the windows stack, and *this*
			// window is NOT an application modal window, then its listeners shouldn't fire as 
			// well.
			switch (activity) {
				case WindowActivity.BEFORE_DESTROY:
					closure = function(event:Event):void {
						if (_amIBlocked()) {
							return;
						}
						var ret:* = callback.apply(context, [_uid]);
						if (!ret) {
							event.preventDefault();
						}
					}
					_windowBase.addEventListener(Event.CLOSING, closure);
					_rememberObserver(activity, callback, closure);
					break;
				case WindowActivity.DESTROY:
					closure = function(... tmp):void {
						if (_amIBlocked()) {
							return;
						}
						callback.apply(context, [_uid]);
					}
					_windowBase.addEventListener(Event.CLOSE, closure);
					_rememberObserver(activity, callback, closure);
					break;
				case WindowActivity.HIDE:
					closure = function(event:NativeWindowDisplayStateEvent):void {
						if (_amIBlocked()) {
							return;
						}
						if (event.afterDisplayState == NativeWindowDisplayState.MINIMIZED) {
							callback.apply(context, [_uid]);
						}
					}
					_windowBase.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, closure);
					_rememberObserver(activity, callback, closure);
					break;
				case WindowActivity.MAXIMIZE:
					closure = function(event:NativeWindowDisplayStateEvent):void {
						if (_amIBlocked()) {
							return;
						}
						if (event.afterDisplayState == NativeWindowDisplayState.MAXIMIZED) {
							callback.apply(context, [_uid]);
						}
					}
					_windowBase.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, closure);
					_rememberObserver(activity, callback, closure);
					break;
				case WindowActivity.MOVE:
					closure = function(event:NativeWindowBoundsEvent):void {
						// We always allow moving, even for blocked windows.
						callback.apply (context, [_uid]);
					}
					_windowBase.addEventListener(FlexNativeWindowBoundsEvent.WINDOW_MOVE, closure);
					_rememberObserver (activity, callback, closure);
					break;
				case WindowActivity.RESIZE:
					closure = function(event:ResizeEvent):void {
						if (_amIBlocked()) {
							return;
						}
						callback.apply(context, [_uid]);
					}
					_windowBase.addEventListener(NativeWindowBoundsEvent.RESIZE, closure);
					_rememberObserver(activity, callback, closure);
					break;
				case WindowActivity.SHOW:
					closure = function(event:NativeWindowDisplayStateEvent):void {
						if (_amIBlocked()) {
							return;
						}
						if (event.afterDisplayState != NativeWindowDisplayState.MINIMIZED) {
							callback.apply(context, [_uid]);
						}
					}
					_windowBase.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, closure);
					_rememberObserver(activity, callback, closure);
					break;
				case WindowActivity.UNMAXIMIZE:
					closure = function(event:NativeWindowDisplayStateEvent):void {
						if (_amIBlocked()) {
							return;
						}
						if (event.afterDisplayState != NativeWindowDisplayState.MAXIMIZED) {
							callback.apply(context, [_uid]);
						}
					}
					_windowBase.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, closure);
					_rememberObserver(activity, callback, closure);
					break;
				case WindowActivity.FOCUS:
					closure = function(event:AIREvent):void {
						if (_amIBlocked()) {
							return;
						}
						callback.apply(context, [_uid]);
					}
					_windowBase.addEventListener(AIREvent.WINDOW_ACTIVATE, closure);
					_rememberObserver(activity, callback, closure);
					break;
				case WindowActivity.BLUR:
					closure = function(event:AIREvent):void {
						if (_amIBlocked()) {
							return;
						}
						callback.apply(context, [_uid]);
					}
					_windowBase.addEventListener(AIREvent.WINDOW_DEACTIVATE, closure);
					_rememberObserver(activity, callback, closure);
					break;
			}
		}

		internal function setParentModal():void {
			_windowBase.alwaysInFront = true;
			_isApplicationModal = true;
		}

		internal function setCatalogue(value:IWindowsCatalogue):void {
			_catalogue = value;
		}

		internal function setDestroyedFlag():void {
			_isDestroyed = true;
		}

		/**
		 * Instead of producing an error when maximum size is less than minimum size,
		 * we will gracefully recover by updating the minimum size.
		 */
		internal function setMaxSize(size:Point, constrainToScreen:Boolean):void {
			if (_minSize && (size.x < _minSize.x || size.y < _minSize.y)) {
				var adjustedMinSize : Point = new Point (
					Math.min (size.x, _minSize.x),
					Math.min (size.y, _minSize.y)
				);
				setMinSize (adjustedMinSize, constrainToScreen);
			}
			_maxSize = size;
			_keepMaxSizeInScreen = constrainToScreen;
		}

		/**
		 * Instead of producing an error when minimum size is greater than maximum size,
		 * we will gracefully recover by updating the maximum size.
		 */		
		 internal function setMinSize(size:Point, constrainToScreen:Boolean):void {
			if (_maxSize && (size.x > _maxSize.x || size.y > _maxSize.y)) {
				var adjustedMaxSize : Point = new Point (
					Math.max (size.x, _maxSize.x),
					Math.max (size.y, _maxSize.y)
				);
				setMaxSize (adjustedMaxSize, constrainToScreen);
			}
			_minSize = size;
			_assertLegalMinSize();
			_keepMinSizeInScreen = constrainToScreen;
		}

		internal function setMaximizedPreviousState():void {
			_saveState(_displayStatesShortHistory[_displayStatesShortHistory.length - 1], NativeWindowDisplayState.MAXIMIZED);
		}


		internal function setNormalPreviousState():void {
			_saveState(_displayStatesShortHistory[_displayStatesShortHistory.length - 1], NativeWindowDisplayState.NORMAL);
		}

		internal function setNormalStateBounds(bounds:Rectangle, constrainToScreen:Boolean):void {
			_normalStateBounds = bounds;
			_keepNormalBoundsInScreen = constrainToScreen;
			if (bounds.width > 0 || bounds.height > 0) {
				_windowBase._canFitContent = false;
			}
		}

		internal function setParent(uid:String):void {
			_parent = uid;
		}

		internal function unObserve(activity:int, callback:Function):void {
			var closure:Function;
			switch (activity) {
				case WindowActivity.BEFORE_DESTROY:
					closure = _getObserverClosure(activity, callback);
					if (closure != null) {
						_windowBase.removeEventListener(Event.CLOSING, closure);
						_forgetObserver(activity, callback);
					}
					break;
				case WindowActivity.DESTROY:
					closure = _getObserverClosure(activity, callback);
					if (closure != null) {
						_windowBase.removeEventListener(Event.CLOSE, closure);
						_forgetObserver(activity, callback);
					}
					break;
				case WindowActivity.HIDE:
					closure = _getObserverClosure(activity, callback);
					if (closure != null) {
						_windowBase.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, closure);
						_forgetObserver(activity, callback);
					}
					break;
				case WindowActivity.MAXIMIZE:
					closure = _getObserverClosure(activity, callback);
					if (closure != null) {
						_windowBase.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, closure);
						_forgetObserver(activity, callback);
					}
					break;
				case WindowActivity.MOVE:
					closure = _getObserverClosure(activity, callback);
					if (closure != null) {
						_windowBase.removeEventListener(NativeWindowBoundsEvent.MOVE, closure);
						_forgetObserver(activity, callback);
					}
					break;
				case WindowActivity.RESIZE:
					closure = _getObserverClosure(activity, callback);
					if (closure != null) {
						_windowBase.removeEventListener(NativeWindowBoundsEvent.RESIZE, closure);
						_forgetObserver(activity, callback);
					}
					break;
				case WindowActivity.SHOW:
					closure = _getObserverClosure(activity, callback);
					if (closure != null) {
						_windowBase.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, closure);
						_forgetObserver(activity, callback);
					}
					break;
				case WindowActivity.UNMAXIMIZE:
					closure = _getObserverClosure(activity, callback);
					if (closure != null) {
						_windowBase.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, closure);
						_forgetObserver(activity, callback);
					}
					break;
				case WindowActivity.FOCUS:
					closure = _getObserverClosure(activity, callback);
					if (closure != null) {
						_windowBase.removeEventListener(AIREvent.WINDOW_ACTIVATE, closure);
						_forgetObserver(activity, callback);
					}
					break;
				case WindowActivity.BLUR:
					closure = _getObserverClosure(activity, callback);
					if (closure != null) {
						_windowBase.removeEventListener(AIREvent.WINDOW_DEACTIVATE, closure);
						_forgetObserver(activity, callback);
					}
					break;
			}
		}
		
		/**
		 * Stops observing all activities ever set under observation. This method is
		 * only meant to be used before destroying a window.
		 */
		internal function unObserveAll () : void {
			for (var activity : String in _observers) {
				var registry : Dictionary = (_observers[activity] as Dictionary);
				for each (var listeners : Array in registry) {
					var localClosure : Function = (listeners[1] as Function);
					var key : int = (parseInt (activity) as int);
					if (localClosure != null) {
						switch (key) {
							case WindowActivity.BEFORE_DESTROY:
								_windowBase.removeEventListener(Event.CLOSING, localClosure);
								break;
							case WindowActivity.DESTROY:
								_windowBase.removeEventListener(Event.CLOSE, localClosure);
								break;
							case WindowActivity.HIDE:
								_windowBase.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, localClosure);
								break;
							case WindowActivity.MAXIMIZE:
								_windowBase.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, localClosure);
								break;
							case WindowActivity.MOVE:
								_windowBase.removeEventListener (NativeWindowBoundsEvent.MOVE, localClosure);
								break;
							case WindowActivity.RESIZE:
								_windowBase.removeEventListener(NativeWindowBoundsEvent.RESIZE, localClosure);
								break;
							case WindowActivity.SHOW:
								_windowBase.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, localClosure);
								break;
							case WindowActivity.UNMAXIMIZE:
								_windowBase.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, localClosure);
								break;
							case WindowActivity.FOCUS:
								_windowBase.removeEventListener(AIREvent.WINDOW_ACTIVATE, localClosure);
								break;
							case WindowActivity.BLUR:
								_windowBase.removeEventListener(AIREvent.WINDOW_DEACTIVATE, localClosure);
								break;
						}
					}
				}
			}
			_observers = {};
		}

		internal function unblock():void {
			if (_isNativeWindowInitialized) {
				_unblockNow();
			} else {
				_mustBlockOnInitialize = false;
			}
		}

		/**
		 * If maximum size is less than current size, we will silently update
		 * the current size to be smaller.
		 */
		internal function updateMaxSize():void {
			if (isInitialized && !isDestroyed && !isMinimized && !isMaximized) {
				if (_maxSize != null) {
					if (_keepMaxSizeInScreen) {
						_keepMaxSizeInScreen = false;
						var maxBounds:Rectangle = _pointToRect(_maxSize);
						maxBounds = _trimGivenBoundsToCurrentScreen(maxBounds);
						_maxSize = _rectToPoint(maxBounds);
					}
					var _onWindowReady : Function = function () : void {
						_windowBase.removeEventListener (AIREvent.WINDOW_COMPLETE, 
							_onWindowReady);
						var nWin : NativeWindow = _windowBase.nativeWindow;
						if (_maxSize.x < nWin.width || _maxSize.y < nWin.height) {
							var adjustedSize : Point = new Point (
								Math.min (_maxSize.x, nWin.width),
								Math.min (_maxSize.y, nWin.height)
							);
							setNormalStateBounds (_pointToRect (adjustedSize), false);
							updateWindowBounds();
						}
						_windowBase.maxWidth = _maxSize.x;
						_windowBase.maxHeight = _maxSize.y;
					}
					if (!_windowBase.closed) {
						if (_windowBase.$frameCounter >= 2) {
							_onWindowReady();
						}
						_windowBase.addEventListener (AIREvent.WINDOW_COMPLETE, _onWindowReady);
					}
				}
			}
		}

		/**
		 * If minimum size is greater than current size, we will silently update
		 * the current size to be larger.
		 */
		internal function updateMinSize():void {
			if (isInitialized && !isDestroyed && !isMinimized && !isMaximized) {
				if (_minSize != null) {
					if (_keepMinSizeInScreen) {
						_keepMinSizeInScreen = false;
						var minBounds:Rectangle = _pointToRect(_minSize);
						minBounds = _trimGivenBoundsToCurrentScreen(minBounds);
						_minSize = _rectToPoint(minBounds);
					}
					var _onWindowReady : Function = function () : void {
						_windowBase.removeEventListener (AIREvent.WINDOW_COMPLETE, 
							_onWindowReady);
						var nWin : NativeWindow = _windowBase.nativeWindow;
						if (_minSize.x > nWin.width || _minSize.y > nWin.height) {
							var adjustedSize : Point = new Point(
								Math.max (_minSize.x, nWin.width),
								Math.max (_minSize.y, nWin.height)
							);
							setNormalStateBounds(_pointToRect (adjustedSize), false);
							updateWindowBounds();
						}
						_windowBase.minWidth = _minSize.x;
						_windowBase.minHeight = _minSize.y;
					}
					if (!_windowBase.closed) {
						if (_windowBase.$frameCounter >= 2) {
							_onWindowReady();
						}
						_windowBase.addEventListener (AIREvent.WINDOW_COMPLETE, _onWindowReady);
					}
				}
			}
		}

		internal function updateWindowBounds():void {
			if (isInitialized && !isDestroyed && !isMinimized && !isMaximized) {
				if (_normalStateBounds != null) {
					if (_keepNormalBoundsInScreen) {
						_keepNormalBoundsInScreen = false;
						_normalStateBounds = _trimGivenBoundsToCurrentScreen(_normalStateBounds);
					}
					_windowBase.invalidateProperties();
					var requiredW : Number = _normalStateBounds.width;
					var requiredH : Number = _normalStateBounds.height;
					var nWin : NativeWindow = _windowBase.nativeWindow;
					nWin.x = _normalStateBounds.x;
					nWin.y = _normalStateBounds.y;
					if (requiredW > 0) {
						nWin.width = requiredW;
						if (_windowBase.stage) {
							_windowBase.width = _windowBase.stage.stageWidth;
						}
					}
					if (requiredH > 0) {
						nWin.height = requiredH;
						if (_windowBase.stage) {
							_windowBase.height = _windowBase.stage.stageHeight;
						}
					}
				}
			}
		}

		/**
		 * @private
		 * "I", as in "myself", or  "the current window". The current window is considered to be
		 * "blocked" if there is a different window (in the whole stack of windows) that is
		 * currently blocking the stack, and that window is NOT the direct parent of the current
		 * window (which is a permitted situation).
		 * 
		 * This is important, as event handlers (especially those hooked up by using the 
		 * "observeWindowActivity()" API of the windows manager) should not be firing on a 
		 * blocked window.
		 */
		private function _amIBlocked():Boolean {
			var i : int = 0;
			var numUids : int = _catalogue.uids.length;
			var someUid : String = null;
			var otherWindow : WindowRecord = null;
			for (i; i < numUids; i++) {
				someUid = _catalogue.uids[i];
				if (someUid != _uid && someUid != _parent) {
					otherWindow = _catalogue.lookup (someUid);
					if (otherWindow.isCurrentlyBlocking) {
						return true;
					}
				}
			}
			return false;
		}

		private function _assertLegalMinSize():void {
			if (_maxSize != null) {
				if (_minSize.x > _maxSize.x || _minSize.y > _maxSize.y) {
					throw(new Error(ILLEGAL_MIN_SIZE));
				}
			}
		}

		/**
		 * Blocks "oneself", that is, this very WindowRecord instance, together with its _windowBase and related
		 * NativeWindow. The first child of the _windowBase component will become disabled, and no essential
		 * operation (e.g., moving, resizing, some state changing) will be available anymore. Also, a WindowRecordEvent
		 * is dispatched to let the rest of the world know about it.
		 */
		private function _blockNow():void {
			if (_windowBase.numChildren > 0) {
				var wrapper:DisplayObject = _windowBase.getChildAt(0);
				if (wrapper is IUIComponent) {
					IUIComponent(wrapper).enabled = false;
				}
			}
			_windowBase.addEventListener(Event.CLOSING, _onPreventDefault);
			var $nw : NativeWindow = _windowBase.nativeWindow;
			$nw.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, _onConditionalPreventDefault);
			$nw.addEventListener(NativeWindowBoundsEvent.MOVING, _onPreventDefault);
			$nw.addEventListener(NativeWindowBoundsEvent.RESIZING, _onPreventDefault);
			dispatchEvent(new WindowRecordEvent(WindowRecordEvent.BLOCKING, $nw, _windowBase, _uid));
		}

		private function _forgetObserver(activity:int, callback:Function):void {
			if (_observers[activity] != null && _observers[activity] is Dictionary) {
				if (_observers[activity][callback] != null &&
					_observers[activity][callback] is Array) {
					_observers[activity][callback][0] = null;
					_observers[activity][callback][1] = null;
					_observers[activity][callback] = null;
					delete _observers[activity][callback];
				}
			}
		}

		private function _getObserverClosure(activity:int, callback:Function):Function {
			if (_observers[activity] != null && _observers[activity] is Dictionary) {
				if (_observers[activity][callback] != null &&
					_observers[activity][callback] is Array) {
					return _observers[activity][callback][1] as Function;
				}
			}
			return null;
		}

		private function _initializeStatesHistory():void {
			_displayStatesShortHistory = [];
			_saveState(NativeWindowDisplayState.NORMAL, NativeWindowDisplayState.NORMAL);
		}

		private function _onDisplayStageChange(event:NativeWindowDisplayStateEvent):void {
			_saveState(event.afterDisplayState, event.beforeDisplayState);
			updateWindowBounds();
			updateMaxSize();
			updateMinSize();
		}

		private function _onNativeWindowInitialized(event:Event):void {
			_windowBase.removeEventListener(Window.WINDOW_OPEN, _onNativeWindowInitialized);
			var $nw : NativeWindow = _windowBase.nativeWindow;
			_isNativeWindowInitialized = true;
			dispatchEvent(new WindowRecordEvent(WindowRecordEvent.WINDOW_READY, $nw, _windowBase, _uid));

			// It is essential that this listener fires before all the others.
			$nw.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, _onDisplayStageChange,
				false, int.MAX_VALUE, true);

			$nw.addEventListener(Event.CLOSE, _onWindowClose);
			$nw.addEventListener(Event.ACTIVATE, _onWindowActivate, false, 0, true);
			$nw.addEventListener(Event.DEACTIVATE, _onWindowDeactivate, false, 0, true);
			updateWindowBounds();
			updateMaxSize();
			updateMinSize();
			if (_isApplicationModal) {

				// CASE (A): We are a modal window, causing other windows to be denied 
				// access to their own content.
				_isCurrentlyBlocking = true;
				for (var i:int = 0; i < _catalogue.uids.length; i++) {
					var someUid:String = _catalogue.uids[i];
					if (someUid != _uid) {
						_catalogue.lookup(someUid).block();
					}
				}
			} else {
				// CASE (B): We are a window that needs to deny access to its own content
				// because of a (grand)child modal window.
				if (_mustBlockOnInitialize) {
					_blockNow();
				}
			}
		}

		private static function _onPreventDefault(event:Event):void {
			event.preventDefault();
		}
		
		/**
		 * By exception, permits certain scenarios involving blocked windows:
		 * (1) Allows the window to be recovered from the taskbar, even when there is a modal
		 * that blocks it;
		 * (2) Allows the window to be minimized to task bar, even when there is a modal that
		 * blocks it.
		 */
		private static function _onConditionalPreventDefault (event:NativeWindowDisplayStateEvent):void {
			if (event.beforeDisplayState == NativeWindowDisplayState.MINIMIZED && 
				(event.afterDisplayState == NativeWindowDisplayState.NORMAL ||
					event.afterDisplayState == NativeWindowDisplayState.MAXIMIZED)) {
				return;
			}
			if (event.beforeDisplayState != NativeWindowDisplayState.MINIMIZED && 
				event.afterDisplayState == NativeWindowDisplayState.MINIMIZED) {
				return;
			}
			event.preventDefault();
		}

		private function _onWindowActivate(event:Event):void {
			_hasFocus = true;
		}

		private function _onWindowClose(event:Event):void {
			_windowBase.nativeWindow.removeEventListener(Event.CLOSE, _onWindowClose);
			_isDestroyed = true;
			if (_isApplicationModal) {
				if (_isCurrentlyBlocking) {
					_isCurrentlyBlocking = false;
					for (var i:int = 0; i < _catalogue.uids.length; i++) {
						var someUid:String = _catalogue.uids[i];
						if (someUid != _uid) {
							_catalogue.lookup(someUid).unblock();
						}
					}
				}
			}
		}

		private function _onWindowDeactivate(event:Event):void {
			_hasFocus = false;
		}

		private function _pointToRect(point:Point):Rectangle {
			var rect:Rectangle = _windowBase.nativeWindow.bounds;
			rect.width = point.x;
			rect.height = point.y;
			return rect;
		}

		private static function _rectToPoint(rect:Rectangle):Point {
			var p:Point = new Point;
			p.x = rect.width;
			p.y = rect.height;
			return p;
		}

		private function _rememberObserver(activity:int, callback:Function, localClosure:Function):void {
			if (_observers[activity] == null) {
				_observers[activity] = new Dictionary;
			}
			if (_observers[activity][callback] == null) {
				_observers[activity][callback] = [];
			}
			_observers[activity][callback][0] = callback;
			_observers[activity][callback][1] = localClosure;
		}

		private function _saveState(currentState:String, previousState:String):void {
			_displayStatesShortHistory.push(previousState);
			_displayStatesShortHistory.push(currentState);
			_displayStatesShortHistory.reverse();
			_displayStatesShortHistory.length = 2;
			_displayStatesShortHistory.reverse();
		}

		private function _trimGivenBoundsToCurrentScreen(bounds:Rectangle):Rectangle {
			var currentBounds:Rectangle = _windowBase.nativeWindow.bounds;
			var currentScreens:Array = Screen.getScreensForRectangle(currentBounds);
			var currentScreen:Screen;
			if (currentScreens.length == 1) {
				currentScreen = currentScreens[0] as Screen;
			}
			if (currentScreen != null) {
				if (bounds.left < 0) {
					bounds.left = 0;
				}
				if (bounds.top < 0) {
					bounds.top = 0;
				}
				if (bounds.right > currentScreen.bounds.right) {
					bounds.right = currentScreen.bounds.right;
				}
				if (bounds.bottom > currentScreen.bounds.bottom) {
					bounds.bottom = currentScreen.bounds.bottom;
				}
			}
			return bounds;
		}

		/**
		 * Un-blocks "oneself", that is, this very WindowRecord instance, together with its _windowBase and related
		 * NativeWindow. The first child of the _windowBase component will become enabled again, and so will all window
		 * essential operations (e.g., moving, resizing, state changing). Also, a WindowRecordEvent is dispatched
		 * to let the rest of the world know about it.
		 */
		private function _unblockNow():void {
			if (_windowBase.numChildren > 0) {
				var wrapper:DisplayObject = _windowBase.getChildAt(0);
				if (wrapper is IUIComponent) {
					IUIComponent(wrapper).enabled = true;
				}
			}
			_windowBase.removeEventListener(Event.CLOSING, _onPreventDefault);
			var $nw : NativeWindow = _windowBase.nativeWindow;
			$nw.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, _onConditionalPreventDefault);
			$nw.removeEventListener(NativeWindowBoundsEvent.MOVING, _onPreventDefault);
			$nw.removeEventListener(NativeWindowBoundsEvent.RESIZING, _onPreventDefault);
			dispatchEvent(new WindowRecordEvent(WindowRecordEvent.UNBLOCKING, $nw, _windowBase, _uid));
		}
	}
}
