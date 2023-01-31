module delta.core.methods;

import core.sys.windows.windows;
import core.sys.windows.wtypes: BSTR;
import std.utf: toUTFz, encode;
import std.algorithm: each;
import std.conv: to;

import delta.core.dll;

bool isProperty(string[] items...) {
	foreach(item; items)
		if(item == "@property")
			return true;
	return false;
}

enum skip;

mixin template PascalClass(string name)
{
	private mixin template PascalImportImpl(T, alias method, size_t overloadIndex)
	{
		import std.traits;

		static if(isProperty(__traits(getFunctionAttributes, method))) {
			static assert(__traits(isStaticFunction, method) == false);

			static if (is(ReturnType!method == void) && Parameters!method.length == 1)
			{
				pragma(mangle, method.mangleof)
				private void implementation(Parameters!method args)
				{
					static if(is(Parameters!method[0] == bool))
					{
						setPropertyBool(_reference, __traits(identifier, method), args[0]);
					}
					else static if(is(Parameters!method[0] == float))
					{
						setPropertyFloat(_reference, __traits(identifier, method), args[0]);
					}
					else static if(is(Parameters!method[0] == short))
					{
						setPropertyShort(_reference, __traits(identifier, method), args[0]);
					}
					else static if(is(Parameters!method[0] == int))
					{
						setPropertyInt(_reference, __traits(identifier, method), args[0]);
					}
					else static if(is(Parameters!method[0] == uint))
					{
						setPropertyUInt(_reference, __traits(identifier, method), args[0]);
					}
					else static if(is(Parameters!method[0] == string))
					{
						setPropertyString(_reference, __traits(identifier, method), args[0]);
					}
					else static if(is(Parameters!method[0] : Object))
					{
						setPropertyReference(_reference, __traits(identifier, method), (args[0] is null) ? 0 : args[0].reference);
					}
					else assert(false, "Not implemented: " ~ __traits(identifier, method));
				}
			}
			else static if (!is(ReturnType!method == void) && Parameters!method.length == 0)
			{
				pragma(mangle, method.mangleof)
				private ReturnType!method implementation()
				{
					static if(is(ReturnType!method == bool))
					{
						return getPropertyBool(_reference, __traits(identifier, method));
					}
					else static if(is(ReturnType!method == float))
					{
						return getPropertyFloat(_reference, __traits(identifier, method));
					}
					else static if(is(ReturnType!method == short))
					{
						return getPropertyShort(_reference, __traits(identifier, method));
					}
					else static if(is(ReturnType!method == int))
					{
						return getPropertyInt(_reference, __traits(identifier, method));
					}
					else static if(is(ReturnType!method == uint))
					{
						return getPropertyUInt(_reference, __traits(identifier, method));
					}
					else static if(is(ReturnType!method == string))
					{
						return getPropertyString(_reference, __traits(identifier, method));
					}
					else static if(is(ReturnType!method : Object))
					{
						auto r = cast(ptrdiff_t) cast(void*) getPropertyReference(_reference, __traits(identifier, method));
						if (r == 0)
							return null;
						else 
							return new ReturnType!method(r);

						/*if(r == 0)
						{
							_`~name~` = null;
						}
						else if (_`~name~` is null || _`~name~`.reference != r)
						{
							_`~name~` = new `~className~`(r);
						}
						return _`~name~`;*/
					}
					else
					{
						static assert(false, "Not implemented: " ~ __traits(identifier, method));
					} 
				}
			} else static assert(false, "Not implemented: " ~ __traits(identifier, method));
		} 
		else 
		{
			static if (__traits(isStaticFunction, method))
			{
				pragma(mangle, method.mangleof)
				private static ReturnType!method implementation(Parameters!method args)
				{
					//	executeClassMethodReturnRefArgsRef
					static if(is(ReturnType!method : Object) && args.length == 1 && is(typeof(args[0]) : Object))
					{
						auto arg0Reference = args[0] is null ? nil : args[0].reference;
						auto resultReference = executeClassMethodReturnRefArgsRef(name, __traits(identifier, method), arg0Reference);
						return new ReturnType!method(resultReference);
					} 
					// executeClassMethodReturnRefArgsString
					else static if(is(ReturnType!method : Object) && args.length == 1 && is(typeof(args[0]) == string))
					{
						auto resultReference = executeClassMethodReturnRefArgsString(name, __traits(identifier, method), args[0]);
						return new ReturnType!method(resultReference);
					}
					// executeClassMethodReturnRefArgsNone
					else static if(is(ReturnType!method : Object) && args.length == 0)
					{
						auto resultReference = executeClassMethodReturnRefArgsNone(name, __traits(identifier, method));
						return new ReturnType!method(resultReference);
					}
					// executeClassMethodReturnRefArgsRefNativeInt
					else static if(is(ReturnType!method : Object) && args.length == 2 && is(typeof(args[0]) : Object) && is(typeof(args[1]) == ptrdiff_t))
					{
						auto arg0Reference = args[0] is null ? nil : args[0].reference;
						auto resultReference = executeClassMethodReturnRefArgsRefNativeInt(name, __traits(identifier, method), arg0Reference, args[1]);
						return new ReturnType!method(resultReference);
					}
					// executeClassMethodReturnNoneArgsNone
					else static if(is(ReturnType!method == void) && args.length == 0)
					{
						executeClassMethodReturnNoneArgsNone(name, __traits(identifier, method));
					}
					// executeClassMethodReturnNoneArgsString
					else static if(is(ReturnType!method == void) && args.length == 1 && is(typeof(args[0]) == string))
					{
						executeClassMethodReturnNoneArgsString(name, __traits(identifier, method), args[0]);
					}
					// executeClassMethodReturnRefArgsIntUInt
					else static if(is(ReturnType!method : Object) && args.length == 2 && is(typeof(args[0]) == enum) && is(typeof(args[1]) == uint))
					{
						// TODO: Is Int correct, for x64?
						auto resultReference = executeClassMethodReturnRefArgsIntUInt(name, __traits(identifier, method), args[0], args[1]);
						return new ReturnType!method(resultReference);
					}
					// executeClassMethodReturnRefArgsRefRefRefBool
					else static if(is(ReturnType!method : Object) && args.length == 4 
						&& is(typeof(args[0]) : Object) && is(typeof(args[1]) : Object) && is(typeof(args[2]) : Object) && is(typeof(args[3]) == bool))
					{
						auto arg0Reference = args[0] is null ? nil : args[0].reference;
						auto arg1Reference = args[1] is null ? nil : args[1].reference;
						auto arg2Reference = args[2] is null ? nil : args[2].reference;
						auto resultReference = executeClassMethodReturnRefArgsRefRefRefBool(name, __traits(identifier, method), arg0Reference, arg1Reference, arg2Reference, args[3]);
						return new ReturnType!method(resultReference);
					}
					// executeClassMethodReturnStringArgsStringStringString
					else static if(is(ReturnType!method == string) && args.length == 3 && is(typeof(args[0]) == string) && is(typeof(args[1]) == string) && is(typeof(args[2]) == string))
					{
						return executeClassMethodReturnStringArgsStringStringString(name, __traits(identifier, method), args[0], args[1], args[2]);
					}
					else static assert(false, "Not implemented: " ~ __traits(identifier, method) ~ ~ __traits(parent, method));
				}
			}
			else
			{
				pragma(mangle, method.mangleof)
				private ReturnType!method implementation(Parameters!method args)
				{
					//	executeInstanceMethodReturnBoolArgsNone
					static if(is(ReturnType!method == bool) && args.length == 0)
					{
						return executeInstanceMethodReturnBoolArgsNone(_reference, __traits(identifier, method));
					}

					//	executeInstanceMethodReturnIntArgsNone
					else static if(is(ReturnType!method == int) && args.length == 0)
					{
						return executeInstanceMethodReturnIntArgsNone(_reference, __traits(identifier, method));
					}

					// executeInstanceMethodReturnNoneArgsRef
					else static if(is(ReturnType!method == void) && args.length == 1 && is(typeof(args[0]) : Object))
					{
						executeInstanceMethodReturnNoneArgsRef(_reference, __traits(identifier, method), args[0].reference);
					}

					// executeInstanceMethodReturnNoneArgsIntf
					else static if(is(ReturnType!method == void) && args.length == 1  && is(typeof(args[0]) == interface))
					{
						executeInstanceMethodReturnNoneArgsRef(_reference, __traits(identifier, method), (cast(TObject) args[0]).reference);
					}

					// executeInstanceMethodReturnNoneArgsString
					else static if(is(ReturnType!method == void) && args.length == 1 && is(typeof(args[0]) == string))
					{
						executeInstanceMethodReturnNoneArgsString(_reference, __traits(identifier, method), args[0]);
					}

					// executeInstanceMethodReturnNoneArgsNone
					else static if(is(ReturnType!method == void) && args.length == 0)
					{
						executeInstanceMethodReturnNoneArgsNone(_reference, __traits(identifier, method));
					}
					
					// executeInstanceMethodReturnStringArgsNone
					else static if(is(ReturnType!method == string) && args.length == 0)
					{
						return executeInstanceMethodReturnStringArgsNone(_reference, __traits(identifier, method));
					}

					// executeInstanceMethodReturnRefArgsNone
					else static if(is(ReturnType!method : Object) && args.length == 0)
					{
						auto resultReference = executeInstanceMethodReturnRefArgsNone(_reference, __traits(identifier, method));
						return new ReturnType!method(resultReference);
					}

					// executeInstanceMethodReturnIntArgsString
					else static if(is(ReturnType!method == int) && args.length == 1 && is(typeof(args[0]) == string))
					{
						return executeInstanceMethodReturnIntArgsString(_reference, __traits(identifier, method), args[0]);
					}

					// executeInstanceMethodReturnIntArgsStringRef
					else static if(is(ReturnType!method == int) && args.length == 2 && is(typeof(args[0]) == string ) && is(typeof(args[1]) : Object))
					{
						return executeInstanceMethodReturnIntArgsStringRef(_reference, __traits(identifier, method), args[0], args[1].reference);
					}

					// executeInstanceMethodReturnRefArgsInt
					else static if(is(ReturnType!method : Object) && args.length == 1 && is(typeof(args[0]) == int ))
					{
						auto resultReference =  executeInstanceMethodReturnRefArgsInt(_reference, __traits(identifier, method), args[0]);
						return new ReturnType!method(resultReference);
					}

					else static assert(false, "Not implemented: " ~ __traits(identifier, method));
				}
				
				
				/*
				executeInstanceMethodReturnEnumArgsNone
				executeInstanceMethodReturnNoneArgsStructFloat
				executeInstanceMethodReturnNoneArgsStructStructFloat
				executeInstanceMethodReturnNoneArgsStructStructFloatRef
				executeInstanceMethodReturnNoneArgsRefStructStructFloatBoolean
				executeInstanceMethodReturnNoneArgsRefFloat
				executeInstanceMethodReturnNoneArgsFloatFloatFloatFloatFloat
				executeInstanceMethodReturnRefArgsString
				*/
			}
		}
	}
	
	import std.traits;
	
	this(ptrdiff_t reference)
	{
		super(reference);
	}

	this(TObject obj)
	{
		super(obj.reference);
	}


	static foreach(memberName; __traits(derivedMembers, typeof(this))) {
		static if(isSomeFunction!(__traits(getMember, typeof(this), memberName)))
		{
			static foreach(oi, overload; __traits(getOverloads, typeof(this), memberName))
			{
				static if(!hasUDA!(overload, skip) && memberName != "__ctor")
				{
					mixin PascalImportImpl!(typeof(this), overload, oi);

					// Create for each object property a member variable for performance reasons
					// ...
				}
				
				
			}
		}
	}
}





void executeInstanceMethodReturnNoneArgsNone(ptrdiff_t reference, string name)
{
	alias extern(Windows) void function(ptrdiff_t, char*) FN;
	auto pChar = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsNone");
	auto fn = cast(FN) fp;
	fn(reference, pChar);
}

string executeInstanceMethodReturnEnumArgsNone(ptrdiff_t reference, string name)
{
	alias extern(Windows) void function(ptrdiff_t, char*, out BSTR) FN;
	auto pChar = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnEnumArgsNone");
	auto fn = cast(FN) fp;
	
	BSTR bStr;
	fn(reference, pChar, bStr);
	
	string s = to!string(bStr[0 .. SysStringLen(bStr)]);
	SysFreeString(bStr);
	
	return s;
}

int executeInstanceMethodReturnIntArgsNone(ptrdiff_t reference, string name)
{
	alias extern(Windows) int function(ptrdiff_t, char*) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnIntArgsNone");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName);
}

bool executeInstanceMethodReturnBoolArgsNone(ptrdiff_t reference, string name)
{
	alias extern(Windows) bool function(ptrdiff_t, char*) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnBoolArgsNone");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName);
}

int executeInstanceMethodReturnIntArgsString(ptrdiff_t reference, string name, string value)
{
	alias extern(Windows) int function(ptrdiff_t, char*, char*) FN;
	auto pCharName = toUTFz!(char*)(name);
	auto pCharValue = toUTFz!(char*)(value);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnIntArgsString");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName, pCharValue);
}

void executeInstanceMethodReturnNoneArgsString(ptrdiff_t reference, string name, string value)
{
	alias extern(Windows) void function(ptrdiff_t, char*, char*) FN;
	auto pCharName = toUTFz!(char*)(name);
	auto pCharValue = toUTFz!(char*)(value);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsString");
	auto fn = cast(FN) fp;
	fn(reference, pCharName, pCharValue);
}

ptrdiff_t executeInstanceMethodReturnRefArgsNone(ptrdiff_t reference, string name)
{
	alias extern(Windows) ptrdiff_t function(ptrdiff_t, char*) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnRefArgsNone");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName);
}

ptrdiff_t executeInstanceMethodReturnRefArgsInt(ptrdiff_t reference, string name, int i)
{
	alias extern(Windows) ptrdiff_t function(ptrdiff_t, char*, int) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnRefArgsInt");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName, i);
}

void executeInstanceMethodReturnNoneArgsRef(ptrdiff_t reference, string name, ptrdiff_t reference2)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsRef");
	alias extern(Windows) void function(ptrdiff_t, char*, ptrdiff_t) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, reference2);
}

void executeInstanceMethodReturnNoneArgsStructFloat(ptrdiff_t reference, string name, ptrdiff_t reference2, float f)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsStructFloat");
	alias extern(Windows) void function(ptrdiff_t, char*, ptrdiff_t, float) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, reference2, f);
}

void executeInstanceMethodReturnNoneArgsStructStructFloat(ptrdiff_t reference, string name, ptrdiff_t reference2, ptrdiff_t reference3, float f)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsStructStructFloat");
	alias extern(Windows) void function(ptrdiff_t, char*, ptrdiff_t, ptrdiff_t, float) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, reference2, reference3, f);
}

void executeInstanceMethodReturnNoneArgsStructStructFloatRef(ptrdiff_t reference, string name, ptrdiff_t reference2, ptrdiff_t reference3, float f, ptrdiff_t reference4)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsStructStructFloatRef");
	alias extern(Windows) void function(ptrdiff_t, char*, ptrdiff_t, ptrdiff_t, float, ptrdiff_t) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, reference2, reference3, f, reference4);
}

void executeInstanceMethodReturnNoneArgsRefStructStructFloatBoolean(ptrdiff_t reference, string name, ptrdiff_t reference2, ptrdiff_t reference3, ptrdiff_t reference4, float f, bool b)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsRefStructStructFloatBoolean");
	alias extern(Windows) void function(ptrdiff_t, char*, ptrdiff_t, ptrdiff_t, ptrdiff_t, float, bool) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, reference2, reference3, reference4, f, b);	
}

void executeInstanceMethodReturnNoneArgsRefFloat(ptrdiff_t reference, string name, ptrdiff_t reference2, float f)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsRefFloat");
	alias extern(Windows) void function(ptrdiff_t, char*, ptrdiff_t, float) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, reference2,f);
}

void executeInstanceMethodReturnNoneArgsFloatFloatFloatFloatFloat(ptrdiff_t reference, string name, float f1, float f2, float f3, float f4, float f5)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsFloatFloatFloatFloatFloat");
	alias extern(Windows) void function(ptrdiff_t, char*, float, float, float, float, float) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, f1, f2, f3, f4, f5);
}

ptrdiff_t executeInstanceMethodReturnRefArgsString(ptrdiff_t reference, string name, string value)
{
	alias extern(Windows) ptrdiff_t function(ptrdiff_t, char*, char*) FN;
	
	auto pCharName = toUTFz!(char*)(name);
	auto pCharValue = toUTFz!(char*)(value);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnRefArgsString");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName, pCharValue);
}

string executeInstanceMethodReturnStringArgsNone(ptrdiff_t reference, string name)
{
	alias extern(Windows) void function(ptrdiff_t, char*, out BSTR) FN;
	
	auto pCharName = toUTFz!(char*)(name);

	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnStringArgsNone_Out_String");
	auto fn = cast(FN) fp;
	
	BSTR bStr;
	fn(reference, pCharName, bStr);
	string s = to!string(bStr[0 .. SysStringLen(bStr)]);
	SysFreeString(bStr);
	return s;
}

int executeInstanceMethodReturnIntArgsStringRef(ptrdiff_t reference, string name, string value, ptrdiff_t r)
{
	alias extern(Windows) int function(ptrdiff_t, char*, char*, ptrdiff_t) FN;
	auto pCharName = toUTFz!(char*)(name);
	auto pCharValue = toUTFz!(char*)(value);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnIntArgsStringRef");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName, pCharValue, r);
}

ptrdiff_t executeClassMethodReturnRefArgsString(string qualifiedName, string name, string value)
{
	alias extern(Windows) ptrdiff_t function(char*, char*, char*) FN;
	auto pCharQualifiedName = toUTFz!(char*)(qualifiedName);
	auto pCharName = toUTFz!(char*)(name);
	auto pCharValue = toUTFz!(char*)(value);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeClassMethodReturnRefArgsString");
	auto fn = cast(FN) fp;
	return fn(pCharQualifiedName, pCharName, pCharValue);
}

ptrdiff_t executeClassMethodReturnRefArgsNone(string qualifiedName, string name)
{
	alias extern(Windows) ptrdiff_t function(char*, char*) FN;
	auto pCharQualifiedName = toUTFz!(char*)(qualifiedName);
	auto pCharName = toUTFz!(char*)(name);
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeClassMethodReturnRefArgsNone");
	auto fn = cast(FN) fp;
	return fn(pCharQualifiedName, pCharName);
}

void executeClassMethodReturnNoneArgsNone(string qualifiedName, string name)
{
	alias extern(Windows) void function(char*, char*) FN;
	auto pCharQualifiedName = toUTFz!(char*)(qualifiedName);
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeClassMethodReturnNoneArgsNone");
	auto fn = cast(FN) fp;
	fn(pCharQualifiedName, pCharName);
}

ptrdiff_t executeClassMethodReturnRefArgsRef(string qualifiedName, string name, ptrdiff_t reference)
{
	alias extern(Windows) ptrdiff_t function(char*, char*, ptrdiff_t) FN;
	
	auto pCharQualifiedName = toUTFz!(char*)(qualifiedName);
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeClassMethodReturnRefArgsRef");
	auto fn = cast(FN) fp;
	return fn(pCharQualifiedName, pCharName, reference);
}

ptrdiff_t executeClassMethodReturnRefArgsIntUInt(string qualifiedName, string name, int i1, uint i2)
{
	alias extern(Windows) ptrdiff_t function(char*, char*, int, uint) FN;
	
	auto pCharQualifiedName = toUTFz!(char*)(qualifiedName);
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeClassMethodReturnRefArgsIntUInt");
	auto fn = cast(FN) fp;
	return fn(pCharQualifiedName, pCharName, i1, i2);
}

ptrdiff_t executeClassMethodReturnRefArgsRefRefRefBool(string qualifiedName, string name, ptrdiff_t ref1, ptrdiff_t ref2, ptrdiff_t ref3, bool b)
{
	alias extern(Windows) ptrdiff_t function(char*, char*, ptrdiff_t, ptrdiff_t, ptrdiff_t, bool) FN;
	
	auto pCharQualifiedName = toUTFz!(char*)(qualifiedName);
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeClassMethodReturnRefArgsRefRefRefBool");
	auto fn = cast(FN) fp;
	return fn(pCharQualifiedName, pCharName, ref1, ref2, ref3, b);
}

private BSTR allocateBSTR(string s)
{
	wstring ws = s.to!wstring;
	return allocateBSTR(ws);
}

private BSTR allocateBSTR(wstring ws)
{
	return SysAllocStringLen(ws.ptr, cast(UINT) ws.length);
}

void executeClassMethodReturnNoneArgsString(string qualifiedName, string name, string value)
{
	alias extern(Windows) void function(char*, char*, BSTR) FN;
	auto pCharQualifiedName = toUTFz!(char*)(qualifiedName);
	auto pCharName = toUTFz!(char*)(name);

	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeClassMethodReturnNoneArgsString");
	auto fn = cast(FN) fp;
	
	BSTR bStr = allocateBSTR(value);
	fn(pCharQualifiedName, pCharName, bStr);
	SysFreeString(bStr);
}

string executeClassMethodReturnStringArgsStringStringString(string qualifiedName, string name, string v1, string v2, string v3)
{
	alias extern(Windows) void function(char*, char*, BSTR, BSTR, BSTR, out BSTR) FN;
	
	auto pCharQualifiedName = toUTFz!(char*)(qualifiedName);
	auto pCharName = toUTFz!(char*)(name);

	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeClassMethodReturnNoneArgsStringStringString_Out_String");
	auto fn = cast(FN) fp;

	BSTR bStr1 = allocateBSTR(v1);
	BSTR bStr2 = allocateBSTR(v2);
	BSTR bStr3 = allocateBSTR(v3);
	
	BSTR bStr;
	fn(pCharQualifiedName, pCharName, bStr1, bStr2, bStr3, bStr);
	SysFreeString(bStr1);
	SysFreeString(bStr2);
	SysFreeString(bStr3);
	
	string s = to!string(bStr[0 .. SysStringLen(bStr)]);
	SysFreeString(bStr);
	
	return s;
}

ptrdiff_t executeClassMethodReturnRefArgsRefNativeInt(string qualifiedName, string name, ptrdiff_t reference, ptrdiff_t i)
{
	alias extern(Windows) ptrdiff_t function(char*, char*, ptrdiff_t, ptrdiff_t) FN;
	
	auto pCharQualifiedName = toUTFz!(char*)(qualifiedName);
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeClassMethodReturnRefArgsRefNativeInt");
	auto fn = cast(FN) fp;
	return fn(pCharQualifiedName, pCharName, reference, i);
}
