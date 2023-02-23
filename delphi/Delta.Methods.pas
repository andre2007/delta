unit Delta.Methods;

interface

uses SysUtils, Classes, Rtti, TypInfo;

function executeClassMethod(const AQualifiedName, AName: string;
  const Args: array of TValue): TValue;

function executeClassMethodReturnIntArgsNone(const AQualifiedName,
  AName: PAnsiChar): Integer; stdcall;

function executeClassMethodReturnRefArgsNone(const AQualifiedName,
  AName: PAnsiChar): NativeInt; stdcall;

function executeClassMethodReturnRefArgsString(const AQualifiedName, AName,
  AValue: PAnsiChar): NativeInt; stdcall;

procedure executeClassMethodReturnNoneArgsString(const AQualifiedName,
  AName: PAnsiChar; const value: WideString); stdcall;

procedure executeClassMethodReturnNoneArgsNone(const AQualifiedName,
  AName: PAnsiChar); stdcall;

procedure executeClassMethodReturnNoneArgsStringStringString_Out_String
  (const AQualifiedName, AName: PAnsiChar; const v1, v2, v3: WideString;
  out value: WideString); stdcall;

procedure executeInstanceMethodReturnEnumArgsNone(const Reference: NativeInt;
  const AName: PAnsiChar; out value: WideString); stdcall;

function executeClassMethodReturnRefArgsRef(const AQualifiedName,
  AName: PAnsiChar; const Reference: NativeInt): NativeInt; stdcall;

function executeClassMethodReturnRefArgsIntUInt(const AQualifiedName,
  AName: PAnsiChar; I1: Integer; I2: Cardinal): NativeInt; stdcall;

function executeClassMethodReturnRefArgsRefNativeInt(const AQualifiedName,
  AName: PAnsiChar; const Reference: NativeInt; I: NativeInt)
  : NativeInt; stdcall;

function executeClassMethodReturnRefArgsRefRefRefBool(const AQualifiedName,
  AName: PAnsiChar; const Ref1, Ref2, Ref3: NativeInt; B: Boolean)
  : NativeInt; stdcall;

function executeInstanceMethod(const Reference: NativeInt; const AName: string;
  const Args: array of TValue): TValue;

procedure executeInstanceMethodReturnNoneArgsNone(const Reference: NativeInt;
  const AName: PAnsiChar); stdcall;

procedure executeInstanceMethodReturnNoneArgsRef(const Reference: NativeInt;
  const AName: PAnsiChar; Reference2: NativeInt); stdcall;

procedure executeInstanceMethodReturnNoneArgsRefString(const Reference: NativeInt;
  const AName: PAnsiChar; Reference2: NativeInt; const AValue: PAnsiChar); stdcall;

procedure executeInstanceMethodReturnNoneArgsRefBool(const Reference: NativeInt;
  const AName: PAnsiChar; Reference2: NativeInt; b : boolean); stdcall;

procedure executeInstanceMethodReturnNoneArgsRefInt(const Reference: NativeInt;
  const AName: PAnsiChar; Reference2: NativeInt; i : Integer); stdcall;

procedure executeInstanceMethodReturnNoneArgsIntRef(const Reference: NativeInt;
  const AName: PAnsiChar; i : Integer; Reference2: NativeInt ); stdcall;

procedure executeInstanceMethodReturnNoneArgsStructFloat(const Reference
  : NativeInt; const AName: PAnsiChar; Reference2: NativeInt;
  s: Single); stdcall;

procedure executeInstanceMethodReturnNoneArgsStructStructFloat(const Reference
  : NativeInt; const AName: PAnsiChar; Reference2, Reference3: NativeInt;
  s: Single); stdcall;

procedure executeInstanceMethodReturnNoneArgsStructStructFloatRef
  (const Reference: NativeInt; const AName: PAnsiChar;
  Reference2, Reference3: NativeInt; s: Single; Reference4: NativeInt); stdcall;

procedure executeInstanceMethodReturnNoneArgsRefFloat(const Reference
  : NativeInt; const AName: PAnsiChar; Reference2: NativeInt;
  s: Single); stdcall;

procedure executeInstanceMethodReturnNoneArgsRefStructStructFloatBoolean
  (const Reference: NativeInt; const AName: PAnsiChar;
  Reference2, Reference3, Reference4: NativeInt; s: Single;
  B: Boolean); stdcall;

procedure executeInstanceMethodReturnNoneArgsFloatFloatFloatFloatFloat
  (const Reference: NativeInt; const AName: PAnsiChar;
  s1, s2, s3, s4, s5: Single); stdcall;

procedure executeInstanceMethodReturnNoneArgsString(const Reference: NativeInt;
  const AName, AValue: PAnsiChar); stdcall;

procedure executeInstanceMethodReturnNoneArgsBool(const Reference: NativeInt;
  const AName : PAnsiChar; AValue: Boolean); stdcall;

procedure executeInstanceMethodReturnNoneArgsBoolBool(const Reference: NativeInt;
  const AName : PAnsiChar; b1, b2: Boolean); stdcall;

procedure executeInstanceMethodReturnNoneArgsInt(const Reference: NativeInt;
  const AName : PAnsiChar; AValue: Integer); stdcall;

procedure executeInstanceMethodReturnNoneArgsFloat(const Reference: NativeInt;
  const AName : PAnsiChar; AValue: Single); stdcall;

procedure executeInstanceMethodReturnNoneArgsFloatFloatBool(const Reference: NativeInt;
  const AName : PAnsiChar; F1, F2: Single; B: Boolean); stdcall;

function executeInstanceMethodReturnIntArgsNone(const Reference: NativeInt;
  const AName: PAnsiChar): Integer; stdcall;

function executeInstanceMethodReturnFloatArgsNone(const Reference: NativeInt;
  const AName: PAnsiChar): Single; stdcall;

function executeInstanceMethodReturnBoolArgsNone(const Reference: NativeInt;
  const AName: PAnsiChar): Boolean; stdcall;

function executeInstanceMethodReturnBoolArgsBool(const Reference: NativeInt;
  const AName: PAnsiChar; b: Boolean): Boolean; stdcall;

function executeInstanceMethodReturnBoolArgsInt(const Reference: NativeInt;
  const AName: PAnsiChar; i: Integer): Boolean; stdcall;

function executeInstanceMethodReturnBoolArgsFloatFloat(const Reference: NativeInt;
  const AName: PAnsiChar; s1, s2: Single): Boolean; stdcall;

function executeInstanceMethodReturnBoolArgsRef(const Reference: NativeInt;
  const AName: PAnsiChar; Reference2: NativeInt): Boolean; stdcall;

function executeInstanceMethodReturnRefArgsNone(const Reference: NativeInt;
  const AName: PAnsiChar): NativeInt; stdcall;

function executeInstanceMethodReturnRefArgsString(const Reference: NativeInt;
  const AName, AValue: PAnsiChar): NativeInt; stdcall;

function executeInstanceMethodReturnRefArgsInt(const Reference: NativeInt;
  const AName: PAnsiChar; const R: Integer): NativeInt; stdcall;

function executeInstanceMethodReturnRefArgsStringBool(const Reference: NativeInt;
  const AName, S: PAnsiChar; B: Boolean): NativeInt; stdcall;

function executeInstanceMethodReturnIntArgsString(const Reference: NativeInt;
  const AName, AValue: PAnsiChar): Integer; stdcall;

function executeInstanceMethodReturnIntArgsStringRef(const Reference: NativeInt;
  const AName, AValue: PAnsiChar; const R: NativeInt): Integer; stdcall;

procedure executeInstanceMethodReturnStringArgsNone_Out_String(const Reference
  : NativeInt; const AName: PAnsiChar; out value: WideString); stdcall;

procedure executeInstanceMethodReturnStringArgsInt_Out_String(const Reference
  : NativeInt; const AName: PAnsiChar; I : Integer; out value: WideString); stdcall;

procedure executeInstanceMethodReturnStringArgsIntInt_Out_String(const Reference
  : NativeInt; const AName: PAnsiChar; I1, I2 : Integer; out value: WideString); stdcall;

exports executeInstanceMethodReturnNoneArgsNone,
  executeInstanceMethodReturnRefArgsNone,
  executeClassMethodReturnRefArgsString,
  executeInstanceMethodReturnIntArgsNone,
  executeInstanceMethodReturnFloatArgsNone,
  executeInstanceMethodReturnBoolArgsNone,
  executeInstanceMethodReturnBoolArgsBool,
  executeInstanceMethodReturnBoolArgsInt,
  executeInstanceMethodReturnBoolArgsFloatFloat,
  executeInstanceMethodReturnBoolArgsRef,
  executeInstanceMethodReturnIntArgsString,
  executeInstanceMethodReturnIntArgsStringRef,
  executeClassMethodReturnRefArgsNone,
  executeClassMethodReturnNoneArgsStringStringString_Out_String,
  executeInstanceMethodReturnRefArgsString,
  executeClassMethodReturnRefArgsRef,
  executeInstanceMethodReturnNoneArgsStructFloat,
  executeInstanceMethodReturnNoneArgsRefFloat,
  executeInstanceMethodReturnNoneArgsStructStructFloat,
  executeInstanceMethodReturnNoneArgsStructStructFloatRef,
  executeInstanceMethodReturnNoneArgsFloatFloatFloatFloatFloat,
  executeInstanceMethodReturnNoneArgsString,
  executeInstanceMethodReturnNoneArgsBool,
  executeInstanceMethodReturnNoneArgsBoolBool,
  executeInstanceMethodReturnNoneArgsInt,
  executeInstanceMethodReturnNoneArgsIntRef,
  executeInstanceMethodReturnNoneArgsFloat,
  executeInstanceMethodReturnNoneArgsRefStructStructFloatBoolean,
  executeClassMethodReturnRefArgsRefNativeInt,
  executeClassMethodReturnRefArgsRefRefRefBool,
  executeClassMethodReturnRefArgsIntUInt,
  executeInstanceMethodReturnNoneArgsRef,
  executeInstanceMethodReturnNoneArgsRefString,
  executeInstanceMethodReturnNoneArgsRefBool,
  executeInstanceMethodReturnNoneArgsRefInt,
  executeClassMethodReturnNoneArgsString,
  executeClassMethodReturnNoneArgsNone,
  executeInstanceMethodReturnEnumArgsNone,
  executeInstanceMethodReturnRefArgsInt,
  executeInstanceMethodReturnRefArgsStringBool,
  executeInstanceMethodReturnStringArgsNone_Out_String,
  executeInstanceMethodReturnStringArgsInt_Out_String,
  executeInstanceMethodReturnStringArgsIntInt_Out_String;

implementation

function executeClassMethod(const AQualifiedName, AName: string;
  const Args: array of TValue): TValue;
var
  context: TRttiContext;
  method: TRttiMethod;
  instType: TRttiInstanceType;
begin
  context := TRttiContext.Create;
  try
    try
      instType := (context.FindType(AQualifiedName) as TRttiInstanceType);
      if instType = nil then
      begin
        writeln('Class ' + AQualifiedName + ' not found');
      end
      else
      begin
        method := instType.GetMethod(AName);
        if method = nil then
          writeln('Class ' + instType.Name + ' does not have method ' + AName)
        else
          result := method.Invoke(instType.MetaclassType, Args);
      end;
    except
      on E: Exception do
        writeln(E.ClassName + ' error raised, with message : ' + E.Message);
    end;

  finally
    context.Free;
  end;
end;

function executeClassMethodReturnIntArgsNone(const AQualifiedName,
  AName: PAnsiChar): Integer; stdcall;
var
  value: TValue;
begin
  value := executeClassMethod(string(AQualifiedName), string(AName), []);
  result := value.AsInteger;
end;

function executeClassMethodReturnRefArgsString(const AQualifiedName, AName,
  AValue: PAnsiChar): NativeInt; stdcall;
var
  value: TValue;
begin
  value := executeClassMethod(string(AQualifiedName), string(AName),
    [string(AValue)]);
  result := NativeInt(value.AsObject);
end;

procedure executeClassMethodReturnNoneArgsString(const AQualifiedName,
  AName: PAnsiChar; const value: WideString); stdcall;
begin
  executeClassMethod(string(AQualifiedName), string(AName), [string(value)]);
end;

procedure executeClassMethodReturnNoneArgsNone(const AQualifiedName,
  AName: PAnsiChar); stdcall;
begin
  executeClassMethod(string(AQualifiedName), string(AName), []);
end;

function executeClassMethodReturnRefArgsNone(const AQualifiedName,
  AName: PAnsiChar): NativeInt; stdcall;
var
  value: TValue;
begin
  value := executeClassMethod(string(AQualifiedName), string(AName), []);
  result := NativeInt(value.AsObject);
end;

function executeClassMethodReturnRefArgsRef(const AQualifiedName,
  AName: PAnsiChar; const Reference: NativeInt): NativeInt; stdcall;
var
  value: TValue;
  obj: TObject;
begin
  if Reference = -1 then
    obj := nil
  else
    obj := TObject(Reference);

  value := executeClassMethod(string(AQualifiedName), string(AName), [obj]);
  result := NativeInt(value.AsObject);
end;

function executeClassMethodReturnRefArgsRefNativeInt(const AQualifiedName,
  AName: PAnsiChar; const Reference: NativeInt; I: NativeInt)
  : NativeInt; stdcall;
var
  value: TValue;
  obj: TObject;
begin
  if Reference = -1 then
    obj := nil
  else
    obj := TObject(Reference);

  value := executeClassMethod(string(AQualifiedName), string(AName), [obj, I]);
  result := NativeInt(value.AsObject);
end;

function executeClassMethodReturnRefArgsRefRefRefBool(const AQualifiedName,
  AName: PAnsiChar; const Ref1, Ref2, Ref3: NativeInt; B: Boolean)
  : NativeInt; stdcall;
var
  value: TValue;
  obj1, obj2, obj3: TObject;
begin
  if Ref1 = -1 then
    obj1 := nil
  else
    obj1 := TObject(Ref1);

  if Ref2 = -1 then
    obj2 := nil
  else
    obj2 := TObject(Ref2);

  if Ref3 = -1 then
    obj3 := nil
  else
    obj3 := TObject(Ref3);

  value := executeClassMethod(string(AQualifiedName), string(AName),
    [obj1, obj2, obj3, B]);
  result := NativeInt(value.AsObject);
end;

function executeClassMethodReturnRefArgsIntUInt(const AQualifiedName,
  AName: PAnsiChar; I1: Integer; I2: Cardinal): NativeInt; stdcall;
var
  value: TValue;
begin
  value := executeClassMethod(string(AQualifiedName), string(AName), [I1, I2]);
  result := NativeInt(value.AsObject);
end;

function executeInstanceMethod(const Reference: NativeInt; const AName: string;
  const Args: array of TValue): TValue;
var
  context: TRttiContext;
  instType: TRttiInstanceType;
  obj: TObject;
  meth: TRttiMethod;
begin
  context := TRttiContext.Create;
  try
    try
      obj := TObject(Reference);
      instType := (context.GetType(obj.ClassType) as TRttiInstanceType);
      meth := instType.GetMethod(AName);
      if meth = nil then
        writeln('Class ' + instType.Name + ' does not have method ' + AName)
      else
        result := instType.GetMethod(AName).Invoke(obj, Args);
    except
      on E: Exception do
        writeln(E.ClassName + ' error raised, with message : ' + E.Message);
    end;
  finally
    context.Free;
  end;
end;

procedure executeInstanceMethodReturnNoneArgsNone(const Reference: NativeInt;
  const AName: PAnsiChar); stdcall;
begin
  executeInstanceMethod(Reference, string(AName), []);
end;

function executeInstanceMethodReturnIntArgsNone(const Reference: NativeInt;
  const AName: PAnsiChar): Integer; stdcall;
var
  value: TValue;
begin
  value := executeInstanceMethod(Reference, string(AName), []);
  result := Integer(value.AsInteger);
end;

function executeInstanceMethodReturnFloatArgsNone(const Reference: NativeInt;
  const AName: PAnsiChar): Single; stdcall;
var
  value: TValue;
begin
  value := executeInstanceMethod(Reference, string(AName), []);
  result := value.AsType<Single>;
end;

function executeInstanceMethodReturnBoolArgsNone(const Reference: NativeInt;
  const AName: PAnsiChar): Boolean; stdcall;
var
  value: TValue;
begin
  value := executeInstanceMethod(Reference, string(AName), []);
  result := Boolean(value.AsBoolean);
end;

function executeInstanceMethodReturnBoolArgsBool(const Reference: NativeInt;
  const AName: PAnsiChar; b: Boolean): Boolean; stdcall;
var
  value: TValue;
begin
  value := executeInstanceMethod(Reference, string(AName), [b]);
  result := Boolean(value.AsBoolean);
end;

function executeInstanceMethodReturnBoolArgsInt(const Reference: NativeInt;
  const AName: PAnsiChar; i: Integer): Boolean; stdcall;
var
  value: TValue;
begin
  value := executeInstanceMethod(Reference, string(AName), [i]);
  result := Boolean(value.AsBoolean);
end;

function executeInstanceMethodReturnBoolArgsFloatFloat(const Reference: NativeInt;
  const AName: PAnsiChar; s1, s2: Single): Boolean; stdcall;
var
  value: TValue;
begin
  value := executeInstanceMethod(Reference, string(AName), [s1, s2]);
  result := Boolean(value.AsBoolean);
end;

function executeInstanceMethodReturnBoolArgsRef(const Reference: NativeInt;
  const AName: PAnsiChar; Reference2: NativeInt): Boolean; stdcall;
var
  value: TValue;
  obj: TObject;
begin
  if Reference2 = -1 then
    obj := nil
  else
    obj := TObject(Reference2);
  value := executeInstanceMethod(Reference, string(AName), [obj]);
  result := Boolean(value.AsBoolean);
end;

function executeInstanceMethodReturnRefArgsNone(const Reference: NativeInt;
  const AName: PAnsiChar): NativeInt; stdcall;
var
  value: TValue;
begin
  value := executeInstanceMethod(Reference, string(AName), []);
  result := NativeInt(value.AsObject);
end;

procedure executeInstanceMethodReturnNoneArgsRef(const Reference: NativeInt;
  const AName: PAnsiChar; Reference2: NativeInt); stdcall;
var
  obj: TObject;
begin
  if Reference2 = -1 then
    obj := nil
  else
    obj := TObject(Reference2);
  executeInstanceMethod(Reference, string(AName), [obj]);
end;

procedure executeInstanceMethodReturnNoneArgsRefString(const Reference: NativeInt;
  const AName: PAnsiChar; Reference2: NativeInt; const AValue: PAnsiChar); stdcall;
var
  obj: TObject;
begin
  if Reference2 = -1 then
    obj := nil
  else
    obj := TObject(Reference2);
  executeInstanceMethod(Reference, string(AName), [obj, string(AValue)]);
end;

procedure executeInstanceMethodReturnNoneArgsRefBool(const Reference: NativeInt;
  const AName: PAnsiChar; Reference2: NativeInt; b : boolean); stdcall;
var
  obj: TObject;
begin
  if Reference2 = -1 then
    obj := nil
  else
    obj := TObject(Reference2);
  executeInstanceMethod(Reference, string(AName), [obj, b]);
end;

procedure executeInstanceMethodReturnNoneArgsRefInt(const Reference: NativeInt;
  const AName: PAnsiChar; Reference2: NativeInt; I : Integer); stdcall;
var
  obj: TObject;
begin
  if Reference2 = -1 then
    obj := nil
  else
    obj := TObject(Reference2);
  executeInstanceMethod(Reference, string(AName), [obj, i]);
end;

procedure executeInstanceMethodReturnNoneArgsIntRef(const Reference: NativeInt;
  const AName: PAnsiChar; I : Integer; Reference2: NativeInt); stdcall;
var
  obj: TObject;
begin
  if Reference2 = -1 then
    obj := nil
  else
    obj := TObject(Reference2);
  executeInstanceMethod(Reference, string(AName), [obj, i]);
end;

procedure executeInstanceMethodReturnNoneArgsRefFloat(const Reference
  : NativeInt; const AName: PAnsiChar; Reference2: NativeInt;
  s: Single); stdcall;
var
  obj: TObject;
begin
  if Reference2 = -1 then
    obj := nil
  else
    obj := TObject(Reference2);
  executeInstanceMethod(Reference, string(AName), [obj, s]);
end;

procedure executeInstanceMethodReturnNoneArgsStructFloat(const Reference
  : NativeInt; const AName: PAnsiChar; Reference2: NativeInt;
  s: Single); stdcall;
var
  context: TRttiContext;
  instType: TRttiInstanceType;
  params: TArray<TRttiParameter>;
  obj: TObject;
  Arg1: TValue;
begin
  context := TRttiContext.Create;
  try
    try
      obj := TObject(Reference);
      instType := (context.GetType(obj.ClassType) as TRttiInstanceType);
      params := instType.GetMethod(string(AName)).GetParameters;
      TValue.Make(Pointer(Reference2), params[0].ParamType.Handle, Arg1);
      executeInstanceMethod(Reference, string(AName), [Arg1, s]);
    except
      on E: Exception do
        writeln(E.ClassName + ' error raised, with message : ' + E.Message);
    end;
  finally
    context.Free;
  end;
end;

procedure executeInstanceMethodReturnNoneArgsStructStructFloat(const Reference
  : NativeInt; const AName: PAnsiChar; Reference2, Reference3: NativeInt;
  s: Single); stdcall;
var
  context: TRttiContext;
  instType: TRttiInstanceType;
  params: TArray<TRttiParameter>;
  obj: TObject;
  Arg1: TValue;
  Arg2: TValue;
begin
  context := TRttiContext.Create;
  try
    try
      obj := TObject(Reference);
      instType := (context.GetType(obj.ClassType) as TRttiInstanceType);
      params := instType.GetMethod(string(AName)).GetParameters;

      TValue.Make(Pointer(Reference2), params[0].ParamType.Handle, Arg1);
      TValue.Make(Pointer(Reference3), params[1].ParamType.Handle, Arg2);

      executeInstanceMethod(Reference, string(AName), [Arg1, Arg2, s]);
    except
      on E: Exception do
        writeln(E.ClassName + ' error raised, with message : ' + E.Message);
    end;
  finally
    context.Free;
  end;
end;

procedure executeInstanceMethodReturnNoneArgsStructStructFloatRef
  (const Reference: NativeInt; const AName: PAnsiChar;
  Reference2, Reference3: NativeInt; s: Single; Reference4: NativeInt); stdcall;
var
  context: TRttiContext;
  instType: TRttiInstanceType;
  params: TArray<TRttiParameter>;
  obj: TObject;
  Arg1: TValue;
  Arg2: TValue;
begin
  context := TRttiContext.Create;
  try
    try
      obj := TObject(Reference);
      instType := (context.GetType(obj.ClassType) as TRttiInstanceType);
      params := instType.GetMethod(string(AName)).GetParameters;

      TValue.Make(Pointer(Reference2), params[0].ParamType.Handle, Arg1);
      TValue.Make(Pointer(Reference3), params[1].ParamType.Handle, Arg2);

      executeInstanceMethod(Reference, string(AName),
        [Arg1, Arg2, s, TObject(Reference4)]);
    except
      on E: Exception do
        writeln(E.ClassName + ' error raised, with message : ' + E.Message);
    end;
  finally
    context.Free;
  end;
end;

procedure executeInstanceMethodReturnNoneArgsRefStructStructFloatBoolean
  (const Reference: NativeInt; const AName: PAnsiChar;
  Reference2, Reference3, Reference4: NativeInt; s: Single;
  B: Boolean); stdcall;
var
  context: TRttiContext;
  instType: TRttiInstanceType;
  params: TArray<TRttiParameter>;
  obj: TObject;
  Arg1: TValue;
  Arg2: TValue;
Begin
  context := TRttiContext.Create;
  try
    try
      obj := TObject(Reference);
      instType := (context.GetType(obj.ClassType) as TRttiInstanceType);
      params := instType.GetMethod(string(AName)).GetParameters;
      TValue.Make(Pointer(Reference3), params[1].ParamType.Handle, Arg1);
      TValue.Make(Pointer(Reference4), params[2].ParamType.Handle, Arg2);

      executeInstanceMethod(Reference, string(AName),
        [TObject(Reference2), Arg1, Arg2, s, B]);
    except
      on E: Exception do
        writeln(E.ClassName + ' error raised, with message : ' + E.Message);
    end;
  finally
    context.Free;
  end;
End;

procedure executeInstanceMethodReturnNoneArgsString(const Reference: NativeInt;
  const AName, AValue: PAnsiChar); stdcall;
begin
  executeInstanceMethod(Reference, string(AName), [string(AValue)]);
end;

procedure executeInstanceMethodReturnNoneArgsBool(const Reference: NativeInt;
  const AName : PAnsiChar; AValue: Boolean); stdcall;
begin
  executeInstanceMethod(Reference, string(AName), [AValue]);
end;

procedure executeInstanceMethodReturnNoneArgsBoolBool(const Reference: NativeInt;
  const AName : PAnsiChar; b1, b2: Boolean); stdcall;
begin
  executeInstanceMethod(Reference, string(AName), [b1, b2]);
end;

procedure executeInstanceMethodReturnNoneArgsInt(const Reference: NativeInt;
  const AName : PAnsiChar; AValue: Integer); stdcall;
begin
  executeInstanceMethod(Reference, string(AName), [AValue]);
end;

procedure executeInstanceMethodReturnNoneArgsFloat(const Reference: NativeInt;
  const AName : PAnsiChar; AValue: Single); stdcall;
begin
  executeInstanceMethod(Reference, string(AName), [AValue]);
end;

procedure executeInstanceMethodReturnNoneArgsFloatFloatBool(const Reference: NativeInt;
  const AName : PAnsiChar; F1, F2: Single; B: Boolean); stdcall;
begin
  executeInstanceMethod(Reference, string(AName), [F1, F2, B]);
end;

procedure executeInstanceMethodReturnNoneArgsFloatFloatFloatFloatFloat
  (const Reference: NativeInt; const AName: PAnsiChar;
  s1, s2, s3, s4, s5: Single); stdcall;
begin
  executeInstanceMethod(Reference, string(AName), [s1, s2, s3, s4, s5]);
end;

function executeInstanceMethodReturnRefArgsInt(const Reference: NativeInt;
  const AName: PAnsiChar; const R: Integer): NativeInt; stdcall;
var
  value: TValue;
begin
  value := executeInstanceMethod(Reference, string(AName), [R]);
  result := NativeInt(value.AsObject);
end;

function executeInstanceMethodReturnRefArgsStringBool(const Reference: NativeInt;
  const AName, S: PAnsiChar; B: Boolean): NativeInt; stdcall;
var
  value: TValue;
begin
  value := executeInstanceMethod(Reference, string(AName), [string(S), B]);
  result := NativeInt(value.AsObject);
end;

function executeInstanceMethodReturnRefArgsString(const Reference: NativeInt;
  const AName, AValue: PAnsiChar): NativeInt; stdcall;
var
  value: TValue;
begin
  value := executeInstanceMethod(Reference, string(AName), [string(AValue)]);
  result := NativeInt(value.AsObject);
end;

function executeInstanceMethodReturnIntArgsString(const Reference: NativeInt;
  const AName, AValue: PAnsiChar): Integer; stdcall;
var
  value: TValue;
begin
  value := executeInstanceMethod(Reference, string(AName), [string(AValue)]);
  result := value.AsInteger;
end;

function executeInstanceMethodReturnIntArgsStringRef(const Reference: NativeInt;
  const AName, AValue: PAnsiChar; const R: NativeInt): Integer; stdcall;
var
  value: TValue;
begin
  value := executeInstanceMethod(Reference, string(AName),
    [string(AValue), TObject(R)]);
  result := value.AsInteger;
end;

procedure executeInstanceMethodReturnStringArgsNone_Out_String(const Reference
  : NativeInt; const AName: PAnsiChar; out value: WideString); stdcall;
var
  methodResultValue: TValue;
begin
  methodResultValue := executeInstanceMethod(Reference, string(AName), []);
  value := methodResultValue.AsString;
end;

procedure executeInstanceMethodReturnStringArgsInt_Out_String(const Reference
  : NativeInt; const AName: PAnsiChar; I: Integer; out value: WideString); stdcall;
var
  methodResultValue: TValue;
begin
  methodResultValue := executeInstanceMethod(Reference, string(AName), [I]);
  value := methodResultValue.AsString;
end;

procedure executeInstanceMethodReturnStringArgsIntInt_Out_String(const Reference
  : NativeInt; const AName: PAnsiChar; I1, I2: Integer; out value: WideString); stdcall;
var
  methodResultValue: TValue;
begin
  methodResultValue := executeInstanceMethod(Reference, string(AName), [I1, I2]);
  value := methodResultValue.AsString;
end;

procedure executeInstanceMethodReturnEnumArgsNone(const Reference: NativeInt;
  const AName: PAnsiChar; out value: WideString); stdcall;
var
  s: String;
  methodResultValue: TValue;
begin
  methodResultValue := executeInstanceMethod(Reference, string(AName), []);
  s := methodResultValue.AsString;
  value := s;
end;

procedure executeClassMethodReturnNoneArgsStringStringString_Out_String
  (const AQualifiedName, AName: PAnsiChar; const v1, v2, v3: WideString;
  out value: WideString); stdcall;
var
  methodResultValue: TValue;
begin
  methodResultValue := executeClassMethod(string(AQualifiedName), string(AName),
    [string(v1), string(v2), string(v3)]);
  value := methodResultValue.AsString;
end;

end.
