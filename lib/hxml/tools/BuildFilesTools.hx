package hxml.tools;

import hxml.ds.BuildFiles;

class BuildFilesTools {
	/**
	 * Cleanly adds two BuildFiles, used for combining
	 * sets of files from different BuildSets on the final
	 * Hxml BulidResult result will have 1 set of files
	 */
	public static function addTo(a : BuildFiles, b : BuildFiles) {
		for (p in b.project) if (!a.project.contains(p)) a.project.push(p);

		for (c in b.core) if (!a.core.contains(c)) a.core.push(c);

		for (lib => files in b.lib) {
			var alib = getLibs(a, lib);
			for (l in files) if (!alib.contains(l)) alib.push(l);
		}
	}

	/**
	 * Helper that allows for short syntax to safely get list of library files
	 */
	 inline public static function getLibs(buildFiles : BuildFiles, libraryName : String) : Array<String> {
		return if (buildFiles.lib.exists(libraryName)) buildFiles.lib.get(libraryName);
			else {
				var l = [];
				buildFiles.lib.set(libraryName, l);
				l;
			}
	}

	/**
	 * Helper that safely adds a library file
	 */
	inline public static function addLibFile(buildFiles : BuildFiles, libraryName : String, file : String) {
		var files = getLibs(buildFiles, libraryName);
		if (!files.contains(file)) files.push(file);
	}
}

