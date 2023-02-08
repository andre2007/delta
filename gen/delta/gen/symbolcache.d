module delta.gen.symbolcache;

import std;
import delta.gen.utils;

enum SymbolCategory {routine, constant, variable, type, structure}
enum SearchScope {currentUnit, usedUnits}

struct Symbol
{
    bool isConstant;
    bool isClass;
    bool isMetaClass;
    bool isInterface;
    bool isRoutine;
    
    string unit;
    SymbolCategory category;
    JSONValue jsSymbol;
    bool isAllowed;
}

struct UnitCache
{
    string[] uses;
    Symbol[string] symbols;
}

struct Constant
{
    string name;
    string declaration;
    string visibility;  
}

struct Variable
{
    string name;
    string declaration;
    string visibility;
}

struct Type
{
    string name;
    string declaration;
    Constant[] constants;
    string visibility;
}

struct Routine
{
    string name;
    string type;
    string declaration;
    string visibility;
}

struct Property
{
    string name;
    bool defaultInClass;
    string defaultValue;
    string indexDecl;
    bool noDefault;
    string reader;
    string stored;
    string type;
    string writer;
    string visibility;
}

struct Ancestor
{
    string name;
    string declaration;
}

struct Record
{
    string name;
    string nameWithGeneric;
    Variable[] variables;
}

struct Interface_
{
    string name;
    string nameWithGeneric;
    Ancestor[] ancestors;
    Property[] properties;
    Routine[] routines;
    Type[] types;
}

struct Class
{
    string name;
    string nameWithGeneric;
    Ancestor[] ancestors;
    Property[] properties;
    Routine[] routines;
    Type[] types;
    Variable[] variables;
}

string decodeXmlString(string s)
{
    return s.replace(`&lt;`, `<`).replace(`&gt;`, `>`).replace(`&amp;`, `&`).replace(`&quot;`, `"`);
}

class SymbolCache
{
    private static UnitCache[string] _unitsCache;
    private string _unit;

    private this(string unit)
    {
        assert((unit in _unitsCache) !is null);
        _unit = unit;
    }

    Symbol getSymbol(string symbolName, bool allowedOnly = true)
    {
        string symbolNameLower = symbolName.toLower;
        
        foreach (unit; _unitsCache[_unit].uses ~ _unit)
        {
            if ((unit in _unitsCache) is null)
            {
                continue;
            }
            
            auto p = symbolNameLower in _unitsCache[unit].symbols;
            if (p !is null)
            {
                if (allowedOnly && (*p).isAllowed == false)
                {
                    throw new SymbolNotAllowedException(symbolName);
                }
                
                return *p;
            }
        }
        throw new SymbolNotFoundException(symbolName);
    }

    JSONValue[] getSymbolsJSON(SearchScope searchScope, SymbolCategory category, bool allowedOnly = true)
    {
        JSONValue[] results;

        foreach(unitName; _unitsCache.keys)
        {
            if (searchScope == SearchScope.currentUnit && unitName != _unit)
            {
                continue;
            }

            foreach(kv; _unitsCache[unitName].symbols.byKeyValue)
            {
                if (kv.value.category == category && (allowedOnly == false || kv.value.isAllowed))
                {
                    results ~= kv.value.jsSymbol;
                }
            }
        }

        return results;
    }

    string[] getUses()
    {
        return _unitsCache[_unit].uses;
    }

    Constant[] getConstants(SearchScope searchScope, bool allowedOnly = true)
    {
        return getSymbolsJSON(searchScope, SymbolCategory.constant, allowedOnly).map!(js => toConstant(js)).array;
    }

    private Constant toConstant(JSONValue js)
    {
        return Constant(js["_name"].str.decodeXmlString, js["_declaration"].str.decodeXmlString, js["_visibility"].str);
    }

    Variable[] getVariables(SearchScope searchScope, bool allowedOnly = true)
    {
        return getSymbolsJSON(searchScope, SymbolCategory.variable, allowedOnly).map!(js => toVariable(js)).array;
    }

    private Variable toVariable(JSONValue js)
    {
        return Variable(js["_name"].str.decodeXmlString, js["_declaration"].str.decodeXmlString, js["_visibility"].str);
    }

    Routine[] getRoutines(SearchScope searchScope, bool allowedOnly = true)
    {
        return getSymbolsJSON(searchScope, SymbolCategory.routine, allowedOnly).map!(js => toRoutine(js)).array;
    }

    private Routine toRoutine(JSONValue jsRoutine)
    {
        Routine routine = {
            name : jsRoutine["_name"].str.decodeXmlString,
            type : jsRoutine["_type"].str.decodeXmlString,
            declaration: jsRoutine["_declaration"].str.decodeXmlString,
            visibility: jsRoutine["_visibility"].str
        };
        return routine;
    }

    Type[] getTypes(SearchScope searchScope, bool allowedOnly = true)
    {
        return getSymbolsJSON(searchScope, SymbolCategory.type, allowedOnly).map!(js => toType(js)).array;
    }

    private Type toType(JSONValue jsType)
    {
        Type type = {
            name : jsType["_name"].str.decodeXmlString,
            declaration: jsType["_declaration"].str.decodeXmlString,
            visibility: jsType["_visibility"].str
        };

        if (("constant" in jsType) !is null)
        {
            JSONValue[] jsConstants = (jsType["constant"].type == JSONType.array) ? jsType["constant"].array : [ JSONValue(jsType["constant"].object)];
            type.constants = jsConstants.map!(js => toConstant(js)).array;
        }
        
        return type;
    }

    private Ancestor toAncestor(JSONValue js)
    {
        return Ancestor(js["_name"].str.decodeXmlString, js["_declaration"].str.decodeXmlString);
    }

    Class[] getClasses(SearchScope searchScope, bool allowedOnly = true)
    {
        return getSymbolsJSON(searchScope, SymbolCategory.structure, allowedOnly)
            .filter!(js => js["_type"].str == "class").map!(js => toClass(js)).array;
    }

    Class getClass(SearchScope searchScope, string className, bool allowedOnly = true)
    {
        auto arr = getSymbolsJSON(searchScope, SymbolCategory.structure, allowedOnly)
            .filter!(js => js["_type"].str == "class" && js["_name"].str.toLower == className.toLower).map!(js => toClass(js)).array;
        if (arr.length == 0)
        {
            throw new SymbolNotFoundException(className);
        }
        return arr[0];
    }

    private Class toClass(JSONValue jsClass)
    {
        Class class_ = {
            name : jsClass["_name"].str.decodeXmlString,
            nameWithGeneric : jsClass["_name_with_generic"].str.decodeXmlString,
        };

        if (("ancestor" in jsClass) !is null)
        {
            JSONValue[] jsAncestors = (jsClass["ancestor"].type == JSONType.array) ? jsClass["ancestor"].array : [ JSONValue(jsClass["ancestor"].object)];
            class_.ancestors = jsAncestors.map!(js => toAncestor(js)).array;
        }

        if (("routine" in jsClass) !is null)
        {
            JSONValue[] jsRoutines = (jsClass["routine"].type == JSONType.array) ? jsClass["routine"].array : [ JSONValue(jsClass["routine"].object)];
            class_.routines = jsRoutines.map!(js => toRoutine(js)).array;
        }

        if (("property" in jsClass) !is null)
        {
            JSONValue[] jsProperties = (jsClass["property"].type == JSONType.array) ? jsClass["property"].array : [ JSONValue(jsClass["property"].object)];
            class_.properties = jsProperties.map!(js => toProperty(js)).array;
        }

        if (("type" in jsClass) !is null)
        {
            JSONValue[] jsTypes = (jsClass["type"].type == JSONType.array) ? jsClass["type"].array : [ JSONValue(jsClass["type"].object)];
            class_.types = jsTypes.map!(js => toType(js)).array;
        }

        if (("variable" in jsClass) !is null)
        {
            JSONValue[] jsVariables = (jsClass["variable"].type == JSONType.array) ? jsClass["variable"].array : [ JSONValue(jsClass["variable"].object)];
            class_.variables = jsVariables.map!(js => toVariable(js)).array;
        }

        // Deep structures ?

        return class_;
    }

    Interface_[] getInterfaces(SearchScope searchScope, bool allowedOnly = true)
    {
        return getSymbolsJSON(searchScope, SymbolCategory.structure, allowedOnly)
            .filter!(js => js["_type"].str == "interface").map!(js => toInterface(js)).array;
    }

    private Interface_ toInterface(JSONValue jsInterface)
    {
        Interface_ interface_ = {
            name : jsInterface["_name"].str,
            nameWithGeneric : jsInterface["_name_with_generic"].str,
        };

        if (("ancestor" in jsInterface) !is null)
        {
            JSONValue[] jsAncestors = (jsInterface["ancestor"].type == JSONType.array) ? jsInterface["ancestor"].array : [ JSONValue(jsInterface["ancestor"].object)];
            interface_.ancestors = jsAncestors.map!(js => toAncestor(js)).array;
        }

        if (("routine" in jsInterface) !is null)
        {
            JSONValue[] jsRoutines = (jsInterface["routine"].type == JSONType.array) ? jsInterface["routine"].array : [ JSONValue(jsInterface["routine"].object)];
            interface_.routines = jsRoutines.map!(js => toRoutine(js)).array;
        }

        if (("property" in jsInterface) !is null)
        {
            JSONValue[] jsProperties = (jsInterface["property"].type == JSONType.array) ? jsInterface["property"].array : [ JSONValue(jsInterface["property"].object)];
            interface_.properties = jsProperties.map!(js => toProperty(js)).array;
        }

        if (("type" in jsInterface) !is null)
        {
            JSONValue[] jsTypes = (jsInterface["type"].type == JSONType.array) ? jsInterface["type"].array : [ JSONValue(jsInterface["type"].object)];
            interface_.types = jsTypes.map!(js => toType(js)).array;
        }

        // Deep structures
        // Variables

        return interface_;
    }

    Record[] getRecords(SearchScope searchScope, bool allowedOnly = true)
    {
        return getSymbolsJSON(searchScope, SymbolCategory.structure, allowedOnly)
            .filter!(js => js["_type"].str == "record").map!(js => toRecord(js)).array;
    }

    private Record toRecord(JSONValue jsRecord)
    {
        Record record = {
            name : jsRecord["_name"].str.decodeXmlString,
            nameWithGeneric : jsRecord["_name_with_generic"].str.decodeXmlString,
        };

        if (("variable" in jsRecord) !is null)
        {
            JSONValue[] jsVariables = (jsRecord["variable"].type == JSONType.array) ? jsRecord["variable"].array : [ JSONValue(jsRecord["variable"].object)];
            record.variables = jsVariables.map!(js => toVariable(js)).array;
        }

        // What else ?

        return record;
    }

    Property toProperty(JSONValue jsProperty)
    {
        Property property = {
            defaultInClass : jsProperty["_default_in_class"].str == "True",
            defaultValue : jsProperty["_default_value"].str.decodeXmlString,
            indexDecl: jsProperty["_indexdecl"].str.decodeXmlString,
            name : jsProperty["_name"].str.decodeXmlString,
            noDefault : jsProperty["_nodefault"].str == "True",
            reader : jsProperty["_reader"].str.decodeXmlString,
            stored : jsProperty["_stored"].str.decodeXmlString,
            type : jsProperty["_type"].str.decodeXmlString,
            writer : jsProperty["_writer"].str.decodeXmlString,
            visibility : jsProperty["_visibility"].str
        };
        
        return property;
    }

    static SymbolCache getSymbolCache(string unit)
    {
        return new SymbolCache(unit);
    }

    static string[] getUnits()
    {
        return _unitsCache.keys;
    }

    static setUnitsCache(UnitCache[string] unitsCache)
    {
        _unitsCache = unitsCache;
    }

    static loadSymbols(string specFolder)
    {
        _unitsCache = null;
        JSONValue jsConfig = parseJSON(readText(buildPath(specFolder, "config.json")));
        string[] specUnitNames = jsConfig["units"].object.keys;

        foreach(unitName; specUnitNames)
        {
            if (("skip" in jsConfig["units"].object[unitName].object) !is null && jsConfig["units"].object[unitName].object["skip"].type == JSONType.true_)
            {
                writeln("Skip unit ", unitName);
                continue;
            }
            
            string jsFilePath = buildPath(specFolder, unitName ~ ".json");
            string xmlFilePath = buildPath(specFolder, unitName ~ ".xml");
            JSONValue jsUnitSpec;
            if(exists(jsFilePath))
            {
                jsUnitSpec = parseJSON(readText(jsFilePath));
            }
            else if(exists(xmlFilePath))
            {
                jsUnitSpec = xmlFileToJSON(xmlFilePath);
            }
            else
            {
                writeln("Skip unit ", unitName, ". File not exist.");
                continue;
            }

            UnitCache unitCache = UnitCache();
            if (("uses" in jsUnitSpec["unit"].object) !is null)
            {
                JSONValue[] jsUses = (jsUnitSpec["unit"].object["uses"].type == JSONType.array) ? 
                    jsUnitSpec["unit"].object["uses"].array : [ JSONValue(jsUnitSpec["unit"].object["uses"].object) ];

                unitCache.uses = jsUses.array.map!(js => js["_name"].str).array;
            }
            unitCache.uses ~= "System";

            if (("constant" in jsUnitSpec["unit"].object) !is null)
            {
                JSONValue[] jsConstants = (jsUnitSpec["unit"].object["constant"].type == JSONType.array) ? 
                    jsUnitSpec["unit"].object["constant"].array : [ JSONValue(jsUnitSpec["unit"].object["constant"].object) ];
                
                string[] allowedConstants = (("constants" in jsConfig["units"].object[unitName].object) !is null) ? 
                    jsConfig["units"].object[unitName].object["constants"].array.map!(js => js.str.toLower).array : []; 

                foreach(jsConstant; jsConstants.array)
                {
                    string constantLowerName = jsConstant["_name"].str.toLower;
                    Symbol symbol = { isConstant: true, category : SymbolCategory.constant, unit : unitName, jsSymbol : jsConstant, isAllowed : allowedConstants.canFind(constantLowerName) };
                    unitCache.symbols[constantLowerName] = symbol;
                }
            }

            if (("routine" in jsUnitSpec["unit"].object) !is null)
            {
                JSONValue[] jsRoutines = (jsUnitSpec["unit"].object["routine"].type == JSONType.array) ? 
                    jsUnitSpec["unit"].object["routine"].array : [ JSONValue(jsUnitSpec["unit"].object["routine"].object) ];
                
                string[] allowedRoutines = (("routines" in jsConfig["units"].object[unitName].object) !is null) ? 
                    jsConfig["units"].object[unitName].object["routines"].array.map!(js => js.str.toLower).array : []; 

                foreach(jsRoutine; jsRoutines.array)
                {
                    string routineLowerName = jsRoutine["_name"].str.toLower;
                    Symbol symbol = { isRoutine: true, category : SymbolCategory.routine, unit : unitName, jsSymbol : jsRoutine, isAllowed : allowedRoutines.canFind(routineLowerName) };
                    unitCache.symbols[routineLowerName] = symbol;
                }
            }

            if (("structure" in jsUnitSpec["unit"].object) !is null)
            {
                JSONValue[] jsStructures = (jsUnitSpec["unit"].object["structure"].type == JSONType.array) ? 
                    jsUnitSpec["unit"].object["structure"].array : [ JSONValue(jsUnitSpec["unit"].object["structure"].object) ];
                
                string[] allowedStructures = (("structures" in jsConfig["units"].object[unitName].object) !is null) ? 
                    jsConfig["units"].object[unitName].object["structures"].array.map!(js => js.str.toLower).array : []; 

                if (("structuresMissing" in jsConfig["units"].object[unitName].object) !is null)
                {
                    allowedStructures ~= jsConfig["units"].object[unitName].object["structuresMissing"].array.map!(js => js.str.toLower).array;
                }  

                foreach(jsStructure; jsStructures.array)
                {
                    string structureLowerName = jsStructure["_name"].str.toLower;
                    Symbol symbol = { category : SymbolCategory.structure, unit : unitName, jsSymbol : jsStructure, isAllowed : allowedStructures.canFind(structureLowerName) };
                    
                    if (jsStructure["_type"].str == "class")
                        symbol.isClass = true;
                    else if (jsStructure["_type"].str == "interface")
                        symbol.isInterface = true;
                    unitCache.symbols[structureLowerName] = symbol;
                }
            }

            if (("type" in jsUnitSpec["unit"].object) !is null)
            {
                JSONValue[] jsTypes = (jsUnitSpec["unit"].object["type"].type == JSONType.array) ? 
                    jsUnitSpec["unit"].object["type"].array : [ JSONValue(jsUnitSpec["unit"].object["type"].object) ];
                
                string[] allowedTypes = (("types" in jsConfig["units"].object[unitName].object) !is null) ? 
                    jsConfig["units"].object[unitName].object["types"].array.map!(js => js.str.toLower).array : [];

                if (("typesMissing" in jsConfig["units"].object[unitName].object) !is null)
                {
                    allowedTypes ~= jsConfig["units"].object[unitName].object["typesMissing"].array.map!(js => js.str.toLower).array;
                }

                foreach(jsType; jsTypes.array)
                {
                    string typeLowerName = jsType["_name"].str.toLower;
                    Symbol symbol = { category : SymbolCategory.type, unit : unitName, jsSymbol : jsType, isAllowed : allowedTypes.canFind(typeLowerName) };
                    if (jsType["_declaration"].str.toLower.canFind("= class of "))
                        symbol.isMetaClass = true;
                    unitCache.symbols[typeLowerName] = symbol;
                }
            }

            if (("variable" in jsUnitSpec["unit"].object) !is null)
            {
                JSONValue[] jsVariables = (jsUnitSpec["unit"].object["variable"].type == JSONType.array) ? 
                    jsUnitSpec["unit"].object["variable"].array : [ JSONValue(jsUnitSpec["unit"].object["variable"].object) ];
                
                string[] allowedVariables = (("variables" in jsConfig["units"].object[unitName].object) !is null) ? 
                    jsConfig["variables"].object[unitName].object["variables"].array.map!(js => js.str.toLower).array : []; 

                foreach(jsVariable; jsVariables.array)
                {
                    string variableLowerName = jsVariable["_name"].str.toLower;
                    Symbol symbol = { category : SymbolCategory.variable, unit : unitName, jsSymbol : jsVariable, isAllowed : allowedVariables.canFind(variableLowerName) };
                    unitCache.symbols[variableLowerName] = symbol;
                }
            }

            _unitsCache[unitName] = unitCache;
        }

        foreach(kv; _unitsCache.byKeyValue)
        {
            kv.value.uses = kv.value.uses.filter!( u => _unitsCache.keys.canFind(u)).array;
        }
    }
}

class SymbolNotFoundException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

class SymbolNotAllowedException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}