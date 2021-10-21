package ro.ciacob.desktop.windows {
	import flash.events.EventDispatcher;

	import ro.ciacob.utils.Objects;

	public class WindowsCatalogue extends EventDispatcher implements IWindowsCatalogue {

		/**
		 * @constructor
		 */
		public function WindowsCatalogue () : void {}

		private var _currentBlocker:String;

		private var _records:Object = {};

		public function add(window:Window, uid:String, style:int, counter:int):void {
			Objects.assertNonExisting(uid, _records);
			var record:WindowRecord = new WindowRecord(window, uid, style, counter);
			record.setCatalogue(this);
			_records[uid] = record;
		}



		public function lookup(uid:String):WindowRecord {
			Objects.assertExisting(uid, _records);
			return _records[uid] as WindowRecord;
		}

		public function get uids():Array {
			return Objects.getKeys(_records);
		}
	}
}
