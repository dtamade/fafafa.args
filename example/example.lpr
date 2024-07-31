program example;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  CustApp,
  fafafa.args { you can add units after this };

var
  LArgs: TArgs;
  i: integer;
  LItem: pargs_item_t;
  LArgEnum: TArgsArgEnumerator;
  LOptionEnum: TArgsOptionEnumerator;

  procedure PrintItem(aItem: pargs_item_t);
  begin
    Write(aItem^.itemType, ' arg:', aItem^.name);
    if aItem^.hasValue then
      WriteLn(' Value:', aItem^.value)
    else
      WriteLn('');
  end;


begin
  LArgs := TArgs.Global;
  WriteLn('Argc:', LArgs.Argc);
  WriteLn('Argv:');
  for i := 0 to Pred(LArgs.Argc) do
    WriteLn('    ',LArgs.Argv[i]);

  WriteLn('');
  WriteLn('items:');
  for LItem in LArgs do
  begin
    Write('    ');
    PrintItem(LItem);
  end;

  WriteLn('');
  WriteLn('arg:');
  LArgEnum := LArgs.GetArgEnumerator;
  while LArgEnum.MoveNext do
    WriteLn('    ',LArgEnum.Current);
  LArgEnum.Free;

  WriteLn('');
  WriteLn('Option:');
  LOptionEnum := LArgs.GetOptionEnumerator;
  while LOptionEnum.MoveNext do
  begin
    Write('    ');
    PrintItem(pargs_item_t(LOptionEnum.Current));
  end;
  LOptionEnum.Free;

  WriteLn('');
  WriteLn('ShortOption:');
  LOptionEnum := LArgs.GetShortOptionEnumerator;
  while LOptionEnum.MoveNext do
  begin
    Write('    ');
    PrintItem(pargs_item_t(LOptionEnum.Current));
  end;
  LOptionEnum.Free;

  WriteLn('');
  WriteLn('LongOption:');
  LOptionEnum := LArgs.GetLongOptionEnumerator;
  while LOptionEnum.MoveNext do
  begin
    Write('    ');
    PrintItem(pargs_item_t(LOptionEnum.Current));
  end;
  LOptionEnum.Free;

end.
