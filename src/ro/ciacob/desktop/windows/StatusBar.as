

package ro.ciacob.desktop.windows {
	
	import flash.display.DisplayObject;
	
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.core.IUITextField;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.core.mx_internal;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.ISimpleStyleClient;
	import mx.styles.IStyleClient;
	
	import ro.ciacob.utils.constants.CommonStrings;
	
	use namespace mx_internal;
	
	[Style(name="statusBarPaddingLeft", format="Number", inherit="yes")]
	[Style(name="statusBarPaddingRight", format="Number", inherit="yes")]
	[Style(name="statusBarPaddingTop", format="Number", inherit="yes")]
	[Style(name="statusBarPaddingBottom", format="Number", inherit="yes")]
	
	/**
	 *  The default status bar for a WindowedApplication or a Window.
	 * 
	 *  @see mx.core.Window
	 *  @see mx.core.WindowedApplication
	 * 
	 *  
	 *  @langversion 3.0
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class StatusBar extends UIComponent {
		
		private static var classConstructed:Boolean = classConstruct ();
		
		/**
		 * Provides default values for this component's own styles
		 */
		private static function classConstruct():Boolean {
			if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration ("ro.ciacob.desktop.windows.StatusBar")) {
				var myStyles : CSSStyleDeclaration = new CSSStyleDeclaration;
				myStyles.defaultFactory = function() : void {
					this.statusBarPaddingLeft = 2;
					this.statusBarPaddingRight = 25;
					this.statusBarPaddingTop = 2;
					this.statusBarPaddingBottom = 2;
				}
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("ro.ciacob.desktop.windows.StatusBar", myStyles, true);
			}
			return true;
		}
		
		/**
		 * Flag indicating that a style property has changed.
		 */ 
		private var bStypePropChanged:Boolean = true;
		
		private var _statusBarPaddingLeft : Number;
		private var _statusBarPaddingRight : Number;
		private var _statusBarPaddingTop : Number;
		private var _statusBarPaddingBottom : Number;
		
		/**
		 *  Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function StatusBar():void {
			super();
		}
		
		/**
		 *  A reference to the status bar's skin.
		 */
		mx_internal var statusBarBackground:IFlexDisplayObject;
		
		/**
		 *  Storage for the status property.
		 */
		private var _status:String = "";
		
		private var statusChanged:Boolean = false;
		
		/**
		 *  The string that appears in the status bar, if it is visible.
		 * 
		 *  @default ""
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get status():String {
			return _status;
		}    
		
		public function set status (value:String) : void {
			_status = value;
			statusChanged = true;
			invalidateProperties();
			invalidateSize();
		}

		
		/**
		 *  A reference to the UITextField that displays the status bar's text.
		 *  
		 *  @langversion 3.0
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public var statusTextField:IUITextField;
		
		override protected function createChildren():void {
			super.createChildren();
			
			var statusBarBackgroundClass : Class = getStyle ("statusBarBackgroundSkin");
			if (statusBarBackgroundClass) {
				statusBarBackground = new statusBarBackgroundClass();
				var backgroundUIComponent : IStyleClient = (statusBarBackground as IStyleClient);     
				if (backgroundUIComponent) {
					backgroundUIComponent.setStyle ("backgroundImage", undefined);
				}
				var backgroundStyleable : ISimpleStyleClient = (statusBarBackground as ISimpleStyleClient);
				if (backgroundStyleable) {
					backgroundStyleable.styleName = this;
				}
				addChild (DisplayObject (statusBarBackground));
			}
			
			if (!statusTextField) {
				statusTextField = IUITextField (createInFontContext(UITextField));
				statusTextField.styleName = getStyle ("statusTextStyleName");
				statusTextField.enabled = true;
				addChild (DisplayObject (statusTextField));
			}
		}
		
		override protected function commitProperties() : void {
			super.commitProperties();
			
			if (statusChanged) {
				statusTextField.text = _status;
				statusChanged = false;
			}
		}
		
		override protected function measure() : void {
			super.measure();
			statusTextField.validateNow();
			if (statusTextField.textHeight == 0) {
				statusTextField.text = " ";
				statusTextField.validateNow();
			}
			
			if (bStypePropChanged) {
				bStypePropChanged = false;
				_statusBarPaddingLeft = (getStyle ('statusBarPaddingLeft') as Number);
				_statusBarPaddingRight = (getStyle ('statusBarPaddingRight') as Number);
				_statusBarPaddingTop = (getStyle ('statusBarPaddingTop') as Number);
				_statusBarPaddingBottom = (getStyle ('statusBarPaddingBottom') as Number);
			}
			
			measuredHeight = (statusTextField.textHeight + _statusBarPaddingTop + _statusBarPaddingBottom);
			measuredWidth = (statusTextField.textWidth + _statusBarPaddingLeft + _statusBarPaddingRight);
		}
		
		override protected function updateDisplayList (w : Number, h : Number) : void {
			super.updateDisplayList (w, h);
			if (statusBarBackground != null) {
				statusBarBackground.setActualSize (w, h);
			}
			var textW : Number = (w - _statusBarPaddingLeft - _statusBarPaddingRight);
			var textH : Number = statusTextField.getExplicitOrMeasuredHeight();
			statusTextField.text = _status;
			statusTextField.truncateToFit (CommonStrings.ELLIPSIS);
			statusTextField.setActualSize (textW, textH);
			statusTextField.move (_statusBarPaddingLeft, _statusBarPaddingTop);
		}
		
		override public function styleChanged (styleProp : String) : void {
			super.styleChanged (styleProp);
			var allStyles : Boolean = (!styleProp || styleProp == "styleName");
			
			if (allStyles || styleProp == "statusBarBackgroundSkin") {
				var statusBarBackgroundClass:Class = getStyle("statusBarBackgroundSkin");
				if (statusBarBackgroundClass) {
					if (statusBarBackground) {
						removeChild (DisplayObject (statusBarBackground));
						statusBarBackground = null;
					}
					statusBarBackground = new statusBarBackgroundClass();
					var backgroundUIComponent:IStyleClient = statusBarBackground as IStyleClient;     
					if (backgroundUIComponent) {
						backgroundUIComponent.setStyle ("backgroundImage", undefined);
					}
					var backgroundStyleable:ISimpleStyleClient = (statusBarBackground as ISimpleStyleClient);
					if (backgroundStyleable) {
						backgroundStyleable.styleName = this;
					}
					addChildAt (DisplayObject (statusBarBackground), 0);
				}
				invalidateDisplayList();
			}
			
			if (allStyles || styleProp == "statusTextStyleName") {
				if (statusTextField) {
					statusTextField.styleName = getStyle("statusTextStyleName");
				}
				invalidateDisplayList();
			}
			
			if (allStyles || 
				styleProp == 'statusBarPaddingLeft'  ||
				styleProp == 'statusBarPaddingRight' || 
				styleProp == 'statusBarPaddingTop'   ||
				styleProp == 'statusBarPaddingBottom') {
				bStypePropChanged = true;
				invalidateSize ();
				invalidateDisplayList ();	
			}
		}
	}
	
}

