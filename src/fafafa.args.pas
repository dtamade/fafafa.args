unit fafafa.args;

{

# fafafa.args

```text
   ______   ______     ______   ______     ______   ______
  /\  ___\ /\  __ \   /\  ___\ /\  __ \   /\  ___\ /\  __ \
  \ \  __\ \ \  __ \  \ \  __\ \ \  __ \  \ \  __\ \ \  __ \
   \ \_\    \ \_\ \_\  \ \_\    \ \_\ \_\  \ \_\    \ \_\ \_\
    \/_/     \/_/\/_/   \/_/     \/_/\/_/   \/_/     \/_/\/_/  Studio

```

## 概述

本库提供了一个强大而灵活的程序输入参数处理器。它可以将输入参数解析为三种类型:参数、短选项和长选项。

解析过程主要参考 Linux/Unix 传参风格,同时也支持 Windows 风格的参数格式。


## 特性

- 支持参数、短选项、长选项三种类型的解析
- 兼容 Linux/Unix 和 Windows 风格的参数格式
- 提供 C 风格和面向对象两种使用方式
- 支持选项值的多种分隔方式(空格、=、:)
- 灵活的迭代器接口,方便遍历和处理参数


## 使用方法

通常只需要使用 args_global(C 风格)或 args(全局对象实例)来初始化并获取参数处理器。

可以根据个人编码风格选择使用 C 风格接口或对象接口来访问和处理参数。


### 参数解析规则

参数是以空格分隔的文本,通常按固定约定顺序处理:

program inFile.txt                        // 单个参数
program inFile.txt outFile.txt fileN.txt  // 多个参数


### 短选项

Linux/Unix 风格的短选项以 "-" 开始，短选项参数可能会以键值形式提供选项值。

program -h                            // 单个短选项
program -lax                          // 多个组合的短选项(linux/unix风格),
                                      // 这种情况下选项会分别展开为三个短选项 -l -a -x
program -e "abc"                      // 短选项以"空格"分隔键值
program -e="abc"                      // 短选项以"="分隔键值
program -e:"abc"                      // 短选项以":"分隔键值


### 长选项

Linux/Unix 风格的长选项以 "--" 开始，长选项参数可能会以键值形式提供选项值。

program --help                        // 长选项不含值
program --encode "abc"                // 长选项空格分割值
program --encode="abc"                // 长选项"="分隔键值
program --encode:abc                  // 长选项":"分隔键值
program --file=c:/test.txt            // 长选项"="分隔键值
program inFile.txt --append --utf8    // 长选项与参数混用


### windows风格的选项

Windows 通常用 "/" 来做选项前缀，并且通常没有长短选项的区分。Windows 风格下将不再支持 Linux/Unix 下的短选项组合形式解析，因为这与 Windows 风格的长选项判定产生了冲突。

program /h                            // 单个短选项
program /help                         // 长选项不含值
program /e "abc"                      // 短选项以空格分隔键值
program /e="abc"                      // 短选项以"="分隔键值
program /e:"abc"                      // 短选项以":"分隔键值
program /encode "abc"                 // 长选项空格分隔键值
program /encode="abc"                 // 长选项"="分隔键值
program /o:output.txt                 // 长选项":"分隔键值
program /o=output.txt /a /b /c /x     // 多个选项混用


###  传参风格的混用

你不必严格按照平台风格来使用传递参数，各种传参风格是可以混用的，例如：

program /x -f --encode /in=in.txt --out:out.txt header.h /with:a;b;c


## 代码示例

基本用法

"program -i inFile.txt -o outFile.txt -xyz"

```pascal

var
  LInFile,LOutFile:string;
begin

  // 我们可以通过同时尝试短选项和长选项拿到想要的选项指并处理它
  if not (args.TryGetShortOptionValue('i',LInFile) or args.TryGetLongOptionValue('in',LInFile)) then
    raise Exception.Create('not inFile');

  if not (args.TryGetShortOptionValue('o',LOutFile) or args.TryGetLongOptionValue('out',LOutFile)) then
    raise Exception.Create('not OutFile');

  // 通过Has判定是否存在指定选项
  if args.HasOption('x') then
    writeFile('x');

  if args.HasOption('y') then
    writeFile('y');

  if args.HasOption('z') then
    WriteFile('z');

  // ...
end;

```

### C风格的迭代器

```pascal
var
  LEnum:pargs_enumerator_t;
begin
  LEnum:=args_option_enumerator_create(args_global); // 创建C风格选项(长、短)迭代器
  while args_enumerator_next(LEnum) do // 迭代
    HandleOption(args_option_enumerator_current(LEnum)); // 处理当前迭代数据

  args_enumerator_destroy(LEnum); // 释放迭代器
end;
```

### 使用对象迭代器

```pascal

var
  LItem:pargs_item_t;
begin
  // for迭代所有解析项
  for LItem in args do
  begin
    case LItem^.itemType of
      at_arg:HandleArg(LItem^.Name);
      at_option_short,at_option_long:HandleOption(pargs_option_t(LItem));
    end;
  end;

  // 只迭代选项
  LEnum:=args.GetOptionEnumerator;
  while LEnum.MoveNext do
    HandleOption(pargs_option_t(LEnum.current));

  LEnum.free;

  // 只迭代参数
  LEnum:=args.GetArgEnumerator;
  while LEnum.MoveNext do
    HandleArg(LEnum.Current);

  LEnum.free;

end;
```


## 原因

编写这些代码的主要原因是 FreePascal RTL 中仅对 TCustomApplication 提供相关的接口方法。我们需要一个不与类和框架绑定耦合的、更好用、更符合自己代码规范的接口。


## 声明

转发或者用于自己项目请保留本项目的版权声明,谢谢.

fafafaStudio
Email:dtamade@gmail.com
QQ群:685403987
QQ:179033731

}


{$mode ObjFPC}{$H+}

interface

uses
  SysUtils;

type
  args_type_t = (at_arg, at_option_short, at_option_long);
  args_type_set_t = set of args_type_t;

const

  at_all = [at_arg, at_option_short, at_option_long];
  at_option_all = [at_option_short, at_option_long];

type

  { 解析项 }

  pargs_item_t = ^args_item_t;

  args_item_t = record
    Name: string;
    Value: string;
    hasValue: boolean;
    itemType: args_type_t;
  end;

  pargs_option_t = ^args_option_t;

  args_option_t = record
    Name: string;
    Value: string;
    hasValue: boolean;
  end;

  args_items_t = array of args_item_t;

type

  pargs_t = ^args_t;

  args_t = record
    argv: PPAnsiChar;
    argc: integer;
    items: args_items_t;
  end;

  args_enumCB_t = procedure(aArgs: pargs_t; aItem: pargs_item_t; aData: Pointer; var aContinue: boolean);
  args_arg_enumCB_t = procedure(aArgs: pargs_t; const aArg: string; aData: Pointer; var aContinue: boolean);
  args_option_enumCB_t = procedure(aArgs: pargs_t; aOption: pargs_option_t; aData: Pointer; var aContinue: boolean);

{**
 * args_strToArgv
 *
 * @desc 根据输入字符串创建 argv 和 argc 参数。这些参数通常在命令行程序中使用，用于模拟命令行参数的传递。
 *
 * @params
 * - const aStr: ansistring 输入字符串，表示命令行参数的字符串形式，参数之间以空格分隔。
 * - const aParam0: ansistring 程序名或第一个命令行参数，通常为程序自身的名称。
 * - out aArgv: PPAnsiChar 输出参数，返回一个指针数组，其中每个元素指向一个命令行参数字符串。
 * - out aArgc: integer 输出参数，返回命令行参数的数量，包括程序名。
 *
 *}
procedure args_strToArgv(const aStr, aParam0: ansistring; out aArgv: PPAnsiChar; out aArgc: integer);

{**
 * args_argv_free
 *
 * @desc 释放用户自构造的argv
 *
 * @params
 * - var aArgv: PPAnsiChar 释放由用户自定义构造的 argv 参数数组所占用的内存。
 * - aArgc: integer 输入参数，表示 argv 数组的长度。
 *
 *}
procedure args_argv_free(var aArgv: PPAnsiChar; aArgc: integer);

{**
 * args_create
 *
 * @desc 创建一个参数处理器，用于处理命令行参数。
 *
 * @params
 * - aArgv: PPAnsiChar 输入参数，指向字符串指针数组，其中每个元素指向一个命令行参数。
 * - aArgc: integer 输入参数，表示字符串指针数组的长度，即命令行参数的数量。
 *
 * @return pargs_t 返回一个指向参数处理器的指针，用于进一步处理命令行参数。
 *
 *}
function args_create(aArgv: PPAnsiChar; aArgc: integer): pargs_t;

{**
 * args_global
 *
 * @desc 获取程序的全局默认输入参数处理器。该处理器用于处理应用程序启动时的命令行参数。
 *
 * @return pargs_t 返回一个指向全局默认参数处理器的指针。
 *
 *}
function args_global: pargs_t;

{**
 * args_destroy
 *
 * @desc 释放由用户创建的参数处理器，释放其占用的内存资源。
 *
 * @params
 * - var aArgs: pargs_t 输入/输出参数，指向需要释放的参数处理器指针。释放后，该指针将被设置为 nil。
 *
 * @note 该函数会释放参数处理器及其相关资源，使用后应确保不再访问 aArgs 指向的内存区域。
 *
 *}
procedure args_destroy(var aArgs: pargs_t);

{**
 * args_argc
 *
 * @desc 获取参数处理器中原始输入字符串的数量，即程序的 "argc" 参数。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 *
 * @return integer 返回参数处理器中原始输入字符串的数量。
 *
 *}
function args_argc(aArgs: pargs_t): integer;

{**
 * args_argv
 *
 * @desc 获取参数处理器中原始输入字符串，即程序的 "argv" 参数中的指定索引处的字符串。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - aIndex: integer 输入参数，指定要获取的字符串在 argv 数组中的索引。
 *
 * @return shortstring 返回 argv 数组中指定索引处的字符串。
 *
 *}
function args_argv(aArgs: pargs_t; aIndex: integer): shortstring;

{**
 * args_getCount
 *
 * @desc 获取参数处理器中解析项的数量。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 *
 * @return integer 返回参数处理器中解析项的数量。
 *
 *}
function args_getCount(aArgs: pargs_t): integer;

{**
 * args_getByIndex
 *
 * @desc 从参数处理器中通过指定的索引访问解析项。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - aIndex: integer 输入参数，指定要访问的解析项在参数处理器中的索引。
 *
 * @return integer 返回指定索引处的解析项指针。
 *
 *}
function args_getByIndex(aArgs: pargs_t; aIndex: integer): pargs_item_t;

{**
 * args_get
 *
 * @desc 查找并返回指定名称和类型的解析项。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - const aName: string 输入参数，指定要查找的解析项名称。
 * - aTypeSet: argType_set_t 输入参数，指定解析项的类型集，默认查找所有类型的解析项。
 *
 * @return pargs_item_t 返回与指定名称和类型匹配的解析项指针，如果未找到匹配项则返回 nil。
 *
 *}
function args_get(aArgs: pargs_t; const aName: string; aTypes: args_type_set_t = at_all): pargs_item_t;

{**
 * args_has
 *
 * @desc 检查参数处理器中是否存在指定名称和类型的解析项。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - const aName: string 输入参数，指定要检查的解析项名称。
 * - aTypeSet: argType_set_t 输入参数，指定解析项的类型集，默认查找所有类型的解析项。
 *
 * @return boolean 返回一个布尔值，表示是否存在匹配的解析项。如果找到匹配项则返回 true，否则返回 false。
 *
 *}
function args_has(aArgs: pargs_t; const aName: string; aTypes: args_type_set_t = at_all): boolean;

{**
 * args_tryGet
 *
 * @desc 尝试获取参数处理器中指定名称和类型的解析项。如果找到匹配的解析项，则返回该项的指针。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - const aName: string 输入参数，指定要查找的解析项名称。
 * - out aItem: pargs_item_t 输出参数，返回找到的解析项指针。如果未找到匹配项，则该参数设置为 nil。
 * - aTypeSet: argType_set_t 输入参数，指定解析项的类型集，默认查找所有类型的解析项。
 *
 * @return boolean 返回一个布尔值，表示是否成功找到匹配的解析项。如果找到匹配项则返回 true，否则返回 false。
 *
 *}
function args_tryGet(aArgs: pargs_t; const aName: string; out aItem: pargs_item_t; aTypes: args_type_set_t = at_all): boolean;


{**
 * args_arg_has
 *
 * @desc 检查参数处理器中是否存在指定名称的参数。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - const aArg: string 输入参数，指定要检查的参数名称。
 *
 * @return boolean 返回一个布尔值，表示是否存在匹配的参数。如果找到匹配的参数则返回 true，否则返回 false。
 *
 *}
function args_arg_has(aArgs: pargs_t; const aArg: string): boolean;

{**
 * args_option_has
 *
 * @desc 检查参数处理器中是否存在指定名称的选项参数（短选项或长选项）。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - const aOptionName: string 输入参数，指定要检查的选项参数名称。
 *
 * @return boolean 返回一个布尔值，表示是否存在匹配的选项参数。如果找到匹配的选项参数则返回 true，否则返回 false。
 *
 *}
function args_option_has(aArgs: pargs_t; const aOptionName: string): boolean;

{**
 * args_option_get
 *
 * @desc 获取参数处理器中指定名称的选项参数（短选项或长选项）。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - const aOptionName: string 输入参数，指定要获取的选项参数名称。
 *
 * @return pargs_option_t 返回一个指向指定名称选项参数的指针。如果未找到匹配的选项参数，则返回 nil。
 *
 *}
function args_option_get(aArgs: pargs_t; const aOptionName: string): pargs_option_t;

{**
 * args_option_tryGet
 *
 * @desc 尝试获取参数处理器中指定名称的选项参数（短选项或长选项）。如果找到匹配的选项参数，则返回该选项。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - const aOptionName: string 输入参数，指定要查找的选项参数名称。
 * - out aOption: pargs_option_t 输出参数，返回找到的选项参数指针。如果未找到匹配项，则该参数设置为 nil。
 *
 * @return boolean 返回一个布尔值，表示是否成功找到匹配的选项参数。如果找到匹配项则返回 true，否则返回 false。
 *
 *}
function args_option_tryGet(aArgs: pargs_t; const aOptionName: string; out aOption: pargs_option_t): boolean;

{**
 * args_option_tryGetValue
 *
 * @desc 尝试获取参数处理器中指定名称的选项参数的值（短选项或长选项）。如果找到匹配的选项参数，则返回该选项的值。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - const aOptionName: string 输入参数，指定要查找的选项参数名称。
 * - out aValue: string 输出参数，返回找到的选项参数的值。如果未找到匹配项，则该参数设置为空字符串。
 *
 * @return boolean 返回一个布尔值，表示是否成功找到匹配的选项参数的值。如果找到匹配项则返回 true，否则返回 false。
 *
 *}
function args_option_tryGetValue(aArgs: pargs_t; const aOptionName: string; out aValue: string): boolean;

{**
 * args_option_short_has
 *
 * @desc 检查参数处理器中是否存在指定名称的短选项参数。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - aOptionName: char 输入参数，指定要检查的短选项参数名称。
 *
 * @return boolean 返回一个布尔值，表示是否存在匹配的短选项参数。如果找到匹配的短选项参数则返回 true，否则返回 false。
 *
 *}
function args_option_short_has(aArgs: pargs_t; aOptionName: char): boolean;


{**
 * args_option_short_get
 *
 * @desc 获取参数处理器中指定名称的短选项参数。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - aOptionName: char 输入参数，指定要获取的短选项参数名称。
 *
 * @return pargs_option_t 返回一个指向指定名称短选项参数的指针。如果未找到匹配的短选项参数，则返回 nil。
 *
 *}
function args_option_short_get(aArgs: pargs_t; aOptionName: char): pargs_option_t; overload;

{**
 * args_option_short_tryGet
 *
 * @desc 尝试获取参数处理器中指定名称的短选项参数。如果找到匹配的短选项参数，则返回该选项。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - aOptionName: char 输入参数，指定要查找的短选项参数名称。
 * - out aOption: pargs_option_t 输出参数，返回找到的短选项参数指针。如果未找到匹配项，则该参数设置为 nil。
 *
 * @return boolean 返回一个布尔值，表示是否成功找到匹配的短选项参数。如果找到匹配项则返回 true，否则返回 false。
 *
 *}
function args_option_short_tryGet(aArgs: pargs_t; aOptionName: char; out aOption: pargs_option_t): boolean;

{**
 * args_option_short_tryGetValue
 *
 * @desc 尝试获取参数处理器中指定名称的短选项参数的值。如果找到匹配的短选项参数，则返回该选项的值。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - aOptionName: char 输入参数，指定要查找的短选项参数名称。
 * - out aValue: string 输出参数，返回找到的短选项参数的值。如果未找到匹配项，则该参数设置为空字符串。
 *
 * @return boolean 返回一个布尔值，表示是否成功找到匹配的短选项参数的值。如果找到匹配项则返回 true，否则返回 false。
 *
 *}
function args_option_short_tryGetValue(aArgs: pargs_t; aOptionName: char; out aValue: string): boolean;

{**
 * args_option_long_has
 *
 * @desc 检查参数处理器中是否存在指定名称的长选项参数。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - const aOptionName: string 输入参数，指定要检查的长选项参数名称。
 *
 * @return boolean 返回一个布尔值，表示是否存在匹配的长选项参数。如果找到匹配的长选项参数则返回 true，否则返回 false。
 *
 *}
function args_option_long_has(aArgs: pargs_t; const aOptionName: string): boolean;


{**
 * args_option_long_get
 *
 * @desc 获取参数处理器中指定名称的长选项参数。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - const aOptionName: string 输入参数，指定要获取的长选项参数名称。
 *
 * @return pargs_option_t 返回一个指向指定名称长选项参数的指针。如果未找到匹配的长选项参数，则返回 nil。
 *
 *}
function args_option_long_get(aArgs: pargs_t; const aOptionName: string): pargs_option_t; overload;

{**
 * args_option_long_tryGet
 *
 * @desc 尝试获取参数处理器中指定名称的长选项参数。如果找到匹配的长选项参数，则返回该选项。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - const aOptionName: string 输入参数，指定要查找的长选项参数名称。
 * - out aOption: pargs_option_t 输出参数，返回找到的长选项参数指针。如果未找到匹配项，则该参数设置为 nil。
 *
 * @return boolean 返回一个布尔值，表示是否成功找到匹配的长选项参数。如果找到匹配项则返回 true，否则返回 false。
 *
 *}
function args_option_long_tryGet(aArgs: pargs_t; const aOptionName: string; out aOption: pargs_option_t): boolean;

{**
 * args_option_long_tryGetValue
 *
 * @desc 尝试获取参数处理器中指定名称的长选项参数的值。如果找到匹配的长选项参数，则返回该选项的值。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - const aOptionName: string 输入参数，指定要查找的长选项参数名称。
 * - out aValue: string 输出参数，返回找到的长选项参数的值。如果未找到匹配项，则该参数设置为空字符串。
 *
 * @return boolean 返回一个布尔值，表示是否成功找到匹配的长选项参数的值。如果找到匹配项则返回 true，否则返回 false。
 *
 *}
function args_option_long_tryGetValue(aArgs: pargs_t; const aOptionName: string; out aValue: string): boolean;

{**
 * args_enum
 *
 * @desc 枚举参数处理器中的解析项，并通过回调函数处理每个解析项。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - aEnumCB: args_enumCB_t 输入参数，枚举回调函数，用于处理每个解析项。
 * - aData: Pointer 可选参数，额外传递的数据，默认为 nil。回调函数可以使用这些数据进行额外的处理。
 * - aTypeSet: arg_type_set_t 可选参数，要枚举的解析项类型集合，默认为枚举所有类型的解析项。可以指定特定的类型集合进行枚举。
 *
 *}
procedure args_enum(aArgs: pargs_t; aEnumCB: args_enumCB_t; aData: Pointer = nil; aTypes: args_type_set_t = at_all);

{**
 * args_arg_enum
 *
 * @desc 枚举参数处理器中的解析参数，并通过回调函数处理每个解析参数。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - aEnumCB: args_arg_enumCB_t 输入参数，枚举回调函数，用于处理每个解析参数。
 * - aData: Pointer 可选参数，额外传递的数据，默认为 nil。回调函数可以使用这些数据进行额外的处理。
 *
 *}
procedure args_arg_enum(aArgs: pargs_t; aEnumCB: args_arg_enumCB_t; aData: Pointer = nil);

{**
 * args_option_enum
 *
 * @desc 枚举参数处理器中的所有选项，并通过回调函数处理每个选项。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - aEnumCB: args_option_enumCB_t 输入参数，枚举回调函数，用于处理每个解析项。
 * - aData: Pointer 可选参数，额外传递的数据，默认为 nil。回调函数可以使用这些数据进行额外的处理。
 *
 *}
procedure args_option_enum(aArgs: pargs_t; aEnumCB: args_option_enumCB_t; aData: Pointer = nil);

{**
 * args_options_short_enum
 *
 * @desc 枚举参数处理器中的所有短选项，并通过回调函数处理每个短选项。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - aEnumCB: args_option_enumCB_t 输入参数，枚举回调函数，用于处理每个短选项。
 * - aData: Pointer 可选参数，额外传递的数据，默认为 nil。回调函数可以使用这些数据进行额外的处理。
 *
 *}
procedure args_option_short_enum(aArgs: pargs_t; aEnumCB: args_option_enumCB_t; aData: Pointer = nil);

{**
 * args_option_long_enum
 *
 * @desc 枚举参数处理器中的所有长选项，并通过回调函数处理每个长选项。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。
 * - aEnumCB: args_option_enumCB_t 输入参数，枚举回调函数，用于处理每个长选项。
 * - aData: Pointer 可选参数，额外传递的数据，默认为 nil。回调函数可以使用这些数据进行额外的处理。
 *
 *}
procedure args_option_long_enum(aArgs: pargs_t; aEnumCB: args_option_enumCB_t; aData: Pointer = nil);

type

  pargs_enumerator_t = ^args_enumerator_t;

  { args_enumerator_t }

  args_enumerator_t = record
    args: pargs_t;
    currentIndex: integer;
    types: args_type_set_t
  end;

{**
 * args_enumerator_init
 *
 * @desc 初始化一个解析项迭代器，用于遍历指定类型的解析项。
 *
 * @params
 * - aEnumerator: pargs_enumerator_t 输入参数，指向迭代器结构的指针。该迭代器将在初始化后用于遍历解析项。
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。迭代器将基于这个参数处理器进行解析项遍历。
 * - aTypes: args_type_set_t 输入参数，指定要迭代的解析项类型集合。可以指定特定类型或所有类型的解析项进行遍历。
 *
 *}
procedure args_enumerator_init(aEnumerator: pargs_enumerator_t; aArgs: pargs_t; aTypes: args_type_set_t);

{**
 * args_enumerator_create
 *
 * @desc 创建并初始化一个解析项迭代器，指定要遍历的解析项类型。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。迭代器将基于这个参数处理器进行解析项遍历。
 * - aTypes: args_type_set_t 可选参数，指定要迭代的解析项类型集合。默认为 `at_all`，即迭代所有类型的解析项。
 *
 * @return pargs_enumerator_t 返回一个指向新创建的迭代器的指针。使用该迭代器可以遍历指定类型的解析项。
 *
 *}
function args_enumerator_create(aArgs: pargs_t; aTypes: args_type_set_t = at_all): pargs_enumerator_t;

{**
 * args_arg_enumerator_create
 *
 * @desc 创建并初始化一个用于遍历参数的迭代器。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。迭代器将基于这个参数处理器进行参数遍历。
 *
 * @return pargs_enumerator_t 返回一个指向新创建的参数迭代器的指针。使用该迭代器可以遍历所有参数。
 *
 *}
function args_arg_enumerator_create(aArgs: pargs_t): pargs_enumerator_t;

{**
 * args_option_enumerator_create
 *
 * @desc 创建并初始化一个用于遍历选项（短选项和长选项）的迭代器。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。迭代器将基于这个参数处理器进行选项遍历。
 *
 * @return pargs_enumerator_t 返回一个指向新创建的选项迭代器的指针。使用该迭代器可以遍历所有选项，包括短选项和长选项。
 *
 *}
function args_option_enumerator_create(aArgs: pargs_t): pargs_enumerator_t;

{**
 * args_option_short_enumerator_create
 *
 * @desc 创建并初始化一个用于遍历短选项的迭代器。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。迭代器将基于这个参数处理器进行短选项遍历。
 *
 * @return pargs_enumerator_t 返回一个指向新创建的短选项迭代器的指针。使用该迭代器可以遍历所有短选项。
 *
 *}
function args_option_short_enumerator_create(aArgs: pargs_t): pargs_enumerator_t;

{**
 * args_option_long_enumerator_create
 *
 * @desc 创建并初始化一个用于遍历长选项的迭代器。
 *
 * @params
 * - aArgs: pargs_t 输入参数，指向参数处理器的指针。迭代器将基于这个参数处理器进行长选项遍历。
 *
 * @return pargs_enumerator_t 返回一个指向新创建的长选项迭代器的指针。使用该迭代器可以遍历所有长选项。
 *
 *}
function args_option_long_enumerator_create(aArgs: pargs_t): pargs_enumerator_t;

{**
 * args_enumerator_destroy
 *
 * @desc 释放并清理迭代器所占用的资源。
 *
 * @params
 * - var aEnumerator: pargs_enumerator_t 迭代器指针，指向需要释放的迭代器。在函数执行后，该指针将被设置为nil。
 *
 *}
procedure args_enumerator_destroy(var aEnumerator: pargs_enumerator_t);

{**
 * args_enumerator_next
 *
 * @desc 使迭代器移动到下一个解析项。
 *
 * @params
 * - aEnumerator: pargs_enumerator_t 迭代器指针，用于遍历解析项的迭代器。
 *
 * @return boolean 返回迭代是否成功。如果成功移动到下一个解析项，返回 true；如果没有更多的解析项，返回 false。
 *
 *}
function args_enumerator_next(aEnumerator: pargs_enumerator_t): boolean;

{**
 * args_enumerator_current
 *
 * @desc 获取当前迭代器指向的解析项。
 *
 * @params
 * - aEnumerator: pargs_enumerator_t 迭代器指针，用于遍历解析项的迭代器。
 *
 * @return pargs_item_t 返回当前迭代的解析项。如果迭代器没有指向有效的解析项，返回 nil。
 *
 *}
function args_enumerator_current(aEnumerator: pargs_enumerator_t): pargs_item_t;

{**
 * args_arg_enumerator_current
 *
 * @desc 获取当前迭代器指向的参数名称。
 *
 * @params
 * - aEnumerator: pargs_enumerator_t 迭代器指针，用于遍历参数的迭代器。
 *
 * @return string 返回当前迭代的参数名称。如果迭代器没有指向有效的参数，返回空字符串。
 *
 *}
function args_arg_enumerator_current(aEnumerator: pargs_enumerator_t): string;

{**
 * args_option_enumerator_current
 *
 * @desc 获取当前迭代器指向的参数选项。
 *
 * @params
 * - aEnumerator: pargs_enumerator_t 迭代器指针，用于遍历参数选项的迭代器。
 *
 * @return pargs_option_t 返回当前迭代的参数选项。如果迭代器没有指向有效的选项，返回 nil。
 *
 *}
function args_option_enumerator_current(aEnumerator: pargs_enumerator_t): pargs_option_t;


type
  TArgs = class;

  { TArgsEnumerator }

  TArgsEnumerator = class
  private
    FEnumerator: args_enumerator_t;
  public
    constructor Create(aArgs: pargs_t; aTypes: args_type_set_t);

    function GetCurrent: pargs_item_t;
    function MoveNext: boolean;
    property Current: pargs_item_t read GetCurrent;
  end;

  { TArgsArgEnumerator }

  TArgsArgEnumerator = class
  private
    FEnumerator: args_enumerator_t;
  public
    constructor Create(aArgs: pargs_t);

    function GetCurrent: string;
    function MoveNext: boolean;
    property Current: string read GetCurrent;
  end;

  { TArgsOptionEnumerator }

  TArgsOptionEnumerator = class
  private
    FEnumerator: args_enumerator_t;
  public
    constructor Create(aArgs: pargs_t; aShort, aLong: boolean);

    function GetCurrent: pargs_option_t;
    function MoveNext: boolean;
    property Current: pargs_option_t read GetCurrent;
  end;


  { IArgs }

  IArgs = interface

    function GetArgc: integer;
    function GetArgs: pargs_t;
    function GetArgv(aIndex: integer): shortstring;
    function GetCount: integer;
    function GetItems(aIndex: integer): pargs_item_t;

    function Has(const aName: string; aTypes: args_type_set_t): boolean; overload;
    function Has(const aName: string): boolean; overload;
    function Get(const aName: string; aTypes: args_type_set_t): pargs_item_t; overload;
    function Get(const aName: string): pargs_item_t; overload;
    function TryGet(const aName: string; out aItem: pargs_item_t; aTypes: args_type_set_t): boolean; overload;
    function TryGet(const aName: string; out aItem: pargs_item_t): boolean; overload;

    function HasArg(const aArg: string): boolean;

    function HasOption(const aOptionName: string): boolean;
    function HasShortOption(aOptionName: char): boolean;
    function HasLongOption(const aOptionName: string): boolean;
    function GetOption(const aOptionName: string): pargs_option_t;
    function GetShortOption(aOptionName: char): pargs_option_t;
    function GetLongOption(const aOptionName: string): pargs_option_t;
    function TryGetOption(const aOptionName: string; out aOption: pargs_option_t): boolean;
    function TryGetShortOption(aOptionName: char; out aOption: pargs_option_t): boolean;
    function TryGetLongOption(const aOptionName: string; out aOption: pargs_option_t): boolean;
    function TryGetOptionValue(const aOptionName: string; out aValue: string): boolean;
    function TryGetShortOptionValue(aOptionName: char; out aValue: string): boolean;
    function TryGetLongOptionValue(const aOptionName: string; out aValue: string): boolean;

    function GetEnumerator: TArgsEnumerator; inline;
    function GetArgEnumerator: TArgsArgEnumerator; inline;
    function GetOptionEnumerator: TArgsOptionEnumerator; inline;
    function GetShortOptionEnumerator: TArgsOptionEnumerator; inline;
    function GetLongOptionEnumerator: TArgsOptionEnumerator; inline;

    property Args: pargs_t read GetArgs;
    property Argc: integer read GetArgc;
    property Argv[aIndex: integer]: shortstring read GetArgv;

    property Count: integer read GetCount;
    property Items[aIndex: integer]: pargs_item_t read GetItems; default;
  end;

  { TArgs }

  TArgs = class(TInterfacedObject, IArgs)
  private
  class var FInstance: TArgs;
  private
    FArgs: pargs_t;
    FArgsOwns: boolean;
    function GetArgs: pargs_t;
    function GetCount: integer;
    function GetItems(aIndex: integer): pargs_item_t;
    function GetArgc: integer;
    function GetArgv(aIndex: integer): shortstring;
  public
    class destructor Destroy;
    class function Global: TArgs;
  public
    constructor Create; overload;
    constructor Create(aArgv: PPAnsiChar; aArgc: integer); overload;
    destructor Destroy; override;

    {**
    * Has
    * @desc 检查是否存在指定名称的解析项或选项。
    *
    * @params
    * - const aName: string 要检查的解析项或选项的名称。
    * - aTypes: args_type_set_t 要检查的解析项类型集合，指定了类型集以进行检查。
    *
    * @return boolean 返回一个布尔值，表示是否存在指定名称的解析项或选项。如果存在，返回 true；否则返回 false。
    *}
    function Has(const aName: string; aTypes: args_type_set_t): boolean; overload;
    function Has(const aName: string): boolean; overload;

    {**
     * Get
     * @desc 获取指定名称和类型的解析项。
     *
     * @params
     * - const aName: string 输入参数，指定要获取的解析项名称。
     * - aTypes: args_type_set_t 输入参数，指定解析项的类型集。
     *
     * @return pargs_item_t 返回匹配的解析项指针。如果没有找到匹配项，返回 nil。
     *}
    function Get(const aName: string; aTypes: args_type_set_t): pargs_item_t; overload;
    function Get(const aName: string): pargs_item_t; overload;

    {**
     * TryGet
     * @desc 尝试获取指定名称和类型的解析项。
     *
     * @params
     * - const aName: string 输入参数，指定要获取的解析项名称。
     * - out aItem: pargs_item_t 输出参数，获取到的解析项指针。
     * - aTypes: args_type_set_t 输入参数，指定解析项的类型集。
     *
     * @return boolean 返回一个布尔值，表示是否成功获取到解析项。如果成功则返回 true，并将解析项指针赋值给 aItem，否则返回 false。
     *}
    function TryGet(const aName: string; out aItem: pargs_item_t; aTypes: args_type_set_t): boolean; overload;
    function TryGet(const aName: string; out aItem: pargs_item_t): boolean; overload;

    {**
     * HasArg
     * @desc 检查参数处理器中是否存在指定名称的参数。
     *
     * @params
     * - const aArg: string 输入参数，指定要检查的参数名称。
     *
     * @return boolean 返回一个布尔值，表示是否存在匹配的参数。如果找到匹配项则返回 true，否则返回 false。
     *}
    function HasArg(const aArg: string): boolean;

    {**
     * HasOption
     * @desc 检查参数处理器中是否存在指定名称的选项参数。
     *
     * @params
     * - const aOptionName: string 输入参数，指定要检查的选项名称。
     *
     * @return boolean 返回一个布尔值，表示是否存在匹配的选项参数。如果找到匹配项则返回 true，否则返回 false。
     *}
    function HasOption(const aOptionName: string): boolean;

    {**
     * HasShortOption
     * @desc 检查参数处理器中是否存在指定名称的短选项。
     *
     * @params
     * - aOptionName: char 输入参数，指定要检查的短选项名称。
     *
     * @return boolean 返回一个布尔值，表示是否存在匹配的短选项。如果找到匹配项则返回 true，否则返回 false。
     *}
    function HasShortOption(aOptionName: char): boolean;

    {**
     * HasLongOption
     * @desc 检查参数处理器中是否存在指定名称的长选项。
     *
     * @params
     * - const aOptionName: string 输入参数，指定要检查的长选项名称。
     *
     * @return boolean 返回一个布尔值，表示是否存在匹配的长选项。如果找到匹配项则返回 true，否则返回 false。
     *}
    function HasLongOption(const aOptionName: string): boolean;

    {**
     * GetOption
     * @desc 获取指定名称的选项参数。
     *
     * @params
     * - const aOptionName: string 输入参数，指定要获取的选项名称。
     *
     * @return pargs_option_t 返回匹配的选项参数。如果没有找到匹配项，返回 nil。
     *}
    function GetOption(const aOptionName: string): pargs_option_t;

    {**
     * GetShortOption
     * @desc 获取指定名称的短选项参数。
     *
     * @params
     * - aOptionName: char 输入参数，指定要获取的短选项名称。
     *
     * @return pargs_option_t 返回匹配的短选项参数。如果没有找到匹配项，返回 nil。
     *}
    function GetShortOption(aOptionName: char): pargs_option_t;

    {**
     * GetLongOption
     * @desc 获取指定名称的长选项参数。
     *
     * @params
     * - const aOptionName: string 输入参数，指定要获取的长选项名称。
     *
     * @return pargs_option_t 返回匹配的长选项参数。如果没有找到匹配项，返回 nil。
     *}
    function GetLongOption(const aOptionName: string): pargs_option_t;

    {**
     * TryGetOption
     * @desc 尝试获取指定名称的选项参数。
     *
     * @params
     * - const aOptionName: string 输入参数，指定要获取的选项名称。
     * - out aOption: pargs_option_t 输出参数，用于返回匹配的选项参数。
     *
     * @return boolean 返回一个布尔值，表示是否成功获取到选项参数。如果成功则返回 true，否则返回 false。
     *}
    function TryGetOption(const aOptionName: string; out aOption: pargs_option_t): boolean;

    {**
     * TryGetShortOption
     * @desc 尝试获取指定名称的短选项参数。
     *
     * @params
     * - aOptionName: char 输入参数，指定要获取的短选项名称。
     * - out aOption: pargs_option_t 输出参数，用于返回匹配的短选项参数。
     *
     * @return boolean 返回一个布尔值，表示是否成功获取到短选项参数。如果成功则返回 true，否则返回 false。
     *}
    function TryGetShortOption(aOptionName: char; out aOption: pargs_option_t): boolean;

    {**
     * TryGetLongOption
     * @desc 尝试获取指定名称的长选项参数。
     *
     * @params
     * - const aOptionName: string 输入参数，指定要获取的长选项名称。
     * - out aOption: pargs_option_t 输出参数，用于返回匹配的长选项参数。
     *
     * @return boolean 返回一个布尔值，表示是否成功获取到长选项参数。如果成功则返回 true，否则返回 false。
     *}
    function TryGetLongOption(const aOptionName: string; out aOption: pargs_option_t): boolean;

    {**
     * TryGetOptionValue
     * @desc 尝试获取指定名称的选项值。
     *
     * @params
     * - const aOptionName: string 输入参数，指定要获取的选项名称。
     * - out aValue: string 输出参数，用于返回匹配选项的值。
     *
     * @return boolean 返回一个布尔值，表示是否成功获取到选项值。如果成功则返回 true，否则返回 false。
     *}
    function TryGetOptionValue(const aOptionName: string; out aValue: string): boolean;

    {**
     * TryGetShortOptionValue
     * @desc 尝试获取指定名称的短选项值。
     *
     * @params
     * - aOptionName: char 输入参数，指定要获取的短选项名称。
     * - out aValue: string 输出参数，用于返回匹配短选项的值。
     *
     * @return boolean 返回一个布尔值，表示是否成功获取到短选项值。如果成功则返回 true，否则返回 false。
     *}
    function TryGetShortOptionValue(aOptionName: char; out aValue: string): boolean;

    {**
     * TryGetLongOptionValue
     * @desc 尝试获取指定名称的长选项值。
     *
     * @params
     * - const aOptionName: string 输入参数，指定要获取的长选项名称。
     * - out aValue: string 输出参数，用于返回匹配长选项的值。
     *
     * @return boolean 返回一个布尔值，表示是否成功获取到长选项值。如果成功则返回 true，否则返回 false。
     *}
    function TryGetLongOptionValue(const aOptionName: string; out aValue: string): boolean;

    {**
     * GetEnumerator
     * @desc 获取参数处理器的枚举器，用于遍历解析项。
     *
     * @return TArgsEnumerator 返回一个枚举器对象，允许遍历当前参数处理器中的解析项。
     *
     *}
    function GetEnumerator: TArgsEnumerator; inline;

    {**
     * GetArgEnumerator
     * @desc 获取用于遍历参数的枚举器。
     *
     * @return TArgsArgEnumerator 返回一个枚举器对象，允许遍历当前参数处理器中的参数。
     *
     *}
    function GetArgEnumerator: TArgsArgEnumerator; inline;

    {**
     * GetOptionEnumerator
     * @desc 获取用于遍历选项的枚举器。
     *
     * @return TArgsOptionEnumerator 返回一个枚举器对象，允许遍历当前参数处理器中的选项。
     *
     *}
    function GetOptionEnumerator: TArgsOptionEnumerator; inline;

    {**
     * GetShortOptionEnumerator
     * @desc 获取用于遍历短选项的枚举器。
     *
     * @return TArgsOptionEnumerator 返回一个枚举器对象，允许遍历当前参数处理器中的短选项。
     *
     *}
    function GetShortOptionEnumerator: TArgsOptionEnumerator; inline;

    {**
     * GetLongOptionEnumerator
     * @desc 获取用于遍历长选项的枚举器。
     *
     * @return TArgsOptionEnumerator 返回一个枚举器对象，允许遍历当前参数处理器中的长选项。
     *
     *}
    function GetLongOptionEnumerator: TArgsOptionEnumerator; inline;

    property Args: pargs_t read GetArgs;
    property Argc: integer read GetArgc;
    property Argv[aIndex: integer]: shortstring read GetArgv;

    property Count: integer read GetCount;
    property Items[aIndex: integer]: pargs_item_t read GetItems; default;

  end;

// 全局 Args对象
function Args: TArgs;

// 构造一个 Args 接口
function MakeArgs(aArgv: PPAnsiChar; aArgc: integer): IArgs;

implementation

var
  _args: pargs_t = nil;

procedure args_strToArgv(const aStr, aParam0: ansistring; out aArgv: PPAnsiChar; out aArgc: integer);
label
  label_last;
var
  LP, LPTmp, LPEnd: pansichar;
  LLen: SizeInt;
  LPArgv: PPAnsiChar;
  LTokenSize: PtrInt;
begin
  aArgc := 1;
  LLen := Length(aStr);

  if LLen > 0 then
    Inc(aArgc)
  else
    goto label_last;

  LP := pansichar(aStr);
  LPTmp := StrScan(LP, ' ');
  while LPTmp <> nil do
  begin
    Inc(aArgc);
    LPTmp := StrScan(LPTmp + 1, ' ');
  end;

  aArgv := GetMem(aArgc * sizeof(pansichar));
  LPArgv := aArgv;
  Inc(LPArgv);
  LPTmp := StrScan(LP, ' ');
  while LPTmp <> nil do
  begin
    LTokenSize := PtrInt(LPTmp - LP);
    LPArgv^ := StrAlloc(LTokenSize + 1);
    StrLCopy(LPArgv^, LP, LTokenSize);
    Inc(LPArgv);

    Inc(LPTmp);
    LP := LPTmp;
    LPTmp := StrScan(LP, ' ');
  end;

  LPEnd := strend(LP);
  if LP < LPEnd then
  begin
    LTokenSize := PtrInt(LPEnd - LP);
    LPArgv^ := StrAlloc(LTokenSize + 1);
    StrCopy(LPArgv^, LP);
  end;

  label_last:
  begin
    aArgv^ := StrAlloc(Length(aParam0) + 1);
    StrCopy(aArgv^, pansichar(aParam0));
  end;
end;

procedure args_argv_free(var aArgv: PPAnsiChar; aArgc: integer);
var
  LPArgv: PPAnsiChar;
  i: integer;
begin
  if aArgc > 0 then
  begin
    LPArgv := aArgv;
    for i := 0 to Pred(aArgc) do
    begin
      StrDispose(LPArgv^);
      Inc(LPArgv);
    end;
    Freemem(aArgv);
  end;
end;

procedure args_parse(aArgs: pargs_t);
const
  GROW_SIZE = 16;
var
  i, LArgsSize, LFreeOptionIndex, LLen, LLenTmp, i2: integer;
  LArgStr: string;
  LArg, LFreeOption: pargs_item_t;
  LP, LPTmp: pansichar;
  LPLen: SizeInt;
  LLikeLongOption, LUnixStyle: boolean;

  procedure argsGrow;
  begin
    Inc(LArgsSize, GROW_SIZE);
    SetLength(aArgs^.items, LArgsSize);
  end;

  procedure IncSize;
  begin
    Inc(LLen);
    if LLen = LArgsSize then
      argsGrow;
  end;

begin
  if aArgs^.argc > 1 then
  begin
    LLen := 0;
    LFreeOptionIndex := -1;
    LArgsSize := 0;
    argsGrow;

    for i := 1 to Pred(aArgs^.argc) do
    begin
      LP := aArgs^.argv[i];

      if (LP^ = '-') or (LP^ = '/') then
      begin
        if LP^ = '-' then
        begin
          Inc(LP);
          LUnixStyle := True;
          if LP^ = '-' then
          begin
            Inc(LP);
            LLikeLongOption := True;
          end
          else
            LLikeLongOption := False;
        end
        else if LP^ = '/' then
        begin
          Inc(LP);
          LUnixStyle := False;
        end;

        LPLen := StrLen(LP);

        if LPLen = 0 then
          Continue;

        LArg := @aArgs^.items[LLen];

        if LPLen > 1 then
        begin
          LPTmp := StrScan(LP, ansichar('='));

          if LPTmp = nil then
            LPTmp := StrScan(LP, ':');

          if LPTmp <> nil then
          begin
            LLenTmp := LPTmp - LP;
            SetLength(LArg^.Name, LLenTmp);
            Move(LP^, LArg^.Name[1], LLenTmp);

            LArg^.hasValue := True;

            if ((not LUnixStyle) and (LLenTmp > 1)) or (LLikeLongOption and (LUnixStyle)) then
              LArg^.itemType := at_option_long
            else
              LArg^.itemType := at_option_short;

            Inc(LPTmp);
            LArg^.Value := StrPas(LPTmp);
            LFreeOptionIndex := -1;
          end
          else
          begin
            if LUnixStyle and (not LLikeLongOption) then
            begin
              for i2 := 0 to Pred(LPLen) do
              begin
                LArg := @aArgs^.items[LLen];
                LArg^.itemType := at_option_short;
                LArg^.Name := LP^;
                LArg^.hasValue := False;
                Inc(LP);
                IncSize;
              end;
              Continue;
            end
            else
            begin
              LArg^.itemType := at_option_long;
              LArg^.Name := StrPas(LP);
              LArg^.hasValue := False;
              LFreeOptionIndex := LLen;
            end;
          end;
        end
        else
        begin
          LArg^.Name := StrPas(LP);
          LArg^.hasValue := False;

          if LUnixStyle and LLikeLongOption then
            LArg^.itemType := at_option_long
          else
            LArg^.itemType := at_option_short;

          LFreeOptionIndex := LLen;
        end;
        IncSize;
      end
      else
      begin
        LArgStr := StrPas(LP);

        if LArgStr = '' then
          Continue;

        LArg := @aArgs^.items[LLen];

        if (LFreeOptionIndex > -1) then
        begin
          LFreeOption := @aArgs^.items[LFreeOptionIndex];
          LFreeOption^.hasValue := True;
          LFreeOption^.Value := LArgStr;
          LFreeOptionIndex := -1;
        end
        else
        begin
          LArg^.hasValue := False;
          LArg^.itemType := at_arg;
          LArg^.Name := LArgStr;

          IncSize;
        end;
      end;
    end;

    if LLen < LArgsSize then
      SetLength(aArgs^.items, LLen);
  end;
end;

function args_create(aArgv: PPAnsiChar; aArgc: integer): pargs_t;
begin
  New(Result);
  with Result^ do
  begin
    argv := aArgv;
    argc := aArgc;
    items := nil;
    args_parse(Result);
  end;
end;

function args_global: pargs_t;
begin
  if _args = nil then
    _args := args_create(argv, argc);

  Result := _args;
end;

procedure args_destroy(var aArgs: pargs_t);
begin
  SetLength(aArgs^.items, 0);
  Dispose(aArgs);
end;

function args_argc(aArgs: pargs_t): integer;
begin
  Result := aArgs^.argc;
end;

function args_argv(aArgs: pargs_t; aIndex: integer): shortstring;
begin
  Result := aArgs^.argv[aIndex];
end;

function args_getCount(aArgs: pargs_t): integer;
begin
  Result := Length(aArgs^.items);
end;

function args_getByIndex(aArgs: pargs_t; aIndex: integer): pargs_item_t;
begin
  Result := @aArgs^.items[aIndex];
end;

function args_get(aArgs: pargs_t; const aName: string; aTypes: args_type_set_t): pargs_item_t;
var
  LArg: pargs_item_t;
  i: integer;
  LLen: SizeInt;
begin
  Result := nil;
  LLen := Length(aArgs^.items);

  if LLen > 0 then
  begin
    for i := 0 to Pred(LLen) do
    begin
      LArg := @aArgs^.items[I];

      if (LArg^.itemType in aTypes) and SameText(LArg^.Name, aName) then
        exit(LArg);
    end;
  end;
end;

function args_has(aArgs: pargs_t; const aName: string; aTypes: args_type_set_t): boolean;
begin
  Result := (args_get(aArgs, aName, aTypes) <> nil);
end;

function args_tryGet(aArgs: pargs_t; const aName: string; out aItem: pargs_item_t; aTypes: args_type_set_t): boolean;
begin
  aItem := args_get(aArgs, aName, aTypes);
  Result := (aItem <> nil);
end;

function args_arg_has(aArgs: pargs_t; const aArg: string): boolean;
begin
  Result := args_has(aArgs, aArg, [at_arg]);
end;

function args_option_has(aArgs: pargs_t; const aOptionName: string): boolean;
begin
  Result := args_has(aArgs, aOptionName, [at_option_short, at_option_long]);
end;

function args_option_get(aArgs: pargs_t; const aOptionName: string): pargs_option_t;
begin
  Result := pargs_option_t(args_get(aArgs, aOptionName, [at_option_short, at_option_long]));
end;

function args_option_tryGet(aArgs: pargs_t; const aOptionName: string; out aOption: pargs_option_t): boolean;
begin
  Result := args_tryGet(aArgs, aOptionName, pargs_item_t(aOption), [at_option_short, at_option_long]);
end;


function args_option_tryGetValue(aArgs: pargs_t; const aOptionName: string; out aValue: string): boolean;
var
  LValue: pargs_option_t;
begin
  Result := args_option_tryGet(aArgs, aOptionName, LValue) and LValue^.hasValue;
  if Result then
    aValue := LValue^.Value;
end;

function args_option_short_has(aArgs: pargs_t; aOptionName: char): boolean;
begin
  Result := args_has(aArgs, aOptionName, [at_option_short]);
end;

function args_option_short_get(aArgs: pargs_t; aOptionName: char): pargs_option_t;
begin
  Result := pargs_option_t(args_get(aArgs, aOptionName, [at_option_short]));
end;

function args_option_short_tryGet(aArgs: pargs_t; aOptionName: char; out aOption: pargs_option_t): boolean;
begin
  Result := args_tryGet(aArgs, aOptionName, pargs_item_t(aOption), [at_option_short]);
end;

function args_option_short_tryGetValue(aArgs: pargs_t; aOptionName: char; out aValue: string): boolean;
var
  LValue: pargs_option_t;
begin
  Result := args_option_short_tryGet(aArgs, aOptionName, LValue) and LValue^.hasValue;
  if Result then
    aValue := LValue^.Value;
end;

function args_option_long_has(aArgs: pargs_t; const aOptionName: string): boolean;
begin
  Result := args_has(aArgs, aOptionName, [at_option_long]);
end;

function args_option_long_get(aArgs: pargs_t; const aOptionName: string): pargs_option_t;
begin
  Result := pargs_option_t(args_get(aArgs, aOptionName, [at_option_long]));
end;

function args_option_long_tryGet(aArgs: pargs_t; const aOptionName: string; out aOption: pargs_option_t): boolean;
begin
  Result := args_tryGet(aArgs, aOptionName, pargs_item_t(aOption), [at_option_long]);
end;

function args_option_long_tryGetValue(aArgs: pargs_t; const aOptionName: string; out aValue: string): boolean;
var
  LValue: pargs_option_t;
begin
  Result := args_option_long_tryGet(aArgs, aOptionName, LValue) and LValue^.hasValue;
  if Result then
    aValue := LValue^.Value;
end;

procedure args_enum(aArgs: pargs_t; aEnumCB: args_enumCB_t; aData: Pointer; aTypes: args_type_set_t);
var
  LItem: pargs_item_t;
  LContinue: boolean;
  LEnum: args_enumerator_t;
begin
  args_enumerator_init(@LEnum, aArgs, aTypes);

  LContinue := True;
  while args_enumerator_next(@LEnum) do
  begin
    LItem := args_enumerator_current(@LEnum);
    aEnumCB(aArgs, LItem, aData, LContinue);
    if not LContinue then
      Break;
  end;
end;

procedure args_arg_enum(aArgs: pargs_t; aEnumCB: args_arg_enumCB_t; aData: Pointer);
var
  LItem: pargs_item_t;
  LContinue: boolean;
  LEnum: args_enumerator_t;
begin
  args_enumerator_init(@LEnum, aArgs, [at_arg]);

  LContinue := True;
  while args_enumerator_next(@LEnum) do
  begin
    LItem := args_enumerator_current(@LEnum);
    aEnumCB(aArgs, LItem^.Name, aData, LContinue);
    if not LContinue then
      Break;
  end;
end;

procedure args_option_enum_internal(aArgs: pargs_t; aEnumCB: args_option_enumCB_t; aData: Pointer; aShort, aLong: boolean);
var
  LTypes: args_type_set_t;
  LContinue: boolean;
  LEnum: args_enumerator_t;
  LItem: pargs_option_t;
begin
  LTypes := [];

  if aShort then
    Include(LTypes, at_option_short);

  if aLong then
    Include(LTypes, at_option_long);

  args_enumerator_init(@LEnum, aArgs, LTypes);

  LContinue := True;
  while args_enumerator_next(@LEnum) do
  begin
    LItem := args_option_enumerator_current(@LEnum);
    aEnumCB(aArgs, LItem, aData, LContinue);
    if not LContinue then
      Break;
  end;
end;

procedure args_option_enum(aArgs: pargs_t; aEnumCB: args_option_enumCB_t; aData: Pointer);
begin
  args_option_enum_internal(aArgs, aEnumCB, aData, True, True);
end;

procedure args_option_short_enum(aArgs: pargs_t; aEnumCB: args_option_enumCB_t; aData: Pointer);
begin
  args_option_enum_internal(aArgs, aEnumCB, aData, True, False);
end;

procedure args_option_long_enum(aArgs: pargs_t; aEnumCB: args_option_enumCB_t; aData: Pointer);
begin
  args_option_enum_internal(aArgs, aEnumCB, aData, False, True);
end;

procedure args_enumerator_init(aEnumerator: pargs_enumerator_t; aArgs: pargs_t; aTypes: args_type_set_t);
begin
  aEnumerator^.args := aArgs;
  aEnumerator^.currentIndex := -1;
  aEnumerator^.types := aTypes;
end;

function args_enumerator_create(aArgs: pargs_t; aTypes: args_type_set_t): pargs_enumerator_t;
begin
  New(Result);
  args_enumerator_init(Result, aArgs, aTypes);
end;

function args_arg_enumerator_create(aArgs: pargs_t): pargs_enumerator_t;
begin
  Result := args_enumerator_create(aArgs, [at_arg]);
end;

function args_option_enumerator_create(aArgs: pargs_t): pargs_enumerator_t;
begin
  Result := args_enumerator_create(aArgs, [at_option_short, at_option_long]);
end;

function args_option_short_enumerator_create(aArgs: pargs_t): pargs_enumerator_t;
begin
  Result := args_enumerator_create(aArgs, [at_option_short]);
end;

function args_option_long_enumerator_create(aArgs: pargs_t): pargs_enumerator_t;
begin
  Result := args_enumerator_create(aArgs, [at_option_long]);
end;

procedure args_enumerator_destroy(var aEnumerator: pargs_enumerator_t);
begin
  Dispose(aEnumerator);
end;

function args_enumerator_next(aEnumerator: pargs_enumerator_t): boolean;
var
  LLen: SizeInt;
  LItem: pargs_item_t;
begin
  LLen := Length(aEnumerator^.args^.items);
  Inc(aEnumerator^.currentIndex);
  while aEnumerator^.currentIndex < LLen do
  begin
    LItem := args_getByIndex(aEnumerator^.args, aEnumerator^.currentIndex);

    if LItem^.itemType in aEnumerator^.types then
      exit(True);

    Inc(aEnumerator^.currentIndex);
  end;

  Result := False;
end;

function args_enumerator_current(aEnumerator: pargs_enumerator_t): pargs_item_t;
begin
  Result := pargs_item_t(@aEnumerator^.args^.items[aEnumerator^.currentIndex]);
end;

function args_arg_enumerator_current(aEnumerator: pargs_enumerator_t): string;
begin
  Result := args_enumerator_current(aEnumerator)^.Name;
end;

function args_option_enumerator_current(aEnumerator: pargs_enumerator_t): pargs_option_t;
begin
  Result := pargs_option_t(args_enumerator_current(aEnumerator));
end;

function Args: TArgs;
begin
  Result := TArgs.Global;
end;

function MakeArgs(aArgv: PPAnsiChar; aArgc: integer): IArgs;
begin
  Result := TArgs.Create(aArgv, aArgc);
end;

{ TArgs }

function TArgs.GetCount: integer;
begin
  Result := args_getCount(FArgs);
end;

function TArgs.GetArgs: pargs_t;
begin
  Result := FArgs;
end;

function TArgs.GetItems(aIndex: integer): pargs_item_t;
begin
  Result := args_getByIndex(FArgs, aIndex);
end;

function TArgs.GetArgc: integer;
begin
  Result := args_argc(FArgs);
end;

function TArgs.GetArgv(aIndex: integer): shortstring;
begin
  Result := args_argv(FArgs, aIndex);
end;

class destructor TArgs.Destroy;
begin
  if FInstance <> nil then
    FInstance.Free;
end;

class function TArgs.Global: TArgs;
begin
  if FInstance = nil then
    FInstance := TArgs.Create;

  Result := FInstance;
end;

constructor TArgs.Create;
begin
  inherited Create;
  FArgs := args_global;
  FArgsOwns := False;
end;

constructor TArgs.Create(aArgv: PPAnsiChar; aArgc: integer);
begin
  inherited Create;
  FArgs := args_create(aArgv, aArgc);
  FArgsOwns := True;
end;

destructor TArgs.Destroy;
begin
  if FArgsOwns then
    args_destroy(FArgs);
  inherited Destroy;
end;

function TArgs.Has(const aName: string; aTypes: args_type_set_t): boolean;
begin
  Result := args_has(FArgs, aName, aTypes);
end;

function TArgs.Has(const aName: string): boolean;
begin
  Result := Has(aName, at_all);
end;

function TArgs.Get(const aName: string; aTypes: args_type_set_t): pargs_item_t;
begin
  Result := args_get(FArgs, aName, aTypes);
end;

function TArgs.Get(const aName: string): pargs_item_t;
begin
  Result := Get(aName, at_all);
end;

function TArgs.TryGet(const aName: string; out aItem: pargs_item_t; aTypes: args_type_set_t): boolean;
begin
  Result := args_tryGet(FArgs, aName, aItem, aTypes);
end;

function TArgs.TryGet(const aName: string; out aItem: pargs_item_t): boolean;
begin
  Result := TryGet(aName, aItem, at_all);
end;

function TArgs.HasArg(const aArg: string): boolean;
begin
  Result := args_arg_has(FArgs, aArg);
end;

function TArgs.HasOption(const aOptionName: string): boolean;
begin
  Result := args_option_has(FArgs, aOptionName);
end;

function TArgs.HasShortOption(aOptionName: char): boolean;
begin
  Result := args_option_short_has(FArgs, aOptionName);
end;

function TArgs.HasLongOption(const aOptionName: string): boolean;
begin
  Result := args_option_long_has(FArgs, aOptionName);
end;

function TArgs.GetOption(const aOptionName: string): pargs_option_t;
begin
  Result := args_option_get(FArgs, aOptionName);
end;

function TArgs.GetShortOption(aOptionName: char): pargs_option_t;
begin
  Result := args_option_short_get(FArgs, aOptionName);
end;

function TArgs.GetLongOption(const aOptionName: string): pargs_option_t;
begin
  Result := args_option_long_get(FArgs, aOptionName);
end;

function TArgs.TryGetOption(const aOptionName: string; out aOption: pargs_option_t): boolean;
begin
  Result := args_option_tryGet(FArgs, aOptionName, aOption);
end;

function TArgs.TryGetShortOption(aOptionName: char; out aOption: pargs_option_t): boolean;
begin
  Result := args_option_short_tryGet(FArgs, aOptionName, aOption);
end;

function TArgs.TryGetLongOption(const aOptionName: string; out aOption: pargs_option_t): boolean;
begin
  Result := args_option_long_tryGet(FArgs, aOptionName, aOption);
end;

function TArgs.TryGetOptionValue(const aOptionName: string; out aValue: string): boolean;
begin
  Result := args_option_tryGetValue(FArgs, aOptionName, aValue);
end;

function TArgs.TryGetShortOptionValue(aOptionName: char; out aValue: string): boolean;
begin
  Result := args_option_short_tryGetValue(FArgs, aOptionName, aValue);
end;

function TArgs.TryGetLongOptionValue(const aOptionName: string; out aValue: string): boolean;
begin
  Result := args_option_long_tryGetValue(FArgs, aOptionName, aValue);
end;

function TArgs.GetEnumerator: TArgsEnumerator;
begin
  Result := TArgsEnumerator.Create(Args, at_all);
end;

function TArgs.GetArgEnumerator: TArgsArgEnumerator;
begin
  Result := TArgsArgEnumerator.Create(Args);
end;

function TArgs.GetOptionEnumerator: TArgsOptionEnumerator;
begin
  Result := TArgsOptionEnumerator.Create(Args, True, True);
end;

function TArgs.GetShortOptionEnumerator: TArgsOptionEnumerator;
begin
  Result := TArgsOptionEnumerator.Create(Args, True, False);
end;

function TArgs.GetLongOptionEnumerator: TArgsOptionEnumerator;
begin
  Result := TArgsOptionEnumerator.Create(Args, False, True);
end;

{ TArgsEnumerator }

constructor TArgsEnumerator.Create(aArgs: pargs_t; aTypes: args_type_set_t);
begin
  inherited Create;
  args_enumerator_init(@FEnumerator, aArgs, aTypes);
end;

function TArgsEnumerator.GetCurrent: pargs_item_t;
begin
  Result := args_enumerator_current(@FEnumerator);
end;

function TArgsEnumerator.MoveNext: boolean;
begin
  Result := args_enumerator_next(@FEnumerator);
end;

{ TArgsArgEnumerator }

constructor TArgsArgEnumerator.Create(aArgs: pargs_t);
begin
  inherited Create;
  args_enumerator_init(@FEnumerator, aArgs, [at_arg]);
end;

function TArgsArgEnumerator.GetCurrent: string;
begin
  Result := args_arg_enumerator_current(@FEnumerator);
end;

function TArgsArgEnumerator.MoveNext: boolean;
begin
  Result := args_enumerator_next(@FEnumerator);
end;

{ TArgsOptionEnumerator }

constructor TArgsOptionEnumerator.Create(aArgs: pargs_t; aShort, aLong: boolean);
var
  LTypes: args_type_set_t;
begin
  inherited Create;
  LTypes := [];

  if aShort then
    Include(LTypes, at_option_short);

  if aLong then
    Include(LTypes, at_option_long);

  args_enumerator_init(@FEnumerator, aArgs, LTypes);
end;

function TArgsOptionEnumerator.GetCurrent: pargs_option_t;
begin
  Result := args_option_enumerator_current(@FEnumerator);
end;

function TArgsOptionEnumerator.MoveNext: boolean;
begin
  Result := args_enumerator_next(@FEnumerator);
end;


finalization
  if _args <> nil then
    args_destroy(_args);

end.
