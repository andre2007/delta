module delta.core.events;

import std.utf: toUTFz;
import std.traits: isDelegate, ReturnType, ParameterTypeTuple, isDelegate;
import core.sys.windows.windows;

import delta.core.delphiobject;
import delta.core.dll;

auto bindDelegate(T, string file = __FILE__, size_t line = __LINE__)(T t) if(isDelegate!T) {
    static T dg;

    dg = t;

    extern(Windows)
    static ReturnType!T func(ParameterTypeTuple!T args) {
            return dg(args);
    }

    return &func;
}

template GenNotifyEvent(string eventName)
{
	const char[] GenNotifyEvent =
	`private TNotifyEvent _`~eventName~`;

	@property void `~eventName~`(TNotifyEvent value) {
		_`~eventName~`= value;
		auto dlg = __traits(getOverloads, this, "`~eventName~`")[1];
		setEventArgsRef(this, __traits(identifier, `~eventName~`), dlg.ptr, dlg.funcptr);
	}
	
	@property TNotifyEvent `~eventName~`() {
		return _`~eventName~`;
	}`;	
}


void setEventArgsRef(DelphiObject object, string delphiEventName, void* framePointer, void* fnPointer)
{
    alias EventArgsRef = void delegate(DelphiObject sender);
    alias EventArgsRefCallback = extern(Windows) void function(void*, void*, void*) ;
	alias Fn = extern(Windows) void function(void*, char*, void*, void*, EventArgsRefCallback) ;
	
	void delegate(void*, void*, void*) dg = (void* delphiRef, void* dRef, void* funcRef) {
		EventArgsRef ne;
		ne.funcptr = cast(void function(DelphiObject)) funcRef;
		ne.ptr = cast(void*) dRef;
		try
		{
			ne(cast(DelphiObject) cast(void*) dRef);
		}
		catch(Exception e)
		{
			import std.stdio;
			writeln(e.msg);
		}
	};
	
	auto pChar = toUTFz!(char*)(delphiEventName);
	FARPROC fp = GetProcAddress(deltaLibrary.handle, "setNotifyEvent");
	Fn fn = cast(Fn) fp;
	fn(object.reference, pChar, framePointer, fnPointer, bindDelegate(dg));
}
