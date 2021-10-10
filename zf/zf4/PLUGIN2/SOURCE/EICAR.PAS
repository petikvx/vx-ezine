{$A-,B-,D-,E-,F-,G+,I-,L-,N+,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
{$M 65520,200000,655360}
{
Формирование плагина для внесение изменений в файл EICAR-TEST-FILE
}
PROGRAM EICAR;

USES CRT, DOS, ProcLib, DataProc, CRC32, LZH;

CONST
     Block : array [1..4] of Byte = ($C9, $CA, $10, $00);

VAR
   I : Integer;
   f : File;
   CW : Word;
   P1, P2 : Pointer;
   MySize : Word;
   fr : FileRecord;
   Sum : LongInt;
   B : Byte;

{$F+}
function EICARProc (pP, pV, pGV : Pointer; var DR : DataRecord) : Byte;
TYPE
    pPA = ^PA;
    PA = array [1..MaxExtPro] of Pointer;
    pVA = ^VA;
    VA = array [1..MaxExtVar] of Pointer;
    pGA = ^GA;
    GA = array [1..10] of LocalVarType;
VAR
   pProcArray : pPA;
   pVarArray  : pVA;
   pLocVarArr : pGA;
   pLibProc : Pointer;

   I : Integer;
   W, W1 : Word;
   P, P1 : Pointer;
   F : File;

   LibProc : procedure;
   fProc0  : procedure (var F : File);
   fProc1  : procedure (var F : File; FileName : String);
   fProc2  : procedure (var F : File; var Buff; Size : Word);
   fProc3  : procedure (var P : Pointer; Size : Word);
   fProc4  : function (MemAddr, BlockAddr : Pointer;
                       MemSize, BlockSize : Word) : Word;
   fProc5  : procedure (S : String);
   fProc6  : procedure (var S : String);
   fProc7  : function (A, B : Byte) : Byte;
   fProc8  : function (A, B : Integer) : Integer;
   fProc9  : function (A, B : Word) : Word;
   fProc10 : function (Param : Byte) : Byte;
   fProc11 : function (Param : Word) : Word;
   fProc12 : procedure (OldName, NewName : String);
   fProc13 : function (FileName : String) : Boolean;
   fProc14 : function (var F : File) : LongInt;
   fProc15 : procedure (var F : File; NewPos : LongInt);
   fProc16 : function (Drive : Byte) : String;
   fProc17 : procedure (Drive : Byte);
   fProc18 : procedure (var Drives : DrivesSetType);
   fProc19 : function (P : Pointer) : Word;
   fProc20 : function (W : Word) : Byte;
   fProc21 : procedure (Path: String; Attr: Word; var F: SearchRec);
   fProc22 : procedure (var F : File; Size : Word);
   fProc23 : procedure (var SR : SearchRec);

BEGIN
     {Init}
     pProcArray := pP;
     pVarArray  := pV;
     pLocVarArr := pGV;
     {FindFirst}
     pLibProc := pProcArray^[C_FindFirst];
     @fProc21 := Addr(pLibProc^);
     fProc21(DR.LocalVar[1].TString, Archive, DR.LocalVar[1].TSearchRec);
     {I := DosError}
     pLibProc := pVarArray^[c_DosError];
     I := Integer(pLibProc^);
     while I = 0 do begin
           {Assign (f, SR.Name)}
           pLibProc := pProcArray^[C_AssignFile];
           @fProc1 := Addr(pLibProc^);
           fProc1(F, DR.LocalVar[1].TSearchRec.Name);
           {ReSet (f, 1)}
           pLibProc := pProcArray^[C_OpenFileRead];
           @fProc0 := Addr(pLibProc^);
           fProc0(F);
           {S := FileSize (f)}
           pLibProc := pProcArray^[C_FileSize];
           @fProc14 := Addr(pLibProc^);
           DR.LocalVar[1].TLongInt := fProc14 (F);
           W := Word (DR.LocalVar[1].TLongInt);
           {GetMem (P, S)}
           pLibProc := pProcArray^[C_GetMemProc];
           @fProc3 := Addr(pLibProc^);
           fProc3 (P, W);
           {BlockRead (f, P^, S, CR)}
           pLibProc := pProcArray^[C_ReadFromFile];
           @fProc2 := Addr(pLibProc^);
           fProc2 (F, P^, W);
           {P1 := @Block}
           P1 := @DR.Signature.SigCode;
           {CR := _SignOffset (P, P1, 65535, 7)}
           pLibProc := pProcArray^[C_SignOffset];
           @fProc4 := Addr(pLibProc^);
           W1 := fProc4 (P, P1, 65535, DR.Signature.CouSigByte);
           if W1 <> 0 then begin
              {Inc (CR, 2)}
              W1 := W1 + 2;
              {P1 := @NewBlock}
              P1 := @DR.LocalVar[2].TString[1];
              {FileMode := 2}
              pLibProc := pVarArray^[c_FileMode];
              Byte(pLibProc^) := 2;
              {Seek (f, CR)}
              pLibProc := pProcArray^[C_FileSeek];
              @fProc15 := Addr(pLibProc^);
              fProc15 (F, W1);
              {BlockWrite (f, P1^, 35, CR)}
              pLibProc := pProcArray^[C_WriteToFile];
              @fProc2 := Addr(pLibProc^);
              fProc2 (F, P1^, Byte(DR.LocalVar[2].TString[0]));
           end;
           {FreeMem (P, S)}
           pLibProc := pProcArray^[C_FreeMemProc];
           @fProc3 := Addr(pLibProc^);
           fProc3 (P, W);
           {Close (f)}
           pLibProc := pProcArray^[C_CloseFile];
           @fProc0 := Addr(pLibProc^);
           fProc0(F);
           {FindNext (SR)}
           pLibProc := pProcArray^[C_FindNext];
           @fProc23 := Addr(pLibProc^);
           fProc23(DR.LocalVar[1].TSearchRec);
           {I := DosError}
           pLibProc := pVarArray^[c_DosError];
           I := Integer(pLibProc^);
     end;
     EICARProc := _TSOk;
END;
{$F-}

BEGIN
     with fr do begin
          with HR do begin
               RecordSize := 0;
               DataSize   := SizeOf (DataRecord);
               CodeSize   := 0;
               VersionPIN := 1;
               CRCRecord  := 0;
          end;
          with DR do begin
               with Signature do begin
                    SigName := 'EICAR Test File';
                    CouSigByte := 7;
                    SigCode[1] := $37;
                    SigCode[2] := $7D;
                    SigCode[3] := $24;
                    SigCode[4] := $45;
                    SigCode[5] := $49;
                    SigCode[6] := $43;
                    SigCode[7] := $41;
               end;
               CouLocVar := 2;
               with LocalVar[1] do begin
                    TypeVar := _TVString;
                    TString := '*.com';
               end;
               with LocalVar[2] do begin
                    TypeVar := _TVString;
                    TString := 'Поздравляю всех с Новым 2001 годом';
               end;
          end;
     end;
     {Test}
     InitProcLib;
     InitVarLib;
     EICARProc (@pProcLib, @pVarLib, @GlobalVar, fr.DR);
     {Write}
     Assign (f, 'CODE.BIN');
     ReWrite (f, 1);
     P1 := @EICARProc;
     P2 := @Block;
     MySize := _SignOffset (P1^, P2^, 65535, 4) + 3;
     BlockWrite (f, P1^, MySize, CW);
     Close (f);
     Assign (f, 'DATA.BIN');
     ReWrite (f, 1);
     BlockWrite (f, fr.DR, SizeOf (DataRecord), CW);
     Close (f);
     Sum := 0;
     B := 0;
     Assign (f, 'DATA.BIN');
     ReSet (f, 1);
     repeat
           BlockRead (f, B, 1, CW);
           if CW = 0 then Break;
           Sum := crc_32 (B, Sum);
     until False;
     Close (f);
     Assign (f, 'CODE.BIN');
     ReSet (f, 1);
     fr.HR.CodeSize := FileSize (f);
     fr.HR.RecordSize := SizeOf (HeaderRecord) +  SizeOf (DataRecord) +
                         fr.HR.CodeSize;
     repeat
           BlockRead (f, B, 1, CW);
           if CW = 0 then Break;
           Sum := crc_32 (B, Sum);
     until False;
     Close (f);
     Sum := crcend(Sum);
     fr.HR.CRCRecord := Sum;
     Assign (f, 'HEADER.BIN');
     ReWrite (f, 1);
     BlockWrite (f, fr.HR, SizeOf (HeaderRecord), CW);
     Close (f);
     Assign (f, 'EICAR.BIN');
     ReWrite (f, 1);
     BlockWrite (f, fr.HR, SizeOf (HeaderRecord), CW);
     BlockWrite (f, fr.DR, SizeOf (DataRecord), CW);
     P1 := @EICARProc;
     BlockWrite (f, P1^, MySize, CW);
     Close (f);
     main ('E', 'EICAR.BIN', 'EICAR.SIG'); {E-Encrypt; D-decrypt}
END.
