Unit VirBase;

INTERFACE

CONST
     KnownViruses = 2; {����쪮 ����ᥩ ॠ��������}
     MaxPartBeg = 3;   {���ᨬ��쭮� ������⢮ ����ᥩ}
     MaxLengthS = 20;  {���ᨬ��쭠� ����� ᨣ������}

     TypeBeg = 0; {������ � ��砫� 䠩�� � ᤢ���� ����}
     TypeMov = 1; {������ � ��砫� 䠩�� � ��७�ᮬ ����}
     TypeAdd = 2; {������ � �।��� 䠩�� � ������� ����������� ����}
     TypeIns = 3; {������ � �।��� 䠩�� � ��७�ᮬ ����}
     TypeEnd = 4; {������ � ����� 䠩��}
     TypeOvr = 5; {������ ����饭��� ����}
     TypeSat = 6; {������쮭}
     TypeUep = 7; {������ � ����� � �ᯮ�짮������ �孮����� UEP}

     DisinfNo  = 0;
     DisinfYes = 1;

     CryptNone  = 0; {������஢����}
     CryptByte0 = 1; {add byte ptr xx:[yy],bCode}
     CryptByte1 = 2; {sub byte ptr xx:[yy],bCode}
     CryptByte2 = 3; {xor byte ptr xx:[yy],bCode}
     CryptWord0 = 4; {add word ptr xx:[yy],wCode}
     CryptWord1 = 5; {sub word ptr xx:[yy],wCode}
     CryptWord2 = 6; {xor word ptr xx:[yy],wCode}

     CouRecords    : LongInt = 0; {������⢮ ������祭��� ����ᥩ}
     CouFileFound  : LongInt = 0; {������⢮ ��������� 䠩���}
     CouFileInfect : LongInt = 0; {������⢮ ����஢����� 䠩���}
     CouFileDesinf : LongInt = 0; {������⢮ �뫥祭��� 䠩���}
     CouFileErased : LongInt = 0; {������⢮ 㤠������ 䠩���}
     CouVirusFind  : LongInt = 0; {������⢮ ��������� ����ᮢ}
     CouVirusSkip  : LongInt = 0; {�ய�饭� ����ᮢ}
     CouErrorFile  : LongInt = 0; {�ய�饭� ��-�� �訡��}

TYPE
    TString40 = String[40];

    PArraySig = array [1..20] of Byte;

    TSigInfo = record
             SigOffset  : Word;          {��१�ࢨ஢���}
             SigLength  : Word; {ࠧ��� ᨣ������}
             SigArray   : PArraySig;     {ᨣ�����}
    end;

    TBegInfo = record
             BytesOffset : Word;    {ᬥ饭�� ���}
             BytesLength : Byte;    {ࠧ��� ���}
             BytesCrypt  : Byte;    {�ਧ��� ���樨}
             CodeOffset  : Word;    {ᬥ饭�� ���� ���}
             SourceOffs  : Word;    {ᬥ饭�� �ਣ������� ����}
    end;

    TBytesInfo = array [1..MaxPartBeg] of TBegInfo;

    TCrypto = record
            TypeCryptCode : Byte;    {0 - �����騩�� ���, 1 - ����ﭭ�}
            ConstCrypCodW : Word;    {��� � ᫮��}
            ConstCrypCodB : Byte;    {��� � ����}
            CodeOffset    : Word;    {ᬥ饭�� �����饣��� ����}
            BegOfCrypt    : Word;    {��砫� ����஢������ �ࠣ����}
            LengthCrypt   : Word;    {����� ����஢������ �ࠣ����}
    end;

    TSignature = packed record
               Init        : Procedure;
               VirName     : TString40; {�������� �����}
               VirLength   : Word;      {����� �����}
               TypeWrt     : Byte;      {⨯ ����� � 䠩�}
               Desinfect   : Byte;   {����������� �����䥪樨}
               CryptInfo   : Byte;      {���ᠭ�� ���樨}
               Crypto      : TCrypto;   {���ᠭ�� ��� ����஢������ ����}
               Sig1Info    : TSigInfo;  {��ࢠ� ᨣ�����}
               Sig2Info    : TSigInfo;  {���� ᨣ�����}
               VirBegOffs  : Word;      {ᬥ饭�� ��砫� ���� �����}
               BytesPartCo : Byte;      {������⢮ ��⥩ ��砫��� ����}
               BytesPartIn : TBytesInfo; {���ᠭ�� ��⥩ � ��砫�묨 ���⠬�}
               TypeSat     : Boolean;   {�����: 0 - ���, 1 - ���७��}
               Name        : String;    {��� ��� ��⥫��}
               Extension   : String[3]; {���७�� ��� ��⥫��}
               CouFind     : LongInt;   {������⢮ �宦�����}
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
