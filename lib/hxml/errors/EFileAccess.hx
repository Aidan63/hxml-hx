package hxml.errors;

#if ansi
import ansi.Paint.paint;
#end

class EFileAccess implements error.Error {
	public var path : String;
	public function new(path : String) {
		this.path = path;
	}

	public function msg() : String {
#if ansi
		return 'path "${paint(path, Cyan)}" does not exist';
#else
		return 'path "$path" does not exist';
#end
	}
}
