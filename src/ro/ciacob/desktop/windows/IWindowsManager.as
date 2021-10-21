package ro.ciacob.desktop.windows {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.IUIComponent;

	public interface IWindowsManager {

		/**
		 * Returns a list with all windows that are currently available. Both visible and hidden windows are
		 * returned, but not destroyed ones.
		 *
		 * @return	A (possible empty) list with all windows that are currently available.  Both visible and
		 * 			hidden windows are returned.
		 */
		function get availableWindows():Vector.<String>;

		/**
		 * Attempts to bring the window pointed to by the given uid in focus.
		 *
		 * This may imply bringing the whole application in focus, should it have lost focus to a different
		 * application or to the operating system. This task may fail on various reasons, such as the
		 * operating system preventing applications from "stealing" focus to themselves. If the window is hidden
		 * an attempt is made to issue a system notification instead - as if the `trigerWindowNotification()` method
		 *  was called.
		 *
		 * @param	uid
		 * 			The uid of the window to be brought in focus. If it does not resolve to a window, or the
		 * 			window it resolves to has been destroyed, an exception will be thrown.
		 */
		function bringWindowInFocus(uid:String):void;
		
		/**
		 * Aligns a given "mobile" window with respect to a given "anchor" window. 
		 * Both windows need to be visible and have their boundaries stabilized in order for this to work (i.e.,
		 * aligning will not produce reliable results if one of the windows has just been shown for the first time).
		 * IMPORTANT: will not work if any of the involved windows wasn't given explicit bounds BEFORE attempting
		 * alignment.
		 * 
		 * @param	mobileWindowUid
		 * 			The UI of the window that will be moved;
		 * 
		 * @param	anchorWindowUid
		 * 			The UID of the window that will remain fixed;
		 * 
		 * @param	xPercent
		 * 			A Number from 0 to 1 representing the horizontal offset to apply, e.g.,
		 * 			`0.5` will center the windows horizontally. Optional, defaults to `0.5`.
		 * 
		 * @param	yPercent
		 * 			A Number from 0 to 1 representing the vertical offset to apply, e.g.,
		 * 			`0.5` will center the windows vertically. Optional, defaults to `0.5`.
		 */
		function alignWindows (mobileWindowUid : String, anchorWindowUid : String, xPercent : Number = 0.5, yPercent : Number = 0.5) : void;

		/**
		 * Builds a new window, without showing it on screen. The newly built window will hold the given
		 * content and obey the given style regulations.
		 *
		 * NOTE:
		 * Some styles create a status bar on the new window. It is important to understand that no additional
		 * space is reserved for this status bar automatically.
		 *
		 * For example, if you set the window's height to 100px, and your content requires exactly 100px, but
		 * the status bar requires an additional 19px, the window's height will NOT be transparently adjusted to
		 * 119px for you, rather, part of your content will be obscured by the status bar.
		 *
		 * This is not true, however, for the `auto-fit to content` feature. To make use of this feature, pay attention
		 * to setting size of your content, and leave the window's size unset. The result is that your window will open
		 * at the size of your content, plus the size of the status bar, if there is one.
		 *
		 * @param	content
		 * 			The visual content that will populate the new window. It is expected that this content
		 * 			will be loaded as an IApplicationModule, and added to the display list as an IUIComponent.
		 * 			It is intended that the window's content be treated as immutable: although there might be
		 * 			ways to replace a window's content past its creation time, this is strongly discouraged.
		 * 			Instead, write logic to generate visual content based on incoming data, or use a states
		 * 			mechanism.
		 *
		 * @param	style
		 * 			A set of visual cues that control the overall window's look and behavior. This is a
		 * 			complex bitmask obtained by OR-ing together (combining with the bitwise OR operator)
		 * 			constant values from the WindowStyle class. The style of a window cannot be changed past
		 * 			its creation time.
		 *
		 * @param	parentModal
		 * 			Sets the given window as `modal` to its parent. Unlike other window managers, the current one enforces
		 * 			strict exclusive modality, in that that a modal window can only be created on a parent that is both
		 * 			active/unblocked by modality, and is, itself, either modal or the main. The idea here is to make sure
		 * 			This argument is illegal on the `main application window`.
		 *
		 * @param	childOf
		 * 			The uid of a `parent` window. If it does not resolve to a window, or the window it resolves to
		 * 			has been destroyed, an exception will be thrown. Specifying this argument creates the window as a
		 * 			child of another window. When two windows have a child-parent relationship, the child will show
		 * 			above the parent, will get hidden and shown along with its parent, and will close the moment the parent
		 * 			closes. Parenting on modal windows is permitted, as long as the parent is itself modal and currently
		 * 			childless. Since the parent will be blocked by its modal child, it will not be able to controll it in 
		 * 			the way described above.
		 * 
		 * 			A window created as a child stays that way until it is destroyed.
		 *			The `main application window` cannot be some other window's child, therefore setting a value to this 
		 * 			argument when creating the very first window will throw an exception.
		 *
		 * @param	specificUID
		 * 			Only consider using when you must refer to a specific window cross application launches (and so, you
		 * 			would somehow persist the window UID and reuse it on the application's next launch). Generally not
		 * 			needed.
		 *
		 * @return 	An unique id that can be used to refer to this window.
		 *
		 * 			NOTE: RETURNS NULL if a modal window is currently shown over the parent (aka "childOf") window, as
		 * 			there cannot be several active child modal windows for the same parent window. If the "childOf"
		 * 			argument is not given, the main window is assumed. Destroy the existing modal window to release blocking.
		 *
		 * @see WindowStyle
		 */
		function createWindow (content:IWindowContent, style:uint, parentModal:Boolean = false, childOf:String = null,
			specificUID:String = null):String;

		/**
		 * Attempts to reclaim any system resources currently linked to the window with the given uid, and
		 * makes the window unavailable for future uses. Destroying the main window automatically destroys all other windows,
		 * effectivelly leaving your application windowless, which may or may not close it, depending on its
		 * `autoExit` setting.
		 *
		 * You should only destroy a window when you no longer need it, as both creating and destroying
		 * windows are expected to be computationally intensive.
		 *
		 * @param	uid
		 * 			The uid of the window to be destroyed. If it does not resolve to a window, or the window
		 * 			it resolves to has already been destroyed, an exception will be thrown.
		 *
		 */
		function destroyWindow(uid:String):void;

		/**
		 * Tests whether given style was set on the given window at creation time.
		 *
		 * @param	The uid of a window. If it does not resolve to a window, or the window it resolves to has
		 * 			been destroyed, an exception will be thrown.
		 * @style	The style whose existence is to be tested. This is a complex bitmask obtained by OR-ing
		 * 			together (combining with the bitwise OR operator) constant values from the WindowStyle
		 * 			class.
		 *
		 * @return	True, if each end every bit in the test bitmask was set. False otherwise.
		 *
		 * @see WindowStyle
		 */
		function hasStyle(uid:String, style:uint):Boolean;

		/**
		 * Hides the window with the given uid. Hiding a window does not destroy it.
		 *
		 * NOTE: In other implementations out there, there is also a `minimize()` method or similar.
		 * Our implementation DOES NOT take this approach; instead it considers all minimized windows as
		 * being hidden and vice versa - therefore, hiding a window also minimizes it.
		 *
		 * @param	uid
		 * 			The uid of the window to be hidden. If it does not resolve to a window, or resolves
		 * 			to a destroyed window, an exception will be thrown.
		 */
		function hideWindow(uid:String):void;

		/**
		 * Tests the window with the given uid as being available.
		 *
		 * @param	uid
		 * 			The uid to be tested.
		 * @return	True, if the uid successfully resolves to a window, and that window has not been destroyed
		 * 			yet; false otherwise.
		 */
		function isWindowAvailable(uid:String):Boolean;

		/**
		 * Tests the window with the given uid as having the `maximized` state set. This state will retain its
		 * value regardless of the window visibility.
		 *
		 * @param	uid
		 * 			The uid of a window. If it does not resolve to a window, or the window it resolves to
		 * 			has been destroyed, an exception will be thrown.
		 * @return	True if the `maximized` state has been set on true, false otherwise. It makes no difference
		 * 			whether the window is currently visible or not, as a window may well be hidden AND maximized.
		 *
		 * 			NOTE: this was not the case in third party implementations which employ the special state of
		 * 			`minimized`. Our implementation does not have a state of `minimized`, instead it treats all
		 * 			minimized windows as hidden and vice versa.
		 * 			If the window cannot accept this setting at all - i.e., it misses the appropriate window
		 * 			style - nothing will happen.
		 * @see setWindowMaximized
		 */
		function isWindowMaximized(uid:String):Boolean;

		/**
		 * Tests the window with the given uid as being visible, i.e., not being minimized.
		 *
		 * NOTE: In other implementations out there, there is also a `isMinimized()` method or similar. Our
		 * implementaion DOES NOT take this approach; instead it considers all minimized windows as being hidden and
		 * viceversa.
		 *
		 * @param	uid
		 * 			The uid to be tested. If it does not resolve to a window, or the window it resolves to has
		 * 			been destroyed, an exception will be thrown.
		 * @return	True, if the uid successfully resolves to a window, and that window is visible; false otherwise.
		 */
		function isWindowVisible (uid:String):Boolean;
		
		/**
		 * Returns true is given window is a modal, that is, it "blocks" other windows.
		 */
		function isWindowBlocking (uid:String):Boolean;

		/**
		 * Returns the uid of the main window. The manager registers the first window you create as the application
		 * main window, and this cannot be changed.
		 *
		 * @return 	uid
		 * 			The main application window's uid.
		 */
		function get mainWindow():String;

		/**
		 * Provides external code with an oportunity to hook into a window's asynchronous activities that weren't
		 * directed by the windows manager, such as a window closing itself in response to user clicking its `x`
		 * button.
		 *
		 * @param	uid
		 * 		 	The uid of a window. If it does not resolve to a window, or the window it resolves to
		 * 			has been destroyed, an exception will be thrown.
		 * @param	activity
		 * 			A specific activity of a window to be observed. Must match one of the WindowActivity class'
		 * 			constants. Unknown activities given will be ignored. Some activities are cancellable, meaning
		 * 			that, if the callback function returns false, they will be prevented from taking place.
		 * 			Read more in the WindowActivity class documentation.
		 * @param	callback
		 * 			A function to execute when the specific activity occurs. It will receive the window's uid as the
		 * 			first argument.
		 * @param	context
		 * 			The context in which the callback function is to be executed. Optional. If omitted, the callback
		 * 			will be executed in an anonymous empty object's context.
		 */
		function observeWindowActivity(uid:String, activity:int, callback:Function, context:Object = null):void;

		/**
		 * Returns a (possibly empty) list with all windows that have a child-parent relationship with the
		 * given window.
		 *
		 * @param	uid
		 * 			Optional. The uid of a window; if it does not resolve to a window, or the window it resolves
		 * 			to has been destroyed, an exception will be thrown.
		 * 			If omitted or null, will return all windows that reside directly in level 0 (thus skipping
		 * 			their children and later descendants). This behavior encourages use of this method in recursive
		 * 			walker functions. Defaults to null.
		 * 			NOTE:
		 * 			The output will skip destroyed windows for you.
		 *
		 * @return	A (possible empty) list of uids.
		 */
		function retrieveChildWindowsOf(uid:String = null):Vector.<String>;

		/**
		 * Returns a rectangle describing the position and size, in desktop absolute coordinates, of the
		 * window pointed to by the given uid.
		 *
		 * @param	uid
		 * 			The uid of a window. If it does not resolve to a window, or the window it resolves to has
		 * 			been destroyed, an exception will be thrown.
		 * @return	A rectangle object, holding the window's current x, y, width and height values. Note that
		 * 			these values are shallow copies. Merely changing them will not affect anything. You must
		 * 			pass any changes you make to setWindowBounds() in order to programmatically move and/or
		 * 			resize the window.
		 */
		function retrieveWindowBounds(uid:String):Rectangle;

		/**
		 * Returns the maximum size set via `updateWindowMaxSize()`, if any.
		 *
		 * @param	uid
		 * 			The uid of a window. If it does not resolve to a window, or the window it resolves to has
		 * 			been destroyed, an exception will be thrown.
		 * @return	A Point object, holding the maximum width in its X value and maximum height in its Y value.
		 * 			Returns null if no maximum size has been defined.
		 */
		function retrieveWindowMaxSize(uid:String):Point;

		/**
		 * Returns the minimum size set via `updateWindowMinSize()`, if any.
		 *
		 * @param	uid
		 * 			The uid of a window. If it does not resolve to a window, or the window it resolves to has
		 * 			been destroyed, an exception will be thrown.
		 * @return	A Point object, holding the minimum width in its X value and minimum height in its Y value.
		 * 			Returns null if no maximum size has been defined.
		 */
		function retrieveWindowMinSize(uid:String):Point;

		/**
		 * Retrieves the title of the given window, provided the window accepts this feature.
		 * @param	uid
		 * 			The uid of a window. If it does not resolve to a window, or the window it resolves to
		 * 			has been destroyed, an exception will be thrown.
		 * @return	The custom window title, if ever set, or the default title, otherwise. The default title
		 * 			is dynamic, consisting of the application's name and version, separated by a white space.
		 * 			If the window cannot accept this setting at all - i.e., it misses the appropriate window
		 * 			style - null will be returned.
		 */
		function retrieveWindowTitle(uid:String):String;

		/**
		 * Applies the `maximized` state of the given window, provided the window accepts this feature. If the window is
		 * currently visible, the 'maximized' state is reflected immediately. If the window is currently hidden,
		 * the 'maximized' state will be applied when the window becomes visible.
		 * If the window cannot accept this setting at all - i.e., it misses the appropriate window
		 * style - nothing will happen.
		 *
		 * @param	uid
		 * 			The uid of a window. If it does not resolve to a window, or the window it resolves to
		 * 			has been destroyed, an exception will be thrown.
		 */
		function setWindowAsMaximized(uid:String):void;

		/**
		 * Shows the window with the given uid.
		 *
		 * NOTE: In other implementations out there, there is also a `unMinimize()`, or `restore()` method or similar.
		 * Our implementation DOES NOT take this approach; instead it considers all minimized windows as being hidden
		 * and viceversa - therefore, making a window visible will bring it back to its previous visible state
		 * (that is, normal or maximized).
		 *
		 * @param	uid
		 * 			The uid of the window to be shown. If it does not resolve to a window, or the window it
		 * 			resolves to has been destroyed, an exception will be thrown.
		 */
		function showWindow (uid : String) : void;

		/**
		 * Stops observing a specific window activity. You only need to call this method if you previously called
		 * the `observeWindowActivity()` method for that specific window.
		 * @param	uid
		 * 		 	The uid of a window. If it does not resolve to a window, or the window it resolves to
		 * 			has been destroyed, an exception will be thrown.
		 * @param	activity
		 * 			The specific activity you previously passed as argument to the `observeWindowActivity()` method. Must
		 * 			match one of the WindowActivity class' constants. Unknown activities given will be ignored.
		 * @param	callback
		 * 			The specific function you previously passed as argument to the `observeWindowActivity()` method.
		 */
		function stopObservingWindowActivity(uid:String, activity:int, callback:Function):void;

		/**
		 * Notifies user using default operating system's notification method (e.g., flashing the task bar on Windows, bouncing
		 * the window's icon on Macintosh).
		 * @param	uid
		 * 			The uid of the window to show notification for. If it does not resolve to a window, or the window it
		 * 			resolves to has been destroyed, an exception will be thrown.
		 */
		function triggerWindowNotification(uid:String):void;

		/**
		 * Removes the `maximized` state of the given window, provided the window accepts this feature. If the window is
		 * currently visible, the 'regular' state is reflected immediately. If the window is currently hidden,
		 * the 'regular' state will be applied when the window becomes visible.
		 * If the window cannot accept this setting at all - i.e., it misses the appropriate window
		 * style - nothing will happen.
		 *
		 * @param	uid
		 * 			The uid of a window. If it does not resolve to a window, or the window it resolves to
		 * 			has been destroyed, an exception will be thrown.
		 */
		function unsetWindowMaximized(uid:String):void;

		/**
		 * Sets the position and size of the window pointed to by the given uid. If you don't call this method,
		 * the window will attempt to measure and accomodate the content's size. This yelds most predictable
		 * results when the content has been given an explicit size.
		 *
		 * @param	uid
		 * 			The uid of a window. If it does not resolve to a window, or the window it resolves to has
		 * 			been destroyed, an exception will be thrown.
		 * @bounds	bounds
		 * 			The new boundaries, in desktop absolute coordinates, that must be applied to the window.
		 * @param	constraintToScreen
		 * 			Optional. If set, will adjust the given boundaries so that the window will stay within its
		 * 			current screen's boundary. Defaults to false.
		 */
		function updateWindowBounds(uid:String, bounds:Rectangle, constraintToScreen:Boolean = false):void;

		/**
		 * Enforces a maximum width/height for the given window.
		 *
		 * @param uid
		 * 			The uid of a window. If it does not resolve to a window, or the window it resolves to
		 * 			has been destroyed, an exception will be thrown.
		 * @param width
		 * 			The maximum width the end user will be able to resize the window to. You may still set
		 * 			the window width, from code, to any values you wish; if you want to prevent the
		 * 			user from resizing the window at all, use the appropriate style. If less than `minimum width`,
		 * 			an exception will be thrown.
		 * @param height
		 * 			The maximum height the end user will be able to resize the window to. You may still set
		 * 			the window height, from code, to any values you wish; if you want to prevent the
		 * 			user from resizing the window at all, use the appropriate style. If less than `minimum height`,
		 * 			an exception will be thrown.
		 * @param constrainToScreen
		 * 			Will adjust the given width and height values with respect to the window's current position and
		 * 			the current screen's size. In result, adjusting the window to these new dimensions will
		 * 			never cause it to cross the boundaries of the screen it's currently in. Optional, defaults to
		 * 			false.
		 */
		function updateWindowMaxSize(uid:String, width:Number, height:Number, constrainToScreen:Boolean = false):void;

		/**
		 * Enforces a minimum width/height for the given window. If the window is visible, and currently
		 * smaller than the minimum size given, it will be instantly updated, with respect to current screen`s
		 * borders.
		 *
		 * @param	uid
		 * 			The uid of a window. If it does not resolve to a window, or the window it resolves to
		 * 			has been destroyed, an exception will be thrown.
		 * @param	width
		 * 			The minimum width the end user will be able to resize the window to. You may still set
		 * 			the window width, from code, to any values you wish; if you want to prevent the
		 * 			user from resizing the window at all, use the appropriate style. If greater than `maximum width`,
		 * 			an exception will be thrown.
		 * @param	height
		 * 			The minimum height the end user will be able to resize the window to. You may still set
		 * 			the window height, from code, to any values you wish;  if you want to prevent the
		 * 			user from resizing the window at all, use the appropriate style. If greater than `maximum height`,
		 * 			an exception will be thrown.
		 * @param constrainToScreen
		 * 			Will adjust the given width and height values with respect to the window's current position and
		 * 			the current screen's size. In result, adjusting the window to these new dimensions will
		 * 			never cause it to cross the boundaries of the screen it's currently in. Optional, defaults to
		 * 			false.
		 */
		function updateWindowMinSize(uid:String, width:Number, height:Number, constrainToScreen:Boolean = false):void;

		/**
		 * Sets the status of the given window, provided the window accepts this feature.
		 *
		 * @param	uid
		 * 			The uid of a window. If it does not resolve to a window, or the window it resolves to
		 * 			has been destroyed, an exception will be thrown.
		 * @param	status
		 * 			A custom status to display. The default status is the empty string.
		 * 			Use styles to create windows without a status.
		 * 			If the window cannot accept this setting at all - i.e., it misses the appropriate window
		 * 			style - nothing will happen.
		 *
		 * @see WindowStyle
		 */
		function updateWindowStatus(uid:String, status:String):void;

		/**
		 * Sets the title of the given window, provided the window accepts this feature.
		 *
		 * @param	uid
		 * 			The uid of a window. If it does not resolve to a window, or the window it resolves to
		 * 			has been destroyed, an exception will be thrown.
		 * @param	title
		 * 			A custom title to replace the default one. The default title is the empty string.
		 * 			Use styles to create windows without a title.
		 * 			If the window cannot accept this setting at all - i.e., it misses the appropriate window
		 * 			style - nothing will happen.
		 *
		 * @see WindowStyle
		 */
		function updateWindowTitle(uid:String, title:String):void;

		/**
		 * Returns a list with all windows that are currently available and visible.
		 *
		 * @return	A (possible empty) list with all windows that are currently available and visible.
		 */
		function get visibleWindows():Vector.<String>;
	}
}
