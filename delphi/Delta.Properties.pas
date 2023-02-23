unit Delta.Properties;

interface

uses SysUtils, Classes, Rtti, TypInfo;

procedure setPropertyValue(const Reference: NativeInt; const AName: string;
  const value: TValue);

function getPropertyReference(const Reference: NativeInt; const AName: PAnsiChar)
  : NativeInt; stdcall;

function getPropertyStruct(const Reference: NativeInt; const AName: PAnsiChar)
  : NativeInt; stdcall;

procedure setPropertyReference(const Reference: NativeInt; const AName: PAnsiChar;
  const value: NativeInt); stdcall;

procedure setPropertyBoolean(const Reference: NativeInt; const AName: PAnsiChar;
  const value: Boolean); stdcall;

function getPropertyBool(const Reference: NativeInt; const AName: PAnsiChar)
  : Boolean; stdcall;

procedure setPropertySmallInt(const Reference: NativeInt; const AName: PAnsiChar;
  const value: SmallInt); stdcall;

function getPropertySmallInt(const Reference: NativeInt; const AName: PAnsiChar)
  : SmallInt; stdcall;

procedure setPropertyInteger(const Reference: NativeInt; const AName: PAnsiChar;
  const value: Integer); stdcall;

function getPropertyInteger(const Reference: NativeInt; const AName: PAnsiChar)
  : Integer; stdcall;

procedure setPropertyCardinal(const Reference: NativeInt; const AName: PAnsiChar;
  const value: Cardinal); stdcall;

function getPropertyCardinal(const Reference: NativeInt; const AName: PAnsiChar)
  : Cardinal; stdcall;

procedure setPropertySingle(const Reference: NativeInt; const AName: PAnsiChar;
  const value: Single); stdcall;

function getPropertySingle(const Reference: NativeInt; const AName: PAnsiChar)
  : Single; stdcall;

procedure setPropertyString(const Reference: NativeInt; const AName: PAnsiChar;
  const value: WideString); stdcall;

procedure getPropertyString(const Reference: NativeInt; const AName: PAnsiChar;
  out value: WideString); stdcall;

procedure setPropertyEnum(const Reference: NativeInt; const AName: PAnsiChar;
  const value: PAnsiChar); stdcall;

procedure getPropertyEnum(const Reference: NativeInt; const AName: PAnsiChar;
  out value: WideString); stdcall;

procedure setPropertySet(const Reference: NativeInt; const AName: PAnsiChar;
  const value: PAnsiChar); stdcall;

function getIntegerIndexedPropertyReference(const Reference: NativeInt;
  const AName: PAnsiChar; const Index: Integer): NativeInt; stdcall;

exports setPropertyEnum, getPropertyEnum, setPropertySet, setPropertyReference,
  setPropertySmallInt, getPropertySmallInt, setPropertyInteger,
  setPropertyBoolean, getPropertyBool, setPropertyString, setPropertySingle, getPropertySingle,
  setPropertyCardinal, getPropertyReference, getPropertyInteger,
  getPropertyCardinal, getPropertyString, getIntegerIndexedPropertyReference,
  getPropertyStruct;

implementation

procedure setPropertyValue(const Reference: NativeInt; const AName: string;
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

function getPropertyValue(const Reference: NativeInt;
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

function getIndexedPropertyValue(const Reference: NativeInt; const AName: string;
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

procedure setPropertySmallInt(const Reference: NativeInt; const AName: PAnsiChar;
  const value: SmallInt); stdcall;
begin
  setPropertyValue(Reference, string(AName), value);
end;

function getPropertySmallInt(const Reference: NativeInt; const AName: PAnsiChar)
  : SmallInt; stdcall;
begin
  result := getPropertyValue(Reference, string(AName)).AsType<SmallInt>;
end;

procedure setPropertyInteger(const Reference: NativeInt; const AName: PAnsiChar;
  const value: Integer); stdcall;
begin
  setPropertyValue(Reference, string(AName), value);
end;

function getPropertyInteger(const Reference: NativeInt; const AName: PAnsiChar)
  : Integer; stdcall;
begin
  result := getPropertyValue(Reference, string(AName)).AsInteger;
end;

procedure setPropertyBoolean(const Reference: NativeInt; const AName: PAnsiChar;
  const value: Boolean); stdcall;
begin
  setPropertyValue(Reference, string(AName), value);
end;

function getPropertyBool(const Reference: NativeInt; const AName: PAnsiChar)
  : Boolean; stdcall;
begin
  result := getPropertyValue(Reference, string(AName)).AsBoolean;
end;

procedure setPropertySingle(const Reference: NativeInt; const AName: PAnsiChar;
  const value: Single); stdcall;
begin
  setPropertyValue(Reference, string(AName), value);
end;

function getPropertySingle(const Reference: NativeInt; const AName: PAnsiChar)
  : Single; stdcall;
begin
  result := getPropertyValue(Reference, string(AName)).AsType<Single>;
end;

procedure setPropertyCardinal(const Reference: NativeInt; const AName: PAnsiChar;
  const value: Cardinal); stdcall;
begin
  setPropertyValue(Reference, string(AName), value);
end;

function getPropertyCardinal(const Reference: NativeInt; const AName: PAnsiChar)
  : Cardinal; stdcall;
begin
  result := getPropertyValue(Reference, string(AName)).AsType<Cardinal>;
end;

procedure setPropertyString(const Reference: NativeInt; const AName: PAnsiChar;
  const value: WideString); stdcall;
begin
  setPropertyValue(Reference, string(AName), string(value));
end;

procedure getPropertyString(const Reference: NativeInt; const AName: PAnsiChar;
  out value: WideString); stdcall;
var
  s: String;
begin
  s := getPropertyValue(Reference, string(AName)).AsString;
  value := s;
end;

procedure setPropertyEnum(const Reference: NativeInt; const AName: PAnsiChar;
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

procedure getPropertyEnum(const Reference: NativeInt; const AName: PAnsiChar;
  out value: WideString); stdcall;
var
  s: String;
begin
  s := getPropertyValue(Reference, string(AName)).ToString;
  value := s;
end;

procedure setPropertySet(const Reference: NativeInt; const AName: PAnsiChar;
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

procedure setPropertyReference(const Reference: NativeInt; const AName: PAnsiChar;
  const value: NativeInt); stdcall;
var
  obj: TObject;
begin
  if value = -1 then
    obj := nil
  else
    obj := TObject(value);
  setPropertyValue(Reference, string(AName), obj);
end;

function getPropertyReference(const Reference: NativeInt; const AName: PAnsiChar)
  : NativeInt; stdcall;
begin
  result := NativeInt(getPropertyValue(Reference, string(AName)).AsObject);
end;

function getIntegerIndexedPropertyReference(const Reference: NativeInt;
  const AName: PAnsiChar; const Index: Integer): NativeInt; stdcall;
begin
  result := NativeInt(getIndexedPropertyValue(Reference, string(AName), Index)
    .AsObject);
end;

function getPropertyStruct(const Reference: NativeInt; const AName: PAnsiChar)
  : NativeInt; stdcall;
var
  value: TValue;
begin
  value := getPropertyValue(Reference, string(AName));
  result := NativeInt(value.GetReferenceToRawData());
end;

end.
