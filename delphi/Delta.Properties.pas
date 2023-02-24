unit Delta.Properties;

interface

uses SysUtils, Classes, Rtti, TypInfo;

procedure setPropertyValue(Reference: Pointer; const AName: string;
  const value: TValue);

function getPropertyReference(Reference: Pointer; const AName: PAnsiChar)
  : Pointer; stdcall;

function getPropertyStruct(Reference: Pointer; const AName: PAnsiChar)
  : Pointer; stdcall;

procedure setPropertyReference(Reference: Pointer; const AName: PAnsiChar;
  value: Pointer); stdcall;

procedure setPropertyBoolean(Reference: Pointer; const AName: PAnsiChar;
  const value: Boolean); stdcall;

function getPropertyBool(Reference: Pointer; const AName: PAnsiChar)
  : Boolean; stdcall;

procedure setPropertySmallInt(Reference: Pointer; const AName: PAnsiChar;
  const value: SmallInt); stdcall;

function getPropertySmallInt(Reference: Pointer; const AName: PAnsiChar)
  : SmallInt; stdcall;

procedure setPropertyInteger(Reference: Pointer; const AName: PAnsiChar;
  const value: Integer); stdcall;

function getPropertyInteger(Reference: Pointer; const AName: PAnsiChar)
  : Integer; stdcall;

procedure setPropertyCardinal(Reference: Pointer; const AName: PAnsiChar;
  const value: Cardinal); stdcall;

function getPropertyCardinal(Reference: Pointer; const AName: PAnsiChar)
  : Cardinal; stdcall;

procedure setPropertySingle(Reference: Pointer; const AName: PAnsiChar;
  const value: Single); stdcall;

function getPropertySingle(Reference: Pointer; const AName: PAnsiChar)
  : Single; stdcall;

procedure setPropertyString(Reference: Pointer; const AName: PAnsiChar;
  const value: WideString); stdcall;

procedure getPropertyString(Reference: Pointer; const AName: PAnsiChar;
  out value: WideString); stdcall;

procedure setPropertyEnum(Reference: Pointer; const AName: PAnsiChar;
  const value: PAnsiChar); stdcall;

procedure getPropertyEnum(Reference: Pointer; const AName: PAnsiChar;
  out value: WideString); stdcall;

procedure setPropertySet(Reference: Pointer; const AName: PAnsiChar;
  const value: PAnsiChar); stdcall;

function getIntegerIndexedPropertyReference(Reference: Pointer;
  const AName: PAnsiChar; const Index: Integer): Pointer; stdcall;

exports setPropertyEnum, getPropertyEnum, setPropertySet, setPropertyReference,
  setPropertySmallInt, getPropertySmallInt, setPropertyInteger,
  setPropertyBoolean, getPropertyBool, setPropertyString, setPropertySingle, getPropertySingle,
  setPropertyCardinal, getPropertyReference, getPropertyInteger,
  getPropertyCardinal, getPropertyString, getIntegerIndexedPropertyReference,
  getPropertyStruct;

implementation

procedure setPropertyValue(Reference: Pointer; const AName: string;
  const value: TValue);
var
  context: TRttiContext;
  rttiType: TRttiType;
  prop: TRttiProperty;
  obj: TObject;
begin
  context := TRttiContext.Create;
  try
    try
      obj := TObject(Reference);
      rttiType := (context.GetType(obj.ClassType));
      prop := rttiType.GetProperty(AName);
      prop.SetValue(obj, value);
    except
      on E: Exception do
        writeln(E.ClassName + ' error raised, with message : ' + E.Message);
    end;
  finally
    context.Free;
  end;
end;

function getPropertyValue(Reference: Pointer;
  const AName: string): TValue;
var
  context: TRttiContext;
  rttiType: TRttiType;
  prop: TRttiProperty;
  obj: TObject;
begin
  context := TRttiContext.Create;
  try
    try
      obj := TObject(Reference);
      rttiType := (context.GetType(obj.ClassType));
      prop := rttiType.GetProperty(AName);
      result := prop.getValue(obj);
    except
      on E: Exception do
        writeln(E.ClassName + ' error raised, with message : ' + E.Message);
    end;
  finally
    context.Free;
  end;
end;

function getIndexedPropertyValue(Reference: Pointer; const AName: string;
  const Index: Integer): TValue;
var
  context: TRttiContext;
  rttiType: TRttiType;
  prop: TRttiIndexedProperty;
  obj: TObject;
begin
  context := TRttiContext.Create;
  try
    try
      obj := TObject(Reference);
      rttiType := (context.GetType(obj.ClassType));
      prop := rttiType.GetIndexedProperty(AName);
      result := prop.getValue(obj, [Index])
    except
      on E: Exception do
        writeln(E.ClassName + ' error raised, with message : ' + E.Message);
    end;
  finally
    context.Free;
  end;
end;

procedure setPropertySmallInt(Reference: Pointer; const AName: PAnsiChar;
  const value: SmallInt); stdcall;
begin
  setPropertyValue(Reference, string(AName), value);
end;

function getPropertySmallInt(Reference: Pointer; const AName: PAnsiChar)
  : SmallInt; stdcall;
begin
  result := getPropertyValue(Reference, string(AName)).AsType<SmallInt>;
end;

procedure setPropertyInteger(Reference: Pointer; const AName: PAnsiChar;
  const value: Integer); stdcall;
begin
  setPropertyValue(Reference, string(AName), value);
end;

function getPropertyInteger(Reference: Pointer; const AName: PAnsiChar)
  : Integer; stdcall;
begin
  result := getPropertyValue(Reference, string(AName)).AsInteger;
end;

procedure setPropertyBoolean(Reference: Pointer; const AName: PAnsiChar;
  const value: Boolean); stdcall;
begin
  setPropertyValue(Reference, string(AName), value);
end;

function getPropertyBool(Reference: Pointer; const AName: PAnsiChar)
  : Boolean; stdcall;
begin
  result := getPropertyValue(Reference, string(AName)).AsBoolean;
end;

procedure setPropertySingle(Reference: Pointer; const AName: PAnsiChar;
  const value: Single); stdcall;
begin
  setPropertyValue(Reference, string(AName), value);
end;

function getPropertySingle(Reference: Pointer; const AName: PAnsiChar)
  : Single; stdcall;
begin
  result := getPropertyValue(Reference, string(AName)).AsType<Single>;
end;

procedure setPropertyCardinal(Reference: Pointer; const AName: PAnsiChar;
  const value: Cardinal); stdcall;
begin
  setPropertyValue(Reference, string(AName), value);
end;

function getPropertyCardinal(Reference: Pointer; const AName: PAnsiChar)
  : Cardinal; stdcall;
begin
  result := getPropertyValue(Reference, string(AName)).AsType<Cardinal>;
end;

procedure setPropertyString(Reference: Pointer; const AName: PAnsiChar;
  const value: WideString); stdcall;
begin
  setPropertyValue(Reference, string(AName), string(value));
end;

procedure getPropertyString(Reference: Pointer; const AName: PAnsiChar;
  out value: WideString); stdcall;
var
  s: String;
begin
  s := getPropertyValue(Reference, string(AName)).AsString;
  value := s;
end;

procedure setPropertyEnum(Reference: Pointer; const AName: PAnsiChar;
  const value: PAnsiChar); stdcall;
var
  context: TRttiContext;
  rttiType: TRttiType;
  prop: TRttiProperty;
  obj: TObject;
  v: TValue;
  I: Integer;
begin
  context := TRttiContext.Create;
  try
    obj := TObject(Reference);
    rttiType := (context.GetType(obj.ClassType));
    prop := rttiType.GetProperty(string(AName));
    I := GetEnumValue(prop.PropertyType.Handle, string(value));
    TValue.Make(I, prop.PropertyType.Handle, v);
    prop.SetValue(obj, v);
  finally
    context.Free;
  end;
end;

procedure getPropertyEnum(Reference: Pointer; const AName: PAnsiChar;
  out value: WideString); stdcall;
var
  s: String;
begin
  s := getPropertyValue(Reference, string(AName)).ToString;
  value := s;
end;

procedure setPropertySet(Reference: Pointer; const AName: PAnsiChar;
  const value: PAnsiChar); stdcall;
var
  context: TRttiContext;
  rttiType: TRttiType;
  prop: TRttiProperty;
  obj: TObject;
  v: TValue;
  I: Integer;
begin
  context := TRttiContext.Create;
  try
    obj := TObject(Reference);
    rttiType := (context.GetType(obj.ClassType));
    prop := rttiType.GetProperty(string(AName));
    I := StringToSet(prop.PropertyType.Handle, string(value));
    TValue.Make(I, prop.PropertyType.Handle, v);
    prop.SetValue(obj, v);
  finally
    context.Free;
  end;
end;

procedure setPropertyReference(Reference: Pointer; const AName: PAnsiChar;
  value: Pointer); stdcall;
var
  obj: TObject;
begin
  if value = nil then
    obj := nil
  else
    obj := TObject(value);
  setPropertyValue(Reference, string(AName), obj);
end;

function getPropertyReference(Reference: Pointer; const AName: PAnsiChar)
  : Pointer; stdcall;
begin
  result := getPropertyValue(Reference, string(AName)).AsObject;
end;

function getIntegerIndexedPropertyReference(Reference: Pointer;
  const AName: PAnsiChar; const Index: Integer): Pointer; stdcall;
begin
  result := getIndexedPropertyValue(Reference, string(AName), Index)
    .AsObject;
end;

function getPropertyStruct(Reference: Pointer; const AName: PAnsiChar)
  : Pointer; stdcall;
var
  value: TValue;
begin
  value := getPropertyValue(Reference, string(AName));
  result := value.GetReferenceToRawData();
end;

end.
