package hxml;

import hxml.ds.BuildSet;
import hxml.ds.Line;

using StringTools;

class Parser {

	/////////////////////////////////////////

	private var text : String;
	private var cursor : Int = 0;

	private var source : String;
	private var line : Int = 0;
	private var lineStartPos : Int = 0;

	// a switch to increment the new line start position variable
	// used for tracing, errors, and debug
	private var newLine : Bool = false;

	/////////////////////////////////////////

	private function new(content : String) {
		this.text = content;
	}

	private function nextLine() : Null<Return<Line>> {
		var char;
		var working : String = "";
		// we are calling the command the line in the hxml file.
		// the command would be the first part, which dictates what
		// the compiler will do / modify
		var command : String = "";

		while ((char = text.charAt(cursor++)) != "") {

			if (newLine) {
				// need to subtract 1 because we added one in the while loop
				lineStartPos = cursor-1;
				newLine = false;
			}

			switch(char) {
				case "#":
					// We are not doing anything with the comments now, so just
					// consume up to the end of the line and throw them away.
					while ((char = text.charAt(cursor++)) != "\n" && char != "\r" && char != "") { }
					cursor -= 1;

					// Here to catch if this comment was on a line with a command
					// not sure if that is supported in the official hxml format,
					// but we are going to support it here.
					if (working.length != 0 || command.length != 0)
						return makeEParse(hxml.ds.Line.parse(command, working));

				case " ":
					if (command.length == 0) {
						command = working;
						working = "";
					} else {
						working += char;
					}

				case "\n" | "\r":
					// because sometime we have both of these, so we are 
					// only going to count \n
					if (char == "\n") {
						line += 1;
						newLine = true;
					}

					// check so we can have empty lines
					if (working.length != 0 || command.length != 0)
						return makeEParse(hxml.ds.Line.parse(command, working));

				case _:
					working += char;
			}
		}

		// Catches the tailing command
		if (working.length != 0 || command.length != 0)
			return makeEParse(hxml.ds.Line.parse(command, working));

		return null;
	}

	///////////////////////////////////////////////////

	inline private function getTraceInfo() : hxml.ds.SourceInfo {
		return {
			file: source, line: line,
			text: text.substring(lineStartPos, cursor).trim(),
			pos: cursor - lineStartPos,
		}
	}

#if (result && error)

	inline private function makeEParse<T>(r : result.Result<T, Array<String>>) : result.Result<T, error.Error> {
		switch(r) {
			case Error(params):
				return Error(new hxml.errors.EParse(params[0], params[1], getTraceInfo(), params[2]));
			case Ok(value):
				return Ok(value);
		}
	}

#elseif result

	inline private function makeEParse<T>(r : result.Result<T, Array<String>>) : result.Result<T, String> {
		switch(r) {
			case Error(params):
				return Error('error parsing ${params[0]} ${params[1]}: ${params[2]}');
			case Ok(value):
				return Ok(value);
		}
	}

#else

	inline private function makeEParse<T>(t:T):T {
		return t;
	}

#end

	///////////////////////////////////////////////////

	static public function parse(content : String, ?source : String) : Return<Array<BuildSet>> {
		var parser = new Parser(content);
		parser.source = source;

		var globals : Array<Line> = [];
		var current : Array<Line> = [];
		var sets : Array<BuildSet> = [];

		var line;
		while ((line = parser.nextLine()) != null) {

#if result
			var line = switch(line) {
				case Error(e): return Error(e);
				case Ok(line): line;
			}
#end

				switch(line) {
					case Each:
						if (globals.length > 0) {
							var message = 'Cannot have more than 1 "--each" in an hxml file';
							#if error
								var error = new hxml.errors.ESyntax(parser.getTraceInfo(), message);
							#else
								var error = message;
							#end
							return Return.Err(error);
						}

						globals = current;
						current = [];

					case Next:
						addToSet(sets, globals, current, source);
						current = [];

					case HxmlFile(path):
						var subFile = hxml.Hxml.load(path);

#if result
						var subFile = switch(subFile) {
							case Error(e): return Error(e);
							case Ok(subfile): subfile;
						}
#end

						// TODO: what was this error for again? why was this a problem? write a blurb
						if (subFile.sets.length != 1) {
							var message = 'I do not know how to parse a file with {subFile.sets.length} different sets';
							#if error
								var error = new hxml.errors.ESyntax(parser.getTraceInfo(), message);
							#else
								var error = message;
							#end
						}

						for (command in subFile.sets[0].lines)
							current.push(command);

					case _:
						current.push(line);

			}
		}

		// catches the last set.
		if (current.length > 0)
			addToSet(sets, globals, current, source);

		return Return.Ok(sets);
	}

	///////////////////////////////////////////////////

	/**
	 * Helper wrapper that cleans up the code. Adds global variable (if exists)
	 * to the beginning of the current set lines. The adds to the set. Used in 
	 * buildSet construction.
	 */
	inline static private function addToSet(sets : Array<BuildSet>, globals : Array<Line>, current : Array<Line>, source : String) {
		for (g in 0 ... globals.length)
			current.unshift(globals[globals.length - 1 - g]);

		sets.push({
			lines: current,
			source: source,
			index: sets.length + 1,
		});
	}

	///////////////////////////////////////////////////
}
