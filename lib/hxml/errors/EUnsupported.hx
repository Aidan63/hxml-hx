package hxml.errors;

/**
 * error because something doesn't work, or is not implemented
 * but probably should be in the future.
 */
class EUnsupported implements error.Error {
	public var details : String;

	public function new(msg : String) {
		this.details = msg;
	}

	public function msg() : String {
		return details;
	}
}
