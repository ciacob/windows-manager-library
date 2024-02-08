package ro.ciacob.desktop.windows {
	import flash.display.Screen;	
	import mx.containers.Canvas;
	import mx.core.ScrollPolicy;

	public class BasicWindowRootContainer extends Canvas implements IWindowContent {
		private var _delegate : WindowContentBehavior;
		
		public function BasicWindowRootContainer () {
			super();
			_delegate = new WindowContentBehavior (this);
			clipContent = false;
			horizontalScrollPolicy = ScrollPolicy.OFF;
			verticalScrollPolicy = ScrollPolicy.OFF;
		}
		
		public function get homeScreen () : Screen {
			return _delegate.homeScreen;
		}
		
		public function get windowUid ():String {
			return _delegate.windowUid;
		}
		
		public function get allScreensX () : Number {
			return _delegate.allScreensX;
		}
		
		public function get allScreensY () : Number {
			return _delegate.allScreensY;
		}
		
		public function get currentScreensX () : Number {
			return _delegate.currentScreensX;
		}
		
		public function get currentScreensY () : Number {
			return _delegate.currentScreensY;
		}
		
		public function set manager (value : IWindowsManager) : void {
			_delegate.manager = value;
		}
		
		public function get manager () : IWindowsManager {
			return _delegate.manager;
		}
	}
}