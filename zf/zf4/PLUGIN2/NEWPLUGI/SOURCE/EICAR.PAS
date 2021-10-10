{$A-,B-,D-,E-,F-,G+,I-,L-,N+,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
{$M 65520,200000,655360}
{
Формирование плагина для внесение изменений в файл EICAR-TEST-FILE
}

PROGRAM EICAR;

USES CRT, DOS, ProcLib, DataProc, CRC32;

CONST
     Block : array [1..4] of Byte = ($C9, $CA, $08, $00);

VAR
   f, f1 : File;
   P1, P2 : Pointer;
   MySize : Word;
   CW : Word;
   Sum : LongInt;
   B : Byte;

{$F+}
function EICARProc (var Env : pTEnvironment; var FR : pFileRecord) : Byte;
BEGIN
     with Env^, LibraryProcedure, FR^.DR, LocalVar[1] do begin
          _FindFirst (TString, Archive, TSearchRec);
          while Integer(LibraryVariable[c_DosError]^) = 0 do begin
                _Assign (TFile, TSearchRec.Name);
                _Reset  (TFile);
                TWord := Word(_FileSize(TFile));
                _GetMem (TPointer, TWord);
                _BlockRead (TFile, TPointer^, TWord);
                LocalVar[2].TPointer := @Signature.SigCode;
                LocalVar[2].TWord := _BlockOffs (TPointer^, LocalVar[2].TPointer^,
                                     TWord, Signature.CouSigByte);
                if LocalVar[2].TWord <> 0 then begin
                   LocalVar[2].TWord := LocalVar[2].TWord + 2;
                   LocalVar[2].TPointer := @LocalVar[2].TString[1];
                   Byte(LibraryVariable[c_FileMode]^) := 2;
                   _Seek (TFile, 0);
                   _Seek (TFile, LocalVar[2].TWord);
                   _BlockWrite (TFile, LocalVar[2].TPointer^, Byte(LocalVar[2].TString[0]));
                end;
                _FreeMem (TPointer, TWord);
                _Close (TFile);
                _FindNext (TSearchRec);
          end;
     end;
     EICARProc := _TSOk;
END;
{$F-}

BEGIN
     InitEnvironment (Environment);
     InitFileRecord  (FileRecord);

     with FileRecord^ do begin
          with HR do begin
               RecordSize := 0;
               DataSize   := SizeOf (DataRecord);
               CodeSize   := 0;
               VersionPIN := 2;
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
     {Write}
     Assign (f, 'CODE.BIN');
     ReWrite (f, 1);
     P1 := @EICARProc;
     P2 := @Block;
     MySize := BlockOffs (P1^, P2^, 65535, 4) + 3;
     BlockWrite (f, P1^, MySize, CW);
     Close (f);
     Assign (f, 'DATA.BIN');
     ReWrite (f, 1);
     BlockWrite (f, FileRecord^.DR, SizeOf (DataRecord), CW);
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
     FileRecord^.HR.CodeSize := FileSize (f);
     FileRecord^.HR.RecordSize := SizeOf (HeaderRecord) +  SizeOf (DataRecord) +
                         FileRecord^.HR.CodeSize;
     repeat
           BlockRead (f, B, 1, CW);
           if CW = 0 then Break;
           Sum := crc_32 (B, Sum);
     until False;
     Close (f);
     Sum := crcend(Sum);
     FileRecord^.HR.CRCRecord := Sum;
     Assign (f, 'HEADER.BIN');
     ReWrite (f, 1);
     BlockWrite (f, FileRecord^.HR, SizeOf (HeaderRecord), CW);
     Close (f);
     Assign (f, 'EICAR.SIG');
     ReWrite (f, 1);
     BlockWrite (f, FileRecord^.HR, SizeOf (HeaderRecord), CW);
     BlockWrite (f, FileRecord^.DR, SizeOf (DataRecord), CW);
     P1 := @EICARProc;
     BlockWrite (f, P1^, MySize, CW);
     Close (f);
END.
