UNIT DataProc;

INTERFACE

USES DOS, CRT, ProcLib;

CONST
     MaxExtVar = 12;  {Максимальное количество библиотечных переменных}

     c_DosError      = 1;
     c_CheckBreak    = 2;
     c_CheckEOF      = 3;
     c_DirectVideo   = 4;
     c_CheckSnow     = 5;
     c_LastMode      = 6;
     c_TextAttr      = 7;
     c_WindMin       = 8;
     c_FileMode      = 9;
     c_ExitCode      = 10;
     c_Test8086      = 11;
     c_Test8087      = 12;

     {Типы переменных}
     _TVString    = 0;   {- строка}
     _TVByte      = 1;   {- байт}
     _TVInteger   = 2;   {- целое}
     _TVWord      = 3;   {- слово}
     _TVLongInt   = 4;   {- длинное целое}
     _TVPointer   = 5;   {- указатель}
     _TVFile      = 6;   {- файл}
     _TVReal      = 7;   {- вещественное}
     _TVSearchRec = 8;   {- запись для поиска файлов}
     _TVDriveType = 9;   {- множество подключенных дисков}
     _TVChar      = 10;  {- символ}
     _TVBool      = 11;  {- логическая}

     {Типы возвращаемых значений}
     _TSOk  = 0; {Ok}
     _TSErr = 1; {Error}
     _TSCur = 2; {Cure}
     _TSDel = 3; {Delete}

     {Типы подключаемых модулей}
     _teProc1 = 0;
     _teProc2 = 1;
     _teFunc1 = 2;
     _teFunc2 = 3;

     days : array [0..6] of String[9] =
            ('Sunday','Monday','Tuesday', 'Wednesday','Thursday','Friday',
             'Saturday');

TYPE
    Proc0 = procedure;
    Proc1 = procedure (var F : File; FileName : String);
    Proc2 = procedure (var F : File);
    Proc3 = procedure (var F : File; var Buff; Size : Word);
    Proc4 = procedure (var P : Pointer; Size : Word);
    Proc5 = procedure (S : String);
    Proc6 = procedure (var S : String);
    Proc7 = procedure (OldName, NewName : String);
    Proc8 = procedure (var F : File; NewPos : LongInt);
    Proc9 = procedure (Drive : Byte);
    ProcA = procedure (var Drives : DrivesSetType);
    ProcB = procedure (var P : Pointer);
    ProcC = procedure (X, Y : Integer);
    ProcD = procedure (W : Word);
    ProcE = procedure (Path : String; Attr : Word; var SR : SearchRec);
    ProcF = procedure (var SR : SearchRec);
    Proc10= procedure (B : Byte; var R : Registers);
    Proc11= procedure (var R : Registers);
    Proc12= procedure (var F; var Time : LongInt);
    Proc13= procedure (var Year, Month, Day, DayOfWeek: Word);
    Proc14= procedure (Year, Month, Day: Word);
    Proc15= procedure (Hour, Minute, Second, Sec100: Word);
    Proc16= procedure (var T: DateTime; var Time: Longint);
    Proc17= procedure (Time: Longint; var DT: DateTime);
    Proc18= procedure (Path: PathStr; var Dir: DirStr; var Name: NameStr; var Ext: ExtStr);
    Proc19= procedure (var F; var W : Word);
    Proc1A= procedure (var F; W : Word);
    Proc1B= procedure (B : Byte; var P : Pointer);
    Proc1C= procedure (B : Byte; P : Pointer);
    Proc1D= procedure (var B : Boolean);
    Proc1E= procedure (B : Boolean);
    Proc1F= procedure (B : Byte);
    Proc20= procedure (I : Integer);
    Proc21= procedure (var F; Time: Longint);

    Func0 = function : Integer;
    Func1 = function (var MemAddr, BlockAddr; MemSize, BlockSize : Word) : Word;
    Func2 = function (A, B : Byte) : Byte;
    Func3 = function (A, B : Integer) : Integer;
    Func4 = function (A, B : Word) : Word;
    Func5 = function (Param : Byte) : Byte;
    Func6 = function (Param : Word) : Word;
    Func7 = function (FileName : String) : Boolean;
    Func8 = function (var F : File) : LongInt;
    Func9 = function (Drive : Byte) : String;
    FuncA = function (P : Pointer) : Word;
    FuncB = function (W : Word) : Byte;
    FuncC = function : LongInt;
    FuncD = function : Char;
    FuncE = function : Boolean;
    FuncF = function (S : PathStr) : PathStr;
    Func10= function (Path: PathStr; DirList: string): PathStr;
    Func11= function : Word;

    TEnvironmentProc = record
                 {System}
                 _Assign     : Proc1;
                 _ReSet      : Proc2;
                 _ReWrite    : Proc2;
                 _BlockRead  : Proc3;
                 _BlockWrite : Proc3;
                 _GetMem     : Proc4;
                 _FreeMem    : Proc4;
                 _New        : ProcB;
                 _Dispose    : ProcB;
                 _BlockOffs  : Func1;
                 _Write      : Proc5;
                 _WriteLn    : Proc5;
                 _Read       : Proc6;
                 _ReadLn     : Proc6;
                 _MaxB       : Func2;
                 _MaxI       : Func3;
                 _MaxW       : Func4;
                 _MinB       : Func2;
                 _MinI       : Func3;
                 _MinW       : Func4;
                 _XorB       : Func2;
                 _XorW       : Func4;
                 _AndB       : Func2;
                 _AndW       : Func4;
                 _NotB       : Func5;
                 _NotW       : Func6;
                 _OrB        : Func2;
                 _OrW        : Func4;
                 _Rename     : Proc1;
                 _Erase      : Proc2;
                 _Truncate   : Proc2;
                 _FileCopy   : Proc7;
                 _FileExists : Func7;
                 _FileSize   : Func8;
                 _FilePos    : Func8;
                 _Seek       : Proc8;
                 _Randomize  : Proc0;
                 _Random     : Func6;
                 _RmDir      : Proc5;
                 _ChDir      : Proc5;
                 _MkDir      : Proc5;
                 _GetDir     : Func9;
                 _ChDrive    : Proc9;
                 _TestDrives : ProcA;
                 _Seq        : FuncA;
                 _Ofs        : FuncA;
                 _Hi         : FuncB;
                 _Lo         : FuncB;
                 _Close      : Proc2;
                 _IOResult   : Func0;
                 _MemAvail   : FuncC;
                 _MaxAvail   : FuncC;
                 {CRT}
                 _ClrScr     : Proc0;
                 _GotoXY     : ProcC;
                 _ReadKey    : FuncD;
                 _Sound      : ProcD;
                 _NoSound    : Proc0;
                 _KeyPressed : FuncE;
                 _Delay      : ProcD;
                 _ClrEOL     : Proc0;
                 _DelLine    : Proc0;
                 _InsLine    : Proc0;
                 _WhereX     : Func0;
                 _WhereY     : Func0;
                 _HighVideo  : Proc0;
                 _NormVideo  : Proc0;
                 _LowVideo   : Proc0;
                 _TextBackGround : Proc1F;
                 _TextColor  : Proc1F;
                 _TextMode   : Proc20;
                 {DOS}
                 _FindFirst  : ProcE;
                 _FindNext   : ProcF;
                 _Intr       : Proc10;
                 _MsDos      : Proc11;
                 _GetFTime   : Proc12;
                 _SetFTime   : Proc21;
                 _GetDate    : Proc13;
                 _GetTime    : Proc13;
                 _SetDate    : Proc14;
                 _SetTime    : Proc15;
                 _PackTime   : Proc16;
                 _UnPackTime : Proc17;
                 _FExpand    : FuncF;
                 _FSplit     : Proc18;
                 _GetFAttr   : Proc19;
                 _SetFAttr   : Proc1A;
                 _FSearch    : Func10;
                 _GetIntVec  : Proc1B;
                 _SetIntVec  : Proc1C;
                 _Exec       : Proc7;
                 _Keep       : ProcD;
                 _SwapVectors: Proc0;
                 _GetCBreak  : Proc1D;
                 _SetCBreak  : Proc1E;
                 _DosExitCode: Func11;
                 _DosVersion : Func11;
    end;

    TVarLib = array [1..MaxExtVar] of Pointer;

    pTEnvironment = ^TEnvironment;
    TEnvironment = record
                 LibraryProcedure : TEnvironmentProc;
                 LibraryVariable  : TVarLib;
    end;

    HeaderRecord = record
                 RecordSize : Word; {Размер записи}
                 DataSize   : Word; {Размер данных}
                 CodeSize   : Word; {Размер кода}
                 VersionPIN : Word; {Версия плагина}
                 CRCRecord  : LongInt; {Контрольная сумма данных и кода}
    end;

    LocalVarType = record
                 TypeVar       : Byte;         {Тип переменной}
                 TString       : String[80];       {- строка}
                 TByte         : Byte;         {- байт}
                 TInteger      : Integer;      {- целое}
                 TWord         : Word;         {- слово}
                 TLongInt      : LongInt;      {- длинное целое}
                 TPointer      : Pointer;      {- указатель}
                 TFile         : File;         {- файл}
                 TReal         : Real;         {- вещественное}
                 TSearchRec    : SearchRec;    {- запись для поиска файлов}
                 TDriveSetType : DrivesSetType;{- множество подключенных дисков}
                 TChar         : Char;         {- символ}
                 TBoolean      : Boolean;      {- логическая}
    end;

    TSignature = record
                 SigName    : String[80];
                 CouSigByte : Byte;
                 SigCode    : array [1..10] of Byte;
    end;

    DataRecord = record
                 Signature : TSignature;
                 CouLocVar : Byte;
                 LocalVar  : array [1..2] of LocalVarType;
    end;

    pFileRecord = ^TFileRecord;
    TFileRecord = record
                 HR : HeaderRecord;
                 DR : DataRecord;
    end;

   Import = function (var Env : pTEnvironment; var FR : pFileRecord) : Byte;

VAR
   Environment : pTEnvironment;
   FileRecord  : pFileRecord;
   ExternFunc  : Import;

procedure InitEnvironment (var E  : pTEnvironment);
procedure DoneEnvironment (var E  : pTEnvironment);
procedure InitFileRecord  (var FR : pFileRecord);
procedure DoneFileRecord  (var FR : pFileRecord);

IMPLEMENTATION

procedure InitVarLib (var V : TVarLib);
var
   i : integer;
begin
     for i := 1 to MaxExtVar do
         V[i] := nil;
     V[c_DosError]    := @DosError;
     V[c_CheckBreak]  := @CheckBreak;
     V[c_CheckEOF]    := @CheckEOF;
     V[c_DirectVideo] := @DirectVideo;
     V[c_CheckSnow]   := @CheckSnow;
     V[c_LastMode]    := @LastMode;
     V[c_TextAttr]    := @TextAttr;
     V[c_WindMin]     := @WindMin;
     V[c_FileMode]    := @FileMode;
     V[c_ExitCode]    := @ExitCode;
     V[c_Test8086]    := @Test8086;
     V[c_Test8087]    := @Test8087;
end;

procedure InitProcLib (var P : TEnvironmentProc);
begin
     with P do begin
          {System}
          _Assign     := ProcLib._AssignFile;
          _ReSet      := ProcLib._OpenFileRead;
          _ReWrite    := ProcLib._OpenFileWrite;
          _BlockRead  := ProcLib._ReadFromFile;
          _BlockWrite := ProcLib._WriteToFile;
          _GetMem     := ProcLib._GetMemProc;
          _FreeMem    := ProcLib._FreeMemProc;
          _New        := ProcLib._NewMem;
          _Dispose    := ProcLib._DisposeMem;
          _BlockOffs  := ProcLib.BlockOffs{_SignOffset};
          _Write      := ProcLib._WriteString;
          _WriteLn    := ProcLib._WriteLnString;
          _Read       := ProcLib._ReadString;
          _ReadLn     := ProcLib._ReadLnString;
          _MaxB       := ProcLib._MaxByte;
          _MaxI       := ProcLib._MaxInteger;
          _MaxW       := ProcLib._MaxWord;
          _MinB       := ProcLib._MinByte;
          _MinI       := ProcLib._MinInteger;
          _MinW       := ProcLib._MinWord;
          _XorB       := ProcLib._XorByte;
          _XorW       := ProcLib._XorWord;
          _AndB       := ProcLib._AndByte;
          _AndW       := ProcLib._AndWord;
          _NotB       := ProcLib._NotByte;
          _NotW       := ProcLib._NotWord;
          _OrB        := ProcLib._OrByte;
          _OrW        := ProcLib._OrWord;
          _Rename     := ProcLib._RenameFile;
          _Erase      := ProcLib._EraseFile;
          _Truncate   := ProcLib._TruncateFile;
          _FileCopy   := ProcLib._CopyFile;
          _FileExists := ProcLib._FileExists;
          _FileSize   := ProcLib._FileSize;
          _FilePos    := ProcLib._FilePos;
          _Seek       := ProcLib._FileSeek;
          _Randomize  := ProcLib._Randomize;
          _Random     := ProcLib._Rnd;
          _RmDir      := ProcLib._RmDir;
          _ChDir      := ProcLib._ChDir;
          _MkDir      := ProcLib._MkDir;
          _GetDir     := ProcLib._GetDir;
          _ChDrive    := ProcLib._ChDrive;
          _TestDrives := ProcLib._TestDrives;
          _Seq        := ProcLib._Seg;
          _Ofs        := ProcLib._Ofs;
          _Hi         := ProcLib._Hi;
          _Lo         := ProcLib._Lo;
          _Close      := ProcLib._CloseFile;
          _IOResult   := ProcLib._IOResult;
          _MemAvail   := ProcLib._MemAvail;
          _MaxAvail   := ProcLib._MaxAvail;
          {CRT}
          _ClrScr     := CRT.ClrScr;
          _GotoXY     := ProcLib._GotoXY;
          _ReadKey    := ReadKey;
          _Sound      := Sound;
          _NoSound    := NoSound;
          _KeyPressed := KeyPressed;
          _Delay      := Delay;
          _ClrEOL     := ClrEOL;
          _DelLine    := DelLine;
          _InsLine    := InsLine;
          _WhereX     := ProcLib._WhereX;
          _WhereY     := ProcLib._WhereY;
          _HighVideo  := HighVideo;
          _NormVideo  := NormVideo;
          _LowVideo   := LowVideo;
          _TextBackGround := TextBackGround;
          _TextColor  := TextColor;
          _TextMode   := TextMode;
          {DOS}
          _FindFirst  := ProcLib._FindFirst;
          _FindNext   := FindNext;
          _Intr       := Intr;
          _MsDos      := MsDos;
          _GetFTime   := GetFTime;
          _SetFTime   := SetFTime;
          _GetDate    := GetDate;
          _GetTime    := GetTime;
          _SetDate    := SetDate;
          _SetTime    := SetTime;
          _PackTime   := PackTime;
          _UnPackTime := UnPackTime;
          _FExpand    := FExpand;
          _FSplit     := FSplit;
          _GetFAttr   := GetFAttr;
          _SetFAttr   := SetFAttr;
          _FSearch    := FSearch;
          _GetIntVec  := GetIntVec;
          _SetIntVec  := SetIntVec;
          _Exec       := ProcLib._Exec;
          _Keep       := Keep;
          _SwapVectors:= SwapVectors;
          _GetCBreak  := GetCBreak;
          _SetCBreak  := SetCBreak;
          _DosExitCode:= DosExitCode;
          _DosVersion := DosVersion;
     end;
end;

procedure InitEnvironment (var E : pTEnvironment);
begin
     New (E);
     InitVarLib (E^.LibraryVariable);
     InitProcLib (E^.LibraryProcedure);
end;

procedure DoneEnvironment (var E : pTEnvironment);
begin
     Dispose (E);
end;

procedure InitFileRecord  (var FR : pFileRecord);
var
   i : integer;
begin
     New (FR);
{
     with FR^ do begin
          with HR do begin
               RecordSize := 0;
               DataSize   := 0;
               CodeSize   := 0;
               VersionPIN := 0;
               CRCRecord  := 0;
          end;
          with DR do begin
               with Signature do begin
                    SigName    := '';
                    CouSigByte := 0;
                    for i := 1 to 10 do
                        SigCode[i] := 0;
               end;
               CouLocVar := 0;
               for i := 1 to 2 do
                   with LocalVar[i] do begin
                        TypeVar       := _TVString;
                        TString       := '';
                        TByte         := 0;
                        TInteger      := 0;
                        TWord         := 0;
                        TLongInt      := 0;
                        TPointer      := nil;
                        TReal         := 0.0;
                        TChar         := #0;
                        TBoolean      := False;
                   end;
          end;
     end;
}
end;

procedure DoneFileRecord  (var FR : pFileRecord);
begin
     Dispose (FR);
end;

END.
