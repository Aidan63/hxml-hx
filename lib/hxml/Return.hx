package hxml;
/*
#if (result && error)
typedef RHxml = result.Result<hxml.Hxml, error.Error>;
#elseif result
typedef RHxml = result.Result<hxml.Hxml, String>;
#else
typedef RHxml = hxml.Hxml;
#end

#if (result && error)
typedef Targets = result.Result<Array<hxml.ds.Target>, error.Error>;
#elseif result
typedef Targets = result.Result<Array<hxml.ds.Target>, String>;
#else
typedef Targets = Array<hxml.ds.Target>;
#end

#if (result && error)
typedef BuildSets = result.Result<Array<hxml.ds.BuildSet>, error.Error>;
#elseif result
typedef BuildSets = result.Result<Array<hxml.ds.BuildSet>, String>;
#else
typedef BuildSets = Array<hxml.ds.BuildSet>;
#end
*/

typedef Return<T> =
#if result
	result.Result<T, ReturnErr>;
#else
	T;
#end

typedef ReturnErr =
#if error
	error.Error
#else
	String
#end

inline function Ok<T>(t:T) : Return<T> {
#if result
	return Result.Ok(t);
#else
	return t;
#end
}

inline function Err<T>(error:ReturnErr) : Return<T> {
#if (result)
	return Result.Error(error);
#else
	throw(error);
#end
}
