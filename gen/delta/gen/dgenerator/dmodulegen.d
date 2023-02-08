module delta.gen.dgenerator.dmodulegen;

import std;
import delta.gen.symbolcache;
import delta.gen.dgenerator.dclassgen;
import delta.gen.dgenerator.common;

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

        foreach(class_; _symbolCache.getClasses(SearchScope.currentUnit))
        {
            add(new DClassGenerator(_unitName).generateClassSourceCode(class_));
        }

        foreach(interface_; _symbolCache.getInterfaces(SearchScope.currentUnit))
        {
            addInterfaceSourceCode(interface_);
        }

        foreach(record; _symbolCache.getRecords(SearchScope.currentUnit))
        {
            addRecordSourceCode(record);
        }

        foreach(type; _symbolCache.getTypes(SearchScope.currentUnit))
        {
            addTypeSourceCode(type);
        }

        foreach(constant; _symbolCache.getConstants(SearchScope.currentUnit))
        {
            addConstantSourceCode(constant);
        }

        foreach(var; _symbolCache.getVariables(SearchScope.currentUnit))
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

        //assert(interface_.properties.length == 0);
        assert(interface_.types.length == 0);
    }

    void addRecordSourceCode(Record record)
    {
         add(`struct ` ~ record.name , `{`, `}`);
    }
}


