package ro.ciacob.desktop.windows {

	public interface IWindowsCatalogue {
		function add (window : Window, uid : String, style : int, counter : int) : void;
		function lookup (uid : String) : WindowRecord;
		function get uids () : Array;
	}
}
