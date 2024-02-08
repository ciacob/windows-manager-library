package ro.ciacob.desktop.windows {
import flash.display.NativeWindow;
import flash.events.Event;

public class WindowsManagerEvent extends Event {
    public static const MAIN_WINDOW_AVAILABLE : String = 'wme_main_window_available';
    public static const MAIN_WINDOW_BLOCKED : String = 'wme_main_window_blocked';
    public static const MAIN_WINDOW_UNBLOCKED : String = 'wme_main_window_unblocked';

    private var _nativeWindow : NativeWindow;


    public function WindowsManagerEvent(type : String, nativeWindow : NativeWindow) {
        super (type, false, true);
        _nativeWindow = nativeWindow;
    }

    override public function clone () : Event {
        return new WindowsManagerEvent(type, _nativeWindow);
    }

    public function get nativeWindow():NativeWindow {
        return _nativeWindow;
    }
}
}
