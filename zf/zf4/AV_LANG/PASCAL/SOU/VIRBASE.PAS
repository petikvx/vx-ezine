Unit VirBase;

INTERFACE

CONST
     KnownViruses = 2; {Сколько записей реализовано}
     MaxPartBeg = 3;   {максимальное количество записей}
     MaxLengthS = 20;  {максимальная длина сигнатуры}

     TypeBeg = 0; {запись в начало файла со сдвигом кода}
     TypeMov = 1; {запись в начало файла с переносом кода}
     TypeAdd = 2; {запись в середину файла в область повторяющихся байт}
     TypeIns = 3; {запись в середину файла с переносом кода}
     TypeEnd = 4; {запись в конец файла}
     TypeOvr = 5; {запись замещением кода}
     TypeSat = 6; {компаньон}
     TypeUep = 7; {запись в конец с использованием технологии UEP}

     DisinfNo  = 0;
     DisinfYes = 1;

     CryptNone  = 0; {незашифрованный}
     CryptByte0 = 1; {add byte ptr xx:[yy],bCode}
     CryptByte1 = 2; {sub byte ptr xx:[yy],bCode}
     CryptByte2 = 3; {xor byte ptr xx:[yy],bCode}
     CryptWord0 = 4; {add word ptr xx:[yy],wCode}
     CryptWord1 = 5; {sub word ptr xx:[yy],wCode}
     CryptWord2 = 6; {xor word ptr xx:[yy],wCode}

     CouRecords    : LongInt = 0; {количество подключенных записей}
     CouFileFound  : LongInt = 0; {количество найденных файлов}
     CouFileInfect : LongInt = 0; {количество инфицированных файлов}
     CouFileDesinf : LongInt = 0; {количество вылеченных файлов}
     CouFileErased : LongInt = 0; {количество удаленных файлов}
     CouVirusFind  : LongInt = 0; {количество найденных вирусов}
     CouVirusSkip  : LongInt = 0; {пропущено вирусов}
     CouErrorFile  : LongInt = 0; {пропущено из-за ошибки}

TYPE
    TString40 = String[40];

    PArraySig = array [1..20] of Byte;

    TSigInfo = record
             SigOffset  : Word;          {зарезервировано}
             SigLength  : Word; {размер сигнатуры}
             SigArray   : PArraySig;     {сигнатура}
    end;

    TBegInfo = record
             BytesOffset : Word;    {смещение части}
             BytesLength : Byte;    {размер части}
             BytesCrypt  : Byte;    {признак шифрации}
             CodeOffset  : Word;    {смещение кода шифра}
             SourceOffs  : Word;    {смещение оригинальных байт}
    end;

    TBytesInfo = array [1..MaxPartBeg] of TBegInfo;

    TCrypto = record
            TypeCryptCode : Byte;    {0 - меняющийся код, 1 - постоянный}
            ConstCrypCodW : Word;    {код в слово}
            ConstCrypCodB : Byte;    {код в байт}
            CodeOffset    : Word;    {смещение меняющегося кода}
            BegOfCrypt    : Word;    {начало зашифрованного фрагмента}
            LengthCrypt   : Word;    {длина зашифрованного фрагмента}
    end;

    TSignature = packed record
               Init        : Procedure;
               VirName     : TString40; {название вируса}
               VirLength   : Word;      {длина вируса}
               TypeWrt     : Byte;      {тип записи в файл}
               Desinfect   : Byte;   {возможность дезинфекции}
               CryptInfo   : Byte;      {описание шифрации}
               Crypto      : TCrypto;   {описание для зашифрованного виря}
               Sig1Info    : TSigInfo;  {первая сигнатура}
               Sig2Info    : TSigInfo;  {вторая сигнатура}
               VirBegOffs  : Word;      {смещение начала кода вируса}
               BytesPartCo : Byte;      {количество частей начальных байт}
               BytesPartIn : TBytesInfo; {описание частей с начальными байтами}
               TypeSat     : Boolean;   {меняет: 0 - имя, 1 - расширение}
               Name        : String;    {имя для саттелита}
               Extension   : String[3]; {расширение для саттелита}
               CouFind     : LongInt;   {количество вхождений}
    end;

VAR
    Signature : array [1..KnownViruses] of TSignature;
    Initialize : array [1..KnownViruses] of Procedure;

function UpStr (S : String) : String;
procedure InitRecords;

procedure KhizhnjakFill;
procedure RedArc112;

IMPLEMENTATION

procedure InitRecordsP;
begin
     Signature[1].Init := KhizhnjakFill;
     Signature[2].Init := RedArc112;
end;

procedure InitRecords;
var
   i : integer;
begin
     InitRecordsP;
     for i := 1 to KnownViruses do
         Signature[i].Init
end;

function UpStr (S : String) : String;
var
   i : integer;
   S1 : String;
begin
     S1 := S;
     for i := 1 to Length (S) do
         S1[i] := UpCase (S[i]);
     UpStr := S1;
end;

procedure KhizhnjakFill;
begin
     with Signature [1] do begin
          VirName   := 'Khizhnjak.452';
          VirLength := 452;
          TypeWrt   := TypeEnd;
          Desinfect := DisinfYes;
          CryptInfo := CryptNone;
          with Sig1Info do begin
               SigOffset := 0;
               SigLength := 7;
               SigArray[1] := $A0;
               SigArray[2] := $39;
               SigArray[3] := $02;
               SigArray[4] := $2E;
               SigArray[5] := $A2;
               SigArray[6] := $00;
               SigArray[7] := $01;
          end;
          with Sig2Info do begin
               SigOffset := $CC;
               SigLength := 9;
               SigArray[1] := $72;
               SigArray[2] := $36;
               SigArray[3] := $80;
               SigArray[4] := $3E;
               SigArray[5] := $D2;
               SigArray[6] := $02;
               SigArray[7] := $37;
               SigArray[8] := $75;
               SigArray[9] := $03;
          end;
          VirBegOffs := 8;
          BytesPartCo := 1;
          with BytesPartIn[1] do begin
               BytesOffset := $121;
               BytesLength := 3;
               BytesCrypt  := CryptNone;
               SourceOffs  := 0;
          end;
          CouFind := 0;
     end;
     Inc (CouRecords);
end;

procedure RedArc112;
begin
     with Signature [2] do begin
          VirName   := 'RedArc.112';
          VirLength := 112;
          TypeWrt   := TypeBeg;
          Desinfect := DisinfYes;
          CryptInfo := CryptNone;
          with Sig1Info do begin
               SigOffset := 0;
               SigLength := 12;
               SigArray[1] := $53;
               SigArray[2] := $68;
               SigArray[3] := $6f;
               SigArray[4] := $6d;
               SigArray[5] := $68;
               SigArray[6] := $2e;
               SigArray[7] := $63;
               SigArray[8] := $68;
               SigArray[9] := $2a;
               SigArray[10] := $3f;
               SigArray[11] := $8b;
               SigArray[12] := $d4;
          end;
          with Sig2Info do begin
               SigOffset := $4b;
               SigLength := 9;
               SigArray[1] := $b4;
               SigArray[2] := $40;
               SigArray[3] := $fe;
               SigArray[4] := $c6;
               SigArray[5] := $cd;
               SigArray[6] := $21;
               SigArray[7] := $55;
               SigArray[8] := $5c;
               SigArray[9] := $cb;
          end;
          VirBegOffs := 0;
          BytesPartCo := 0;
          CouFind := 0;
     end;
     Inc (CouRecords);
end;

BEGIN
     if (ParamCount = 0) or (UpStr(ParamStr (1)) = '/H')
     or (ParamStr (1) = '/?') or (ParamStr (1) = '?') then begin
        WriteLn;
        WriteLn ('USAGE: PASAV.EXE [Drive/Path] [Keys]');
        WriteLn ('       Drive:');
        WriteLn ('             * - Flopy and HDD');
        WriteLn ('             + - only HDD');
        WriteLn ('             - - only Flopy');
        WriteLn ('       Keys:');
        WriteLn ('             /? - this help');
        WriteLn ('             /O - show Ok');
        WriteLn ('             /C - cure mode');
        WriteLn ('             /P - protokol save');
        WriteLn ('Example:');
        WriteLn ('         PASAV.EXE D:\TEST');
        WriteLn ('         PASAV.EXE * /C /O /P');
        WriteLn ('         PASAV.EXE /O /P');
        Halt (0);
     end;
END.
