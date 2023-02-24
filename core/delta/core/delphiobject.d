module delta.core.delphiobject;

class DelphiObject
{
	protected void* _reference;
	
	@property void* reference()
	{
		return _reference;
	}

	T opCast(T)()
	{
        return new T(_reference);
    }

	this(void* reference)
	{
		_reference = reference;
	}
}
