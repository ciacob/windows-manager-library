package ro.ciacob.desktop.windows {
	import flash.display.Screen;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	import ro.ciacob.utils.ScreenUtils;

	/**
	 * Class to be composed into all IWindowContent implementors. Uses `WindowManager` as the `IWindowManager` implementor.
	 * @see IWindowContent
	 */
	public class WindowContentBehavior implements IWindowContent {
		
		private var _windowsManager : WindowsManager;
		private var _client : UIComponent;
		
		public function WindowContentBehavior (client : UIComponent) {
			_client = client;
		}

		public function get windowUid () : String {
			var windowOfClient : Window = (Window.getWindow (_client) as Window);
			if (windowOfClient != null) {
				return _windowsManager.getUidByWindow (windowOfClient);
			}
			return null;
		}

		public function get homeScreen () : flash.display.Screen {
			var uid : String = windowUid;
			if (uid != null) {
				var bounds : Rectangle = _windowsManager.retrieveWindowBounds (uid);
				if (bounds != null) {
					var topLeft : Point = new Point (bounds.x, bounds.y); 
					return ScreenUtils.getScreenForPoint (topLeft);
				}
			}
			return null;
		}
		
		public function get allScreensX () : Number {
			var uid : String = windowUid;
			if (uid != null) {
				var bounds : Rectangle = _windowsManager.retrieveWindowBounds (uid);
				return (_client.x + bounds.x);
			}
			return NaN;
		}
		
		public function get allScreensY () : Number {
			var uid : String = windowUid;
			if (uid != null) {
				var bounds : Rectangle = _windowsManager.retrieveWindowBounds (uid);
				return (_client.y + bounds.y);
			}
			return NaN;
		}
		
		public function get currentScreensX () : Number {
			var uid : String = windowUid;
			if (uid != null) {
				var currScreen : flash.display.Screen = homeScreen;
				if (currScreen != null) {
					var winBounds : Rectangle = _windowsManager.retrieveWindowBounds (uid);
					var screenBounds : Rectangle = homeScreen.bounds;
					return (_client.x + winBounds.x - screenBounds.x);
				}
			}
			return NaN;
		}

		public function get currentScreensY () : Number {
			var uid : String = windowUid;
			if (uid != null) {
				var currScreen : flash.display.Screen = homeScreen;
				if (currScreen != null) {
					var winBounds : Rectangle = _windowsManager.retrieveWindowBounds (uid);
					var screenBounds : Rectangle = homeScreen.bounds;
					return (_client.y + winBounds.y - screenBounds.y);
				}
			}
			return NaN;
		}
		
		public function set manager (value : IWindowsManager) : void {
			_windowsManager = (value as WindowsManager);
		}
		
		public function get manager () : IWindowsManager {
			return _windowsManager;
		}
	}
}