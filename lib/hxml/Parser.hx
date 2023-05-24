package hxml;

import tracer.Debug.debug;

using tools.Strings;
using StringTools;

private enum Mode {
	Each;
	Next;
}

private var NAME : String = "hxml/parser";

/**
	* a parser for hxml files
	*
	*/
class Parser {

	public static function parse(path : String, ?cwd : String) {
		var hxml = new Hxml();
		
		hxml.load(path, cwd);

		//var hxml = makeHxml(path, cwd);
		// trace("\n" + hxml.commandString());
		trace("\n" + hxml.buildFile());
	}

	private static function makeHxml(path : String, ?cwd : String) : hxml.Hxml {
		debug('parsing ${ansi.Paint.paint(path,Green)}', NAME);

		if (cwd == null) cwd = Sys.getCwd();
		var fullPath = haxe.io.Path.join([cwd, path]);

		var hxml = new hxml.Hxml();
		var mode : Mode = Each;

		for (l in lines(fullPath)) {
			var line = l.trim();

			// this is a comment, nothing to note here
			if (line.substring(0,1) == "#") continue;
			// this is a command or something.
			else if (line.substring(0,1) == "-") {
				if (line == "--next") {
					trace('next');
					hxml.newRun();
					mode = Next;
				} else if (line == "--each") mode = Each;
				else {
					debug('adding "${ansi.Paint.paint(line,Green)}" to $mode', NAME);
					switch (mode) {
						case Next: hxml.addToRun(line);
						case Each: hxml.addToGlobal(line);
					}
				}
			}
			// lastly then this must be some kind of hxml file
			else if (line.length > 0) {
				debug('requested from ${ansi.Paint.paint(path,Green)} in $mode', NAME);
				var newhxml = makeHxml(line, cwd);
				var instructions = newhxml.resolve();
				if(instructions.length > 1) {
					hxml.newRun();
					for (i in instructions) hxml.addToRun( ... i);
				}
				else if (hxml.commands() == 1) for (i in instructions) hxml.addToGlobal( ... i);

				/*
					switch (mode) {
					case Next:
						for (i in newhxml.resolve()) hxml.addToRun(... i);
					case Each:
						for (i in newhxml.resolve()) hxml.addToGlobal(... i);
				}*/
				//hxml.buildFile();
			}

		}
		return hxml;
	}

	private static function lines(path : String) : Array<String> {
		if (!sys.FileSystem.exists(path)) {
			debug('${ansi.Paint.paint(path, Cyan)} does not exist, ${ansi.Paint.paint("skipping", Yellow)}');
			return [ ];
		}

		var contents = sys.io.File.getContent(path);
		return contents.lines();
	}

}
