package ro.ciacob.desktop.windows {

import flash.desktop.NativeApplication;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.NativeWindow;
import flash.display.NativeWindowDisplayState;
import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowResize;
import flash.display.NativeWindowSystemChrome;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.NativeWindowBoundsEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.Capabilities;

import mx.controls.Button;
import mx.controls.FlexNativeMenu;
import mx.controls.scrollClasses.ScrollThumb;
import mx.core.ClassFactory;
import mx.core.ContainerCreationPolicy;
import mx.core.EdgeMetrics;
import mx.core.FlexGlobals;
import mx.core.FlexShape;
import mx.core.IFactory;
import mx.core.IWindow;
import mx.core.LayoutContainer;
import mx.core.ScrollPolicy;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.AIREvent;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.FlexNativeWindowBoundsEvent;
import mx.events.WindowExistenceEvent;
import mx.managers.CursorManagerImpl;
import mx.managers.FocusManager;
import mx.managers.IActiveWindowManager;
import mx.managers.ICursorManager;
import mx.managers.ISystemManager;
import mx.managers.SystemManagerGlobals;
import mx.managers.WindowedSystemManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleProxy;

import ro.ciacob.utils.OSFamily;

use namespace mx_internal;

[Event(type="flash.events.Event", name="windowOpen")]
[Event(type="flash.events.Event", name="windowReady")]

/**
 *  Dispatched when this application gets activated.
 *  @eventType mx.events.AIREvent.APPLICATION_ACTIVATE
 */
[Event(name="applicationActivate", type="mx.events.AIREvent")]

/**
 *  Dispatched when this application gets deactivated.
 *  @eventType mx.events.AIREvent.APPLICATION_DEACTIVATE
 */
[Event(name="applicationDeactivate", type="mx.events.AIREvent")]

/**
 *  Dispatched after the window has been activated.
 *  @eventType mx.events.AIREvent.WINDOW_ACTIVATE
 */
[Event(name="windowActivate", type="mx.events.AIREvent")]

/**
 *  Dispatched after the window has been deactivated.
 *  @eventType mx.events.AIREvent.WINDOW_DEACTIVATE
 */
[Event(name="windowDeactivate", type="mx.events.AIREvent")]

/**
 *  Dispatched after the window has been closed.
 *  @eventType flash.events.Event.CLOSE
 *  @see flash.display.NativeWindow
 */
[Event(name="close", type="flash.events.Event")]

/**
 *  Dispatched before the window closes.
 *  This event is cancelable.
 *
 *  @eventType flash.events.Event.CLOSING
 *  @see flash.display.NativeWindow
 */
[Event(name="closing", type="flash.events.Event")]

/**
 *  Dispatched after the display state changes
 *  to minimize, maximize or restore.
 *
 *  @eventType flash.events.NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE
 */
[Event(name="displayStateChange", type="flash.events.NativeWindowDisplayStateEvent")]

/**
 *  Dispatched before the display state changes
 *  to minimize, maximize or restore.
 *
 *  @eventType flash.events.NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING
 */
[Event(name="displayStateChanging", type="flash.events.NativeWindowDisplayStateEvent")]

/**
 *  Dispatched before the window moves,
 *  and while the window is being dragged.
 *
 *  @eventType flash.events.NativeWindowBoundsEvent.MOVING
 */
[Event(name="moving", type="flash.events.NativeWindowBoundsEvent")]

/**
 *  Dispatched when the computer connects to or disconnects from the network.
 *
 *  @eventType flash.events.Event.NETWORK_CHANGE
 */
[Event(name="networkChange", type="flash.events.Event")]

/**
 *  Dispatched before the underlying NativeWindow is resized, or
 *  while the Window object boundaries are being dragged.
 *
 *  @eventType flash.events.NativeWindowBoundsEvent.RESIZING
 */
[Event(name="resizing", type="flash.events.NativeWindowBoundsEvent")]

/**
 *  Dispatched when the Window completes its initial layout
 *  and opens the underlying NativeWindow.
 *
 *  @eventType mx.events.AIREvent.WINDOW_COMPLETE
 */
[Event(name="windowComplete", type="mx.events.AIREvent")]

/**
 *  Dispatched after the window moves.
 *  @eventType mx.events.FlexNativeWindowBoundsEvent.WINDOW_MOVE
 */
[Event(name="windowMove", type="mx.events.FlexNativeWindowBoundsEvent")]

/**
 *  Dispatched after the underlying NativeWindow is resized.
 *  @eventType mx.events.FlexNativeWindowBoundsEvent.WINDOW_RESIZE
 */
[Event(name="windowResize", type="mx.events.FlexNativeWindowBoundsEvent")]

/**
 *  Position of buttons in title bar. Possible values: "left",
 *  "right", "auto".
 *
 *  A value of "left" means the buttons are aligned
 *  at the left of the title bar.
 *  A value of "right" means the buttons are aligned
 *  at the right of the title bar.
 *  A value of "auto" means the buttons are aligned
 *  at the left of the title bar on Mac OS and on the
 *  right on Windows.
 *
 *  @default "auto"
 */
[Style(name="buttonAlignment", type="String", enumeration="left,right,auto", inherit="yes")]

/**
 *  Defines the distance between the titleBar buttons.
 *  @default 2
 */
[Style(name="buttonPadding", type="Number", inherit="yes")]

/**
 *  Skin for close button when using Flex chrome.
 *  @default mx.skins.halo.WindowCloseButtonSkin
 */
[Style(name="closeButtonSkin", type="Class", inherit="no", states="up, over, down, disabled")]

/**
 *  The extra space around the gripper. The total area of the gripper
 *  plus the padding around the edges is the hit area for the gripper resizing.
 *
 *  @default 3
 */
[Style(name="gripperPadding", type="Number", format="Length", inherit="no")]

/**
 *  Style declaration for the skin of the gripper.
 *
 *  @default "gripperStyle"
 */
[Style(name="gripperStyleName", type="String", inherit="no")]

/**
 *  The explicit height of the header. If this style is not set, the header
 *  height is calculated from the largest of the text height, the button
 *  heights, and the icon height.
 *
 *  @default undefined
 */
[Style(name="headerHeight", type="Number", format="Length", inherit="no")]

/**
 *  Skin for maximize button when using Flex chrome.
 *
 *  @default mx.skins.halo.WindowMaximizeButtonSkin
 */
[Style(name="maximizeButtonSkin", type="Class", inherit="no", states="up, over, down, disabled")]

/**
 *  Skin for minimize button when using Flex chrome.
 *
 *  @default mx.skins.halo.WindowMinimizeButtonSkin
 */
[Style(name="minimizeButtonSkin", type="Class", inherit="no", states="up, over, down, disabled")]

/**
 *  Skin for restore button when using Flex chrome.
 *  This style is ignored for Mac OS.
 *
 *  @default mx.skins.halo.WindowRestoreButtonSkin
 */
[Style(name="restoreButtonSkin", type="Class", inherit="no", states="up, over, down, disabled")]

/**
 *  Determines whether the window draws its own Flex Chrome or depends on the developer
 *  to draw chrome. Changing this style once the window is open has no effect.
 *
 *  @default true
 */
[Style(name="showFlexChrome", type="Boolean", inherit="no")]

/**
 *  The colors used to draw the status bar.
 *  @default 0xC0C0C0
 */
[Style(name="statusBarBackgroundColor", type="uint", format="Color", inherit="yes")]

/**
 *  The status bar background skin.
 *  @default mx.skins.halo.StatusBarBackgroundSkin
 */
[Style(name="statusBarBackgroundSkin", type="Class", inherit="yes")]

/**
 *  Style declaration for the status text.
 *  @default undefined
 */
[Style(name="statusTextStyleName", type="String", inherit="yes")]

/**
 *  Position of the title in title bar.
 *  The possible values are "left",
 *  "center", "auto"
 *
 *  A value of "left" means the title is aligned
 *  at the left of the title bar.
 *  A value of "center" means the title is aligned
 *  at the center of the title bar.
 *  A value of "auto" means the title is aligned
 *  at the left on Windows and at the center on Mac OS.
 *
 *  @default "auto"
 */
[Style(name="titleAlignment", type="String", enumeration="left,center,auto", inherit="yes")]

/**
 *  The title background skin.
 *  @default mx.skins.halo.ApplicationTitleBarBackgroundSkin
 */
[Style(name="titleBarBackgroundSkin", type="Class", inherit="yes")]

/**
 *  The distance between the furthest out title bar button and the
 *  edge of the title bar.
 *  @default 5
 */
[Style(name="titleBarButtonPadding", type="Number", inherit="true")]

/**
 *  An array of two colors used to draw the header.
 *  The first color is the top color.
 *  The second color is the bottom color.
 *  The default values are undefined, which
 *  makes the header background the same as the
 *  panel background.
 *
 *  @default [ 0x000000, 0x000000 ]
 */
[Style(name="titleBarColors", type="Array", arrayType="uint", format="Color", inherit="yes")]

/**
 *  The style name for the title text.
 *  @default undefined
 */
[Style(name="titleTextStyleName", type="String", inherit="yes")]

/**
 *  Played when the window is closed.
 */
[Effect(name="closeEffect", event="windowClose")]

/**
 *  Played when the component is minimized.
 */
[Effect(name="minimizeEffect", event="windowMinimize")]

/**
 *  Played when the component is unminimized.
 */
[Effect(name="unminimizeEffect", event="windowUnminimize")]

[Exclude(name="moveEffect", kind="effect")]

/**
 *  The frameworks must be initialized by SystemManager.
 *  This factoryClass will be automatically subclassed by any
 *  MXML applications that don't explicitly specify a different
 *  factoryClass.
 */
[Frame(factoryClass="mx.managers.WindowedSystemManager")]

/**
 *  The Window is a top-level container for additional windows
 *  in an AIR desktop application.
 *
 *  The Window container is a special kind of container in the sense
 *  that it cannot be used within other layout containers. An mx:Window
 *  component must be the top-level component in its MXML document.
 *
 *  The easiest way to use a Window component to define a native window is to
 *  create an MXML document with an <mx:Window> tag as the top-level tag in
 *  the document. You use the Window component just as you do any other container,
 *  including specifying the layout type, defining child controls, and so forth.
 *  Like any other custom MXML component, when your application is compiled your
 *    MXML document is compiled into a custom class that is a subclass of the Window
 *  component.
 *
 *  In your application code, to make an instance of your Window subclass appear
 *  on the screen you first create an instance of the class in code (by defining a
 *  variable and calling the "new MyWindowClass()" constructor. Next you set any
 *    properties you wish to specify for the new window. Finally you call your Window
 *  component's "open()" method to open the window on the screen.
 *
 *  Note that several of the Window class's properties can only be set BEFORE calling
 *  the "open()" method to open the window. Once the underlying NativeWindow is created,
 *    these initialization properties can be read but cannot be changed. This restriction
 *  applies to the following properties:
 *
 *  - maximizable
 *  - minimizable
 *  - resizable
 *  - systemChrome
 *  - transparent
 *  - type
 *
 *  @see mx.core.WindowedApplication
 */
public class Window extends LayoutContainer implements IWindow {
    public static const WINDOW_OPEN:String = 'windowOpen';
    public static const WINDOW_READY:String = 'windowReady';

    /**
     *  The default height for a window
     */
    public static const DEFAULT_WINDOW_HEIGHT:Number = 45;

    /**
     *  The default width for a window
     */
    public static const DEFAULT_WINDOW_WIDTH:Number = 158;

    /**
     *  Returns the Window to which a component is parented.
     *
     *  @param component the component whose Window you wish to find.
     *
     *  @return The Window to which a component is parented.
     *
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function getWindow(component:UIComponent):IWindow {
        if (component.systemManager is WindowedSystemManager) {
            return WindowedSystemManager(component.systemManager).window;
        }
        return null;
    }

    /**
     *  Constructor.
     *
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function Window() {
        super();
        _onPreinitialize();
        addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
        addEventListener(FlexEvent.PREINITIALIZE, preinitializeHandler);
        invalidateProperties();
    }

    internal var _canFitContent:Boolean = true;

    private var _firstChild:UIComponent;
    private var _isContentFitScheduled:Boolean;
    private var _nativeWindow:NativeWindow;
    private var _windowBounds:Rectangle;
    private var _flagForOpen:Boolean = false;
    private var _nativeWindowVisible:Boolean = true;
    private var _maximized:Boolean = false;
    private var _cursorManager:ICursorManager;
    private var _toMax:Boolean = false;
    private var _currentlyResizing:Boolean;

    /**
     *  Ensures that the Window has finished drawing
     *  before it becomes visible.
     */
    private var _frameCounter:int = 0;

    /**
     * Provides read only access to the internal frame counter.
     * It's value will be less than `2` if the windows isn't
     * "ready" yet,`2` or more otherwise.
     */
    public function get $frameCounter():int {
        return _frameCounter;
    }

    private var gripper:Button;
    private var gripperHit:Sprite;
    private var openActive:Boolean = true;

    private var oldX:Number;
    private var oldY:Number;
    private var resizeHandlerAdded:Boolean = false;

    /**
     *  This flag indicates whether the width of the Application instance
     *  can change or has been explicitly set by the developer.
     *  When the stage is resized we use this flag to know whether the
     *  width of the Application should be modified.
     */
    private var resizeWidth:Boolean = true;

    /**
     *  This flag indicates whether the height of the Application instance
     *  can change or has been explicitly set by the developer.
     *  When the stage is resized we use this flag to know whether the
     *  height of the Application should be modified.
     */
    private var resizeHeight:Boolean = true;

    /**
     * Whether to draw an opaque background underneath the content area of the
     * window (the header and footer must draw their own background).
     */
    private var _drawContentBackground:Boolean;

    protected function get isWinMaximized():Boolean {
        return (_nativeWindow && !_nativeWindow.closed &&
                _nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED);
    }

    public function set drawContentBackground(value:Boolean):void {
        if (_drawContentBackground != value) {
            _drawContentBackground = value;
            invalidateDisplayList();
        }
    }

    [Bindable("heightChanged")]
    [Inspectable(category="General")]
    [PercentProxy("percentHeight")]
    override public function get height():Number {
        return _bounds.height;
    }

    /**
     *  Also sets the stage's height.
     */
    override public function set height(value:Number):void {
        if (value < minHeight) {
            value = minHeight;
        } else if (value > maxHeight) {
            value = maxHeight;
        }
        _bounds.height = value;
        boundsChanged = true;
        invalidateProperties();
        invalidateSize();
        invalidateViewMetricsAndPadding();

        // Note: also dispatched in the resizeHandler
        dispatchEvent(new Event("heightChanged"));
    }

    /**
     *  Storage for the maxHeight property.
     */
    private var _maxHeight:Number = 2880;

    /**
     *  Keeps track of whether maxHeight property changed, so we can
     *  handle it in commitProperties.
     */
    private var maxHeightChanged:Boolean = false;

    [Bindable("maxHeightChanged")]
    [Bindable("windowComplete")]
    override public function get maxHeight():Number {
        if (nativeWindow && !maxHeightChanged) {
            return nativeWindow.maxSize.y - chromeHeight();
        } else {
            return _maxHeight;
        }
    }

    /**
     *  Specifies the maximum height of the application's window.
     *  @default dependent on the operating system and the AIR systemChrome setting.
     */
    override public function set maxHeight(value:Number):void {
        _maxHeight = value;
        maxHeightChanged = true;
        invalidateProperties();
    }

    /**
     *  Storage for the maxWidth property.
     */
    private var _maxWidth:Number = 2880;

    /**
     *  Keeps track of whether maxWidth property changed so we can
     *  handle it in commitProperties.
     */
    private var maxWidthChanged:Boolean = false;

    [Bindable("maxWidthChanged")]
    [Bindable("windowComplete")]
    override public function get maxWidth():Number {
        if (nativeWindow && !maxWidthChanged) {
            return nativeWindow.maxSize.x - chromeWidth();
        } else {
            return _maxWidth;
        }
    }

    /**
     *  Specifies the maximum width of the application's window.
     *  @default dependent on the operating system and the AIR systemChrome setting.
     */
    override public function set maxWidth(value:Number):void {
        _maxWidth = value;
        maxWidthChanged = true;
        invalidateProperties();
    }

    private var _minHeight:Number = 0;

    /**
     *  Keeps track of whether minHeight property changed so we can
     *  handle it in commitProperties.
     */
    private var minHeightChanged:Boolean = false;


    /**
     *  Specifies the minimum height of the application's window.
     *  @default dependent on the operating system and the AIR systemChrome setting.
     */
    [Bindable("minHeightChanged")]
    [Bindable("windowComplete")]
    override public function get minHeight():Number {
        if (nativeWindow && !minHeightChanged) {
            return nativeWindow.minSize.y - chromeHeight();
        } else {
            return _minHeight;
        }
    }

    override public function set minHeight(value:Number):void {
        _minHeight = value;
        minHeightChanged = true;
        invalidateProperties();
    }

    /**
     *  Storage for the minWidth property.
     */
    private var _minWidth:Number = 0;

    /**
     *  Keeps track of whether minWidth property changed so we can
     *  handle it in commitProperties.
     */
    private var minWidthChanged:Boolean = false;


    /**
     *  Specifies the minimum width of the application's window.
     *  @default dependent on the operating system and the AIR systemChrome setting.
     */
    [Bindable("minWidthChanged")]
    [Bindable("windowComplete")]
    override public function get minWidth():Number {
        if (nativeWindow && !minWidthChanged) {
            return nativeWindow.minSize.x - chromeWidth();
        } else {
            return _minWidth;
        }
    }

    override public function set minWidth(value:Number):void {
        _minWidth = value;
        minWidthChanged = true;
        invalidateProperties();
    }


    /**
     *  Controls the window's visibility. Unlike the
     *  UIComponent.visible property of most Flex
     *  visual components, this property affects the visibility
     *  of the underlying NativeWindow (including operating system
     *  chrome) as well as the visibility of the Window's child
     *  controls.
     *
     *  When this property changes, Flex dispatches a show
     *  or hide event.
     *
     *  @default true
     */
    [Bindable("hide")]
    [Bindable("show")]
    [Bindable("windowComplete")]
    override public function get visible():Boolean {
        if (nativeWindow && nativeWindow.closed) {
            return false;
        }
        if (nativeWindow) {
            return nativeWindow.visible;
        } else {
            return _nativeWindowVisible;
        }
    }

    override public function set visible(value:Boolean):void {
        setVisible(value);
    }

    /**
     *  We override setVisible because there's the flash display object concept
     *  of visibility and also the nativeWindow concept of visibility.
     */
    override public function setVisible(value:Boolean, noEvent:Boolean = false):void {
        if (!_nativeWindow) {
            _nativeWindowVisible = value;
            invalidateProperties();
        } else if (!_nativeWindow.closed) {
            if (value) {
                _nativeWindow.visible = value;
            } else {
                if (getStyle("hideEffect") && initialized && $visible != value) {
                    addEventListener(EffectEvent.EFFECT_END, hideEffectEndHandler);
                } else {
                    _nativeWindow.visible = value;
                }
            }
        }
        super.setVisible(value, noEvent);
    }

    [Bindable("widthChanged")]
    [Inspectable(category="General")]
    [PercentProxy("percentWidth")]
    override public function get width():Number {
        return _bounds.width;
    }

    /**
     *  Note: also sets the stage's width.
     */
    override public function set width(value:Number):void {
        if (value < minWidth) {
            value = minWidth;
        } else if (value > maxWidth) {
            value = maxWidth;
        }
        _bounds.width = value;
        boundsChanged = true;
        invalidateProperties();
        invalidateSize();
        invalidateViewMetricsAndPadding();

        // Note: also dispatched in the resize handler
        dispatchEvent(new Event("widthChanged"));
    }

    /**
     * Note: since the header covers the solid portion of the border,
     * we need to use the larger of borderThickness or headerHeight.
     */
    override public function get viewMetrics():EdgeMetrics {
        var bm:EdgeMetrics = super.viewMetrics;
        var vm:EdgeMetrics = new EdgeMetrics(bm.left, bm.top, bm.right, bm.bottom);
        if (showTitleBar) {
            var hHeight:Number = getHeaderHeight();
            if (!isNaN(hHeight)) {
                vm.top += hHeight;
            }
        }
        if (showStatusBar) {
            var sHeight:Number = getStatusBarHeight();
            if (!isNaN(sHeight)) {
                vm.bottom += sHeight;
            }
        }
        return vm;
    }

    /**
     *  Storage for the alwaysInFront property.
     */
    private var _alwaysInFront:Boolean = false;

    /**
     *  Determines whether the underlying NativeWindow is always in front
     *  of other windows (including those of other applications). Setting
     *  this property sets the alwaysInFront property of the
     *  underlying NativeWindow. See the NativeWindow.alwaysInFront
     *  property description for details of how this affects window stacking
     *  order.
     *
     *  @see flash.display.NativeWindow#alwaysInFront
     */
    public function get alwaysInFront():Boolean {
        if (_nativeWindow && !_nativeWindow.closed) {
            return nativeWindow.alwaysInFront;
        } else {
            return _alwaysInFront;
        }
    }

    public function set alwaysInFront(value:Boolean):void {
        _alwaysInFront = value;
        if (_nativeWindow && !_nativeWindow.closed) {
            nativeWindow.alwaysInFront = value;
        }
    }

    /**
     *  Storage for the bounds property.
     */
    private var _bounds:Rectangle = new Rectangle(0, 0, DEFAULT_WINDOW_WIDTH, DEFAULT_WINDOW_HEIGHT);

    private var boundsChanged:Boolean = false;

    /**
     *  A Rectangle specifying the window's bounds
     *  relative to the screen.
     */
    protected function get bounds():Rectangle {
        return _bounds;
    }

    protected function set bounds(value:Rectangle):void {
        _bounds = value;
        boundsChanged = true;
        invalidateProperties();
        invalidateSize();
        invalidateViewMetricsAndPadding();
    }

    /**
     *  A flag indicating whether the window has been closed.
     */
    public function get closed():Boolean {
        return nativeWindow.closed;
    }

    /**
     *  Storage for the maximizable property.
     */
    private var _maximizable:Boolean = true;

    /**
     *  Specifies whether the window can be maximized.
     *  This property's value is read-only after the window
     *  has been opened.
     */
    public function get maximizable():Boolean {
        return _maximizable;
    }

    public function set maximizable(value:Boolean):void {
        if (!_nativeWindow) {
            _maximizable = value;
            invalidateProperties();
        }
    }

    /**
     *  Storage for the menu property.
     */
    private var _menu:FlexNativeMenu;

    /**
     *  Returns the cursor manager for this Window.
     */
    override public function get cursorManager():ICursorManager {
        return _cursorManager;
    }

    private var menuChanged:Boolean = false;

    public function get menu():FlexNativeMenu {
        return _menu;
    }

    /**
     *  The window menu for this window.
     *  Some operating systems do not support window menus,
     *  in which case this property is ignored.
     */
    public function set menu(value:FlexNativeMenu):void {
        if (_menu) {
            _menu.automationParent = null;
            _menu.automationOwner = null;
        }
        _menu = value;
        menuChanged = true;
        if (_menu) {
            menu.automationParent = this;
            menu.automationOwner = this;
        }
    }

    /**
     *  Storage for the minimizable property.
     */
    private var _minimizable:Boolean = true;

    /**
     * Storage for the windowOwner property
     */
    private var _windowOwner:IWindow;

    /**
     *  Specifies whether the window can be minimized.
     *  This property is read-only after the window has
     *  been opened.
     */
    public function get minimizable():Boolean {
        return _minimizable;
    }

    public function set minimizable(value:Boolean):void {
        if (!_nativeWindow) {
            _minimizable = value;
            invalidateProperties();
        }
    }

    /**
     * Specifies this component's window owner.
     *
     * This property is read-only once the window has been opened.
     * The default value is null.
     * When a window has an owner, that window is always displayed in front
     * of its owner, is minimized and hidden along with its owner, and closes when
     * its owner closes.
     */
    public function get windowOwner():IWindow {
        return _windowOwner;
    }

    public function set windowOwner(value:IWindow):void {
        if (!_nativeWindow) {
            _windowOwner = value;
            invalidateProperties();
        }
    }

    /**
     *  The underlying NativeWindow that this Window component uses.
     */
    public function get nativeWindow():NativeWindow {
        if (systemManager && systemManager.stage) {
            return systemManager.stage.nativeWindow;
        }
        return null;
    }

    /**
     *  Storage for the resizable property.
     */
    private var _resizable:Boolean = true;

    /**
     *  Specifies whether the window can be resized.
     *  This property is read-only after the window
     *  has been opened.
     */
    public function get resizable():Boolean {
        return _resizable;
    }

    public function set resizable(value:Boolean):void {
        if (!_nativeWindow) {
            _resizable = value;
            invalidateProperties();
        }
    }

    /**
     *  Storage for the showGripper property.
     */
    private var _showGripper:Boolean = true;

    private var showGripperChanged:Boolean = true;

    /**
     *  If true, the gripper is visible.
     *
     *  On Mac OS, a window with systemChrome
     *  set to "standard"
     *  always has an operating system gripper, so this property is ignored
     *  in that case.
     *
     *  @default true
     */
    public function get showGripper():Boolean {
        return _showGripper;
    }

    public function set showGripper(value:Boolean):void {
        if (_showGripper == value) {
            return;
        }
        _showGripper = value;
        showGripperChanged = true;
        invalidateProperties();
        invalidateDisplayList();
    }

    /**
     *  Storage for the showStatusBar property.
     */
    private var _showStatusBar:Boolean = true;

    private var showStatusBarChanged:Boolean = true;

    /**
     *  If true, the status bar is visible.
     *  @default true
     */
    public function get showStatusBar():Boolean {
        return _showStatusBar;
    }

    public function set showStatusBar(value:Boolean):void {
        if (_showStatusBar == value) {
            return;
        }
        _showStatusBar = value;
        showStatusBarChanged = true;
        invalidateProperties();
        invalidateDisplayList();
    }

    /**
     *  Storage for the showTitleBar property.
     */
    private var _showTitleBar:Boolean = true;
    private var showTitleBarChanged:Boolean = true;

    /**
     *  If true, the window's title bar is visible.
     *  @default true
     */
    public function get showTitleBar():Boolean {
        return _showTitleBar;
    }

    public function set showTitleBar(value:Boolean):void {
        if (_showTitleBar == value) {
            return;
        }
        _showTitleBar = value;
        showTitleBarChanged = true;
        invalidateProperties();
        invalidateDisplayList();
    }

    /**
     *  Storage for the status property.
     */
    private var _status:String = "";

    private var statusChanged:Boolean = false;


    /**
     *  The string that appears in the status bar, if it is visible.
     *  @default ""
     */
    [Bindable("statusChanged")]
    public function get status():String {
        return _status;
    }

    public function set status(value:String):void {
        _status = value;
        statusChanged = true;
        invalidateProperties();
        invalidateSize();
        invalidateViewMetricsAndPadding();
        dispatchEvent(new Event("statusChanged"));
    }

    /**
     *  Storage for the statusBar property.
     */
    private var _statusBar:UIComponent;

    /**
     *  The UIComponent that displays the status bar.
     */
    public function get statusBar():UIComponent {
        return _statusBar;
    }

    /**
     *  Storage for the statusBarFactory property
     */
    private var _statusBarFactory:IFactory = new ClassFactory(StatusBar);

    private var statusBarFactoryChanged:Boolean = false;

    [Bindable("statusBarFactoryChanged")]

    /**
     *  The IFactory that creates an instance to use
     *  as the status bar.
     *  The default value is an IFactory for StatusBar.
     *  If you write a custom status bar class, it should expose
     *  a public property named status.
     */
    public function get statusBarFactory():IFactory {
        return _statusBarFactory;
    }

    public function set statusBarFactory(value:IFactory):void {
        _statusBarFactory = value;
        statusBarFactoryChanged = true;
        invalidateProperties();
        dispatchEvent(new Event("statusBarFactoryChanged"));
    }

    private static var _statusBarStyleFilters:Object = {
        "statusBarBackgroundColor": "statusBarBackgroundColor",
        "statusBarBackgroundSkin": "statusBarBackgroundSkin",
        "statusTextStyleName": "statusTextStyleName"
    };

    /**
     *  Set of styles to pass from the window to the status bar.
     *  @see mx.styles.StyleProxy
     */
    protected function get statusBarStyleFilters():Object {
        return _statusBarStyleFilters;
    }

    /**
     *  Storage for the systemChrome property.
     */
    private var _systemChrome:String = NativeWindowSystemChrome.STANDARD;

    /**
     *  Specifies the type of system chrome (if any) the window has.
     *  The set of possible values is defined by the constants
     *  in the NativeWindowSystemChrome class.
     *
     *  This property is read-only once the window has been opened.
     *
     *  The default value is NativeWindowSystemChrome.STANDARD.
     *
     *  @see flash.display.NativeWindowSystemChrome
     *  @see flash.display.NativeWindowInitOptions#systemChrome
     */
    [Inspectable(enumeration="none,standard", defaultValue="standard")]
    public function get systemChrome():String {
        return _systemChrome;
    }

    public function set systemChrome(value:String):void {
        if (!_nativeWindow) {
            _systemChrome = value;
            invalidateProperties();
        }
    }

    /**
     *  Storage for the title property.
     */
    private var _title:String = "";

    private var titleChanged:Boolean = false;

    /**
     *  The title text that appears in the window title bar and
     *  the taskbar.
     *
     *  @default ""
     */
    [Bindable("titleChanged")]
    public function get title():String {
        return _title;
    }

    public function set title(value:String):void {
        titleChanged = true;
        _title = value;
        invalidateProperties();
        invalidateSize();
        invalidateViewMetricsAndPadding();
        invalidateDisplayList();
        dispatchEvent(new Event("titleChanged"));
    }

    /**
     *  Storage for the titleBar property.
     */
    private var _titleBar:UIComponent;

    /**
     *  The UIComponent that displays the title bar.
     */
    public function get titleBar():UIComponent {
        return _titleBar;
    }

    /**
     *  Storage for the titleBarFactory property
     */
    private var _titleBarFactory:IFactory = new ClassFactory(TitleBar);

    private var titleBarFactoryChanged:Boolean = false;

    /**
     *  The IFactory that creates an instance to use
     *  as the title bar.
     *  The default value is an IFactory for TitleBar.
     *  If you write a custom title bar class, it should expose
     *  public properties named titleIcon
     *  and title.
     */
    [Bindable("titleBarFactoryChanged")]
    public function get titleBarFactory():IFactory {
        return _titleBarFactory;
    }

    public function set titleBarFactory(value:IFactory):void {
        _titleBarFactory = value;
        titleBarFactoryChanged = true;
        invalidateProperties();
        dispatchEvent(new Event("titleBarFactoryChanged"));
    }

    private static var _titleBarStyleFilters:Object = {
        "buttonAlignment": "buttonAlignment",
        "buttonPadding": "buttonPadding",
        "closeButtonSkin": "closeButtonSkin",
        "cornerRadius": "cornerRadius",
        "headerHeight": "headerHeight",
        "maximizeButtonSkin": "maximizeButtonSkin",
        "minimizeButtonSkin": "minimizeButtonSkin",
        "restoreButtonSkin": "restoreButtonSkin",
        "titleAlignment": "titleAlignment",
        "titleBarBackgroundSkin": "titleBarBackgroundSkin",
        "titleBarButtonPadding": "titleBarButtonPadding",
        "titleBarColors": "titleBarColors",
        "titleTextStyleName": "titleTextStyleName"
    };

    /**
     *  Set of styles to pass from the Window to the titleBar.
     *
     *  @see mx.styles.StyleProxy
     */
    protected function get titleBarStyleFilters():Object {
        return _titleBarStyleFilters;
    }

    /**
     *  Storage for the titleIcon property.
     */
    private var _titleIcon:Class;

    private var titleIconChanged:Boolean = false;

    /**
     *  The Class (usually an image) used to draw the title bar icon.
     *  @default null
     */
    [Bindable("titleIconChanged")]
    public function get titleIcon():Class {
        return _titleIcon;
    }

    public function set titleIcon(value:Class):void {
        _titleIcon = value;
        titleIconChanged = true;
        invalidateProperties();
        invalidateSize();
        invalidateViewMetricsAndPadding();
        invalidateDisplayList();
        dispatchEvent(new Event("titleIconChanged"));
    }

    /**
     *  Storage for the transparent property.
     */
    private var _transparent:Boolean = false;

    /**
     *  Specifies whether the window is transparent. Setting this
     *  property to true for a window that uses
     *  system chrome is not supported.
     *
     *  This property is read-only after the window has been opened.
     */
    public function get transparent():Boolean {
        return _transparent;
    }

    public function set transparent(value:Boolean):void {
        if (!_nativeWindow) {
            _transparent = value;
            invalidateProperties();
        }
    }

    /**
     *  Storage for the type property.
     */
    private var _type:String = "normal";

    /**
     *  Specifies the type of NativeWindow that this component
     *  represents. The set of possible values is defined by the constants
     *  in the NativeWindowType class.
     *
     *  This property is read-only once the window has been opened.
     *
     *  The default value is NativeWindowType.NORMAL.
     *
     *  @see flash.display.NativeWindowType
     *  @see flash.display.NativeWindowInitOptions#type
     */
    public function get type():String {
        return _type;
    }

    public function set type(value:String):void {
        if (!_nativeWindow) {
            _type = value;
            invalidateProperties();
        }
    }

    override public function initialize():void {
        if (documentDescriptor) {
            creationPolicy = documentDescriptor.properties.creationPolicy;
            if (creationPolicy == null || creationPolicy.length == 0) {
                creationPolicy = ContainerCreationPolicy.AUTO;
            }
            var properties:Object = documentDescriptor.properties;
            if (properties.width != null) {
                width = properties.width;
                delete properties.width;
            }
            if (properties.height != null) {
                height = properties.height;
                delete properties.height;
            }

            // Flex auto-generated code has already set up events.
            documentDescriptor.events = null;
        }
        super.initialize();
    }

    override protected function createChildren():void {
        // Note: this is to help initialize the stage
        width = _bounds.width;
        height = _bounds.height;

        super.createChildren();

        // Add a status bar if required.
        if (!_statusBar && showStatusBar) {
            _statusBar = statusBarFactory.newInstance();
            _statusBar.styleName = new StyleProxy(this, statusBarStyleFilters);
            rawChildren.addChild(DisplayObject(_statusBar));
            showStatusBarChanged = true;
            statusBarFactoryChanged = false;
        }

        // If a Flex chrome is not required, stop here
        if (!getStyle("showFlexChrome") ||
                getStyle("showFlexChrome") == "false") {
            setStyle("borderStyle", "none");
            setStyle("backgroundAlpha", 0);
            return;
        }

        // Add a Flex gripper if required.
        if (!gripper && showGripper) {
            gripper = new Button();
            var gripSkin:String = getStyle("gripperStyleName");
            if (gripSkin) {
                gripper.styleName = gripSkin;
            }
            gripper.tabEnabled = false;
            gripper.tabFocusEnabled = false;
            gripper.skinLayoutDirection = undefined;
            rawChildren.addChild(gripper);
            gripperHit = new Sprite();
            rawChildren.addChild(gripperHit);
            gripperHit.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        }

        // Add a Flex title bar if required.
        if (_showTitleBar && !_titleBar) {
            _titleBar = titleBarFactory.newInstance();
            _titleBar.styleName = new StyleProxy(this, titleBarStyleFilters);
            rawChildren.addChild(DisplayObject(titleBar));
            showTitleBarChanged = true;
        }
    }

    override protected function commitProperties():void {
        super.commitProperties();

        // Create and open window.
        if (_flagForOpen && !_nativeWindow) {
            _flagForOpen = false;

            // Set up our module factory if we don't have one.
            if (moduleFactory == null) {
                moduleFactory = SystemManagerGlobals.topLevelSystemManagers[0];
            }

            var init:NativeWindowInitOptions = new NativeWindowInitOptions();
            init.maximizable = _maximizable;
            init.minimizable = _minimizable;
            init.resizable = _resizable;
            init.type = _type;
            init.systemChrome = _systemChrome;
            init.transparent = _transparent;
            if (_windowOwner != null) {
                if (_windowOwner.nativeWindow != null) {
                    init.owner = _windowOwner.nativeWindow;
                }
            }
            _nativeWindow = new NativeWindow(init);

            var sm:WindowedSystemManager = new WindowedSystemManager(this);
            _nativeWindow.stage.addChild(sm);
            systemManager = sm;
            sm.window = this;

            _nativeWindow.alwaysInFront = _alwaysInFront;
            initManagers(sm);
            addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);

            var nativeApplication:NativeApplication = NativeApplication.nativeApplication;
            nativeApplication.addEventListener(Event.ACTIVATE, nativeApplication_activateHandler, false, 0, true);
            nativeApplication.addEventListener(Event.DEACTIVATE, nativeApplication_deactivateHandler, false, 0, true);
            nativeApplication.addEventListener(Event.NETWORK_CHANGE, nativeApplication_networkChangeHandler, false, 0, true);
            _nativeWindow.addEventListener(Event.ACTIVATE, nativeWindow_activateHandler, false, 0, true);
            _nativeWindow.addEventListener(Event.DEACTIVATE, nativeWindow_deactivateHandler, false, 0, true);

            addEventListener(Event.ENTER_FRAME, enterFrameHandler);

            //'register' with WindowedSystemManager so it can cleanup when done.
            sm.addWindow(this);
        }

        // AIR won't allow you to set the min width greater than the current
        // max width (same is true for height). You also can't set the max
        // width less than the current min width (same is true for height).
        // This makes the updating of the new minSize and maxSize a bit tricky.
        if (minWidthChanged || minHeightChanged || maxWidthChanged || maxHeightChanged) {
            var minSize:Point = nativeWindow.minSize;
            var maxSize:Point = nativeWindow.maxSize;
            var newMinWidth:Number = minWidthChanged ? _minWidth + chromeWidth() : minSize.x;
            var newMinHeight:Number = minHeightChanged ? _minHeight + chromeHeight() : minSize.y;
            var newMaxWidth:Number = maxWidthChanged ? _maxWidth + chromeWidth() : maxSize.x;
            var newMaxHeight:Number = maxHeightChanged ? _maxHeight + chromeHeight() : maxSize.y;

            if (minWidthChanged || minHeightChanged) {

                // If the new min size is greater than the old max size, then
                // we need to set the new max size now.
                if ((maxWidthChanged && newMinWidth > minSize.x) || (maxHeightChanged && newMinHeight > minSize.y)) {
                    nativeWindow.maxSize = new Point(newMaxWidth, newMaxHeight);
                }
                nativeWindow.minSize = new Point(newMinWidth, newMinHeight);
            }

            // Set the max width or height if it is not already set. The max
            // width and height could have been set above when setting minSize
            // but the max size would have been rejected by AIR if it were less
            // than the old min size.
            if (newMaxWidth != maxSize.x || newMaxHeight != maxSize.y) {
                nativeWindow.maxSize = new Point(newMaxWidth, newMaxHeight);
            }
        }

        // Ensure width and height as at least as large as minimum width and height
        if (minWidthChanged || minHeightChanged) {
            if (minWidthChanged) {
                minWidthChanged = false;
                if (width < minWidth) {
                    width = minWidth;
                }
                dispatchEvent(new Event("minWidthChanged"));
            }
            if (minHeightChanged) {
                minHeightChanged = false;
                if (height < minHeight) {
                    height = minHeight;
                }
                dispatchEvent(new Event("minHeightChanged"));
            }
        }

        // Ensure width and height are not larger than maximum width and height
        if (maxWidthChanged || maxHeightChanged) {
            if (maxWidthChanged) {
                maxWidthChanged = false;
                if (width > maxWidth) {
                    width = maxWidth;
                }
                dispatchEvent(new Event("maxWidthChanged"));
            }
            if (maxHeightChanged) {
                maxHeightChanged = false;
                if (height > maxHeight) {
                    height = maxHeight;
                }
                dispatchEvent(new Event("maxHeightChanged"));
            }
        }

        if (boundsChanged) {
            // Work around an AIR issue setting the stageHeight to zero when
            // using system chrome. Setting the stage.stageHeight property
            // is rejected unless the nativeWindow is first set to the proper height.
            // Don't perform this workaround if the window has zero height due
            // to being minimized. Setting the nativeWindow height to non-zero
            // causes AIR to restore the window.
            if (_bounds.height == 0 && nativeWindow.displayState != NativeWindowDisplayState.MINIMIZED &&
                    systemChrome == NativeWindowSystemChrome.STANDARD) {
                nativeWindow.height = (chromeHeight() + _bounds.height);
            }

            // We use temporary variables because when we set stageWidth or
            // stageHeight, _bounds will be overwritten if we receive
            // a RESIZE event.
            var newWidth:Number = _bounds.width;
            var newHeight:Number = _bounds.height;
            systemManager.stage.stageWidth = newWidth;
            systemManager.stage.stageHeight = newHeight;
            boundsChanged = false;
        }

        // Native menu
        if (menuChanged && !nativeWindow.closed) {
            menuChanged = false;
            if (menu == null) {
                if (NativeWindow.supportsMenu) {
                    nativeWindow.menu = null;
                }
            } else if (menu.nativeMenu) {
                if (NativeWindow.supportsMenu) {
                    nativeWindow.menu = menu.nativeMenu;
                }
            }
            dispatchEvent(new Event("menuChanged"));
        }

        // Title bar
        if (titleBarFactoryChanged) {
            if (_titleBar) {

                // Remove old titleBar.
                rawChildren.removeChild(DisplayObject(titleBar));
                _titleBar = null;
            }
            _titleBar = titleBarFactory.newInstance();
            _titleBar.styleName = new StyleProxy(this, titleBarStyleFilters);
            rawChildren.addChild(DisplayObject(titleBar));
            titleBarFactoryChanged = false;
            invalidateDisplayList();
        }
        if (showTitleBarChanged) {
            if (_titleBar) {
                _titleBar.visible = _showTitleBar;
            }
            showTitleBarChanged = false;
        }

        // Icon
        if (titleIconChanged) {
            if (_titleBar && "titleIcon" in _titleBar) {
                _titleBar["titleIcon"] = _titleIcon;
            }
            titleIconChanged = false;
        }

        // Title
        if (titleChanged) {
            if (!nativeWindow.closed) {
                systemManager.stage.nativeWindow.title = _title;
            }
            if (_titleBar && "title" in _titleBar) {
                _titleBar["title"] = _title;
            }
            titleChanged = false;
        }

        // Status bar
        if (statusBarFactoryChanged) {
            if (_statusBar) {

                // Remove old status bar.
                rawChildren.removeChild(DisplayObject(_statusBar));
                _statusBar = null
            }
            _statusBar = statusBarFactory.newInstance();
            _statusBar.styleName = new StyleProxy(this, statusBarStyleFilters);

            // Add it underneath the gripper.
            rawChildren.addChild(DisplayObject(_statusBar));
            if (gripper) {
                var gripperIndex:int = rawChildren.getChildIndex(DisplayObject(gripper));
                rawChildren.setChildIndex(DisplayObject(_statusBar), gripperIndex);
            }
            statusBarFactoryChanged = false;
            showStatusBarChanged = true;
            statusChanged = true;
            invalidateDisplayList();
        }
        if (showStatusBarChanged) {
            if (_statusBar) {
                _statusBar.visible = _showStatusBar;
            }
            showStatusBarChanged = false;
        }

        // Status
        if (statusChanged) {
            if (_statusBar && "status" in _statusBar) {
                _statusBar["status"] = _status;
            }
            statusChanged = false;
        }

        // Gripper
        if (showGripperChanged) {
            if (gripper) {
                gripper.visible = _showGripper;
                gripperHit.visible = _showGripper;
            }
            showGripperChanged = false;
        }

        // Maximize
        if (_toMax) {
            _toMax = false;
            if (!nativeWindow.closed) {
                nativeWindow.maximize();
            }
        }
    }

    override protected function measure():void {
        if (_maximized) {
            _maximized = false;
            if (!nativeWindow.closed)
                systemManager.stage.nativeWindow.maximize();
        }
        super.measure();
    }

    override public function validateDisplayList():void {
        super.validateDisplayList();

        // We need to move the scroll bars so they do not overlap the systemChrome gripper.
        // If both scrollbars are already visible, this has been done for us.
        if (Capabilities.os.substring(0, 3) == "Mac" && systemChrome == "standard") {
            if ((horizontalScrollBar || verticalScrollBar) && !(horizontalScrollBar && verticalScrollBar) && !showStatusBar) {
                if (!whiteBox) {
                    whiteBox = new FlexShape();
                    whiteBox.name = "whiteBox";
                    var g:Graphics = whiteBox.graphics;
                    g.beginFill(0xFFFFFF, 0.0001);
                    g.drawRect(0, 0, verticalScrollBar ? verticalScrollBar.minWidth : 15, horizontalScrollBar ? horizontalScrollBar.minHeight : 15);
                    g.endFill();
                    rawChildren.addChild(whiteBox);
                }
                whiteBox.visible = true;
                if (horizontalScrollBar) {
                    horizontalScrollBar.setActualSize(horizontalScrollBar.width - whiteBox.width, horizontalScrollBar.height);
                }
                if (verticalScrollBar) {
                    verticalScrollBar.setActualSize(verticalScrollBar.width, verticalScrollBar.height - whiteBox.height);
                }
                whiteBox.x = (systemManager.stage.stageWidth - whiteBox.width);
                whiteBox.y = (systemManager.stage.stageHeight - whiteBox.height);
            } else if (!(horizontalScrollBar && verticalScrollBar)) {
                if (whiteBox) {
                    rawChildren.removeChild(whiteBox);
                    whiteBox = null;
                }
            }
        } else if (gripper && showGripper && !showStatusBar) {

            // See if both scrollbars are visible
            if (whiteBox) {
                whiteBox.visible = false;

                // If gripper + padding > whiteBox size, we need to move scrollbars
                if (gripperHit.height > whiteBox.height) {
                    verticalScrollBar.setActualSize(verticalScrollBar.width, verticalScrollBar.height - (gripperHit.height - whiteBox.height));
                }
                if (gripperHit.width > whiteBox.width) {
                    horizontalScrollBar.setActualSize(horizontalScrollBar.width - (gripperHit.width - whiteBox.height), horizontalScrollBar.height);
                }
            } else if (horizontalScrollBar) {
                horizontalScrollBar.setActualSize(horizontalScrollBar.width - gripperHit.width, horizontalScrollBar.height);
            } else if (verticalScrollBar) {
                verticalScrollBar.setActualSize(verticalScrollBar.width, verticalScrollBar.height - gripperHit.height);
            }
        }

        // If there's no gripper, we need to show the white box, if appropriate
        else if (whiteBox) {
            whiteBox.visible = true;
        }
    }

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
        if (!nativeWindow.closed) {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            // Patch: unscaledWidth and unscaledHeight must not exceed stage.stageWidth and stage.stageHeight,
            // respectively. This may occur in very obscure situations, and when a native chrome is used on a
            // Window.
            if (stage != null) {
                if (unscaledWidth > stage.stageWidth) {
                    unscaledWidth = stage.stageWidth;
                }
                if (unscaledHeight > stage.stageHeight) {
                    unscaledHeight = stage.stageHeight;
                }
            }

            // Application.updateDisplayList can change the width and height.
            // We use their new values.
            resizeWidth = isNaN(explicitWidth);
            resizeHeight = isNaN(explicitHeight);
            if (resizeWidth || resizeHeight) {
                resizeHandler(new Event(Event.RESIZE));

                // Validate transform.matrix after setting actual size.  This is normally done
                // by validateDisplayList() before our updateDisplayList() is called.
                validateMatrix();

                if (!resizeHandlerAdded) {
                    systemManager.addEventListener(Event.RESIZE, resizeHandler, false, 0, true); // weak reference
                    resizeHandlerAdded = true;
                }
            } else {
                if (resizeHandlerAdded) {
                    systemManager.removeEventListener(Event.RESIZE, resizeHandler);
                    resizeHandlerAdded = false;
                }
            }

            // Only layout the border after all the children have been positioned
            createBorder();
            var bm:EdgeMetrics = borderMetrics;

            // Status bar
            var footerHeight:Number = 0;
            if (_statusBar) {
                if (!_currentlyResizing) {
                    _statusBar.visible = true;
                    _statusBar.includeInLayout = true;
                    footerHeight = getStatusBarHeight();
                    _statusBar.move(bm.left, unscaledHeight - bm.bottom - footerHeight);
                    _statusBar.setActualSize(unscaledWidth - bm.left - bm.right, footerHeight);
                } else {
                    _statusBar.visible = false;
                    _statusBar.includeInLayout = false;
                }
            }

            // Title bar
            var headerHeight:Number = 0;
            if (titleBar) {
                if (!_currentlyResizing) {
                    titleBar.visible = true;
                    titleBar.includeInLayout = true;
                    headerHeight = getHeaderHeight();
                    titleBar.move(bm.left, bm.top);
                    titleBar.setActualSize(unscaledWidth - bm.left - bm.right, headerHeight);
                } else {
                    titleBar.visible = false;
                    titleBar.includeInLayout = false;
                }
            }

            // Gripper
            if (gripper && showGripper) {
                if (!_currentlyResizing && !(isWinMaximized && OSFamily.isWindows)) {
                    gripper.visible = true;
                    gripper.includeInLayout = true;
                    var gripperPadding:Number = getStyle("gripperPadding");
                    if (isNaN(gripperPadding)) {
                        gripperPadding = 0;
                    }
                    gripper.setActualSize(gripper.measuredWidth, gripper.measuredHeight);
                    gripperHit.graphics.beginFill(0xffffff, .0001);
                    gripperHit.graphics.drawRect(0, 0, gripper.width + (2 * gripperPadding), gripper.height + (2 * gripperPadding));
                    gripper.move(unscaledWidth - gripper.measuredWidth - gripperPadding - bm.right,
                            unscaledHeight - gripper.measuredHeight - gripperPadding - bm.bottom);
                    gripperHit.x = gripper.x - gripperPadding - bm.right;
                    gripperHit.y = gripper.y - gripperPadding - bm.bottom;
                } else {
                    gripper.visible = false;
                    gripper.includeInLayout = false;
                }
            }

            // Offset & resize the first (and only) child DOWN AND RIGHT, so that:
            // 1) the title bar does not cover it;
            // 2) it does not cover the left border (if any).
            if (_firstChild) {
                if (!_currentlyResizing) {
                    _firstChild.visible = true;
                    _firstChild.includeInLayout = true;
                    _firstChild.move(bm.left, bm.top + headerHeight);
                    if (!_canFitContent && !_isContentFitScheduled) {
                        var contentW:Number = (unscaledWidth - bm.left - bm.right);
                        var contentH:Number = (unscaledHeight - headerHeight - footerHeight - bm.top - bm.bottom);
                        _firstChild.setActualSize(contentW, contentH);
                    }
                } else {
                    _firstChild.visible = false;
                    _firstChild.includeInLayout = false;
                }
            }
        }

        // Draw an opaque background beneath the content area, if requested to do so.
        if (_drawContentBackground) {
            graphics.clear();
            var rawBackgroundColor:Object = getStyle('chromeColor');
            styleManager.getColorNames([rawBackgroundColor]);
            var backgroundColor:uint = (rawBackgroundColor as uint || 0x000000);
            graphics.beginFill(backgroundColor, (_currentlyResizing ? 0.2 : 1));
            graphics.drawRect(0, headerHeight, unscaledWidth, unscaledHeight - headerHeight - footerHeight);
            graphics.endFill();
        }
    }

    override public function styleChanged(styleProp:String):void {
        super.styleChanged(styleProp);
        if (!nativeWindow.closed) {
            if (!(getStyle("showFlexChrome") == "false" || !getStyle("showFlexChrome"))) {
                if (styleProp == null || styleProp == "headerHeight" || styleProp == "gripperPadding") {
                    invalidateViewMetricsAndPadding();
                    invalidateDisplayList();
                    invalidateSize();
                }
            }
        }
    }

    override public function move(x:Number, y:Number):void {
        if (nativeWindow && !nativeWindow.closed) {
            var tmp:Rectangle = nativeWindow.bounds;
            tmp.x = x;
            tmp.y = y;
            nativeWindow.bounds = tmp;
        }
    }

    /**
     *  Window also handles themeColor defined
     *  on the global selector. (Stolen from Application)
     */
    override mx_internal function initThemeColor():Boolean {
        var result:Boolean = super.initThemeColor();
        if (!result) {
            var tc:Object;  // Can be number or string
            var rc:Number;
            var sc:Number;
            var globalSelector:CSSStyleDeclaration = styleManager.getStyleDeclaration("global");
            if (globalSelector) {
                tc = globalSelector.getStyle("themeColor");
                rc = globalSelector.getStyle("rollOverColor");
                sc = globalSelector.getStyle("selectionColor");
            }
            if (tc && isNaN(rc) && isNaN(sc)) {
                setThemeColor(tc);
            }
            result = true;
        }
        return result;
    }

    /**
     *  Closes the window. This action is cancelable.
     */
    public function close():void {
        if (_nativeWindow && !_nativeWindow.closed) {
            var e:Event = new Event("closing", false, true);
            _nativeWindow.dispatchEvent(e);
            if (!(e.isDefaultPrevented())) {
                removeEventListener(Event.ENTER_FRAME, enterFrameHandler);

                // A listener of "closing" may destroy the window meanwhile
                if (_nativeWindow) {
                    _nativeWindow.close();
                    _nativeWindow = null;
                }

                if (systemManager.contains(this)) {
                    systemManager.removeChild(this);
                }
            }
        }
    }

    /**
     *  Returns the height of the header.
     */
    private function getHeaderHeight():Number {
        if (!nativeWindow.closed) {
            if (getStyle("headerHeight") != null) {
                return getStyle("headerHeight");
            }
            if (!systemManager.stage) {
                return 0;
            }
            if (systemManager.stage.nativeWindow.systemChrome != "none") {
                return 0;
            }
            if (titleBar) {
                return (titleBar.getExplicitOrMeasuredHeight());
            }
        }
        return 0;

    }

    /**
     *  Returns the height of the statusBar.
     */
    public function getStatusBarHeight():Number {
        if (_statusBar) {
            return _statusBar.getExplicitOrMeasuredHeight();
        }
        return 0;
    }

    private function initManagers(sm:ISystemManager):void {
        if (sm.isTopLevel()) {
            focusManager = new FocusManager(this);
            var awm:IActiveWindowManager = IActiveWindowManager(sm.getImplementation("mx.managers::IActiveWindowManager"));
            if (awm) {
                awm.activate(this);
            } else {
                focusManager.activate();
            }
            _cursorManager = new CursorManagerImpl(sm);
        }
    }

    /**
     *  Maximizes the window, or does nothing if it's already maximized.
     */
    public function maximize():void {
        if (!nativeWindow || !nativeWindow.maximizable || nativeWindow.closed) {
            return;
        }
        if (stage.nativeWindow.displayState != NativeWindowDisplayState.MAXIMIZED) {
            var f:NativeWindowDisplayStateEvent = new NativeWindowDisplayStateEvent(
                    NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
                    false, true, stage.nativeWindow.displayState,
                    NativeWindowDisplayState.MAXIMIZED);
            stage.nativeWindow.dispatchEvent(f);
            if (!f.isDefaultPrevented()) {
                _toMax = true;
                invalidateProperties();
                invalidateSize();
            }
        }
    }

    /**
     *  Minimizes the window.
     */
    public function minimize():void {
        if (!minimizable) {
            return;
        }
        if (!nativeWindow.closed) {
            var e:NativeWindowDisplayStateEvent = new NativeWindowDisplayStateEvent(
                    NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
                    false, true, nativeWindow.displayState,
                    NativeWindowDisplayState.MINIMIZED);
            stage.nativeWindow.dispatchEvent(e);
            if (!e.isDefaultPrevented()) {
                stage.nativeWindow.minimize();
            }
        }
    }

    /**
     *  Restores the window (unmaximizes it if it's maximized, or
     *  unminimizes it if it's minimized).
     */
    public function restore():void {
        if (!nativeWindow.closed) {
            var e:NativeWindowDisplayStateEvent;
            if (stage.nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED) {
                e = new NativeWindowDisplayStateEvent(
                        NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
                        false, true, NativeWindowDisplayState.MAXIMIZED,
                        NativeWindowDisplayState.NORMAL);
                stage.nativeWindow.dispatchEvent(e);
                if (!e.isDefaultPrevented()) {
                    nativeWindow.restore();
                }
            } else if (stage.nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED) {
                e = new NativeWindowDisplayStateEvent(
                        NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
                        false, true, NativeWindowDisplayState.MINIMIZED,
                        NativeWindowDisplayState.NORMAL);
                stage.nativeWindow.dispatchEvent(e);
                if (!e.isDefaultPrevented()) {
                    nativeWindow.restore();
                }
            }
        }
    }

    /**
     *  Activates the underlying NativeWindow (even if this Window's application
     *  is not currently active).
     *
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function activate():void {
        if (!nativeWindow.closed) {
            _nativeWindow.activate();

            // activate makes the native window visible so this
            // component should become visible as well.
            visible = true;
        }
    }

    /**
     *  Creates the underlying NativeWindow and opens it.
     *
     *  After being closed, the Window object is still a valid reference, but
     *  accessing most properties and methods will not work.
     *  Closed windows cannot be reopened.
     *
     *  @param  openWindowActive specifies whether the Window opens
     *  activated (that is, whether it has focus). The default value
     *  is true.
     */
    public function open(openWindowActive:Boolean = true):void {
        // Event for Automation so we know when windows are created or destroyed.
        if (FlexGlobals.topLevelApplication) {
            FlexGlobals.topLevelApplication.dispatchEvent(
                    new WindowExistenceEvent(WindowExistenceEvent.WINDOW_CREATING, false, false, this));
        }
        _flagForOpen = true;
        openActive = openWindowActive;
        commitProperties();
        dispatchEvent(new Event(WINDOW_OPEN));
    }


    /**
     *  Orders the window just behind another. To order the window behind
     *  a NativeWindow that does not implement IWindow, use this window's
     *  nativeWindow's orderInBackOf() method.
     *
     *  @param window The IWindow (Window or WindowedApplication)
     *  to order this window behind.
     *
     *  @return true if the window was successfully sent behind;
     *          false if the window is invisible or minimized.
     */
    public function orderInBackOf(window:IWindow):Boolean {
        if (nativeWindow && !nativeWindow.closed) {
            return nativeWindow.orderInBackOf(window.nativeWindow);
        } else {
            return false;
        }
    }

    /**
     *  Orders the window just in front of another. To order the window
     *  in front of a NativeWindow that does not implement IWindow, use this
     *  window's nativeWindow's  orderInFrontOf() method.
     *
     *  @param window The IWindow (Window or WindowedApplication)
     *  to order this window in front of.
     *
     *  @return true if the window was successfully sent in front;
     *          false if the window is invisible or minimized.
     */
    public function orderInFrontOf(window:IWindow):Boolean {
        if (nativeWindow && !nativeWindow.closed) {
            return nativeWindow.orderInFrontOf(window.nativeWindow);
        } else {
            return false;
        }
    }

    /**
     *  Orders the window behind all others in the same application.
     *
     *  @return true if the window was successfully sent to the back;
     *  false if the window is invisible or minimized.
     */
    public function orderToBack():Boolean {
        if (nativeWindow && !nativeWindow.closed) {
            return nativeWindow.orderToBack();
        } else {
            return false;
        }
    }

    /**
     *  Orders the window in front of all others in the same application.
     *
     *  @return true if the window was successfully sent to the front;
     *  false if the window is invisible or minimized.
     */
    public function orderToFront():Boolean {
        if (nativeWindow && !nativeWindow.closed) {
            return nativeWindow.orderToFront();
        } else {
            return false;
        }
    }

    /**
     *  Returns the width of the chrome for the window
     */
    private function chromeWidth():Number {
        return (nativeWindow.width - systemManager.stage.stageWidth);
    }

    /**
     *  Returns the height of the chrome for the window
     */
    private function chromeHeight():Number {
        return (nativeWindow.height - systemManager.stage.stageHeight);
    }

    /**
     *  Starts a system resize.
     */
    private function startResize(start:String):void {
        if (resizable && !nativeWindow.closed) {
            stage.nativeWindow.startResize(start);
        }
    }

    private function enterFrameHandler(e:Event):void {
        if (_frameCounter == 2) {
            removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
            _nativeWindow.visible = _nativeWindowVisible;
            dispatchEvent(new AIREvent(AIREvent.WINDOW_COMPLETE));

            // Event for Automation so we know when windows are created or destroyed.
            if (FlexGlobals.topLevelApplication) {
                FlexGlobals.topLevelApplication.dispatchEvent(
                        new WindowExistenceEvent(WindowExistenceEvent.WINDOW_CREATE,
                                false, false, this));
            }
            if (_nativeWindow.visible) {
                if (openActive) {
                    _nativeWindow.activate();
                }
            }
        }
        _frameCounter++;
    }

    private function hideEffectEndHandler(event:Event):void {
        if (!_nativeWindow.closed) {
            _nativeWindow.visible = false;
        }
        removeEventListener(EffectEvent.EFFECT_END, hideEffectEndHandler);
    }

    private function windowMinimizeHandler(event:Event):void {
        if (!nativeWindow.closed) {
            stage.nativeWindow.minimize();
        }
        removeEventListener(EffectEvent.EFFECT_END, windowMinimizeHandler);
    }

    private function windowUnminimizeHandler(event:Event):void {
        removeEventListener(EffectEvent.EFFECT_END, windowUnminimizeHandler);
    }

    private function window_moveHandler(event:NativeWindowBoundsEvent):void {
        var newEvent:FlexNativeWindowBoundsEvent = new FlexNativeWindowBoundsEvent(
                FlexNativeWindowBoundsEvent.WINDOW_MOVE,
                event.bubbles, event.cancelable,
                event.beforeBounds, event.afterBounds);
        dispatchEvent(newEvent);
    }

    private function window_displayStateChangeHandler(event:NativeWindowDisplayStateEvent):void {

        // Redispatch event
        dispatchEvent(event);
        if (stage) {
            height = stage.stageHeight;
            width = stage.stageWidth;
        }

        // Restored from a minimized state.
        if (event.beforeDisplayState == NativeWindowDisplayState.MINIMIZED) {
            addEventListener(EffectEvent.EFFECT_END, windowUnminimizeHandler);
            dispatchEvent(new Event("windowUnminimize"));
        }
    }

    private function window_displayStateChangingHandler(event:NativeWindowDisplayStateEvent):void {

        // Redispatch event for cancellation purposes.
        dispatchEvent(event);
        if (event.isDefaultPrevented()) {
            return;
        }
        if (event.afterDisplayState == NativeWindowDisplayState.MINIMIZED) {
            if (getStyle("minimizeEffect")) {
                event.preventDefault();
                addEventListener(EffectEvent.EFFECT_END, windowMinimizeHandler);
                dispatchEvent(new Event("windowMinimize"));
            }
        }
    }

    /**
     *  Manages mouse down events on the window border (causing a window resize to happen).
     */
    protected function mouseDownHandler(event:MouseEvent):void {
        // Stop if window is not supposed to be resizable
        if (!_resizable) {
            return;
        }

        // Stop if there is no window content
        if (!_firstChild || !_firstChild.enabled) {
            return;
        }

        // Stop if clicked on a scrollbar part
        if (event.target is ScrollThumb) {
            return;
        }

        // Proceed if clicked on the gripper, a border or a corner
        if (event.target == gripperHit) {
            startResize(layoutDirection == "rtl" ? NativeWindowResize.BOTTOM_LEFT :
                    NativeWindowResize.BOTTOM_RIGHT);
            event.stopPropagation();
            _reactToResizeStart();
        } else {
            var dragWidth:int = Number(getStyle("borderThickness")) + 6;
            var cornerSize:int = 12;
            if (event.stageY < Number(getStyle("borderThickness"))) {
                if (event.stageX < cornerSize) {
                    startResize(NativeWindowResize.TOP_LEFT);
                    _reactToResizeStart();
                } else if (event.stageX > width - cornerSize) {
                    startResize(NativeWindowResize.TOP_RIGHT);
                    _reactToResizeStart();
                } else {
                    startResize(NativeWindowResize.TOP);
                    _reactToResizeStart();
                }
                event.stopPropagation();
            } else if (event.stageY > (height - dragWidth)) {
                if (event.stageX < cornerSize) {
                    startResize(NativeWindowResize.BOTTOM_LEFT);
                    _reactToResizeStart();
                } else if (event.stageX > width - cornerSize) {
                    startResize(NativeWindowResize.BOTTOM_RIGHT);
                    _reactToResizeStart();
                } else {
                    startResize(NativeWindowResize.BOTTOM);
                    _reactToResizeStart();
                }
                event.stopPropagation();
            } else if (event.stageX < dragWidth) {
                if (event.stageY < cornerSize) {
                    startResize(NativeWindowResize.TOP_LEFT);
                    _reactToResizeStart();
                } else if (event.stageY > height - cornerSize) {
                    startResize(NativeWindowResize.BOTTOM_LEFT);
                    _reactToResizeStart();
                } else {
                    startResize(NativeWindowResize.LEFT);
                    _reactToResizeStart();
                }
                event.stopPropagation();
            } else if (event.stageX > width - dragWidth) {
                if (event.stageY < cornerSize) {
                    startResize(NativeWindowResize.TOP_RIGHT);
                    _reactToResizeStart();
                } else if (event.stageY > height - cornerSize) {
                    startResize(NativeWindowResize.BOTTOM_RIGHT);
                    _reactToResizeStart();
                } else {
                    startResize(NativeWindowResize.RIGHT);
                    _reactToResizeStart();
                }
                event.stopPropagation();
            }
        }
    }

    // We hide all window content while dragging, to avoid the ugly "cheesing" effect
    private function _reactToResizeStart():void {
        if (!_currentlyResizing) {
            if (stage) {
                stage.addEventListener(MouseEvent.MOUSE_UP, _reactToResizeEnd);
            }
            _currentlyResizing = true;
            invalidateDisplayList();
        }
    }

    // We show back window content when done resizing
    private function _reactToResizeEnd(event:MouseEvent):void {
        if (_currentlyResizing) {
            if (stage) {
                stage.removeEventListener(MouseEvent.MOUSE_UP, _reactToResizeEnd);
            }
        }
        _currentlyResizing = false;
        invalidateDisplayList();
    }

    /**
     *  Triggered by a resize event of the stage. Sets the new width and height.
     *  After the SystemManager performs its function, it is only necessary to notify
     * the children of the change.
     */
    private function resizeHandler(event:Event):void {
        // When user has not specified any width/height,
        // application assumes the size of the stage.
        // If developer has specified width/height,
        // the application will not resize.
        // If developer has specified percent width/height,
        // application will resize to the required value
        // based on the current stage width/height.
        // If developer has specified min/max values,
        // then application will not resize beyond those values.

        var w:Number;
        var h:Number

        if (resizeWidth) {
            if (isNaN(percentWidth)) {
                w = DisplayObject(systemManager).width;
            } else {
                super.percentWidth = Math.max(percentWidth, 0);
                super.percentWidth = Math.min(percentWidth, 100);
                w = percentWidth * screen.width / 100;
            }

            if (!isNaN(explicitMaxWidth))
                w = Math.min(w, explicitMaxWidth);

            if (!isNaN(explicitMinWidth))
                w = Math.max(w, explicitMinWidth);
        } else {
            w = width;
        }

        if (resizeHeight) {
            if (isNaN(percentHeight)) {
                h = DisplayObject(systemManager).height;
            } else {
                super.percentHeight = Math.max(percentHeight, 0);
                super.percentHeight = Math.min(percentHeight, 100);
                h = percentHeight * screen.height / 100;
            }

            if (!isNaN(explicitMaxHeight))
                h = Math.min(h, explicitMaxHeight);

            if (!isNaN(explicitMinHeight))
                h = Math.max(h, explicitMinHeight);
        } else {
            h = height;
        }

        if (w != width || h != height) {
            invalidateProperties();
            invalidateSize();
        }

        setActualSize(w, h);

        invalidateDisplayList();
    }

    private function creationCompleteHandler(event:Event = null):void {
        systemManager.stage.nativeWindow.addEventListener(
                "closing", window_closingHandler);

        systemManager.stage.nativeWindow.addEventListener(
                "close", window_closeHandler, false, 0, true);

        systemManager.stage.nativeWindow.addEventListener(
                NativeWindowBoundsEvent.MOVING, window_boundsHandler);

        systemManager.stage.nativeWindow.addEventListener(
                NativeWindowBoundsEvent.MOVE, window_moveHandler);

        systemManager.stage.nativeWindow.addEventListener(
                NativeWindowBoundsEvent.RESIZING, window_boundsHandler);

        systemManager.stage.nativeWindow.addEventListener(
                NativeWindowBoundsEvent.RESIZE, window_resizeHandler);

    }

    private function preinitializeHandler(event:FlexEvent):void {
        systemManager.stage.nativeWindow.addEventListener(
                NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
                window_displayStateChangingHandler);
        systemManager.stage.nativeWindow.addEventListener(
                NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,
                window_displayStateChangeHandler);
    }

    private function window_boundsHandler(event:NativeWindowBoundsEvent):void {

        var newBounds:Rectangle = event.afterBounds;
        if (event.type == NativeWindowBoundsEvent.MOVING) {
            dispatchEvent(event);
            if (event.isDefaultPrevented())
                return;
        } else //event is resizing
        {
            dispatchEvent(event);
            if (event.isDefaultPrevented())
                return;
            var cancel:Boolean = false;
            if (newBounds.width < nativeWindow.minSize.x) {
                cancel = true;
                if (newBounds.x != event.beforeBounds.x && !isNaN(oldX))
                    newBounds.x = oldX;
                newBounds.width = nativeWindow.minSize.x;
            } else if (newBounds.width > nativeWindow.maxSize.x) {
                cancel = true;
                if (newBounds.x != event.beforeBounds.x && !isNaN(oldX))
                    newBounds.x = oldX;
                newBounds.width = nativeWindow.maxSize.x;
            }
            if (newBounds.height < nativeWindow.minSize.y) {
                cancel = true;
                if (event.afterBounds.y != event.beforeBounds.y && !isNaN(oldY))
                    newBounds.y = oldY;
                newBounds.height = nativeWindow.minSize.y;
            } else if (newBounds.height > nativeWindow.maxSize.y) {
                cancel = true;
                if (event.afterBounds.y != event.beforeBounds.y && !isNaN(oldY))
                    newBounds.y = oldY;
                newBounds.height = nativeWindow.maxSize.y;
            }
            if (cancel) {
                event.preventDefault();
                stage.nativeWindow.bounds = newBounds;
            }
        }
        oldX = newBounds.x;
        oldY = newBounds.y;
    }

    private function window_closeEffectEndHandler(event:Event):void {
        removeEventListener(EffectEvent.EFFECT_END, window_closeEffectEndHandler);
        if (!nativeWindow.closed)
            stage.nativeWindow.close();
    }

    private function window_closingHandler(event:Event):void {
        var e:Event = new Event("closing", true, true);
        dispatchEvent(e);
        if (e.isDefaultPrevented()) {
            event.preventDefault();
        } else if (getStyle("closeEffect") &&
                stage.nativeWindow.transparent) {
            addEventListener(EffectEvent.EFFECT_END, window_closeEffectEndHandler);
            dispatchEvent(new Event("windowClose"));
            event.preventDefault();
        }
    }

    private function window_closeHandler(event:Event):void {
        dispatchEvent(new Event("close"));

        // Event for Automation so we know when windows
        // are created or destroyed.
        if (FlexGlobals.topLevelApplication) {
            FlexGlobals.topLevelApplication.dispatchEvent(
                    new WindowExistenceEvent(WindowExistenceEvent.WINDOW_CLOSE,
                            false, false, this));
        }
    }

    private function window_resizeHandler(event:NativeWindowBoundsEvent):void {
        if (stage != null) {
            invalidateViewMetricsAndPadding();
            invalidateDisplayList();

            var dispatchWidthChangeEvent:Boolean = (bounds.width != stage.stageWidth);
            var dispatchHeightChangeEvent:Boolean = (bounds.height != stage.stageHeight);

            bounds.x = stage.x;
            bounds.y = stage.y;
            bounds.width = stage.stageWidth;
            bounds.height = stage.stageHeight;

            validateNow();
            var e:FlexNativeWindowBoundsEvent = new FlexNativeWindowBoundsEvent(FlexNativeWindowBoundsEvent.WINDOW_RESIZE,
                    event.bubbles, event.cancelable, event.beforeBounds, event.afterBounds);
            dispatchEvent(e);

            if (dispatchWidthChangeEvent) {
                dispatchEvent(new Event("widthChanged"));
            }
            if (dispatchHeightChangeEvent) {
                dispatchEvent(new Event("heightChanged"));
            }
        }
    }

    private function nativeApplication_activateHandler(event:Event):void {
        dispatchEvent(new AIREvent(AIREvent.APPLICATION_ACTIVATE));
    }

    private function nativeApplication_deactivateHandler(event:Event):void {
        dispatchEvent(new AIREvent(AIREvent.APPLICATION_DEACTIVATE));
    }

    private function nativeWindow_activateHandler(event:Event):void {
        dispatchEvent(new AIREvent(AIREvent.WINDOW_ACTIVATE));
    }

    private function nativeWindow_deactivateHandler(event:Event):void {
        dispatchEvent(new AIREvent(AIREvent.WINDOW_DEACTIVATE));
    }

    private function nativeApplication_networkChangeHandler(event:Event):void {
        dispatchEvent(event);
    }

    override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
        if (numChildren == 0 && index == 0) {
            _firstChild = (super.addChildAt(child, index) as UIComponent);
            return _firstChild;
        }
        return null;
    }

    override public function removeChildAt(index:int):DisplayObject {
        if (numChildren == 1 && index == 0) {
            _firstChild = null;
            return super.removeChildAt(index);
        }
        return null;
    }

    protected function fitWindowContent():void {
        if (!closed) {
            var haveValidContent:Boolean = _validateContent();
            if (haveValidContent) {
                _windowBounds = getBounds(this);
                if (_firstChild != null) {
                    _windowBounds = _firstChild.getBounds(this);
                }
                width = _windowBounds.right;
                height = _windowBounds.bottom;
                if (showStatusBar && statusBar != null) {
                    height += statusBar.height;
                }
                if (showTitleBar && titleBar != null) {
                    height += titleBar.height;
                    _firstChild.y = titleBar.height;
                }
                this.setActualSize(width, height);
            }
        }
    }
    private function _onApplicationClosing(event:Event):void {
    }

    private function _onMainAppActivated(event:AIREvent):void {
    }

    private function _onMainAppDeactivated(event:AIREvent):void {
    }

    private function _onPreinitialize():void {
        clipContent = false;
        horizontalScrollPolicy = ScrollPolicy.OFF;
        verticalScrollPolicy = ScrollPolicy.OFF;
        layout = 'absolute';
        width = 0;
        height = 0;
        FlexGlobals.topLevelApplication.addEventListener(Event.CLOSING, _onApplicationClosing);
        FlexGlobals.topLevelApplication.addEventListener(AIREvent.APPLICATION_DEACTIVATE, _onMainAppDeactivated);
        FlexGlobals.topLevelApplication.addEventListener(AIREvent.APPLICATION_ACTIVATE, _onMainAppActivated);
        addEventListener(FlexEvent.CREATION_COMPLETE, _onCreationComplete);
        addEventListener(FlexEvent.UPDATE_COMPLETE, _onUpdateComplete);
    }

    /**
     * Executed when window content is initialized and measured but not yet laid out. This is our earliest opportunity
     * to attempt to fit the window size to its content.
     * @param event
     */
    private function _onCreationComplete (event : FlexEvent):void {
        removeEventListener(FlexEvent.CREATION_COMPLETE, _onCreationComplete);
        if (_canFitContent) {
            fitWindowContent();
        }
    }

    /**
     * Executed when window content is initialized, measured and laid out. This is our second, and final, opportunity
     * to attempt to fit the window size to its content.
     * @param event
     */
    private function _onUpdateComplete(event:FlexEvent):void {
        removeEventListener(FlexEvent.UPDATE_COMPLETE, _onUpdateComplete);
        if (_canFitContent) {
            _canFitContent = false;
            fitWindowContent();
        }
        dispatchEvent(new Event(WINDOW_READY, false, false));
    }

    private function _validateContent():Boolean {
        return (numChildren == 1);
    }
}

}
