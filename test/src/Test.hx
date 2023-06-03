import utest.Runner;
import utest.ui.Report;

class Test {
	inline private static var LIBRARIES : String =
#if (ansi)
		" ansi," +
#end
#if (error)
		" error," +
#end
#if (result)
		" result," +
#end
		"";

	public static function main() {
		Sys.println('\nOptional Libraries:$LIBRARIES');
		Sys.println("========================================================");
		var runner = new Runner();
		runner.addCase(new TestParser());
		var report = Report.create(runner);
		report.displayHeader = NeverShowHeader;
		report.displaySuccessResults = NeverShowSuccessResults;
		runner.run();
	}
}
