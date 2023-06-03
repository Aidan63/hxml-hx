package hxml.errors;

#if ansi
import ansi.Paint.paint;
#end
import hxml.ds.SourceInfo;

/**
 * error because the syntax of the hxml file
 * is wrong
 */
class ESyntax implements error.Error {
	public var info : SourceInfo;
	public var reason : String;

	public function new(info : SourceInfo, reason : String) {
		this.reason = reason;
	}

	public function msg() : String {
		return "not implemented";
	}
}
