{$A-,B-,D-,E-,F-,G+,I-,L-,N+,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
{$M 65520,200000,655360}
{
Менеджер для запуска плагинов
}
PROGRAM MANAGER;

USES CRT, DOS, ProcLib, DataProc, CRC32, LZH;

CONST
     PlugInVersion = 1;

VAR
   SR : SearchRec;
   GError : Byte;
   P : Pointer;
   fr : FileRecord;
   f : file;
   Dir : DirStr;
   Nam : NameStr;
   Ext : ExtStr;
   S : String;
   CR : Word;
   Sum : LongInt;
   B : Byte;
   ArrByteWrite : array [1..400] of Byte;

procedure EraseFile (var f : file);
var
   i : integer;
begin
     for i := 5 to 400 do
         ArrByteWrite[i] := 55 + Random (200);
     ArrByteWrite[1] := Byte (Ord ('D'));
     ArrByteWrite[2] := Byte (Ord ('e'));
     ArrByteWrite[3] := Byte (Ord ('a'));
     ArrByteWrite[4] := Byte (Ord ('d'));
     ReWrite (f, 1);
     BlockWrite (f, ArrByteWrite, SizeOf (ArrByteWrite), CR);
     Close (f);
     Erase (f);
end;

function TestSig (FileName : String) : Boolean;
begin
     FSplit (FileName, Dir, Nam, Ext);
     S := Dir + Nam + '.bin';
     Assign (f, FileName);
     ReSet (f, 1);
     if IOResult <> 0 then begin
        GError := 0;
        TestSig := False;
        Exit;
     end;
     Close (f);
     main ('D', FileName, S);
     Assign (f, S);
     ReSet (f, 1);
     if FileSize (f) < SizeOf (FileRecord) then begin
        Close (f);
        EraseFile (f);
        GError := 1;
        TestSig := False;
        Exit;
     end;
     BlockRead (f, fr, SizeOf(FileRecord), CR);
     if fr.HR.RecordSize <> FileSize (f) then begin
        Close (f);
        EraseFile (f);
        GError := 3;
        TestSig := False;
        Exit;
     end;
     Close (f);
     ReSet (f, 1);
     Seek (f, SizeOf(HeaderRecord));
     Sum := 0;
     B := 0;
     repeat
           BlockRead (f, B, 1, CR);
           if CR = 0 then Break;
           Sum := crc_32 (B, Sum);
     until False;
     Sum := crcend(Sum);
     if fr.HR.CRCRecord <> Sum then begin
        Close (f);
        EraseFile (f);
        GError := 2;
        TestSig := False;
        Exit;
     end;
     if fr.HR.DataSize <> SizeOf(FileRecord) - SizeOf(HeaderRecord) then begin
        Close (f);
        EraseFile (f);
        GError := 3;
        TestSig := False;
        Exit;
     end;
     if fr.HR.CodeSize <> FileSize (f) - SizeOf(FileRecord) then begin
        Close (f);
        EraseFile (f);
        GError := 3;
        TestSig := False;
        Exit;
     end;
     if fr.HR.VersionPIN <> PlugInVersion then begin
        Close (f);
        EraseFile (f);
        GError := 4;
        TestSig := False;
        Exit;
     end;
     Close (f);
     TestSig := True;
end;

BEGIN
     Randomize;
     CouPlugIn := 0;
     ClrScr;
     WriteLn ('PlugIn-Manager v.1.0');
     WriteLn ('Example for ZF (c) 2001 by RedArc');
     WriteLn;
     InitProcLib;
     InitVarLib;
     FindFirst ('*.sig', Archive, SR);
     while DosError = 0 do begin
           Write (SR.Name, ' - ');
           if TestSig (SR.Name) then begin
              GetMem (P, fr.HR.CodeSize);
              Assign (f, S);
              ReSet (f, 1);
              Seek (f, SizeOf (FileRecord));
              BlockRead (f, P^, fr.HR.CodeSize, CR);
              if (fr.HR.CodeSize <> CR) or (CR = 0) then begin
                 WriteLn ('файл испорчен');
                 FreeMem (P, fr.HR.CodeSize);
              end else begin
                 Inc (CouPlugIn);
                 pExtern[CouPlugIn].T := _teFunc1;
                 pExtern[CouPlugIn].P := Addr(P^);
                 pExtern[CouPlugIn].S := fr.HR.CodeSize;
                 pExtern[CouPlugIn].F := fr;
                 @ExternFunc[CouPlugIn] := Addr (P^);
                 WriteLn ('подключен');
              end;
              Close (f);
              EraseFile (f);
              if CouPlugIn = MaxPlugIn then Break;
           end else begin
               case GError of
                    0 : WriteLn ('ошибка чтения файла');
                    1 : WriteLn ('ошибка в структуре файла');
                    2 : WriteLn ('несовпадение контрольной суммы');
                    3 : WriteLn ('файл испорчен');
                    4 : WriteLn ('неизвестная версия файла');
               end;
           end;
           FindNext (SR);
     end;
     WriteLn;
     if CouPlugIn = 0 then begin
        WriteLn ('Плагины не подключены');
        Exit;
     end;
     {Здесь может быть заложен алгоритм для порядка вызова плагинов}
     for B := 1 to CouPlugIn do begin
         S := pExtern[B].F.DR.Signature.SigName;
         Write ('Стартует "', S, '" - ');
         ExternFunc[B] (@pProcLib, @pVarLib, @GlobalVar, pExtern[B].F.DR);
         WriteLn ('выполнен');
     end;
     {Обязательная часть - освобождение памяти}
     for B := CouPlugIn downto 1 do begin
         P := Addr (pExtern[B].P^);
         CR := pExtern[CouPlugIn].S;
         FreeMem (P, CR);
     end;
END.
