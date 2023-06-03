package hxml.ds;

/**
 * Returns a boolean which tells the build command if we should
 * continue with the build
 */
typedef Start = (set : BuildSet) -> Bool;

typedef Update = () -> Void;

typedef End = (result : Null<BuildResult>) -> Void;

