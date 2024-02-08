package ro.ciacob.desktop.windows {
import flash.display.NativeWindow;
import flash.events.Event;

public class WindowRecordEvent extends Event {
    public static const WINDOW_READY : String = 'wre_window_ready';
    public static const BLOCKING : String = 'wre_blocking';
    public static const UNBLOCKING : String = 'wre_unblocking';

    private var _nativeWindow : NativeWindow;
    private var _windowComponent : Window;
    private var _windowUid : String;

    public function WindowRecordEvent (type : String, nativeWindow : NativeWindow, windowComponent : Window, windowUid : String) {
        super (type, false, true);
        _nativeWindow = nativeWindow;
        _windowComponent = windowComponent;
        _windowUid = windowUid;
    }


    public function get nativeWindow():NativeWindow {
        return _nativeWindow;
    }

    public function get windowComponent():Window {
        return _windowComponent;
    }

    public function get windowUid():String {
        return _windowUid;
    }

    override public function clone () : Event {
        return new WindowRecordEvent(type, _nativeWindow, _windowComponent, _windowUid);
    }
}
}
