module delta.gen.dgenerator.common;

class MetaClassException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
