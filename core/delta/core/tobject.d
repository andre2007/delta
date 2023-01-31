module delta.core.tobject;

class TObject
{
	protected ptrdiff_t _reference;
	
	@property ptrdiff_t reference()
	{
		return _reference;
	}

	T opCast(T)() {
        return new T(reference);
    }
	
	this(ptrdiff_t reference)
	{
		_reference = reference;
	}

	void Destroy()
	{
		
	}

	void BeforeDestruction()
	{

	}


}