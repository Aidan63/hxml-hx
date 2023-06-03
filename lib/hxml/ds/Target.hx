package hxml.ds;

using StringTools;

enum Target {
	Neko;
	Hashlink;
	Javascript;
	Flash;
	Php;
	Cpp;
	Cs;
	Java;
	JVM;
	Python;
	Lua;
	Cppia;
	Interp;
	Run;
}

function parseCommand(command : String) : Null<Target> {
	return switch(command.toLowerCase().trim()) {
		case "--js": Javascript;
		case "--swf": Flash;
		case "--neko" | "--x" : Neko;
		case "--php": Php;
		case "--cpp": Cpp;
		case "--cs": Cs;
		case "--java": Java;
		case "--jvm": JVM;
		case "--python": Python;
		case "--lua": Lua;
		case "--hl": Hashlink;
		case "--cppia": Cppia;
		case "--interp": Interp;
		case "--run": Run;
		case _: null;
	}
}
