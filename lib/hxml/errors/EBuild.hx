package hxml.errors;

#if ansi
import ansi.Paint.paint;
#end
import hxml.ds.SourceInfo;

/**
 * error used for issues with using the haxe compile
 */
class EBuild implements error.Error {
	public var exitCode : Int;
	public var reason : String;
	public var file : String;

	public function new(file : String, exitCode : Int, reason : String) {
		this.exitCode = exitCode;
		this.reason = reason;
		this.file = file;
	}

	public function msg() : String {
		return "not implemented";
	}
}
