package hxml;

import tracer.Debug.*;
import tracer.Warning.warning;
import tracer.Error.error;
import tracer.Print.print;

import ansi.Paint.paint;
import ansi.colors.Style;

import hxml.ds.*;

using tools.Strings;
using StringTools;

private inline var NAME : String = "hxml";

private enum Mode {
	Global;
	Group(a : Array<Command>);
}

class Hxml {

	public var file : String;
	private var commandGroups : Array<Array<Command>> = [ ];
	private var globalCommands : Array<Command> = [ ];

	public function new() { }

	////////////////////////////////////////////////////////////////////
	// PUBLIC ACCESS FUNCTIONS
	////////////////////////////////////////////////////////////////////

	/**
		* loads the contents of the file creating a new HXML object.
		*
		* @param filePath String the path of the hxml file
		* @param cwd String the optional working directory. if none is given than the
		*                   current working directory will be used
		*/
	public static function load(filePath : String, ?cwd : String) : Hxml {
		var hxml = new Hxml();

		// getting the full path to the file
		if (cwd == null) cwd = Sys.getCwd();
		hxml.file = haxe.io.Path.join([cwd, filePath]);
		// checking that it exists
		if (!sys.FileSystem.exists(hxml.file)) {
			error('cannot find file ${paint(hxml.file,Yellow)}', NAME);
			return hxml;
		}

		debug('parsing ${paint(hxml.file,Green)}', NAME);

		var mode : Mode = Global;
		var lines = tools.Fs.contentLines(hxml.file);
		for (lineNo in 0 ... lines.length) {
			var line = lines[lineNo].trim();

			// a comment
			if (line.substring(0,1) == "#") continue;

			// a command
			else if (line.substring(0,1) == "-") {
				
				if (line == "--next") {
					var g = [ ];
					hxml.commandGroups.push(g);
					mode = Group(g);
					continue;
				}

				var cmd = {
					command : line,
					line : lineNo + 1,
					file : hxml.file,
				}

				switch(mode) {
					case Global: hxml.globalCommands.push(cmd);
					case Group(group): group.push(cmd);
				}
			}

			// an additional hxml file
			else {

				var sub = load(line, cwd);
				var subCommands = sub.commands();

				switch ([mode, subCommands.length]) {

					// we have only been adding to the global space and the external
					// file only has 1 command, this means we should add it to the
					// global
					case [ Global, 1 ]:
						hxml.addToGlobal(... subCommands[0]);

					// we are in the global namespace and the external file has multiple
					// commands. we need to convert this to group space and start
					// adding each as a new group
					case [ Global, _ ]:

						for (sc in subCommands) {
							var g = [];
							hxml.commandGroups.push(g);
							mode = Group(g);

							for (cmd in sc) {
								g.push(cmd);
							}
						}

						//warning('global with ${subCommands.length} not implemented', NAME);

					// we are inside a group and the external file only has 1 command,
					// so we should roll it up.
					case [ Group(g), 1 ]:
						for (sc in subCommands[0]) g.push(sc);

					// we are inside a group and the external file has multiple commands,
					// we are going to have to split this into multiple groups based on
					// how many command groups are in the external file. we also need to
					// be careful of other commands that are beneath this one because they
					// should also split the commands; and we can't guarantee order
					case [ Group(g), _ ]:
						warning('group with ${subCommands.length} not implemented', NAME);
						
					case _:
				}

			}
		}

		// for (c in hxml.commands) trace('${c.command} >> ${paint(c.file, Yellow)}:${paint(c.line + "",Cyan)}');

		return hxml;
	}

	/**
		* creates the content of an "hxml" file.
		*/
	public function toFileContents() : String {
		var content = "";

		content += "# auto generated using the HXML library";

		for (gs in globalCommands) content += "\n" + gs.command;

		for (cg in commandGroups) {
			content += "\n\n--next";
			for (cmd in cg) content += "\n" + cmd.command;
		}

		return content;
	}

	/**
		* iterates through all the commands and runs a callback before executing the hxml
		* and an optional callback after finishing the execution
		*
		* @param check (check:commands:Array<Command>)->Bool a callback function that passes all the
		* commands as an arguement. The resulting bool should tell the function if the hxml should be
		* run. `True` will run the build, `False` will noh.
		*
		* @param post (result:RunResult)->Void a callback function that gives the result of the build
		* as an arguement.
		*
		* @param additionalCommands String any additional commands that will be passed to `haxe`
		* during the build. These will be included in the set of commands that are supplied with
		* the `check` and `post` callbacks.
		*/
	public function beforeEachRun(check : (commands : Array<Command>) -> CheckResult, ?post : (result : RunResult) -> Void, ... additionalCommands : String) : Bool {

		
		var commandSets = commands();
		for(c in 0 ... commandSets.length) {

			var build = ansi.Paint.paint('build' , White, Strike);
			var run = ansi.Paint.paint('run', White, Strike);
			{
				var left = "[";
				var right = "]";
				var divider = "/";
				var leftNo = paint(""+(c+1), Blue);
				var rightNo = paint(""+commandSets.length, Blue);
				print('command $left$leftNo $divider $rightNo$right  $build  $run', NAME, false);
			}
			var pos = ansi.Command.cursorPosition();
			if (pos == null) pos = {r:0,c:0};
			var posRun = pos.c - ansi.colors.ColorTools.length(run);
			var posBuild = posRun - ansi.colors.ColorTools.length(build) - 2;
			print(''); // a new line;

			var commands : Array<Command> = [];
			for (adc in additionalCommands) commands.push({command : adc, file: "", line: -1});
			for (cmd in commandSets[c]) commands.push(cmd);
		
			var crCheck = ansi.Command.cursorPosition();
			if (crCheck == null) crCheck = {r:0,c:0};
			switch(check(commands)) {
				case ExecuteOnly(n):
					debug('running command only', NAME);
					debug('running command only', NAME);
					// need to count the line I just made.
					debugRun(() -> n += 2);

					var start = Sys.time();
					var currentPos = ansi.Command.cursorPosition();
					if (currentPos == null) currentPos = {r:0,c:0};

					// determines the real position, we need to add
					// another `n` if we do have a difference (the
					// difference is because we are at the end of the
					// terminal's buffer)
					//var difference = (crCheck.r + n - currentPos.r);
					//if (difference != 0) difference += 1;
					if (crCheck.r == currentPos.r) {
						pos.r -= (1 + n);
					} else if (n == 0) n = 1;

					// pos.r -= difference;

					// only gets the --cmd lines
					var cmds = commands.filter((f) -> f.command.substr(0,5) == "--cmd");
					ansi.Command.moveCursor(pos.r, posRun);
					var result = runCommand(cmds, "run");
					// writing the build time.
					var elapsed = Math.floor(100*(Sys.time() - start))/100;
					ansi.Command.write(pos.r, pos.c + 1, '${paint(elapsed + "s",Yellow)} elapsed');

					ansi.Command.moveCursor(currentPos.r, currentPos.c);

					if (result == null) return false;

				case Build(n):
					debug('running build', NAME);
					// need to count the line I just made.
					debugRun(() -> n += 1);

					var start = Sys.time();
					var currentPos = ansi.Command.cursorPosition();
					if (currentPos == null) currentPos = {r:0,c:0};

					// determines the real position, we need to add
					// another `n` if we do have a difference (the
					// difference is because we are at the end of the
					// terminal's buffer)
					var difference = (crCheck.r + n - currentPos.r);
					if (difference != 0 || (difference == 0 && n == 0)) difference += 1;
					pos.r -= difference;

					ansi.Command.moveCursor(pos.r, posBuild);
					var result = runCommand(commands);
					// writing the build time.
					var elapsed = Math.floor(100*(Sys.time() - start))/100;
					ansi.Command.write(pos.r, pos.c + 1, '${paint(elapsed + "s",Yellow)} elapsed');
					ansi.Command.moveCursor(currentPos.r, currentPos.c);

					if (result != null && post != null) post(result);
					if (result == null) return false;

				case Skip(n):
					// we don't have to do anything because we aren't writing anything
					debug('skipping build, no files have changed', NAME);
					
			}
		}

		return true;
	}

	/**
		* gets a list of the executable targets in the hxml.
		*/
	public function getTargets() : Array<String> {
		var targets = [];

		for (cset in commands()) for (c in cset) {
			var s = c.command.split(" ");
			var command = s[0].replace("-","");

			if (command == "hl" || command == "neko" || command == "x") targets.push(s[1]);
		}

		return targets;
	}

	/////////////////////////////////////////////////////////////////////////
	// PRIVATE INTERNAL ASSISTANCE FUNCTIONS
	////////////////////////////////////////////////////////////////////////

	/**
		* runs the supplied commands using `haxe`
		*
		* @params commands Array<Command> a list of commands to run
		*
		* @params pos {r:Int,c:Int} the screen position that should be updated.
		* if nothing is given then the current screen position is used.
		*/
	private function runCommand(commands : Array<Command>, ?resultText : String = "build") : Null<RunResult> {

		var result : RunResult = {
			commands : commands,
			files : commandFiles(commands, haxe.io.Path.directory(file)),
		};

		var commandString = "";
		for (cmd in commands) commandString += processForCmdline(cmd) + " ";

		//debug(paint("running command: ", Yellow) + "haxe " + commandString, NAME);

		var process = new sys.io.Process("haxe " + commandString);	

		/////////////////////////////
		// some feedback to know it working

		var pos = ansi.Command.cursorPosition();
		if (pos == null) pos = {r:0,c:0};

		ansi.Command.hideCursor();

		var start = Sys.time();
		var time = 0.0;
		var speed = 1; // cycles per second

		var code = process.exitCode(false);
		while(code == null) {

			if (ansi.Mode.mode != Bare) {
				time = (Sys.time() - start);
				while(time > speed) time -= speed;

				var text = " " + resultText + " ";
				if (time / speed <= 0.5) {
					var pos = Math.ceil(time / speed / 0.5 * text.length);
					text = paint(text.substr(0, pos), White, Blue, Bold) +
						paint(text.substr(pos), Blue, Bold);
				} else {
					var pos = Math.floor(((time / speed) - 0.5) / 0.5 * text.length);
					text = paint(text.substr(0, pos), Blue, Bold) +
						paint(text.substr(pos), White, Blue, Bold);
				}
				
				ansi.Command.write(pos.r, pos.c - 1, text);
			}
			code = process.exitCode(false);
		}
		
		// need to clear the space
		if (ansi.Mode.mode != Bare) ansi.Command.write(pos.r, pos.c - 1, paint(" " + resultText + " ", White, null, Bold));

		//////////////////////////////////

		var out = process.stdout.readAll().toString();
		var err = process.stderr.readAll().toString();
		if (code == 0) {

			ansi.Command.write(pos.r, pos.c, ansi.Paint.paint(resultText, Green, Bold));
			// ansi.Command.write(pos.r, pos.c,'${paint("success", Green)} ${paint(""+Math.floor(100*(Sys.time() - start))/100 + "s",Cyan)} elapsed');
			// if it is successful then we should move the cursor to he bottom because we will
			// not have any more outputs, we are done with this chunk.
			process.close();
			return result;
		} else { 

			// if we error we should print the error message with the build line and show
			// the message at the bottom.
			var message = if (err.length > 0) err else out;
			ansi.Command.write(pos.r, pos.c, ansi.Paint.paint(resultText, Red, Bold));
			error( paint(message, Yellow), NAME);
			process.close();
			return null;
		}
	}

	private static function commandFiles(commands : Array<Command>, ?root : String) : Array<String> {
		var files = [];
		if (root == null) root = "";

		for (c in commands) {
			var short = c.file.substring(root.length);
			if (!files.contains(short)) files.push(short);
		}

		return files;
	}

	private function processForCmdline(cmd : Command) : String {
		if (cmd.command.substring(0,5) == "--cmd") return '--cmd "${cmd.command.substring(6)}"';
		return cmd.command;
	}
	
	private function addToGlobal( ... commands : Command) {
		for (c in commands) globalCommands.push(c);
	}

	private function commands() : Array<Array<Command>> {
		var cs = [ ];

		if (commandGroups.length == 0) {
			var c = [ ];
			for (gc in globalCommands) c.push(gc);
			cs.push(c);
		}

		else {
			for (ic in commandGroups) {
				var c = [ ];
				for (gc in globalCommands) c.push(gc);
				for (cmd in ic) c.push(cmd);
				cs.push(c);
			}
		}

		return cs;
	}

	/**
		* the count of commands
		*/
	private function length() : Int {
		if (commandGroups.length == 1) return 1;
		else if (commandGroups.length == 0 && globalCommands.length == 0) return 0;
		else if (commandGroups.length == 0 && globalCommands.length > 0) return 1;
		else return commandGroups.length;
	}
}
