module delta.gen.utils;

import std;
import dxml.dom;

JSONValue xmlFileToJSON(string xmlFilePath)
{
    auto dom = parseDOM(readText(xmlFilePath));

    JSONValue getJsonValue(DOMEntity!string c)
    {       
        JSONValue jsResult = JSONValue(string[string].init);

        foreach(attr; c.attributes)
        {
            jsResult["_" ~ attr.name] = attr.value;
        }

        foreach(child; c.children)
        {
            if (child.type == EntityType.elementStart && child.name != "description")
            {
                if ((child.name in jsResult) is null)
                    jsResult[child.name] = getJsonValue(child);
                else if (jsResult[child.name].type == JSONType.object)
                    jsResult[child.name] = JSONValue([jsResult[child.name], getJsonValue(child)]);
                else if (jsResult[child.name].type == JSONType.array)
                    jsResult[child.name] = JSONValue(jsResult[child.name].array ~ getJsonValue(child));
            }
            else if (child.type == EntityType.elementEmpty)
            {
                JSONValue o;
                foreach(attr; child.attributes)
                {
                    o["_" ~ attr.name] = attr.value;
                }
                
                if ((child.name in jsResult) is null)
                    jsResult[child.name] = JSONValue([o]);
                else if (jsResult[child.name].type == JSONType.object)
                    jsResult[child.name] = JSONValue([jsResult[child.name], o]);
                else if (jsResult[child.name].type == JSONType.array)
                    jsResult[child.name] = JSONValue(jsResult[child.name].array ~ o);
            }
            else if (child.type == EntityType.text)
            {
                jsResult["__text"] = child.text;
            }
            
        }
        return jsResult;
    }

    return getJsonValue(dom);
}