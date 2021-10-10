{
Данные для работы с внешними подпрограммами
}

UNIT DataProc;

INTERFACE

USES DOS, CRT, PROCLIB;

CONST
     C_AssignFile    = 1;
     C_OpenFileRead  = 2;
     C_OpenFileWrite = 3;
     C_ReadFromFile  = 4;
     C_WriteToFile   = 5;
     C_GetMemProc    = 6;
     C_FreeMemProc   = 7;
     C_SignOffset    = 8;
     C_ClrScr        = 9;
     C_GotoXY        = 10;
     C_ReadKey       = 11;
     C_Sound         = 12;
     C_NoSound       = 13;
     C_FindFirst     = 14;
     C_FindNext      = 15;
     C_Intr          = 16;
     C_MsDos         = 17;
     C_ClrEOL        = 18;
     C_DelLine       = 19;
     C_InsLine       = 20;
     C_Delay         = 21;
     C_KeyPressed    = 22;
     C_WhereX        = 23;
     C_WhereY        = 24;
     C_GetFTime      = 25;
     C_SetFTime      = 26;
     C_GetDate       = 27;
     C_GetTime       = 28;
     C_SetDate       = 29;
     C_SetTime       = 30;
     C_PackTime      = 31;
     C_UnPackTime    = 32;
     C_FExpand       = 33;
     C_FSplit        = 34;
     C_GetFAttr      = 35;
     C_SetFAttr      = 36;
     C_FSearch       = 37;
     C_GetIntVec     = 38;
     C_SetIntVec     = 39;
     C_Exec          = 40;
     C_Keep          = 41;
     C_SwapVectors   = 42;
     C_GetCBreak     = 43;
     C_SetCBreak     = 44;
     C_DosExitCode   = 45;
     C_DosVersion    = 46;
     C_WriteString   = 47;
     C_WriteLnString = 48;
     C_ReadString    = 49;
     C_ReadLnString  = 50;
     C_HighVideo     = 51;
     C_NormVideo     = 52;
     C_LowVideo      = 53;
     C_TextBackGround = 54;
     C_TextColor     = 55;
     C_TextMode      = 56;
     C_MaxByte       = 57;
     C_MaxInteger    = 58;
     C_MaxWord       = 59;
     C_MinByte       = 60;
     C_MinInteger    = 61;
     C_MinWord       = 62;
     C_XorByte       = 63;
     C_XorWord       = 64;
     C_AndByte       = 65;
     C_AndWord       = 66;
     C_NotByte       = 67;
     C_NotWord       = 68;
     C_OrByte        = 69;
     C_OrWord        = 70;
     C_RenameFile    = 71;
     C_EraseFile     = 72;
     C_TruncateFile  = 73;
     C_CopyFile      = 74;
     C_FileExists    = 75;
     C_FileSize      = 76;
     C_FilePos       = 77;
     C_FileSeek      = 78;
     C_Randomize     = 79;
     C_Rnd           = 80;
     C_RmDir         = 81;
     C_ChDir         = 82;
     C_MkDir         = 83;
     C_GetDir        = 84;
     C_ChDrive       = 85;
     C_TestDrives    = 86;
     C_Seg           = 87;
     C_Ofs           = 88;
     C_Hi            = 89;
     C_Lo            = 90;
     C_CloseFile     = 91;
     C_IOResult      = 92;
     C_MemAvail      = 93;
     C_MaxAvail      = 94;

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


     MaxPlugIn = 20; {Максимально возможное количество PlugIn}
     MaxExtPro = 94;  {Максимальное количество библиотечных подпрограмм}
     MaxExtVar = 12;  {Максимальное количество библиотечных переменных}

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

    FileRecord = record
                 HR : HeaderRecord;
                 DR : DataRecord;
    end;

    TEternFunc = function (pP, pV, pGV : Pointer; var DR : DataRecord) : Byte;

    rExtFun = record
            T : Byte;
            P : Pointer;
            S : Word;
            F : FileRecord;
    end;

var
    ExternFunc : array [1..MaxPlugIn] of TEternFunc;
    pExtern    : array [1..MaxPlugIn] of rExtFun;
    pProcLib   : array [1..MaxExtPro] of Pointer;
    pVarLib    : array [1..MaxExtVar] of Pointer;
    CouPlugIn  : byte; {Количество подключенных плагинов}
    GlobalVar  : array [1..10] of LocalVarType; {Глобальные переменные}
    HD         : DrivesSetType;

procedure InitProcLib;
procedure InitVarLib;

IMPLEMENTATION

procedure InitProcLib;
var
   i : integer;
begin
     for i := 1 to MaxExtPro do
         pProcLib[i] := nil;
     pProcLib[C_AssignFile]  := @_AssignFile;
     pProcLib[C_OpenFileRead]  := @_OpenFileRead;
     pProcLib[C_OpenFileWrite]  := @_OpenFileWrite;
     pProcLib[C_ReadFromFile]  := @_ReadFromFile;
     pProcLib[C_WriteToFile]  := @_WriteToFile;
     pProcLib[C_GetMemProc]  := @_GetMemProc;
     pProcLib[C_FreeMemProc]  := @_FreeMemProc;
     pProcLib[C_SignOffset]  := @_SignOffset;
     pProcLib[C_ClrScr]  := @ClrScr;
     pProcLib[C_GotoXY] := @GotoXY;
     pProcLib[C_ReadKey] := @ReadKey;
     pProcLib[C_Sound] := @Sound;
     pProcLib[C_NoSound] := @NoSound;
     pProcLib[C_FindFirst] := @FindFirst;
     pProcLib[C_FindNext] := @FindNext;
     pProcLib[C_Intr] := @Intr;
     pProcLib[C_MsDos] := @MsDos;
     pProcLib[C_ClrEOL] := @ClrEOL;
     pProcLib[C_DelLine] := @DelLine;
     pProcLib[C_InsLine] := @InsLine;
     pProcLib[C_Delay] := @Delay;
     pProcLib[C_KeyPressed] := @KeyPressed;
     pProcLib[C_WhereX] := @WhereX;
     pProcLib[C_WhereY] := @WhereY;
     pProcLib[C_GetFTime] := @GetFTime;
     pProcLib[C_SetFTime] := @SetFTime;
     pProcLib[C_GetDate] := @GetDate;
     pProcLib[C_GetTime] := @GetTime;
     pProcLib[C_SetDate] := @SetDate;
     pProcLib[C_SetTime] := @SetTime;
     pProcLib[C_PackTime] := @PackTime;
     pProcLib[C_UnPackTime] := @UnPackTime;
     pProcLib[C_FExpand] := @FExpand;
     pProcLib[C_FSplit] := @FSplit;
     pProcLib[C_GetFAttr] := @GetFAttr;
     pProcLib[C_SetFAttr] := @SetFAttr;
     pProcLib[C_FSearch] := @FSearch;
     pProcLib[C_GetIntVec] := @GetIntVec;
     pProcLib[C_SetIntVec] := @SetIntVec;
     pProcLib[C_Exec] := @Exec;
     pProcLib[C_Keep] := @Keep;
     pProcLib[C_SwapVectors] := @SwapVectors;
     pProcLib[C_GetCBreak] := @GetCBreak;
     pProcLib[C_SetCBreak] := @SetCBreak;
     pProcLib[C_DosExitCode] := @DosExitCode;
     pProcLib[C_DosVersion] := @DosVersion;
     pProcLib[C_WriteString] := @_WriteString;
     pProcLib[C_WriteLnString] := @_WriteLnString;
     pProcLib[C_ReadString] := @_ReadString;
     pProcLib[C_ReadLnString] := @_ReadLnString;
     pProcLib[C_HighVideo] := @HighVideo;
     pProcLib[C_NormVideo] := @NormVideo;
     pProcLib[C_LowVideo] := @LowVideo;
     pProcLib[C_TextBackGround] := @TextBackGround;
     pProcLib[C_TextColor] := @TextColor;
     pProcLib[C_TextMode] := @TextMode;
     pProcLib[C_MaxByte] := @_MaxByte;
     pProcLib[C_MaxInteger] := @_MaxInteger;
     pProcLib[C_MaxWord] := @_MaxWord;
     pProcLib[C_MinByte] := @_MinByte;
     pProcLib[C_MinInteger] := @_MinInteger;
     pProcLib[C_MinWord] := @_MinWord;
     pProcLib[C_XorByte] := @_XorByte;
     pProcLib[C_XorWord] := @_XorWord;
     pProcLib[C_AndByte] := @_AndByte;
     pProcLib[C_AndWord] := @_AndWord;
     pProcLib[C_NotByte] := @_NotByte;
     pProcLib[C_NotWord] := @_NotWord;
     pProcLib[C_OrByte] := @_OrByte;
     pProcLib[C_OrWord] := @_OrWord;
     pProcLib[C_RenameFile] := @_RenameFile;
     pProcLib[C_EraseFile] := @_EraseFile;
     pProcLib[C_TruncateFile] := @_TruncateFile;
     pProcLib[C_CopyFile] := @_CopyFile;
     pProcLib[C_FileExists] := @_FileExists;
     pProcLib[C_FileSize] := @_FileSize;
     pProcLib[C_FilePos] := @_FilePos;
     pProcLib[C_FileSeek] := @_FileSeek;
     pProcLib[C_Randomize] := @_Randomize;
     pProcLib[C_Rnd] := @_Rnd;
     pProcLib[C_RmDir] := @_RmDir;
     pProcLib[C_ChDir] := @_ChDir;
     pProcLib[C_MkDir] := @_MkDir;
     pProcLib[C_GetDir] := @_GetDir;
     pProcLib[C_ChDrive] := @_ChDrive;
     pProcLib[C_TestDrives] := @_TestDrives;
     pProcLib[C_Seg] := @_Seg;
     pProcLib[C_Ofs] := @_Ofs;
     pProcLib[C_Hi] := @_Hi;
     pProcLib[C_Lo] := @_Lo;
     pProcLib[C_CloseFile] := @_CloseFile;
     pProcLib[C_IOResult]  := @_IOResult;
     pProcLib[C_MemAvail]  := @_MemAvail;
     pProcLib[C_MaxAvail]  := @_MaxAvail;
end;

procedure InitVarLib;
var
   i : integer;
begin
     for i := 1 to MaxExtVar do
         pVarLib[i] := nil;
     pVarLib[c_DosError]    := @DosError;
     pVarLib[c_CheckBreak]  := @CheckBreak;
     pVarLib[c_CheckEOF]    := @CheckEOF;
     pVarLib[c_DirectVideo] := @DirectVideo;
     pVarLib[c_CheckSnow]   := @CheckSnow;
     pVarLib[c_LastMode]    := @LastMode;
     pVarLib[c_TextAttr]    := @TextAttr;
     pVarLib[c_WindMin]     := @WindMin;
     pVarLib[c_FileMode]    := @FileMode;
     pVarLib[c_ExitCode]    := @ExitCode;
     pVarLib[c_Test8086]    := @Test8086;
     pVarLib[c_Test8087]    := @Test8087;
end;

END.
