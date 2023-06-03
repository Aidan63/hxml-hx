package hxml;

import hxml.ds.BuildSet;
import hxml.ds.Target;
using hxml.tools.BuildSetTools;

class Hxml {

	public static var tempFilePath = "temp";

	///////////////////////////////////////

	public var sets : Array<BuildSet>;
	public var source : String;

	///////////////////////////////////////

	private function new() { }

	/**
	 * Gets the total count and "type" of targets for
	 * this hxml file.
	 *
	 * `Target` index does not guarantee to match up with 
	 * `BuildSet` index as there could be buildSets that don't
	 * generate a target.
	 */
	public function getTargets() : Return<Array<Target>> {
		var targets = [];

		for (buildSet in sets) {

#if result

			switch(buildSet.getTarget()) {
				case Error(e): return Error(e);
				case Ok(target):
					if (target != null) targets.push(target);
			}

#else

			targets.push(buildSet.getTarget());

#end

		}

		return Return.Ok(targets);
	}
	
	///////////////////////////////////////////////

	public static function load(path : String) : Return<Hxml> {
		if (!sys.FileSystem.exists(path))
			return fileAccessError(path);

		var content = sys.io.File.getContent(path);
		return parse(content, path);
	}

	inline private static function fileAccessError(path : String) : Return<Hxml> {
#if error
		var error = new hxml.errors.EFileAccess(path);
#else
		var error = 'cannot access file $path';
#end
		return Return.Err(error);
	}

	/**
	 * `soure` is only used in debug and error handling.
	 * may be useful to the user of the final application.
	 */
	public static function parse(content : String, ?source : String) : Return<Hxml> {
		var hxml = new Hxml();
		hxml.source = source;

		var parsed = Parser.parse(content, source);

#if result

		switch(parsed) {
			case Ok(sets): hxml.sets = sets;
			case Error(e): return Error(e);
		}

#else

		hxml.sets = parsed;

#end

		return Return.Ok(hxml);
	}

	///////////////////////////////////////////////////
}
