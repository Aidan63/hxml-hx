import hxml.Hxml;
import utest.Assert;

import hxml.ds.Line;

using hxml.tools.HxmlTools;
using hxml.tools.BuildSetTools;

#if result
using result.ResultTools;
#end

class TestParser extends utest.Test {

		function testSomeBadStuff() {
			testFail("Hxml.load", function() { return Hxml.load("nothing/is/here"); });
		}

		function testSingle() {

			var hxml = load("test/test-files/Single.hxml");

			Assert.equals(1, hxml.sets.length);
			assertLineEq(Line.Command("--class-path", "src"), hxml.sets[0].lines[0]);
			assertLineEq(Line.Command("--dce", "full"), hxml.sets[0].lines[1]);
			assertLineEq(Line.Command("--js", "bin/homepage.js"), hxml.sets[0].lines[2]);
			assertLineEq(Line.Command("--main", "website.HomePage"), hxml.sets[0].lines[3]);
		}

		function testMultiple() {
	
			var hxml = load("test/test-files/Multiple.hxml");

			Assert.equals(3, hxml.sets.length);
			assertLineEq(Line.Command("--class-path", "src"), hxml.sets[0].lines[0]);
			assertLineEq(Line.Command("--dce", "full"), hxml.sets[0].lines[1]);
			assertLineEq(Line.Command("--js", "bin/homepage.js"), hxml.sets[0].lines[2]);
			assertLineEq(Line.Command("--main", "website.HomePage"), hxml.sets[0].lines[3]);

			assertLineEq(Line.Command("--class-path", "src"), hxml.sets[1].lines[0]);
			assertLineEq(Line.Command("--dce", "full"), hxml.sets[1].lines[1]);
			assertLineEq(Line.Command("--js", "bin/gallery.js"), hxml.sets[1].lines[2]);
			assertLineEq(Line.Command("--main", "website.GalleryPage"), hxml.sets[1].lines[3]);

			assertLineEq(Line.Command("--class-path", "src"), hxml.sets[2].lines[0]);
			assertLineEq(Line.Command("--dce", "full"), hxml.sets[2].lines[1]);
			assertLineEq(Line.Command("--js", "bin/contact.js"), hxml.sets[2].lines[2]);
			assertLineEq(Line.Command("--main", "website.ContactPage"), hxml.sets[2].lines[3]);
		}

		function testComplex() {

			var hxml = load("test/test-files/Complex.hxml");

			Assert.equals(3, hxml.sets.length);
			assertLineEq(Line.Command("--class-path", "src"), hxml.sets[0].lines[0]);
			assertLineEq(Line.Command("--dce", "full"), hxml.sets[0].lines[1]);
			assertLineEq(Line.Command("--js", "bin/homepage.js"), hxml.sets[0].lines[2]);
			assertLineEq(Line.Command("--main", "website.HomePage"), hxml.sets[0].lines[3]);

			assertLineEq(Line.Command("--class-path", "src"), hxml.sets[1].lines[0]);
			assertLineEq(Line.Command("--dce", "full"), hxml.sets[1].lines[1]);
			assertLineEq(Line.Command("--js", "bin/gallery.js"), hxml.sets[1].lines[2]);
			assertLineEq(Line.Command("--main", "website.GalleryPage"), hxml.sets[1].lines[3]);

			assertLineEq(Line.Command("--class-path", "src"), hxml.sets[2].lines[0]);
			assertLineEq(Line.Command("--dce", "full"), hxml.sets[2].lines[1]);
			assertLineEq(Line.Command("--js", "bin/contact.js"), hxml.sets[2].lines[2]);
			assertLineEq(Line.Command("--main", "website.ContactPage"), hxml.sets[2].lines[3]);
		}
}

inline function assertLineEq(a : Line, b : Line) {
	Assert.isTrue(hxml.ds.Line.equals(a,b),'expected $a but got $b');
}

inline function load(path : String) {
#if result
		var hxmlResult = Hxml.load(path);
		Assert.equals(true, hxmlResult.isOk());
		return hxmlResult.unwrap();
#else
		return Hxml.load(path);
#end
}

inline function testFail<T>(source : String, func : () -> Dynamic) {
	var err = 'failure expected but not found in $source';
#if result
	var r : hxml.Return<T> = func();
	Assert.isTrue(r.isError(), err);

#else
	Assert.raises(func, hxml.Return.ReturnErr, err);
#end
}
