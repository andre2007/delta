module delta.core.events;

import std.traits: isDelegate, ReturnType, ParameterTypeTuple;

auto bindDelegate(T, string file = __FILE__, size_t line = __LINE__)(T t) if(isDelegate!T) {
    static T dg;

    dg = t;

    extern(Windows)
    static ReturnType!T func(ParameterTypeTuple!T args) {
            return dg(args);
    }

    return &func;
}