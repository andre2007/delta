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
						setPropertyReference(_reference, __traits(identifier, method), (args[0] is null) ? null : args[0].reference);
					}
					else static if( isDelegate!(Parameters!method[0]))
					{                            
                        alias dlg = Parameters!method[0];
                        static if (Parameters!dlg.length == 1 && is(Parameters!dlg[0] : Object))
                        {
                            setEventArgsRef(this, __traits(identifier, method), args[0].ptr, args[0].funcptr);
                        }
                        else
                        {
                            assert(false, "Not implemented");
                        }
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
						auto r = cast(void*) getPropertyReference(_reference, __traits(identifier, method));
						if (r is null)
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
					else static if( isDelegate!(ReturnType!method))
					{                            
                        return null;
                        /*alias dlg = Parameters!method[0];
                        static if (Parameters!dlg.length == 1 && is(Parameters!dlg[0] : Object))
                        {
                            alias methodInstance = __traits(getOverloads, this, __traits(identifier, method))[0];
                            setEventArgsRef(this, __traits(identifier, method), methodInstance.ptr, methodInstance.funcptr);
                        }
                        else
                        {
                            assert(false, "Not implemented");
                        }*/
					}
                    else
					{
						assert(false, "Not implemented");
						//static assert(false, "Not implemented: " ~ __traits(identifier, method));
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
						auto arg0Reference = args[0] is null ? null : args[0].reference;
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
						auto arg0Reference = args[0] is null ? null : args[0].reference;
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
						auto arg0Reference = args[0] is null ? null : args[0].reference;
						auto arg1Reference = args[1] is null ? null : args[1].reference;
						auto arg2Reference = args[2] is null ? null : args[2].reference;
						auto resultReference = executeClassMethodReturnRefArgsRefRefRefBool(name, __traits(identifier, method), arg0Reference, arg1Reference, arg2Reference, args[3]);
						return new ReturnType!method(resultReference);
					}
					// executeClassMethodReturnStringArgsStringStringString
					else static if(is(ReturnType!method == string) && args.length == 3 && is(typeof(args[0]) == string) && is(typeof(args[1]) == string) && is(typeof(args[2]) == string))
					{
						return executeClassMethodReturnStringArgsStringStringString(name, __traits(identifier, method), args[0], args[1], args[2]);
					}
					else 
					{
						assert(false, "Not implemented");
						//static assert(false, "Not implemented: " ~ __traits(identifier, method) ); // ~ __traits(parent, method)
					}
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

					//	executeInstanceMethodReturnBoolArgsBool
					else static if(is(ReturnType!method == bool) && args.length == 1 && is(typeof(args[0]) == bool))
					{
						return executeInstanceMethodReturnBoolArgsBool(_reference, __traits(identifier, method), args[0]);
					}

					//	executeInstanceMethodReturnBoolArgsInt
					else static if(is(ReturnType!method == bool) && args.length == 1 && is(typeof(args[0]) == int))
					{
						return executeInstanceMethodReturnBoolArgsInt(_reference, __traits(identifier, method), args[0]);
					}

					//	executeInstanceMethodReturnBoolArgsFloatFloat
					else static if(is(ReturnType!method == bool) && args.length == 2 && is(typeof(args[0]) == float) && is(typeof(args[1]) == float))
					{
						return executeInstanceMethodReturnBoolArgsFloatFloat(_reference, __traits(identifier, method), args[0], args[1]);
					}

					//	executeInstanceMethodReturnBoolArgsRef
					else static if(is(ReturnType!method == bool) && args.length == 1 && is(typeof(args[0]) : Object))
					{
						return executeInstanceMethodReturnBoolArgsRef(_reference, __traits(identifier, method), args[0].reference);
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

					// executeInstanceMethodReturnNoneArgsRefString
					else static if(is(ReturnType!method == void) && args.length == 2 && is(typeof(args[0]) : Object) && is(typeof(args[1]) == string))
					{
						executeInstanceMethodReturnNoneArgsRefString(_reference, __traits(identifier, method), args[0].reference, args[1]);
					}

					// executeInstanceMethodReturnNoneArgsRefBool
					else static if(is(ReturnType!method == void) && args.length == 2 && is(typeof(args[0]) : Object) && is(typeof(args[1]) == bool))
					{
						executeInstanceMethodReturnNoneArgsRefBool(_reference, __traits(identifier, method), args[0].reference, args[1]);
					}

					// executeInstanceMethodReturnNoneArgsRefInt
					else static if(is(ReturnType!method == void) && args.length == 2 && is(typeof(args[0]) : Object) && is(typeof(args[1]) == int))
					{
						executeInstanceMethodReturnNoneArgsRefInt(_reference, __traits(identifier, method), args[0].reference, args[1]);
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

					// executeInstanceMethodReturnNoneArgsBool
					else static if(is(ReturnType!method == void) && args.length == 1 && is(typeof(args[0]) == bool))
					{
						executeInstanceMethodReturnNoneArgsBool(_reference, __traits(identifier, method), args[0]);
					}

					// executeInstanceMethodReturnNoneArgsBoolBool
					else static if(is(ReturnType!method == void) && args.length == 2 && is(typeof(args[0]) == bool) && is(typeof(args[1]) == bool))
					{
						executeInstanceMethodReturnNoneArgsBoolBool(_reference, __traits(identifier, method), args[0], args[1]);
					}

					// executeInstanceMethodReturnNoneArgsInt
					else static if(is(ReturnType!method == void) && args.length == 1 && is(typeof(args[0]) == int))
					{
						executeInstanceMethodReturnNoneArgsInt(_reference, __traits(identifier, method), args[0]);
					}

					// executeInstanceMethodReturnNoneArgsIntRef
					else static if(is(ReturnType!method == void) && args.length == 2 && is(typeof(args[0]) == int) && is(typeof(args[1]) : Object))
					{
						executeInstanceMethodReturnNoneArgsIntRef(_reference, __traits(identifier, method), args[0], args[1].reference);
					}

					// executeInstanceMethodReturnNoneArgsFloat
					else static if(is(ReturnType!method == void) && args.length == 1 && is(typeof(args[0]) == float))
					{
						executeInstanceMethodReturnNoneArgsFloat(_reference, __traits(identifier, method), args[0]);
					}

					// executeInstanceMethodReturnNoneArgsFloatFloatBool
					else static if(is(ReturnType!method == void) && args.length == 3 && is(typeof(args[0]) == float) && is(typeof(args[1]) == float) && is(typeof(args[2]) == bool))
					{
						executeInstanceMethodReturnNoneArgsFloatFloatBool(_reference, __traits(identifier, method), args[0], args[1], args[2]);
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

					// executeInstanceMethodReturnStringArgsInt
					else static if(is(ReturnType!method == string) && args.length == 1 && is(typeof(args[0]) == int))
					{
						return executeInstanceMethodReturnStringArgsInt(_reference, __traits(identifier, method), args[0]);
					}

					// executeInstanceMethodReturnStringArgsIntInt
					else static if(is(ReturnType!method == string) && args.length == 2 && is(typeof(args[0]) == int) && is(typeof(args[1]) == int))
					{
						return executeInstanceMethodReturnStringArgsIntInt(_reference, __traits(identifier, method), args[0], args[1]);
					}

					// executeInstanceMethodReturnRefArgsNone
					else static if(is(ReturnType!method : Object) && args.length == 0)
					{
						auto resultReference = executeInstanceMethodReturnRefArgsNone(_reference, __traits(identifier, method));
						return new ReturnType!method(resultReference);
					}

					// executeInstanceMethodReturnRefArgsString
					else static if(is(ReturnType!method : Object) && args.length == 1 && is(typeof(args[0]) == string))
					{
						auto resultReference = executeInstanceMethodReturnRefArgsString(_reference, __traits(identifier, method), args[0]);
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

					// executeInstanceMethodReturnFloatArgsNone
					else static if(is(ReturnType!method == float) && args.length == 0)
					{
						return executeInstanceMethodReturnFloatArgsNone(_reference, __traits(identifier, method));
					}

					// executeInstanceMethodReturnRefArgsInt
					else static if(is(ReturnType!method : Object) && args.length == 1 && is(typeof(args[0]) == int ))
					{
						auto resultReference =  executeInstanceMethodReturnRefArgsInt(_reference, __traits(identifier, method), args[0]);
						return new ReturnType!method(resultReference);
					}

					// executeInstanceMethodReturnRefArgsStringBool
					else static if(is(ReturnType!method : Object) && args.length == 2 && is(typeof(args[0]) == string) && is(typeof(args[1]) == bool ))
					{
						auto resultReference =  executeInstanceMethodReturnRefArgsStringBool(_reference, __traits(identifier, method), args[0], args[1]);
						return new ReturnType!method(resultReference);
					}
					else
					{
						assert(false, "Not implemented");
						// static assert(false, "Not implemented: " ~ __traits(identifier, method));
					} 
				}
				
				
				/*
				executeInstanceMethodReturnEnumArgsNone
				executeInstanceMethodReturnNoneArgsStructFloat
				executeInstanceMethodReturnNoneArgsStructStructFloat
				executeInstanceMethodReturnNoneArgsStructStructFloatRef
				executeInstanceMethodReturnNoneArgsRefStructStructFloatBoolean
				executeInstanceMethodReturnNoneArgsRefFloat
				executeInstanceMethodReturnNoneArgsFloatFloatFloatFloatFloat
				*/
			}
		}
	}
	
	import std.traits;
	
	this(void* reference)
	{
		super(reference);
	}

	this(DelphiObject obj)
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

void executeInstanceMethodReturnNoneArgsNone(void* reference, string name)
{
	alias extern(Windows) void function(void*, char*) FN;
	auto pChar = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsNone");
	auto fn = cast(FN) fp;
	fn(reference, pChar);
}

string executeInstanceMethodReturnEnumArgsNone(void* reference, string name)
{
	alias extern(Windows) void function(void*, char*, out BSTR) FN;
	auto pChar = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnEnumArgsNone");
	auto fn = cast(FN) fp;
	
	BSTR bStr;
	fn(reference, pChar, bStr);
	
	string s = to!string(bStr[0 .. SysStringLen(bStr)]);
	SysFreeString(bStr);
	
	return s;
}

int executeInstanceMethodReturnIntArgsNone(void* reference, string name)
{
	alias extern(Windows) int function(void*, char*) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnIntArgsNone");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName);
}

bool executeInstanceMethodReturnBoolArgsNone(void* reference, string name)
{
	alias extern(Windows) bool function(void*, char*) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnBoolArgsNone");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName);
}

bool executeInstanceMethodReturnBoolArgsBool(void* reference, string name, bool b)
{
	alias extern(Windows) bool function(void*, char*, bool) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnBoolArgsBool");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName, b);
}

bool executeInstanceMethodReturnBoolArgsInt(void* reference, string name, int i)
{
	alias extern(Windows) bool function(void*, char*, int) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnBoolArgsInt");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName, i);
}

bool executeInstanceMethodReturnBoolArgsFloatFloat(void* reference, string name, float f1, float f2)
{
	alias extern(Windows) bool function(void*, char*, float, float) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnBoolArgsFloatFloat");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName, f1, f2);
}

bool executeInstanceMethodReturnBoolArgsRef(void* reference, string name, void* reference2)
{
	alias extern(Windows) bool function(void*, char*, void*) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnBoolArgsRef");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName, reference2);
}

int executeInstanceMethodReturnIntArgsString(void* reference, string name, string value)
{
	alias extern(Windows) int function(void*, char*, char*) FN;
	auto pCharName = toUTFz!(char*)(name);
	auto pCharValue = toUTFz!(char*)(value);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnIntArgsString");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName, pCharValue);
}

void executeInstanceMethodReturnNoneArgsString(void* reference, string name, string value)
{
	alias extern(Windows) void function(void*, char*, char*) FN;
	auto pCharName = toUTFz!(char*)(name);
	auto pCharValue = toUTFz!(char*)(value);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsString");
	auto fn = cast(FN) fp;
	fn(reference, pCharName, pCharValue);
}

void executeInstanceMethodReturnNoneArgsBool(void* reference, string name, bool value)
{
	alias extern(Windows) void function(void*, char*, bool) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsBool");
	auto fn = cast(FN) fp;
	fn(reference, pCharName, value);
}

void executeInstanceMethodReturnNoneArgsBoolBool(void* reference, string name, bool b1, bool b2)
{
	alias extern(Windows) void function(void*, char*, bool, bool) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsBoolBool");
	auto fn = cast(FN) fp;
	fn(reference, pCharName, b1, b2);
}

void executeInstanceMethodReturnNoneArgsInt(void* reference, string name, int value)
{
	alias extern(Windows) void function(void*, char*, int) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsInt");
	auto fn = cast(FN) fp;
	fn(reference, pCharName, value);
}

void executeInstanceMethodReturnNoneArgsIntRef(void* reference, string name, int value, void* reference2)
{
	alias extern(Windows) void function(void*, char*, int, void*) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsIntRef");
	auto fn = cast(FN) fp;
	fn(reference, pCharName, value, reference2);
}

void executeInstanceMethodReturnNoneArgsFloat(void* reference, string name, float value)
{
	alias extern(Windows) void function(void*, char*, float) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsFloat");
	auto fn = cast(FN) fp;
	fn(reference, pCharName, value);
}

void executeInstanceMethodReturnNoneArgsFloatFloatBool(void* reference, string name, float f1, float f2, bool b)
{
	alias extern(Windows) void function(void*, char*, float, float, bool) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsFloatFloatBool");
	auto fn = cast(FN) fp;
	fn(reference, pCharName, f1, f2, b);
}

void* executeInstanceMethodReturnRefArgsNone(void* reference, string name)
{
	alias extern(Windows) void* function(void*, char*) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnRefArgsNone");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName);
}

void* executeInstanceMethodReturnRefArgsInt(void* reference, string name, int i)
{
	alias extern(Windows) void* function(void*, char*, int) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnRefArgsInt");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName, i);
}

void* executeInstanceMethodReturnRefArgsStringBool(void* reference, string name, string s, bool b)
{
	alias extern(Windows) void* function(void*, char*, char*, bool) FN;
	auto pCharName = toUTFz!(char*)(name);
	auto pCharValue = toUTFz!(char*)(s);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnRefArgsStringBool");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName, pCharValue, b);
}

void executeInstanceMethodReturnNoneArgsRef(void* reference, string name, void* reference2)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsRef");
	alias extern(Windows) void function(void*, char*, void*) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, reference2);
}

void executeInstanceMethodReturnNoneArgsRefString(void* reference, string name, void* reference2, string s)
{
	auto pCharName = toUTFz!(char*)(name);
	auto pCharValue = toUTFz!(char*)(s);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsRefString");
	alias extern(Windows) void function(void*, char*, void*, char*) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, reference2, pCharValue);
}

void executeInstanceMethodReturnNoneArgsRefBool(void* reference, string name, void* reference2, bool b)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsRefBool");
	alias extern(Windows) void function(void*, char*, void*, bool) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, reference2, b);
}

void executeInstanceMethodReturnNoneArgsRefInt(void* reference, string name, void* reference2, int i)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsRefInt");
	alias extern(Windows) void function(void*, char*, void*, int) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, reference2, i);
}

void executeInstanceMethodReturnNoneArgsStructFloat(void* reference, string name, void* reference2, float f)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsStructFloat");
	alias extern(Windows) void function(void*, char*, void*, float) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, reference2, f);
}

void executeInstanceMethodReturnNoneArgsStructStructFloat(void* reference, string name, void* reference2, void* reference3, float f)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsStructStructFloat");
	alias extern(Windows) void function(void*, char*, void*, void*, float) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, reference2, reference3, f);
}

void executeInstanceMethodReturnNoneArgsStructStructFloatRef(void* reference, string name, void* reference2, void* reference3, float f, void* reference4)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsStructStructFloatRef");
	alias extern(Windows) void function(void*, char*, void*, void*, float, void*) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, reference2, reference3, f, reference4);
}

void executeInstanceMethodReturnNoneArgsRefStructStructFloatBoolean(void* reference, string name, void* reference2, void* reference3, void* reference4, float f, bool b)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsRefStructStructFloatBoolean");
	alias extern(Windows) void function(void*, char*, void*, void*, void*, float, bool) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, reference2, reference3, reference4, f, b);	
}

void executeInstanceMethodReturnNoneArgsRefFloat(void* reference, string name, void* reference2, float f)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsRefFloat");
	alias extern(Windows) void function(void*, char*, void*, float) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, reference2,f);
}

void executeInstanceMethodReturnNoneArgsFloatFloatFloatFloatFloat(void* reference, string name, float f1, float f2, float f3, float f4, float f5)
{
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnNoneArgsFloatFloatFloatFloatFloat");
	alias extern(Windows) void function(void*, char*, float, float, float, float, float) FN;
	auto fn = cast(FN) fp;
	fn(reference, pCharName, f1, f2, f3, f4, f5);
}

void* executeInstanceMethodReturnRefArgsString(void* reference, string name, string value)
{
	alias extern(Windows) void* function(void*, char*, char*) FN;
	
	auto pCharName = toUTFz!(char*)(name);
	auto pCharValue = toUTFz!(char*)(value);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnRefArgsString");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName, pCharValue);
}

string executeInstanceMethodReturnStringArgsNone(void* reference, string name)
{
	alias extern(Windows) void function(void*, char*, out BSTR) FN;
	
	auto pCharName = toUTFz!(char*)(name);

	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnStringArgsNone_Out_String");
	auto fn = cast(FN) fp;
	
	BSTR bStr;
	fn(reference, pCharName, bStr);
	string s = to!string(bStr[0 .. SysStringLen(bStr)]);
	SysFreeString(bStr);
	return s;
}

string executeInstanceMethodReturnStringArgsInt(void* reference, string name, int i)
{
	alias extern(Windows) void function(void*, char*, int, out BSTR) FN;
	
	auto pCharName = toUTFz!(char*)(name);

	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnStringArgsInt_Out_String");
	auto fn = cast(FN) fp;
	
	BSTR bStr;
	fn(reference, pCharName, i, bStr);
	string s = to!string(bStr[0 .. SysStringLen(bStr)]);
	SysFreeString(bStr);
	return s;
}

string executeInstanceMethodReturnStringArgsIntInt(void* reference, string name, int i1, int i2)
{
	alias extern(Windows) void function(void*, char*, int, int, out BSTR) FN;
	
	auto pCharName = toUTFz!(char*)(name);

	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnStringArgsIntInt_Out_String");
	auto fn = cast(FN) fp;
	
	BSTR bStr;
	fn(reference, pCharName, i1, i2, bStr);
	string s = to!string(bStr[0 .. SysStringLen(bStr)]);
	SysFreeString(bStr);
	return s;
}

int executeInstanceMethodReturnIntArgsStringRef(void* reference, string name, string value, void* r)
{
	alias extern(Windows) int function(void*, char*, char*, void*) FN;
	auto pCharName = toUTFz!(char*)(name);
	auto pCharValue = toUTFz!(char*)(value);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnIntArgsStringRef");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName, pCharValue, r);
}

float executeInstanceMethodReturnFloatArgsNone(void* reference, string name)
{
	alias extern(Windows) float function(void*, char*) FN;
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeInstanceMethodReturnFloatArgsNone");
	auto fn = cast(FN) fp;
	return fn(reference, pCharName);
}

void* executeClassMethodReturnRefArgsString(string qualifiedName, string name, string value)
{
	alias extern(Windows) void* function(char*, char*, char*) FN;
	auto pCharQualifiedName = toUTFz!(char*)(qualifiedName);
	auto pCharName = toUTFz!(char*)(name);
	auto pCharValue = toUTFz!(char*)(value);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeClassMethodReturnRefArgsString");
	auto fn = cast(FN) fp;
	return fn(pCharQualifiedName, pCharName, pCharValue);
}

void* executeClassMethodReturnRefArgsNone(string qualifiedName, string name)
{
	alias extern(Windows) void* function(char*, char*) FN;
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

void* executeClassMethodReturnRefArgsRef(string qualifiedName, string name, void* reference)
{
	alias extern(Windows) void* function(char*, char*, void*) FN;
	
	auto pCharQualifiedName = toUTFz!(char*)(qualifiedName);
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeClassMethodReturnRefArgsRef");
	auto fn = cast(FN) fp;
	return fn(pCharQualifiedName, pCharName, reference);
}

void* executeClassMethodReturnRefArgsIntUInt(string qualifiedName, string name, int i1, uint i2)
{
	alias extern(Windows) void* function(char*, char*, int, uint) FN;
	
	auto pCharQualifiedName = toUTFz!(char*)(qualifiedName);
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeClassMethodReturnRefArgsIntUInt");
	auto fn = cast(FN) fp;
	return fn(pCharQualifiedName, pCharName, i1, i2);
}

void* executeClassMethodReturnRefArgsRefRefRefBool(string qualifiedName, string name, void* ref1, void* ref2, void* ref3, bool b)
{
	alias extern(Windows) void* function(char*, char*, void*, void*, void*, bool) FN;
	
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

void* executeClassMethodReturnRefArgsRefNativeInt(string qualifiedName, string name, void* reference, ptrdiff_t i)
{
	alias extern(Windows) void* function(char*, char*, void*, ptrdiff_t) FN;
	
	auto pCharQualifiedName = toUTFz!(char*)(qualifiedName);
	auto pCharName = toUTFz!(char*)(name);
	
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "executeClassMethodReturnRefArgsRefNativeInt");
	auto fn = cast(FN) fp;
	return fn(pCharQualifiedName, pCharName, reference, i);
}
