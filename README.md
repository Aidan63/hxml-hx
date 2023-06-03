Native Haxe HXML parsing.

## Features

- Parse HXML files (of all complexity)
- Run the HXML and read the result
- Get information from the HXML, such as files, libraries, src files used.



## Optional Dependencies

HXML-HX does not require any other libraries, but it does work nicely with some libraries if they are installed. 
To better control what haxe can see consider using a "local repository" or one of the many tools like [lix](https://github.com/lix-pm/lix.client).

### [Ansi](https://github.com/snsvrno/ansi-hx)
Error messages will have color.

### [Error](https://github.com/snsvrno/error-hx)
Returned error messages will be the error class instead of a string. If not using `Result-hx` then this will
have no use.

```haxe
// with error-hx & result-hx
public static function parse(content : String, ?source : String) : Result<Hxml, Error>
// without error-hx but with result-hx
public static function parse(content : String, ?source : String) : Result<Hxml, String>
```

### [Result](https://github.com/snsvrno/result-hx)
Failures will return with a message instead of throwing an exception. Requires version `>0.2.1`

```haxe
// with result-hx
public static function parse(content : String, ?source : String) : Result<Hxml, Error> 
// without result-hx
public static function parse(content : String, ?source : String) : Hxml
```
