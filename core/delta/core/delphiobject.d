module delta.core.delphiobject;

class DelphiObject
{
	protected ptrdiff_t _reference;
	
	@property ptrdiff_t reference()
	{
		return _reference;
	}

	T opCast(T)()
	{
        return new T(_reference);
    }

	this(ptrdiff_t reference)
	{
		_reference = reference;
	}
}
