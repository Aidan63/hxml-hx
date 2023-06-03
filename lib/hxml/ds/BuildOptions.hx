package hxml.ds;

typedef BuildOptions = {
	// a function that will be called before a build begins
	?startFunc: BuildFunc.Start,
	// a function that is called at a predefined update frequency
	// while the build is still occuring
	?updateFunc: BuildFunc.Update,
	// a function that is called when the build is stopped, regardless
	// of the outcome
	?endFunc: BuildFunc.End,
	// the frequency of the update function
	?updateTick: Float,
	// extra commands that are passed to the haxe compiler
	?extraCommands : Array<String>
};

private final default_values : BuildOptions = {
		updateTick: 0.05, // in seconds
}

function generate(?options : BuildOptions) : BuildOptions {
	if (options == null) options = {};

	for (key in Reflect.fields(default_values)) {
		if (!Reflect.hasField(options, key))
			Reflect.setProperty(options, key, Reflect.getProperty(default_values, key));
	}

	return options;
}
