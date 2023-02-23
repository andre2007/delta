module delta.gen.dgenerator.dclassgen;

import std;
import delta.gen.symbolcache;
import delta.gen.dgenerator.common;

struct DPropertyModel
{
    bool isOverrideRead;
    bool isOverrideWrite;
    bool hasRead;
    bool hasWrite;
    string type;
    string name;
    string visibility;
}

class DClassGenerator
{
    private string _classSourceCode;
    private string _unitName;
    private SymbolCache _symbolCache;

    this(string unitName)
    {
        _unitName = unitName;
		_symbolCache = SymbolCache.getSymbolCache(_unitName);
    }

    private string _validateSymbol(string symbolName)
    {
        Symbol symbol = _symbolCache.getSymbol(symbolName);
        enforce!MetaClassException(!symbol.isMetaClass);
        return symbol.name;
    }

    DClassGenerator add(string[] s...)
    {
        _classSourceCode ~= s.join("\n") ~ "\n";
        return this;
    }

    string generateClassSourceCode(Class class_)
    {
        Ancestor ancestorClass;
        Ancestor[] ancestorInterfaces;

        foreach(ancestor; class_.ancestors)
        {
            try
            {
                if (_symbolCache.getSymbol(ancestor.name).isClass)
                    ancestorClass = ancestor;
                else
                    ancestorInterfaces ~= ancestor;
            }
            catch (SymbolNotFoundException)
            {
                    writeln("Symbol not found: ", ancestor.name);
            }
            catch (SymbolNotAllowedException)
            {
                    writeln("Symbol not allowed: ", ancestor.name);
            }
        }

        string genericId;
        if (class_.name != class_.nameWithGeneric)
        {
            genericId = class_.nameWithGeneric[class_.nameWithGeneric.countUntil("<") + 1..class_.nameWithGeneric.countUntil(">")];
        }

        if (class_.name == "TObject")
            add(`class ` ~ class_.name ~ ` : DelphiObject {`);
        else
        {
            string ancestorClassStr = ancestorClass.name;
            if (ancestorClass.name != ancestorClass.declaration)
            {
                string genericParameter = ancestorClass.declaration[ancestorClass.declaration.countUntil("<") + 1 .. ancestorClass.declaration.countUntil(">")];
                ancestorClassStr = ancestorClass.name ~ "!" ~ genericParameter;
            }
            
            add(`class ` ~ class_.name ~ (genericId ? `(` ~ genericId ~ `)` : ``) ~ (ancestorClassStr ? ` : ` ~ ancestorClassStr : ``), ` {`);
        }
        
        add(`mixin PascalClass!("` ~ _unitName ~ `.` ~ class_.name ~ `");`);

        foreach(routine; class_.routines)
        {
            add(_routineToDDeclaration(class_.name, routine, genericId));
        }

        foreach(property; class_.properties)
        {
            add(_propertyToDDeclaration(property, ancestorClass.name));
        }

        add(`}`, ``);
        return _classSourceCode;
    }

    private string _propertyToDDeclaration(Property property, string ancestorClassName)
    {
        DPropertyModel propertyModel;

        try
        {
            propertyModel = _getDPropertyModel(property, ancestorClassName);
            if (propertyModel == DPropertyModel.init)
            {
                return "// " ~ to!string(property);
            }
        }
        catch (SymbolNotFoundException)
        {
                writeln("Symbol not found: ", property.type);
                return "// " ~ to!string(property);
        }
        catch (SymbolNotAllowedException)
        {
                writeln("Symbol not allowed: ", property.type);
                return "// " ~ to!string(property);
        }

        string[] result;

        if (propertyModel.hasRead)
        {
            result ~= `@property ` ~ (propertyModel.isOverrideRead ? "override " : "") ~ propertyModel.type ~ ` ` ~ propertyModel.name ~ `();`;
        }

        if (propertyModel.hasWrite)
        {
            result ~= `@property ` ~ (propertyModel.visibility == "protected" ? "protected " : "") ~ (propertyModel.isOverrideWrite ? "override " : "") ~ `void ` ~ propertyModel.name ~ `(` ~ propertyModel.type ~ ` value);`;
        }

        if (propertyModel.isOverrideRead || propertyModel.isOverrideWrite)
        {
            result ~= ` alias ` ~ propertyModel.name ~ ` = typeof(super).` ~ propertyModel.name ~ `;`;
        }

        return result.join("\n");
    }
    
    private string _routineToDDeclaration(string className, Routine routine, string genericId)
    {
        if (routine.name.canFind("."))
        {
            return "//" ~ routine.declaration;
        }
        
        auto argsStart = routine.declaration.countUntil("(");
        auto argsEnd = routine.declaration.countUntil(")");
        string dArgs;

        if (argsStart > 0)
        {
            string argsLine = routine.declaration[argsStart + 1 .. argsEnd];
            string[] args = argsLine.split(";");
            foreach(argGroup; args)
            {
                string[] namesTypeArr = argGroup.split(":");
                if (namesTypeArr.length == 2)
                {
                    string[] namesArr = namesTypeArr[0].split(",");
                    
                    string delphiArgType = namesTypeArr[1].strip;
                    string[] argTypeDefaultArr = delphiArgType.split("=");
                    string defaultValue;
                    if (argTypeDefaultArr.length == 2)
                    {
                        delphiArgType = argTypeDefaultArr[0].strip;
                        defaultValue = argTypeDefaultArr[1].strip;

                        if (defaultValue.toLower == "nil") defaultValue = "null";
                        if (defaultValue.toLower == "true") defaultValue = "true";
                        if (defaultValue.toLower == "false") defaultValue = "false";
                    }
                    if (delphiArgType.toLower == "array of const")
                    {
                        writeln("Not yet supported: ", delphiArgType);
                        return "//" ~ routine.declaration;
                    }

                    string dArgType;
					try
					{
						dArgType = toDArgType(delphiArgType, genericId);
					}
					catch (MetaClassException)
					{
						 writeln("MetaClass not yet supported: ", delphiArgType);
						 return "//" ~ routine.declaration;
					}
                    catch (SymbolNotFoundException)
					{
						 writeln("Symbol not found: ", delphiArgType);
						 return "//" ~ routine.declaration;
					}
                    catch (SymbolNotAllowedException)
					{
						 writeln("Symbol not allowed: ", delphiArgType);
						 return "//" ~ routine.declaration;
					}
					
                    bool isVar;
                    foreach(argName; namesArr)
                    {
                        argName = argName.strip;
                        if (argName.toLower.startsWith("const ")) argName = argName[6..$];
                        if (argName.toLower.startsWith("out ")) argName = argName[4..$]; // How to handle?
                        if (argName.toLower.startsWith("var "))
                        {
                            argName = argName[3..$];
                            isVar = true;
                        } 
                        dArgs ~= (dArgs == "" ? "" : ", ") ~ dArgType ~ " " ~ (isVar ? "*" : "") ~ argName.strip ~ (defaultValue == "" ? "" : " = " ~ defaultValue);
                    }
                }
                else 
                {
                    writeln("Not yet supported: ", namesTypeArr);
                    return "//" ~ routine.declaration;    
                }
            }
        }

        string returnType;
        bool isStatic;
        bool isOverride = routine.declaration.toLower.canFind(`override;`);
        bool isReintroduce = routine.declaration.toLower.canFind(`reintroduce;`);
        string routineName = routine.name;
        if (routine.type == "procedure")
        {
            isStatic = routine.declaration.toLower.startsWith("class ");
            returnType = "void";
        }
        else if (routine.type == "function")
        {
            isStatic = routine.declaration.toLower.startsWith("class ");
            
            auto colonPos = routine.declaration.countUntil(":");
            if (colonPos > 0)
            {
                string[] colonsArr = routine.declaration.split(":");
                string[] semiColonArr = colonsArr[$-1].split(";");
                try
                {
                    returnType = toDArgType(semiColonArr[0].strip, genericId);
                }
                catch (SymbolNotFoundException)
                {
                        writeln("Symbol not found: ", semiColonArr[0].strip);
                        return "//" ~ routine.declaration;
                }
                catch (SymbolNotAllowedException)
                {
                        writeln("Symbol not allowed: ", semiColonArr[0].strip);
                        return "//" ~ routine.declaration;
                }
            }
            else 
            {
                writeln("Not yet supported: ", routine.declaration);
                return "//" ~ routine.declaration;
            }
            
        }
        else if (routine.type == "constructor")
        {
            isStatic = true;
            isOverride = false;
            returnType = className;
        }
        else if (routine.type == "destructor")
        {
            returnType = "void";
        }

        string overloadSet;
        if (isOverride || isReintroduce)
        {
            overloadSet = ` alias ` ~ routine.name ~ ` = typeof(super).` ~ routine.name ~ `;`;
        }

        return (isStatic ? "static " : "") ~ (routine.visibility == "protected" ? "protected " : "") ~ (isOverride ? "override " : "") ~ returnType ~ " " ~ routineName ~ "(" ~ dArgs ~ ");" 
            ~ overloadSet;
    }

    private string _getAncestorClassName(Ancestor[] ancestors)
    {
        foreach(ancestor; ancestors)
        {
            try
            {
                if (_symbolCache.getSymbol(ancestor.name).isClass)
                    return ancestor.name;
            }
            catch (SymbolNotFoundException)
            {
                    writeln("Symbol not found: ", ancestor.name);
            }
            catch (SymbolNotAllowedException)
            {
                    writeln("Symbol not allowed: ", ancestor.name);
            }
        }
        return "";
    }

    private string toDArgType(string delphiArgType, string genericId)
    {
        if (delphiArgType.startsWith("array of "))
        {
            return toDArgType(delphiArgType[9..$]~"[]", genericId);
        }
        
        if (delphiArgType == genericId)
        {
            return genericId;
        }

        auto genericStartPos = delphiArgType.countUntil("<");
        if (genericStartPos > 0)
        {
            string genericBaseClass = delphiArgType[0..genericStartPos];
            _validateSymbol(genericBaseClass);
            string genericParameter = toDArgType(delphiArgType[genericStartPos+1..$-1], genericId);
            return genericBaseClass ~ "!" ~ genericParameter;
        }

        switch(delphiArgType.toLower)
        {
            case "integer":
                return "int";
            case "string":
                return "string";
            case "boolean":
                return "bool";
            case "nativeint":
                return "ptrdiff_t";
            case "word":
                return "ushort";
            case "single":
                return "float";
            case "char":
                return "char";
            case "widechar":
                return "dchar";
            default:
                return _validateSymbol(delphiArgType); // Assuming it is a class
        }
    }

    DPropertyModel _getDPropertyModel(Property property, string ancestorClassName)
    {
        DPropertyModel model;

        string currentAncestorClassName = ancestorClassName;
        while(currentAncestorClassName != "")
        {
            auto ancestorClass = _symbolCache.getClass(SearchScope.usedUnits, currentAncestorClassName);
            auto arr = ancestorClass.properties.filter!(p => p.name.toLower == property.name.toLower).array;

            if (arr.length == 1)
            {
                auto parentProperty = arr[0];
                model.isOverrideRead = property.type == "" || property.type != parentProperty.type;
                model.isOverrideWrite = property.type == "" || property.type == parentProperty.type;
                break;
            }

            currentAncestorClassName = _getAncestorClassName(ancestorClass.ancestors);
        }

        currentAncestorClassName = ancestorClassName;
        if (property.type == "")
        {
            while (ancestorClassName != "")
            {
                auto ancestorClass = _symbolCache.getClass(SearchScope.usedUnits, currentAncestorClassName);
                auto filteredProp = ancestorClass.properties.filter!(p => p.name == property.name && p.type != "").array;
                if (filteredProp.length == 0)
                {
                    currentAncestorClassName = _getAncestorClassName(ancestorClass.ancestors);
                }
                else 
                {
                    property = filteredProp[0];
                    break;
                }
            }
        }

        switch (property.type.toLower)
        {
            case "integer":
                model.type = "int";
                break;
            case "string":
                model.type = "string";
                break;
            case "boolean":
                model.type = "bool";
                break;
            case "nativeint":
                model.type = "ptrdiff_t";
                break;
            case "word":
                model.type = "ushort";
                break;
            case "single":
                model.type = "float";
                break;
            case "widechar":
                model.type = "dchar";
                break;
            case "":
                writeln("Empty property");
                return DPropertyModel();
            default:
                try
                {
                    model.type = _validateSymbol(property.type);
                }
                catch (MetaClassException)
                {
                        writeln("Metadata class not supported: ", property.type);
                        return DPropertyModel();
                }
                catch (SymbolNotFoundException)
                {
                        writeln("Symbol not found: ", property.type);
                        return DPropertyModel();
                }
                catch (SymbolNotAllowedException)
                {
                        writeln("Symbol not allowed: ", property.type);
                        return DPropertyModel();
                }
        }

        model.hasRead = property.reader != "";
        model.hasWrite = property.writer != "";
        model.name = property.name;
        model.visibility = property.visibility;
        return model;
    }
}

unittest
{
    string[Routine] tests = [
       /*Routine("Create", "constructor", "constructor Create(AOwner: TComponent); override;"):
            "static TSample Create(TComponent AOwner);",

        Routine("FormDestroyed", "procedure", "procedure FormDestroyed(const AForm: TCommonCustomForm);"):
            "void FormDestroyed(TCommonCustomForm AForm);",

        Routine("CreateForm", "procedure", "procedure CreateForm(const InstanceClass: TComponentClass; var Reference);"):
            "",

        Routine("RegisterFormFamily", "procedure", "procedure RegisterFormFamily(const AFormFamily: string; const AForms: array of TComponentClass);"):
            "void RegisterFormFamily(string AFormFamily, TComponentClass[] AForms);",

        Routine("DoIdle", "procedure", "procedure DoIdle(var Done: Boolean);"):
            "void DoIdle(bool *Done);",*/

        Routine("DoSetSize", "function", "function DoSetSize(ANewWidth, ANewHeight: Single; var ALastWidth, ALastHeight: Single): Boolean; override;"):
            "override bool DoSetSize(float ANewWidth, float ANewHeight, float *ALastWidth, float *ALastHeight);",

       /* Routine("ShowException", "procedure", "procedure ShowException(E: Exception);"):
            "void ShowException(Exception E);",

        Routine("OverrideScreenSize", "procedure", "procedure OverrideScreenSize(W, H: Integer);"):
            "void OverrideScreenSize(int W, int H);",

        Routine("ValidateRename", "procedure", "procedure ValidateRename(AComponent: TComponent; const CurName, NewName: string); override;"):
            "void ValidateRename(TComponent AComponent, string CurName, string NewName);",

        Routine("CreateNew", "constructor", "constructor CreateNew(AOwner: TComponent; Dummy: NativeInt = 0); virtual;"):
            "static TSample CreateNew(TComponent AOwner, ptrdiff_t Dummy = 0);",

        Routine("ShowModal", "procedure", "procedure ShowModal(const ResultProc: TProc<TModalResult>); overload;"):
            "void ShowModal(TProc!TModalResult ResultProc);",

        Routine("Create", "constructor", "constructor Create(AOwner: TComponent; AStyleBook: TStyleBook = nil; APlacementTarget: TControl = nil; AutoFree: Boolean = True); reintroduce;"):
            "static TSample Create(TComponent AOwner, TStyleBook AStyleBook = null, TControl APlacementTarget = null, bool AutoFree = true);",

        Routine("QueryInterface", "function", "function QueryInterface(const IID: TGUID; out Obj): HResult; override;"):
            "",

        Routine("GetUniqueName", "function", "function GetUniqueName: string;"):
            "string GetUniqueName();",

        Routine("GetBackIndex", "function", "function GetBackIndex: Integer; override;"):
            "int GetBackIndex();",

        Routine("FindTarget", "function", "function FindTarget(P: TPointF; const Data: TDragObject): IControl; virtual;"):
            "IControl FindTarget(TPointF P, TDragObject Data);",

        Routine("IControl.GetVisible", "function", "function IControl.GetVisible= ShouldTestMouseHits;"):
            "",

        Routine("CreatePopupList", "function", "function CreatePopupList(const SaveForm: TCommonCustomForm): TList<TCommonCustomForm>;"):
            "TList!TCommonCustomForm CreatePopupList(TCommonCustomForm SaveForm);",

        Routine("Size", "function", "function Size: TSize;"):
            "TSize Size();",

        Routine("CreateAnonymousThread", "function", "class function CreateAnonymousThread(const ThreadProc: TProc): TThread; static;"):
            "static TThread CreateAnonymousThread(TProc ThreadProc);",

        Routine("GetTypeInfoCount", "function", "function GetTypeInfoCount(out Count: Integer): HResult; stdcall;"):
            "HResult GetTypeInfoCount(int Count);",
            
        Routine("BeginInvoke", "function", "function BeginInvoke(const AProc: TAsyncConstArrayProc; const Params: array of const; const AContext: TObject = nil): IAsyncResult; overload;"):
            "",*/
        
    ];

    SymbolCache.setUnitsCache(["samplemodule": UnitCache([], [
        "TComponent": Symbol(false, true, false, false, false, "sample", SymbolCategory.structure, JSONValue(), true),
        "HResult": Symbol(true, false, false, false, false, "sample", SymbolCategory.constant, JSONValue(), true)
    ])]);

    foreach(kv; tests.byKeyValue)
    {
        string actual = new DClassGenerator("samplemodule")._routineToDDeclaration("TSample", kv.key);
        assert(actual == kv.value, "Failed for: `" ~ kv.key.declaration ~ "` Expected:  `" ~ kv.value ~ "` actual: `" ~ actual ~ "`");
    }
}


