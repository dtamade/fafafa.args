unit argTestCase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry,
  //.
  fafafa.args;

type

  { TArgsTestCase }

  TArgsTestCase = class(TTestCase)
  private
    FArgs: pargs_t;
    function CompareItem(aA, aB: pargs_item_t): boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    procedure Test_args_strToArgv;

    procedure Test_args_create;
    procedure Test_args_global;
    procedure Test_args_argc;
    procedure Test_args_argv;
    procedure Test_args_getCount;
    procedure Test_args_getByIndex;
    procedure Test_args_get;
    procedure Test_args_has;
    procedure Test_args_tryGet;
    procedure Test_args_arg_has;
    procedure Test_args_option_has;
    procedure Test_args_option_get;
    procedure Test_args_option_tryGet;
    procedure Test_args_option_tryGetValue;
    procedure Test_args_option_short_has;
    procedure Test_args_option_short_get;
    procedure Test_args_option_short_tryGet;
    procedure Test_args_option_short_tryGetValue;
    procedure Test_args_option_long_has;
    procedure Test_args_option_long_get;
    procedure Test_args_option_long_tryGet;
    procedure Test_args_option_long_tryGetValue;
    procedure Test_args_enum;
    procedure Test_args_arg_enum;
    procedure Test_args_option_enum;
    procedure Test_args_option_short_enum;
    procedure Test_args_option_long_enum;

    procedure Test_args_enumerator_create;
    procedure Test_args_arg_enumerator_create;
    procedure Test_args_option_enumerator_create;
    procedure Test_args_option_short_enumerator_create;
    procedure Test_args_option_long_enumerator_create;
    procedure Test_args_enumerator_next;
    procedure Test_args_enumerator_current;
    procedure Test_args_arg_enumerator_current;
    procedure Test_args_option_enumerator_current;

    procedure Test_TArgs_Create;
    procedure Test_TArgs_Create2;
    procedure Test_TArgs_Has;
    procedure Test_TArgs_Get;
    procedure Test_TArgs_TryGet;
    procedure Test_TArgs_HasArg;
    procedure Test_TArgs_HasOption;
    procedure Test_TArgs_HasShortOption;
    procedure Test_TArgs_HasLongOption;
    procedure Test_TArgs_GetOption;
    procedure Test_TArgs_GetShortOption;
    procedure Test_TArgs_GetLongOption;
    procedure Test_TArgs_TryGetOption;
    procedure Test_TArgs_TryGetShortOption;
    procedure Test_TArgs_TryGetLongOption;
    procedure Test_TArgs_TryGetOptionValue;
    procedure Test_TArgs_TryGetShortOptionValue;
    procedure Test_TArgs_TryGetLongOptionValue;
    procedure Test_TArgs_GetEnumerator;
    procedure Test_TArgs_GetArgEnumerator;
    procedure Test_TArgs_GetOptionEnumerator;
    procedure Test_TArgs_GetShortOptionEnumerator;
    procedure Test_TArgs_GetLongOptionEnumerator;

  end;


implementation

const

  TEST_ARGS_STR = '-abc arg1 /wow /x -f --encode /in=in.txt arg2 --enableDebug:true --out:out.txt header.h arg3 -xyz';

  TEST_ARGS_COUNT = 17;
  TEST_ARGS_ARG_SIZE = 4;
  TEST_ARGS_OPTION_SIZE = 13;
  TEST_ARGS_OPTION_SHORT_SIZE = 8;
  TEST_ARGS_OPTION_LONG_SIZE = 5;

  TEST_ARGS_ITEMS: array [0..16] of args_item_t = (
    (Name: 'a'; Value: ''; hasValue: False; itemType: at_option_short),
    (Name: 'b'; Value: ''; hasValue: False; itemType: at_option_short),
    (Name: 'c'; Value: ''; hasValue: False; itemType: at_option_short),
    (Name: 'arg1'; Value: ''; hasValue: False; itemType: at_arg),
    (Name: 'wow'; Value: ''; hasValue: False; itemType: at_option_long),
    (Name: 'x'; Value: ''; hasValue: False; itemType: at_option_short),
    (Name: 'f'; Value: ''; hasValue: False; itemType: at_option_short),
    (Name: 'encode'; Value: ''; hasValue: False; itemType: at_option_long),
    (Name: 'in'; Value: 'in.txt'; hasValue: True; itemType: at_option_long),
    (Name: 'arg2'; Value: ''; hasValue: False; itemType: at_arg),
    (Name: 'enableDebug'; Value: 'true'; hasValue: True; itemType: at_option_long),
    (Name: 'out'; Value: 'out.txt'; hasValue: True; itemType: at_option_long),
    (Name: 'header.h'; Value: ''; hasValue: False; itemType: at_arg),
    (Name: 'arg3'; Value: ''; hasValue: False; itemType: at_arg),
    (Name: 'x'; Value: ''; hasValue: False; itemType: at_option_short),
    (Name: 'y'; Value: ''; hasValue: False; itemType: at_option_short),
    (Name: 'z'; Value: ''; hasValue: False; itemType: at_option_short)
    );

var
  this_testCase: TArgsTestCase;
  test_argv: PPAnsiChar;
  test_argc: integer;

function TArgsTestCase.CompareItem(aA, aB: pargs_item_t): boolean;
begin
  Result := SameText(aA^.Name, aB^.Name) and (aA^.itemType = aB^.itemType) and ((aA^.hasValue = aB^.hasValue) and (SameText(aA^.Value, aB^.Value)));
end;

constructor TArgsTestCase.Create;
begin
  inherited Create;
  FArgs := args_create(test_argv, test_argc);
  this_testCase := Self;
end;

destructor TArgsTestCase.Destroy;
begin
  args_destroy(FArgs);
  inherited Destroy;
end;

procedure TArgsTestCase.Test_args_strToArgv;
var
  LArgsArray: TAnsiStringArray;
  LArrayLen: SizeInt;
  i: integer;
begin
  LArgsArray := string(TEST_ARGS_STR).Split(' ');
  LArrayLen := Length(LArgsArray);

  AssertTrue(TEST_ARGS_STR <> '');
  AssertTrue(LArrayLen + 1 = test_argc);
  AssertTrue(SameText(test_argv[0], ParamStr(0)));

  for i := 1 to Pred(LArrayLen) do
    AssertTrue(SameText(LArgsArray[i - 1], test_argv[i]));
end;

procedure TArgsTestCase.Test_args_create;
var
  LArgs: pargs_t;
begin
  LArgs := args_create(test_argv, test_argc);
  AssertTrue(LArgs <> nil);
  args_destroy(LArgs);
end;

procedure TArgsTestCase.Test_args_global;
var
  LArgs: pargs_t;
begin
  LArgs := args_global;
  AssertTrue(LArgs <> nil);
end;

procedure TArgsTestCase.Test_args_argc;
begin
  AssertTrue(args_argc(FArgs) = test_argc);
end;

procedure TArgsTestCase.Test_args_argv;
var
  i: integer;
begin
  for i := 0 to Pred(test_argc) do
    AssertTrue(SameText(args_argv(FArgs, i), test_argv[I]));
end;

procedure TArgsTestCase.Test_args_getCount;
begin
  AssertTrue(args_getCount(FArgs) = TEST_ARGS_COUNT);
end;

procedure TArgsTestCase.Test_args_getByIndex;
var
  i: integer;
  LItemA, LItemB: pargs_item_t;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    LItemB := args_getByIndex(FArgs, i);
    AssertTrue(CompareItem(LItemA, LItemB));
  end;
end;

procedure TArgsTestCase.Test_args_get;
var
  i: integer;
  LItemA, LItemB: pargs_item_t;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    LItemB := args_get(FArgs, LItemA^.Name);
    AssertTrue((LItemB <> nil) and CompareItem(LItemA, LItemB));
  end;

  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    LItemB := args_get(FArgs, LItemA^.Name, [LItemA^.itemType]);
    AssertTrue((LItemB <> nil) and CompareItem(LItemA, LItemB));
  end;
end;

procedure TArgsTestCase.Test_args_has;
var
  i: integer;
  LItemA: pargs_item_t;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    AssertTrue(args_has(FArgs, LItemA^.Name));
  end;

  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    AssertTrue(args_has(FArgs, LItemA^.Name, [LItemA^.itemType]));
  end;
end;

procedure TArgsTestCase.Test_args_tryGet;
var
  i: integer;
  LItemA, LItemB: pargs_item_t;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    AssertTrue(args_tryGet(FArgs, LItemA^.Name, LItemB) and CompareItem(LItemA, LItemB));
  end;

  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    AssertTrue(args_tryGet(FArgs, LItemA^.Name, LItemB, [LItemA^.itemType]) and CompareItem(LItemA, LItemB));
  end;
end;

procedure TArgsTestCase.Test_args_arg_has;
var
  i: integer;
  LItemA: pargs_item_t;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if LItemA^.itemType = at_arg then
      AssertTrue(args_arg_has(FArgs, LItemA^.Name));
  end;
end;

procedure TArgsTestCase.Test_args_option_has;
var
  i: integer;
  LItemA: pargs_item_t;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if (LItemA^.itemType = at_option_short) or (LItemA^.itemType = at_option_long) then
      AssertTrue(args_option_has(FArgs, LItemA^.Name));
  end;
end;

procedure TArgsTestCase.Test_args_option_get;
var
  i: integer;
  LItemA: pargs_item_t;
  LItemB: pargs_option_t;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if (LItemA^.itemType = at_option_short) or (LItemA^.itemType = at_option_long) then
    begin
      LItemB := args_option_get(FArgs, LItemA^.Name);
      AssertTrue((LItemB <> nil) and CompareItem(LItemA, pargs_item_t(LItemB)));
    end;
  end;
end;

procedure TArgsTestCase.Test_args_option_tryGet;
var
  i: integer;
  LItemA: pargs_item_t;
  LItemB: pargs_option_t;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if (LItemA^.itemType = at_option_short) or (LItemA^.itemType = at_option_long) then
      AssertTrue(args_option_tryGet(FArgs, LItemA^.Name, LItemB) and (LItemB <> nil) and CompareItem(LItemA, pargs_item_t(LItemB)));
  end;
end;

procedure TArgsTestCase.Test_args_option_tryGetValue;
var
  i: integer;
  LItemA: pargs_item_t;
  LItemBValue: string;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if ((LItemA^.itemType = at_option_short) or (LItemA^.itemType = at_option_long)) and LItemA^.hasValue then
      AssertTrue(args_option_tryGetValue(FArgs, LItemA^.Name, LItemBValue) and SameText(LItemA^.Value, LItemBValue));
  end;
end;

procedure TArgsTestCase.Test_args_option_short_has;
var
  i: integer;
  LItemA: pargs_item_t;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if (LItemA^.itemType = at_option_short) then
      AssertTrue(args_option_short_has(FArgs, pansichar(LItemA^.Name)^));
  end;
end;

procedure TArgsTestCase.Test_args_option_short_get;
var
  i: integer;
  LItemA: pargs_item_t;
  LItemB: pargs_option_t;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if (LItemA^.itemType = at_option_short) then
    begin
      LItemB := args_option_short_get(FArgs, pansichar(LItemA^.Name)^);
      AssertTrue((LItemB <> nil) and CompareItem(LItemA, pargs_item_t(LItemB)));
    end;
  end;
end;

procedure TArgsTestCase.Test_args_option_short_tryGet;
var
  i: integer;
  LItemA: pargs_item_t;
  LItemB: pargs_option_t;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if (LItemA^.itemType = at_option_short) then
      AssertTrue(args_option_short_tryGet(FArgs, pansichar(LItemA^.Name)^, LItemB) and (LItemB <> nil) and CompareItem(LItemA, pargs_item_t(LItemB)));
  end;
end;

procedure TArgsTestCase.Test_args_option_short_tryGetValue;
var
  i: integer;
  LItemA: pargs_item_t;
  LItemBValue: string;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if (LItemA^.itemType = at_option_short) and LItemA^.hasValue then
      AssertTrue(args_option_short_tryGetValue(FArgs, pansichar(LItemA^.Name)^, LItemBValue) and SameText(LItemA^.Value, LItemBValue));
  end;
end;

procedure TArgsTestCase.Test_args_option_long_has;
var
  i: integer;
  LItemA: pargs_item_t;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if (LItemA^.itemType = at_option_long) then
      AssertTrue(args_option_long_has(FArgs, LItemA^.Name));
  end;
end;

procedure TArgsTestCase.Test_args_option_long_get;
var
  i: integer;
  LItemA: pargs_item_t;
  LItemB: pargs_option_t;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if (LItemA^.itemType = at_option_long) then
    begin
      LItemB := args_option_long_get(FArgs, LItemA^.Name);
      AssertTrue((LItemB <> nil) and CompareItem(LItemA, pargs_item_t(LItemB)));
    end;
  end;
end;

procedure TArgsTestCase.Test_args_option_long_tryGet;
var
  i: integer;
  LItemA: pargs_item_t;
  LItemB: pargs_option_t;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if (LItemA^.itemType = at_option_long) then
      AssertTrue(args_option_long_tryGet(FArgs, LItemA^.Name, LItemB) and (LItemB <> nil) and CompareItem(LItemA, pargs_item_t(LItemB)));
  end;
end;

procedure TArgsTestCase.Test_args_option_long_tryGetValue;
var
  i: integer;
  LItemA: pargs_item_t;
  LItemBValue: string;
begin
  for i := 0 to Pred(TEST_ARGS_COUNT) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if (LItemA^.itemType = at_option_long) and LItemA^.hasValue then
      AssertTrue(args_option_long_tryGetValue(FArgs, LItemA^.Name, LItemBValue) and SameText(LItemA^.Value, LItemBValue));
  end;
end;

type

  ptest_args_enum_data_t = ^test_args_enum_data_t;

  test_args_enum_data_t = record
    Count: integer;
    types: args_type_set_t;
  end;

procedure DoTestEnumCB_all(aArgs: pargs_t; aItem: pargs_item_t; aData: Pointer; var aContinue: boolean);
var
  LData: ptest_args_enum_data_t;
  LItemA: pargs_item_t;
begin
  LData := ptest_args_enum_data_t(aData);
  LItemA := @TEST_ARGS_ITEMS[LData^.Count];
  this_testCase.AssertTrue(this_testCase.CompareItem(LItemA, aItem));
  this_testCase.AssertTrue(aItem^.itemType in LData^.types);
  Inc(LData^.Count);
end;

procedure TArgsTestCase.Test_args_enum;
var
  LData: test_args_enum_data_t;
begin
  LData.Count := 0;
  LData.types := at_all;
  args_enum(FArgs, @DoTestEnumCB_all, @LData, LData.types);
  AssertTrue(LData.Count = args_getCount(FArgs));
end;

procedure DoTestEnumCB_arg(aArgs: pargs_t; const aArg: string; aData: Pointer; var aContinue: boolean);
var
  LData: ptest_args_enum_data_t;
begin
  LData := ptest_args_enum_data_t(aData);
  this_testCase.AssertTrue(aArg <> '');
  Inc(LData^.Count);
end;

procedure TArgsTestCase.Test_args_arg_enum;
var
  LData: test_args_enum_data_t;
begin
  LData.Count := 0;
  LData.types := [at_arg];
  args_arg_enum(FArgs, @DoTestEnumCB_arg, @LData);
  AssertTrue(LData.Count = TEST_ARGS_ARG_SIZE);
end;

procedure DoTestEnumCB_option(aArgs: pargs_t; aOption: pargs_option_t; aData: Pointer; var aContinue: boolean);
begin
  Inc(ptest_args_enum_data_t(aData)^.Count);
  this_testCase.AssertTrue(aOption <> nil);
end;

procedure TArgsTestCase.Test_args_option_enum;
var
  LData: test_args_enum_data_t;
begin
  LData.Count := 0;
  LData.types := at_option_all;
  args_option_enum(FArgs, @DoTestEnumCB_option, @LData);
  AssertTrue(LData.Count = TEST_ARGS_OPTION_SIZE);
end;

procedure DoTestEnumCB_option_short(aArgs: pargs_t; aOption: pargs_option_t; aData: Pointer; var aContinue: boolean);
begin
  Inc(ptest_args_enum_data_t(aData)^.Count);
  this_testCase.AssertTrue(aOption <> nil);
end;

procedure TArgsTestCase.Test_args_option_short_enum;
var
  LData: test_args_enum_data_t;
begin
  LData.Count := 0;
  LData.types := [at_option_short];
  args_option_short_enum(FArgs, @DoTestEnumCB_option_short, @LData);
  AssertTrue(LData.Count = TEST_ARGS_OPTION_SHORT_SIZE);
end;

procedure DoTestEnumCB_option_long(aArgs: pargs_t; aOption: pargs_option_t; aData: Pointer; var aContinue: boolean);
begin
  Inc(ptest_args_enum_data_t(aData)^.Count);
  this_testCase.AssertTrue(aOption <> nil);
end;

procedure TArgsTestCase.Test_args_option_long_enum;
var
  LData: test_args_enum_data_t;
begin
  LData.Count := 0;
  LData.types := [at_option_long];
  args_option_long_enum(FArgs, @DoTestEnumCB_option_long, @LData);
  AssertTrue(LData.Count = TEST_ARGS_OPTION_LONG_SIZE);
end;

procedure TArgsTestCase.Test_args_enumerator_create;
var
  LEnum: pargs_enumerator_t;
begin
  LEnum := args_enumerator_create(FArgs);
  AssertTrue(LEnum <> nil);
  args_enumerator_destroy(LEnum);
end;

procedure TArgsTestCase.Test_args_arg_enumerator_create;
var
  LEnum: pargs_enumerator_t;
begin
  LEnum := args_arg_enumerator_create(FArgs);
  AssertTrue(LEnum <> nil);
  args_enumerator_destroy(LEnum);
end;

procedure TArgsTestCase.Test_args_option_enumerator_create;
var
  LEnum: pargs_enumerator_t;
begin
  LEnum := args_option_enumerator_create(FArgs);
  AssertTrue(LEnum <> nil);
  args_enumerator_destroy(LEnum);
end;

procedure TArgsTestCase.Test_args_option_short_enumerator_create;
var
  LEnum: pargs_enumerator_t;
begin
  LEnum := args_option_short_enumerator_create(FArgs);
  AssertTrue(LEnum <> nil);
  args_enumerator_destroy(LEnum);
end;

procedure TArgsTestCase.Test_args_option_long_enumerator_create;
var
  LEnum: pargs_enumerator_t;
begin
  LEnum := args_option_long_enumerator_create(FArgs);
  AssertTrue(LEnum <> nil);
  args_enumerator_destroy(LEnum);
end;

procedure TArgsTestCase.Test_args_enumerator_next;
var
  LEnum: pargs_enumerator_t;
  LCount: integer;
begin
  LEnum := args_enumerator_create(FArgs);

  LCount := 0;
  while args_enumerator_next(LEnum) do
    Inc(LCount);

  AssertTrue(LCount = args_getCount(FArgs));

  args_enumerator_destroy(LEnum);
end;

procedure TArgsTestCase.Test_args_enumerator_current;
var
  LEnum: pargs_enumerator_t;
  LCount: integer;
  LItemA, LItemB: pargs_item_t;
begin
  LEnum := args_enumerator_create(FArgs);

  LCount := 0;
  while args_enumerator_next(LEnum) do
  begin
    LItemA := @TEST_ARGS_ITEMS[LCount];
    LItemB := args_enumerator_current(LEnum);
    AssertTrue(CompareItem(LItemA, LItemB));
    Inc(LCount);
  end;

  args_enumerator_destroy(LEnum);
end;

procedure TArgsTestCase.Test_args_arg_enumerator_current;
var
  LArrays: array of pargs_item_t;
  i: integer;
  LP, LItemA: pargs_item_t;
  LLen: SizeInt;
  LEnum: pargs_enumerator_t;
begin
  Initialize(LArrays);

  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LP := @TEST_ARGS_ITEMS[i];
    if LP^.itemType = at_arg then
    begin
      LLen := Length(LArrays);
      SetLength(LArrays, LLen + 1);

      LArrays[LLen] := LP;
    end;
  end;

  LEnum := args_arg_enumerator_create(FArgs);

  i := 0;
  while args_enumerator_next(LEnum) do
  begin
    LItemA := LArrays[i];
    AssertTrue(SameText(LItemA^.Name, args_arg_enumerator_current(LEnum)));
    Inc(i);
  end;

  AssertTrue(i = Length(LArrays));

  args_enumerator_destroy(LEnum);

end;

procedure TArgsTestCase.Test_args_option_enumerator_current;
var
  LArrays: array of pargs_item_t;
  i: integer;
  LP, LItemA: pargs_item_t;
  LLen: SizeInt;
  LEnum: pargs_enumerator_t;
  LItemB: pargs_option_t;
begin
  Initialize(LArrays);

  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LP := @TEST_ARGS_ITEMS[i];
    if LP^.itemType in at_option_all then
    begin
      LLen := Length(LArrays);
      SetLength(LArrays, LLen + 1);

      LArrays[LLen] := LP;
    end;
  end;

  LEnum := args_option_enumerator_create(FArgs);

  i := 0;
  while args_enumerator_next(LEnum) do
  begin
    LItemA := LArrays[i];
    LItemB := args_option_enumerator_current(LEnum);
    AssertTrue(CompareItem(pargs_item_t(LItemA), pargs_item_t(LItemB)));
    Inc(i);
  end;

  AssertTrue(i = Length(LArrays));

  args_enumerator_destroy(LEnum);
end;

procedure TArgsTestCase.Test_TArgs_Create;
var
  LArgs: TArgs;
begin
  LArgs := TArgs.Create;
  AssertTrue(LArgs <> nil);
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_Create2;
var
  LArgs: TArgs;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  AssertTrue(LArgs <> nil);
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_Has;
var
  LArgs: TArgs;
  i: integer;
  LItemA: pargs_item_t;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    AssertTrue(LArgs.Has(LItemA^.Name));
    AssertTrue(LArgs.Has(LItemA^.Name, [LItemA^.itemType]));
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_Get;
var
  LArgs: TArgs;
  i: integer;
  LItemA, LItemB: pargs_item_t;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    LItemB := LArgs.Get(LItemA^.Name);
    AssertTrue(CompareItem(LItemA, LItemB));

    LItemB := LArgs.Get(LItemA^.Name, [LItemA^.itemType]);
    AssertTrue(CompareItem(LItemA, LItemB));
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_TryGet;
var
  LArgs: TArgs;
  i: integer;
  LItemA, LItemB: pargs_item_t;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    AssertTrue(LArgs.TryGet(LItemA^.Name, LItemB) and CompareItem(LItemA, LItemB));
    AssertTrue(LArgs.TryGet(LItemA^.Name, LItemB, [LItemA^.itemType]) and CompareItem(LItemA, LItemB));
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_HasArg;
var
  LArgs: TArgs;
  i: integer;
  LItemA: pargs_item_t;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if LItemA^.itemType = at_arg then
      AssertTrue(LArgs.HasArg(LItemA^.Name));
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_HasOption;
var
  LArgs: TArgs;
  i: integer;
  LItemA: pargs_item_t;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if LItemA^.itemType in at_option_all then
      AssertTrue(LArgs.HasOption(LItemA^.Name));
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_HasShortOption;
var
  LArgs: TArgs;
  i: integer;
  LItemA: pargs_item_t;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if LItemA^.itemType = at_option_short then
      AssertTrue(LArgs.HasShortOption(pansichar(LItemA^.Name)^));
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_HasLongOption;
var
  LArgs: TArgs;
  i: integer;
  LItemA: pargs_item_t;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if LItemA^.itemType = at_option_long then
      AssertTrue(LArgs.HasLongOption(LItemA^.Name));
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_GetOption;
var
  LArgs: TArgs;
  i: integer;
  LItemA: pargs_item_t;
  LItemB: pargs_option_t;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if LItemA^.itemType in at_option_all then
    begin
      LItemB := LArgs.GetOption(LItemA^.Name);
      AssertTrue((LItemB <> nil) and CompareItem(LItemA, pargs_item_t(LItemB)));
    end;
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_GetShortOption;
var
  LArgs: TArgs;
  i: integer;
  LItemA: pargs_item_t;
  LItemB: pargs_option_t;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if LItemA^.itemType = at_option_short then
    begin
      LItemB := LArgs.GetShortOption(pansichar(LItemA^.Name)^);
      AssertTrue((LItemB <> nil) and CompareItem(LItemA, pargs_item_t(LItemB)));
    end;
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_GetLongOption;
var
  LArgs: TArgs;
  i: integer;
  LItemA: pargs_item_t;
  LItemB: pargs_option_t;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if LItemA^.itemType = at_option_long then
    begin
      LItemB := LArgs.GetLongOption(LItemA^.Name);
      AssertTrue((LItemB <> nil) and CompareItem(LItemA, pargs_item_t(LItemB)));
    end;
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_TryGetOption;
var
  LArgs: TArgs;
  i: integer;
  LItemA: pargs_item_t;
  LItemB: pargs_option_t;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if LItemA^.itemType in at_option_all then
      AssertTrue((LArgs.TryGetOption(LItemA^.Name, LItemB)) and (LItemB <> nil) and CompareItem(LItemA, pargs_item_t(LItemB)));
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_TryGetShortOption;
var
  LArgs: TArgs;
  i: integer;
  LItemA: pargs_item_t;
  LItemB: pargs_option_t;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if LItemA^.itemType = at_option_short then
      AssertTrue((LArgs.TryGetShortOption(pansichar(LItemA^.Name)^, LItemB)) and (LItemB <> nil) and CompareItem(LItemA, pargs_item_t(LItemB)));
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_TryGetLongOption;
var
  LArgs: TArgs;
  i: integer;
  LItemA: pargs_item_t;
  LItemB: pargs_option_t;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if LItemA^.itemType = at_option_long then
      AssertTrue((LArgs.TryGetLongOption(LItemA^.Name, LItemB)) and (LItemB <> nil) and CompareItem(LItemA, pargs_item_t(LItemB)));
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_TryGetOptionValue;
var
  LArgs: TArgs;
  i: integer;
  LItemA: pargs_item_t;
  LValue: string;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if (LItemA^.itemType in at_option_all) and LItemA^.hasValue then
      AssertTrue((LArgs.TryGetOptionValue(LItemA^.Name, LValue)) and SameText(LItemA^.Value, LValue));
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_TryGetShortOptionValue;
var
  LArgs: TArgs;
  i: integer;
  LItemA: pargs_item_t;
  LValue: string;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if (LItemA^.itemType = at_option_short) and LItemA^.hasValue then
      AssertTrue((LArgs.TryGetShortOptionValue(pansichar(LItemA^.Name)^, LValue)) and SameText(LItemA^.Value, LValue));
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_TryGetLongOptionValue;
var
  LArgs: TArgs;
  i: integer;
  LItemA: pargs_item_t;
  LValue: string;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if (LItemA^.itemType = at_option_long) and LItemA^.hasValue then
      AssertTrue((LArgs.TryGetLongOptionValue(LItemA^.Name, LValue)) and SameText(LItemA^.Value, LValue));
  end;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_GetEnumerator;
var
  LArgs: TArgs;
  LEnum: TArgsEnumerator;
  i: integer;
  LItemA, LItemB: pargs_item_t;
begin
  LArgs := TArgs.Create(test_argv, test_argc);
  LEnum := LArgs.GetEnumerator;
  AssertTrue(LEnum <> nil);

  i := 0;
  while LEnum.MoveNext do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    LItemB := LEnum.Current;
    AssertTrue(CompareItem(LItemA, LitemB));
    Inc(i);
  end;
  LEnum.Free;

  i := 0;
  for LItemB in LArgs do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    AssertTrue(CompareItem(LItemA, LitemB));
    Inc(i);
  end;

  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_GetArgEnumerator;
var
  LArray: array of string;
  i: integer;
  LItemA: pargs_item_t;
  LLen: SizeInt;
  LArgs: TArgs;
  LEnum: TArgsArgEnumerator;
begin
  Initialize(LArray);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if LItemA^.itemType = at_arg then
    begin
      LLen := Length(LArray);
      SetLength(LArray, LLen + 1);
      LArray[LLen] := LItemA^.Name;
    end;
  end;

  LArgs := TArgs.Create(test_argv, test_argc);
  LEnum := LArgs.GetArgEnumerator;
  i := 0;
  while LEnum.MoveNext do
  begin
    AssertTrue(SameText(LArray[i], LEnum.Current));
    Inc(i);
  end;
  LEnum.Free;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_GetOptionEnumerator;
var
  LArray: array of pargs_item_t;
  i: integer;
  LItemA: pargs_item_t;
  LLen: SizeInt;
  LArgs: TArgs;
  LEnum: TArgsOptionEnumerator;
begin
  Initialize(LArray);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if LItemA^.itemType in at_option_all then
    begin
      LLen := Length(LArray);
      SetLength(LArray, LLen + 1);
      LArray[LLen] := LItemA;
    end;
  end;

  LArgs := TArgs.Create(test_argv, test_argc);
  LEnum := LArgs.GetOptionEnumerator;
  i := 0;
  while LEnum.MoveNext do
  begin
    AssertTrue(CompareItem(LArray[i], pargs_item_t(LEnum.Current)));
    Inc(i);
  end;
  LEnum.Free;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_GetShortOptionEnumerator;
var
  LArray: array of pargs_item_t;
  i: integer;
  LItemA: pargs_item_t;
  LLen: SizeInt;
  LArgs: TArgs;
  LEnum: TArgsOptionEnumerator;
begin
  Initialize(LArray);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if LItemA^.itemType = at_option_short then
    begin
      LLen := Length(LArray);
      SetLength(LArray, LLen + 1);
      LArray[LLen] := LItemA;
    end;
  end;

  LArgs := TArgs.Create(test_argv, test_argc);
  LEnum := LArgs.GetShortOptionEnumerator;
  i := 0;
  while LEnum.MoveNext do
  begin
    AssertTrue(CompareItem(LArray[i], pargs_item_t(LEnum.Current)));
    Inc(i);
  end;
  LEnum.Free;
  LArgs.Free;
end;

procedure TArgsTestCase.Test_TArgs_GetLongOptionEnumerator;
var
  LArray: array of pargs_item_t;
  i: integer;
  LItemA: pargs_item_t;
  LLen: SizeInt;
  LArgs: TArgs;
  LEnum: TArgsOptionEnumerator;
begin
  Initialize(LArray);
  for i := 0 to Pred(Length(TEST_ARGS_ITEMS)) do
  begin
    LItemA := @TEST_ARGS_ITEMS[i];
    if LItemA^.itemType = at_option_long then
    begin
      LLen := Length(LArray);
      SetLength(LArray, LLen + 1);
      LArray[LLen] := LItemA;
    end;
  end;

  LArgs := TArgs.Create(test_argv, test_argc);
  LEnum := LArgs.GetLongOptionEnumerator;
  i := 0;
  while LEnum.MoveNext do
  begin
    AssertTrue(CompareItem(LArray[i], pargs_item_t(LEnum.Current)));
    Inc(i);
  end;
  LEnum.Free;
  LArgs.Free;
end;


initialization
  args_strToArgv(TEST_ARGS_STR, ParamStr(0), test_argv, test_argc);
  RegisterTest(TArgsTestCase);

finalization
  args_argv_free(test_argv, test_argc);

end.
