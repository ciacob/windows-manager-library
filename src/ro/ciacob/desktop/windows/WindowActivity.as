package ro.ciacob.desktop.windows {

	public class WindowActivity {

		/**
		 * The window is just about to be destroyed by the user
		 * (e.g., via the `x` button or the keyboard equivalent).
		 *
		 * This activity is cancellable, meaning that, if user
		 * returns `false` in the callback registered to this
		 * particular window activity, the action of closing the
		 * window will not take place.
		 */
		public static const BEFORE_DESTROY:int = 2;

		/**
		 * The window has just been `blured` by the user, while previously `focused` (e.g., via a mouse click or keyboard equivalent on another window or the desktop).
		 */
		public static const BLUR:int = 11;

		/**
		 * The window has just been destroyed by the user (e.g., via the `x` button or the keyboard equivalent).
		 */
		public static const DESTROY:int = 3;

		/**
		 * The window has just been `focused` by the user, while previously `blured` (e.g., via a mouse click or keyboard equivalent).
		 */
		public static const FOCUS:int = 10;

		/**
		 * The window has just been hidden by the user (e.g., via the `_` button or the keyboard equivalent).
		 */
		public static const HIDE:int = 4;

		/**
		 * The window has just `maximized` by the user (e.g., via the `[]` button or the keyboard equivalent).
		 */
		public static const MAXIMIZE:int = 5;

		/**
		 * The window has just been moved by the user (e.g., via dragging or the keyboard equivalent).
		 */
		public static const MOVE:int = 6;

		/**
		 * The window has just been resized by the user (e.g., via dragging or the keyboard equivalent).
		 */
		public static const RESIZE:int = 7;

		/**
		 * The window has just been made visible by the user (e.g., via the task bar button or the keyboard equivalent).
		 */
		public static const SHOW:int = 8;

		/**
		 * The window has just been `restored down` by the user, while previously `maximized` (e.g., via the `[]]` button or the keyboard equivalent).
		 */
		public static const UNMAXIMIZE:int = 9;
	}
}
