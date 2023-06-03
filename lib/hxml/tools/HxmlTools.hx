package hxml.tools;

import hxml.ds.BuildResult;
import hxml.ds.BuildOptions;
import hxml.ds.BuildFiles;

using StringTools;
using hxml.tools.BuildSetTools;
using hxml.tools.BuildFilesTools;

class HxmlTools {

	/**
	 * creates a txt string with the contents of 1 hxml file
	 * that contains all the commands. will not use "--each"
	 * and will separate multiple builds with "--next"
	 */
	public static function toHxmlFileString(hxml : Hxml) : String {
		var contents = "";
		for (s in 0 ... hxml.sets.length) {

			if (s > 0) contents += "--next\n";

			for (command in hxml.sets[s].lines) switch (command) {

				case Next | Each | HxmlFile(_) :
					throw 'error here';

				case Command(c,a):
					contents += c + " " + a + "\n";

				case Flag(c):
					contents += c + "\n";
			}
			
		}

		// trim off the last newline
		if (contents.charAt(contents.length-1) == "\n") contents = contents.substring(0, contents.length-1);

		return contents;
	}

	/**
	 * creates a string that can be sent to the haxe compiler for each
	 * build set
	 */
	public static function toCompilerCommands(hxml : Hxml) : Array<String> {
		var commands = [];
		
		for (buildSet in hxml.sets)
			commands.push(buildSet.toCompileCommand());

		return commands;
	}

	/**
	 * runs the haxe compiler commands, usually meaning a build of
	 * some artifact or target, but could be other things
	 */
	static public function build(hxmlFile : Hxml, ?options : BuildOptions) : Return<BuildResult> {

		var duration : Float = 0;

		var files : BuildFiles = null;
		var libraries : Map<String, String> = new Map();

		for (buildSet in hxmlFile.sets) {
			var runResult = buildSet.run(options);

#if result
			var runResult = switch(runResult) {
				case Error(e): return Error(e);
				case Ok(runResult): runResult;
			}
#end
			// we skip this one
			if(runResult == null) continue;

			duration += runResult.duration;

			if (files == null) files = runResult.files;
			else files.addTo(runResult.files);

			for (lib => ver in runResult.libraries) {
				var current = libraries.get(lib);

				// TODO: would there be a case where a single HXML file could build
				// multiple things but have different library versions? maybe i don't
				// need to worry about this.
				if (current != null && current != ver)
					return ReturnUnsupError('2 different versions of library $lib are used: $ver and $current');

				if (current == null) libraries.set(lib, ver);
			}
		}

		return Return.Ok({
			duration: duration,
			files: files,
			libraries: libraries,
			buildSet: null,
		});
	}

	inline private static function ReturnUnsupError<T>(message:String) : Return<T> {
#if error
		var error = new hxml.errors.EUnsupported(message);
#else
		var error = message;
#end
		return Return.Err(error);
	}

}
