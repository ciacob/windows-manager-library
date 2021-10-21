package ro.ciacob.desktop.windows {
	import flash.display.Screen;

	/**
	 * Represents the root IUIComponent implementor that delivers content to a window managed by the windows manager.
	 * The prefered implementation composes a new instance of WindowContentBehavior within the implementor, and delegates
	 * to it all the methods exposed by this interface.
	 */
	public interface IWindowContent {
		
		/**
		 * Returns the UID of the window owning this content. The windows manager assigns unique IDs to all windows upon creation,
		 * and manipulates them by mean of these IDS. Will return `null` if the owner window has been destroyed (or, in other words,
		 * `windowUid` will be `null` for orphaned content).
		 * @readonly
		 */
		function get windowUid () : String;
		
		/**
		 * Returns the screen this content is, or was displayed onto. Returns null if this content was never displayed (e.g., if the
		 * windows holding this content has been created, but never shown).
		 * @readonly
		 */
		function get homeScreen () : Screen;
		
		/**
		 * Returns the horizontal position of this content across the joined space of all screens in use. For instance, it will return
		 * `1920` for a content held by a window which is placed at (0, 0) on the second monitor on the right, on a two, side-by-side
		 * Full HD monitors setup. The offset of the window chrome, if any, is also taken into account. Returns `NaN` for orphaned content
		 * (content not assigned to a window, or assigned to a window that has been destroyed meanwhile).
		 * @readonly
		 */
		function get allScreensX () : Number;
		
		/**
		 * @see `allScreensX`
		 * @readonly
		 */
		function get allScreensY () : Number;
		
		/**
		 * Returns the horizontal position of this content within the screen its left boundary is laid on. For instance, it will return
		 * `0` (rather than `1920`) for a content held by a window which is placed at (0, 0) on the second monitor on the right,
		 * on a two, side-by-side Full HD monitors setup. The offset of the window chrome, if any, is also taken into account.
		 *  Returns `NaN` for orphaned content (content not assigned to a window, or assigned to a window that has been destroyed meanwhile).
		 * @readonly
		 */
		function get currentScreensX () : Number;
		
		/**
		 * @see `currentScreensX`
		 * @readonly
		 */
		function get currentScreensY () : Number;
		
		/**
		 * Sends an instance of the windows manager owner into this implementor (required for performing various calculations).
		 */
		function set manager (value : IWindowsManager) : void;

		/**
		 * Retrieves the windows manager instance previously sent into this implementor.
		 */
		function get manager () : IWindowsManager;
		
	}
}