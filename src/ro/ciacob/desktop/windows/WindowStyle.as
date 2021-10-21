package ro.ciacob.desktop.windows {
	public final class WindowStyle {

		//------------------
		// INDIVIDUAL FLAGS
		//------------------
		
		/**
		 * "Base ground" style to build upon. Implied in all the other styles, only meaningful "per se".
		 */
		public static const WINDOW_BASE : int = 0;
		
		/**
		 * Attempts to controll whether the new window will have a header, which usually includes (at least)
		 * a title and a `close` button.
		 */
		public static const HEADER : int = 1;
		
		/**
		 * Attempts to controll whether the new window will have a status bar.
		 */
		public static const FOOTER : int = 2;
		
		/**
		 * Attempts to controll whether the new window will show in the status bar.
		 */
		public static const TASKBAR : int = 4;
		
		/**
		 * Attempts to controll whether the new window will be transparent.
		 */
		public static const TRANSPARENT : int = 16;
		
		/**
		 * Attempts to controll whether the new window will be minimizable by the end-user.
		 */
		public static const MINIMIZE : int = 32;
		
		/**
		 * Attempts to controll whether the new window will be maximizable by the end-user.
		 */
		public static const MAXIMIZE : int = 64;
		
		/**
		 * Attempts to controll whether the new window will be resizable by the end-user.
		 */
		public static const RESIZE : int = 128;
		
		/**
		 * Attempts to controll whether the new window will lock itself to the top of the windows stack.
		 */
		public static const TOP : int = 256;
		
		//---------
		// PRESETS
		//---------
		
		/**
		 * Shortcut for HEADER | FOOTER | TASKBAR | MINIMIZE | MAXIMIZE | RESIZE. Creates a type of window
		 * that is most commonly used for "main windows".
		 */
		public static const MAIN : int = (HEADER | FOOTER | TASKBAR | MINIMIZE | MAXIMIZE | RESIZE);

		/**
		 * A variation of `MAIN`, that lacks the footer (typically containing a "status bar"). Also commonly used for 
		 * "main windows".
		 */
		public static const MAIN_NO_FOOTER : int = (HEADER | TASKBAR | MINIMIZE | MAXIMIZE | RESIZE);
		
		/**
		 * Alias for HEADER. Creates a type of window suitable for alerts, confirmations, etc.
		 */
		public static const PROMPT : int = HEADER;
		
		/**
		 * Shortcut for HEADER | RESIZE. Creates a window type that is commonly used for floating tool panels
		 * in applications.
		 */
		public static const TOOL : int = (HEADER | RESIZE);
		
		/**
		 * Shortcut for TRANSPARENT | TOP. Creates a transparent, "always in front" window container. You are responsible 
		 * for providing visible content, as well as a way for manipulating the window. Pop-ups of various sorts are the
		 * typical candidates for this type.
		 */
		public static const BLANK : int = TRANSPARENT | TOP;
	}
}
