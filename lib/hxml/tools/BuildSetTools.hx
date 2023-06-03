package hxml.tools;

import hxml.ds.Target;
import hxml.ds.BuildSet;
import hxml.ds.BuildResult;
import hxml.ds.BuildOptions;
import hxml.ds.BuildFiles;

using StringTools;
using hxml.tools.BuildFilesTools;

class BuildSetTools {

	public static function getTarget(buildSet : BuildSet) : Return<Null<Target>> {
		var target : Target = null;

		for (command in buildSet.lines) switch(command) {
			case Next | Each | HxmlFile(_):

			case Flag(flag) | Command(flag, _):
				var parsed = hxml.ds.Target.parseCommand(flag);
				if (parsed != null) {
					if (target == null) target = parsed;
					else {
						var message = 'Each HXML Build Set can only have 1 target';
						return ReturnBuildError(buildSet, 1, message);
					}
				}
		}

		return Return.Ok(target);
	}

	public static function toCompileCommand(buildSet : BuildSet) : String {
		var command = "";
		for (comm in buildSet.lines) switch (comm) {
			case Next | Each | HxmlFile(_) :
				// TODO: maybe make this a real error?
				throw 'error here';

			case Command(c,a):
				command = (command + " " + c + " \"" + a.replace("\"","\\\"") + "\"").trim();

			case Flag(c):
				command = (command += " " + c).trim();
		}

		return command;
	}

	public static function run(buildSet : BuildSet, ?options : BuildOptions) : Return<Null<BuildResult>> {
		options = hxml.ds.BuildOptions.generate(options);

		var command = toCompileCommand(buildSet);
		command += ' --xml ${hxml.Hxml.tempFilePath}';
		if (options.extraCommands != null) for (extra in options.extraCommands) {
			command += " " + extra;
		}

		if (options.startFunc != null) {
			if (options.startFunc(buildSet) == false) {
				return Return.Ok(null);
			}
		}

		// TODO: add error handling
		var process = new sys.io.Process("haxe " + command);
		var code : Null<Int> = null;

		// originally was using the non-blocking `process.exitCode(false)` but
		// it seems that is not supported on may platforms, so instead using a
		// thread to check the code status, that way we can block this thread
		// but not the main thread.
		sys.thread.Thread.create(() -> {
			code = process.exitCode();
		});

		var start = Sys.time();
		var last = 0.0;
		var progress = 0.0;
		var time = 0.0;

		while(code == null) {
			progress += Sys.time() - last;
			if (progress > options.updateTick) {
				if (options.updateFunc != null) options.updateFunc();
				progress = 0;
			}
			last = Sys.time();
			// code = process.exitCode(false);  // from the old non-blocking implementation
		}

		var duration = Sys.time() - start;
		var out = process.stdout.readAll().toString().trim();
		var err = process.stderr.readAll().toString().trim();
		process.close();

		switch (code) {
			case 0:
				var buildResult : BuildResult = {
					duration: duration,
					files: getTouchedFiles(),
					libraries: getLibraries(),
					buildSet: buildSet, 
				};

				if (options.endFunc != null) options.endFunc(buildResult);

				return Return.Ok(buildResult);

			case 1:
				if (options.endFunc != null) options.endFunc(null);
				return ReturnBuildError(buildSet, 1, err);

			case other:
				if (options.endFunc != null) options.endFunc(null);
				return ReturnBuildError(buildSet, other, "unknown exitcode");
		}
	}

	private static function getLibraries() : Map<String, String> {
		var libraries : Map<String, String> = new Map();

		// TODO: add error handling
		var process = new sys.io.Process("haxelib list");
		var out = process.stdout.readAll().toString().trim();
		var err = process.stderr.readAll().toString().trim();
		process.close();

		var checker = new EReg("([A-Za-z]*):[^\\[]*\\[([^\\]]*)\\]", "g");
		for (line in out.split("\n")) {
			if (checker.match(line)) {
				var version = checker.matched(2);
				// checking if this is a dev thing
				if (version.length > 4 && version.substring(0,4) == "dev:")
					version = "dev";
					//version = version.substring(4);
				libraries.set(checker.matched(1), version);
			}
		}

		return libraries;
	}

	private static function getLibraryPaths(libs : Map<String, String>) : Map<String, String> {
		var paths : Map<String, String> = new Map();

		for (lib in libs.keys()) {
			// TODO: add error handling
			var process = new sys.io.Process('haxelib path $lib');
			var out = process.stdout.readAll().toString().trim();
			var err = process.stderr.readAll().toString().trim();
			process.close();

			var path = out.split("\n")[0].trim();
			paths.set(lib, path);
		}

		return paths;
	}

	/**
	 * Meaning the files that were used in the build.
	 */
	private static function getTouchedFiles() : BuildFiles {

		var files : BuildFiles =  {
			project: [],
			lib: new Map(),
			core: [],
		};

		var libraryPaths = getLibraryPaths(getLibraries());

		var xmlContent = sys.io.File.getContent(hxml.Hxml.tempFilePath);
		var xml = haxe.xml.Parser.parse(xmlContent);
		var dirSlash = haxe.io.Path.addTrailingSlash("");

		for (el in xml.elements()) {
			for (cs in el.elements()) {
				var file = cs.get("file");
				if (file != null) {
					var absPath = sys.FileSystem.absolutePath(file);

					if (absPath != file) {
						// relative path file, so it is part of the project.
						if (!files.project.contains(file)) files.project.push(file);

					} else {
						// checking if these are library files

						var isLib = false;
						for (lib => libPath in libraryPaths) {
							if (file.substring(0,libPath.length) == libPath) {
								files.addLibFile(lib, file);
								isLib = true;
								break;
							}
						}

						if (!isLib && !files.core.contains(file)) files.core.push(file);
					}
				}
			}
		}

		sys.FileSystem.deleteFile(hxml.Hxml.tempFilePath);

		return files;
	}

	inline private static function ReturnBuildError<T>(buildSet:BuildSet, code:Int, message:String) : Return<T> {
#if (error)
		var error = new hxml.errors.EBuild(buildSet.source, 1, message);
#else
		var error = message;
#end
		return Return.Err(error);
	}

}
