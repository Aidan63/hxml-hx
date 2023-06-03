package hxml.errors;

#if ansi
import ansi.Paint.paint;
#end
import hxml.ds.SourceInfo;

/**
 * error when there are problems reading (parsing)
 * not because the user typed something wrong.
 *
 * these are issues with the parser,
 */
class EParse implements error.Error {
	public var command : String;
	public var arguments : String;
	public var info : SourceInfo;
	public var reason : String;

	public function new(command : String, arguments : String, info : SourceInfo, reason : String) {
		this.command = command;
		this.arguments = arguments;
		this.reason = reason;
	}

	public function msg() : String {
		return "not implemented";
	}
}
