package hxml.ds;

import hxml.ds.BuildFiles;

typedef BuildResult = {
	?buildSet : BuildSet,

	duration: Float,

	files: BuildFiles,

	// name, version
	libraries: Map<String, String>,
};
