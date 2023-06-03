package hxml.ds;

enum Line {
	Flag(flag : String);
	Command(flag : String, parameter : String);
	HxmlFile(path : String);
	Next;
	Each;
}

#if result
function parse(command : String, arguments : String) : result.Result<Line, Array<String>> {
#else
function parse(command : String, arguments : String) : Line {
#end

	if (command.length == 0 && arguments.length > 0) {
		command = arguments;
		arguments = "";
	}

	var line : Line = null;

	if (command.length > 5 && command.substring(command.length-5) == ".hxml" && arguments.length == 0)
		line = HxmlFile(command);

	else if (command == "--next" && arguments.length == 0)
		line = Next;

	else if (command == "--each" && arguments.length == 0)
		line = Each;

	else if (command.length > 0 && command.substring(0,1) == "-" && arguments.length == 0)
		line = Flag(command);

	else if (command.length > 0 && command.substring(0,1) == "-" && arguments.length > 0)
		line = Command(command, arguments);

#if result
	if (line == null) return Error([command,arguments]);
	else return Ok(line);
#else
	if (line == null) throw('error parsing "$command" "$arguments": dont know what to do');
	else return line;
#end
}

function equals(a : Line, b : Line) : Bool {
	switch ([a, b]) {
		case [Flag(fa), Flag(fb)]:
			return fa == fb;

		case [Command(fa, pa), Command(fb, pb)]:
			return fa == fb && pa == pb;

		case [HxmlFile(pa), HxmlFile(pb)]:
			return pa == pb;

		case [Next, Next]: return true;
		case [Each, Each]: return true;

		case _: return false;
	}
}
