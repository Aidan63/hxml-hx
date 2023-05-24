package hxml.ds;

enum CheckResult {
	Build(?lines:Int);
	Skip(?lines:Int);
	ExecuteOnly(?lines:Int);
}
