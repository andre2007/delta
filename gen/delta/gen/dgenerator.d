module delta.gen.dgenerator;

import std;
import delta.gen.symbolcache;

struct DGeneratorSettings
{
    bool upperCamelCase = true;
}

void generateDWrapper(string specFolderPath, string targetFolderPath, DGeneratorSettings settings = DGeneratorSettings.init)
{
	SymbolCache.loadSymbols(specFolderPath);

    foreach(unitName; SymbolCache.getUnits)
    {
        writeln("Processing unit ", unitName);

        auto moduleSoureCodeGenerator = new ModuleSoureCodeGenerator(unitName);
        string moduleSourceCode = moduleSoureCodeGenerator.generate();
        string moduleFilePath = determineModuleFilePath(targetFolderPath, unitName, SymbolCache.getUnits);
        mkdirRecurse(moduleFilePath.dirName);
        moduleSourceCode.toFile(moduleFilePath);
    } 
}

string determineModuleFilePath(string basePath, string unitName, string[] unitNames)
{
    string[] arr = unitName.split(".");
    bool packageModule;
    foreach(unit; unitNames)
    {
        if (unit.startsWith(unitName~"."))
        {
            packageModule = true;
            break;
        }
    }
    if (packageModule)
        arr ~= ["package.d"];
    else
        arr[$-1] = arr[$-1]~".d";
    return buildPath(basePath ~ arr);
}

unittest
{
    assert(determineModuleFilePath(`C:\test`, `FMX.Controls`, [`FMX.Controls`]) == `C:\test\FMX\Controls.d`);
    assert(determineModuleFilePath(`C:\test`, `FMX.Controls`, [`FMX.Controls`, `FMX.Controls.Presentation`]) == `C:\test\FMX\Controls\package.d`);
    assert(determineModuleFilePath(`C:\test`, `FMX.Controls.Presentation`, [`FMX.Controls`, `FMX.Controls.Presentation`]) == `C:\test\FMX\Controls\Presentation.d`);
}

class MetaClassException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

class ModuleSoureCodeGenerator
{
    private string _moduleSourceCode;
    private string _unitName;
	private SymbolCache _symbolCache;

    this(string unitName)
    {
        _unitName = unitName;
		_symbolCache = SymbolCache.getSymbolCache(_unitName);
    }

    string generate()
    {
        add(`module ` ~_unitName ~ ";", "", "import delta.core;");
		add("import " ~ _symbolCache.getUses().join(", ") ~ ";", "");

        foreach(class_; _symbolCache.getClasses())
        {
            addClassSourceCode(class_);
        }

        foreach(interface_; _symbolCache.getInterfaces())
        {
            addInterfaceSourceCode(interface_);
        }

        foreach(record; _symbolCache.getRecords())
        {
            addRecordSourceCode(record);
        }

        foreach(type; _symbolCache.getTypes())
        {
            addTypeSourceCode(type);
        }

        foreach(constant; _symbolCache.getConstants())
        {
            addConstantSourceCode(constant);
        }

        foreach(var; _symbolCache.getVariables())
        {
            addVariableSourceCode(var);
        }

        return _moduleSourceCode;
    }

    ModuleSoureCodeGenerator add(string[] s...)
    {
        _moduleSourceCode ~= s.join("\n") ~ "\n";
        return this;
    }

    void addTypeSourceCode(Type type)
    {
        string[] parts = type.declaration.split(" = ");
        if (parts.length == 2)
        {
            switch (parts[1].toLower)
            {
                case "array of t;":
                    add(`alias ` ~ type.name ~ `(T) = T[];`);
                    break;
                case "integer;":
                    add(`alias ` ~ type.name ~ ` = int;`);
                    break;
                case "(...);":
                    add(`enum ` ~ type.name ~ ` {` ~ type.constants.map!(c => c.declaration).join(", ") ~ `}`);
                    break;
                default:
                    writeln("Unknown type: " ~ type.declaration);
            }
        }
        else writeln("Unknown type: " ~ type.declaration);
    }

    void addConstantSourceCode(Constant constant)
    {

    }

    void addVariableSourceCode(Variable var)
    {
        
    }

    void addInterfaceSourceCode(Interface_ interface_)
    {
        string[] interfaceNames = interface_.ancestors.map!(a => a.name).array;
        add(`interface ` ~ interface_.name ~ (interfaceNames.length ? `: ` ~ interfaceNames.join(", ") : ``) , `{`, `}`);

        assert(interface_.properties.length == 0);
        assert(interface_.types.length == 0);
    }

    void addRecordSourceCode(Record record)
    {
        writeln(record);
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

    void addClassSourceCode(Class class_)
    {
        if (class_.name == "TObject")
        {
            return;
        }

        string ancestorClass;
        string[] ancestorInterfaces;

        foreach(ancestor; class_.ancestors)
        {
            try
            {
                if (_symbolCache.getSymbol(ancestor.name).isClass)
                    ancestorClass = ancestor.name;
                else
                    ancestorInterfaces ~= ancestor.name;
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

        add(`class ` ~ class_.name ~ (ancestorClass ? ` : ` ~ ancestorClass : ``), `{`);
        add(`mixin PascalClass!("` ~ _unitName ~ `.` ~ class_.name ~ `");`);

        foreach(routine; class_.routines)
        {
            add(_routineToDDeclaration(class_.name, routine));
        }

        foreach(property; class_.properties)
        {
            add(_propertyToDDeclaration(property, ancestorClass));
        }

        add(`}`, ``);
    }

    private string _propertyToDDeclaration(Property property, string ancestorClassName)
    {
        string[] result;
        string dPropertyType;

        if (property.type == "")
        {
            string currentAncestorClassName = ancestorClassName;
            while (ancestorClassName != "")
            {
                auto ancestorClass = _symbolCache.getClass(currentAncestorClassName);
                auto filteredProp = ancestorClass.properties.filter!(p => p.name == property.name && p.type != "").array;
                if (filteredProp.length == 0)
                {
                    currentAncestorClassName = _getAncestorClassName(ancestorClass.ancestors);
                }
                else 
                {
                    writeln("Ancestor property found");
                    property = filteredProp[1];
                    break;
                }
            }
        }


        switch (property.type.toLower)
        {
            case "integer":
                dPropertyType = "int";
                break;
            case "string":
                dPropertyType = "string";
                break;
            case "boolean":
                dPropertyType = "bool";
                break;
            case "nativeint":
                dPropertyType = "ptrdiff_t";
                break;
            case "word":
                dPropertyType = "ushort";
                break;
            case "single":
                dPropertyType = "float";
                break;
            case "widechar":
                dPropertyType = "dchar";
                break;
            case "":
                writeln("Empty property in unit", _unitName);
                return "// " ~ property.to!string;
            default:
                try
                {
                    validateSymbol(property.type);
                }
                catch (MetaClassException)
                {
                        writeln("Metadata class not supported: ", property.type);
                        return "// " ~ property.to!string ;
                }
                catch (SymbolNotFoundException)
                {
                        writeln("Symbol not found: ", property.type);
                        return "// " ~ property.to!string;
                }
                catch (SymbolNotAllowedException)
                {
                        writeln("Symbol not allowed: ", property.type);
                        return "//" ~ property.to!string;
                }
                dPropertyType = property.type;
        }

        if (property.reader != "")
        {
            result ~= `@property ` ~ dPropertyType ~ ` ` ~ property.name ~ `();`;
        }

        if (property.writer != "")
        {
            result ~= `@property void ` ~ property.name ~ `(` ~ dPropertyType ~ ` value);`;
        }

        return result.join("\n");
    }

    private string toDArgType(string delphiArgType)
    {
        if (delphiArgType.startsWith("array of "))
        {
            return toDArgType(delphiArgType[9..$]~"[]");
        }

        auto genericStartPos = delphiArgType.countUntil("<");
        if (genericStartPos > 0)
        {
            return delphiArgType[0..genericStartPos] ~ "!" ~ toDArgType(delphiArgType[genericStartPos+1..$-1]);
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
            case "widechar":
                return "dchar";
            default:
                validateSymbol(delphiArgType);
                return delphiArgType; // Assuming it is a class
        }
    }

    private void validateSymbol(string symbolName)
    {
        Symbol symbol = _symbolCache.getSymbol(symbolName);
        enforce!MetaClassException(!symbol.isMetaClass);
    }

    private string _routineToDDeclaration(string className, Routine routine)
    {
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
						dArgType = toDArgType(delphiArgType);
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
					
                    foreach(argName; namesArr)
                    {
                        bool isVar;
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
                    returnType = toDArgType(semiColonArr[0].strip);
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
            //isStatic = true;
            //returnType = className;
            
            // TEST
            returnType = "";
            isStatic = false;
            isOverride = false;
            routineName = "this";
            // TEST
        }
        else if (routine.type == "destructor")
        {
            returnType = "void";
        }

        return (isStatic ? "static " : "") ~ (isOverride ? "override " : "") ~ returnType ~ " " ~ routineName ~ "(" ~ dArgs ~ ");";
    }


}


unittest
{
    struct Sample
    {
        string className;
        string functionName;
        string functionType;
        string functionDeclaration;
    }

    string[Sample] tests = [
        Sample("TSample", "Create", "constructor", "constructor Create(AOwner: TComponent); override;"):
            "static TSample Create(TComponent AOwner);",

        Sample("TSample", "FormDestroyed", "procedure", "procedure FormDestroyed(const AForm: TCommonCustomForm);"):
            "void FormDestroyed(TCommonCustomForm AForm);",

        Sample("TSample", "CreateForm", "procedure", "procedure CreateForm(const InstanceClass: TComponentClass; var Reference);"):
            "",

        Sample("TSample", "RegisterFormFamily", "procedure", "procedure RegisterFormFamily(const AFormFamily: string; const AForms: array of TComponentClass);"):
            "void RegisterFormFamily(string AFormFamily, TComponentClass[] AForms);",

        Sample("TSample", "DoIdle", "procedure", "procedure DoIdle(var Done: Boolean);"):
            "void DoIdle(bool *Done);",

        Sample("TSample", "ShowException", "procedure", "procedure ShowException(E: Exception);"):
            "void ShowException(Exception E);",

        Sample("TSample", "OverrideScreenSize", "procedure", "procedure OverrideScreenSize(W, H: Integer);"):
            "void OverrideScreenSize(int W, int H);",

        Sample("TSample", "ValidateRename", "procedure", "procedure ValidateRename(AComponent: TComponent; const CurName, NewName: string); override;"):
            "void ValidateRename(TComponent AComponent, string CurName, string NewName);",

        Sample("TSample", "CreateNew", "constructor", "constructor CreateNew(AOwner: TComponent; Dummy: NativeInt = 0); virtual;"):
            "static TSample CreateNew(TComponent AOwner, ptrdiff_t Dummy = 0);",

        Sample("TSample", "ShowModal", "procedure", "procedure ShowModal(const ResultProc: TProc<TModalResult>); overload;"):
            "void ShowModal(TProc!TModalResult ResultProc);",

        Sample("TSample", "Create", "constructor", "constructor Create(AOwner: TComponent; AStyleBook: TStyleBook = nil; APlacementTarget: TControl = nil; AutoFree: Boolean = True); reintroduce;"):
            "static TSample Create(TComponent AOwner, TStyleBook AStyleBook = null, TControl APlacementTarget = null, bool AutoFree = true);",

        Sample("TSample", "QueryInterface", "function", "function QueryInterface(const IID: TGUID; out Obj): HResult; override;"):
            "",

        Sample("TSample", "GetUniqueName", "function", "function GetUniqueName: string;"):
            "string GetUniqueName();",

        Sample("TSample", "GetBackIndex", "function", "function GetBackIndex: Integer; override;"):
            "int GetBackIndex();",

        Sample("TSample", "FindTarget", "function", "function FindTarget(P: TPointF; const Data: TDragObject): IControl; virtual;"):
            "IControl FindTarget(TPointF P, TDragObject Data);",

        Sample("TSample", "IControl.GetVisible", "function", "function IControl.GetVisible= ShouldTestMouseHits;"):
            "",

        Sample("TSample", "CreatePopupList", "function", "function CreatePopupList(const SaveForm: TCommonCustomForm): TList<TCommonCustomForm>;"):
            "TList!TCommonCustomForm CreatePopupList(TCommonCustomForm SaveForm);",

        Sample("TSample", "Size", "function", "function Size: TSize;"):
            "TSize Size();",

        Sample("TSample", "CreateAnonymousThread", "function", "class function CreateAnonymousThread(const ThreadProc: TProc): TThread; static;"):
            "static TThread CreateAnonymousThread(TProc ThreadProc);",

        Sample("TSample", "GetTypeInfoCount", "function", "function GetTypeInfoCount(out Count: Integer): HResult; stdcall;"):
            "HResult GetTypeInfoCount(int Count);",
            
        Sample("TSample", "BeginInvoke", "function", "function BeginInvoke(const AProc: TAsyncConstArrayProc; const Params: array of const; const AContext: TObject = nil): IAsyncResult; overload;"):
            "",
        
    ];

    foreach(kv; tests.byKeyValue)
    {
        string actual = ModuleSoureCodeGenerator._toDDeclaration(kv.key.className, kv.key.functionName, kv.key.functionType, kv.key.functionDeclaration);
        assert(actual == kv.value, "Failed for: `" ~ kv.key.functionDeclaration ~ "` Expected:  `" ~ kv.value ~ "` actual: `" ~ actual ~ "`");
    }
}