{$A-,B-,D-,E-,F-,G+,I-,L-,N+,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
{$M 65520,200000,655360}
{
Менеджер для запуска плагинов
}
PROGRAM MANAGER;

USES CRT, DOS, ProcLib, DataProc, CRC32;

CONST
     PlugInVersion = 2;

VAR
   SR : SearchRec;
   GError : Byte;
   P : Pointer;
   f : file;
   Dir : DirStr;
   Nam : NameStr;
   Ext : ExtStr;
   S : String;
   CR : Word;
   Sum : LongInt;
   B : Byte;
   ArrByteWrite : array [1..400] of Byte;

function TestSig (FileName : String) : Boolean;
begin
     S := FileName;
     Assign (f, S);
     ReSet (f, 1);
     if FileSize (f) < SizeOf (TFileRecord) then begin
        Close (f);
        GError := 1;
        TestSig := False;
        Exit;
     end;
     BlockRead (f, FileRecord^, SizeOf(TFileRecord), CR);
     if FileRecord^.HR.RecordSize <> FileSize (f) then begin
        Close (f);
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
     if FileRecord^.HR.CRCRecord <> Sum then begin
        Close (f);
        GError := 2;
        TestSig := False;
        Exit;
     end;
     if FileRecord^.HR.DataSize <> SizeOf(TFileRecord) - SizeOf(HeaderRecord) then begin
        Close (f);
        GError := 3;
        TestSig := False;
        Exit;
     end;
     if FileRecord^.HR.CodeSize <> FileSize (f) - SizeOf(TFileRecord) then begin
        Close (f);
        GError := 3;
        TestSig := False;
        Exit;
     end;
     if FileRecord^.HR.VersionPIN <> PlugInVersion then begin
        Close (f);
        GError := 4;
        TestSig := False;
        Exit;
     end;
     Close (f);
     TestSig := True;
end;

BEGIN
     Randomize;
     ClrScr;
     WriteLn ('PlugIn-Manager v.1.0');
     WriteLn ('Example for ZF (c) 2001 by RedArc');
     WriteLn;
     InitEnvironment (Environment);
     InitFileRecord  (FileRecord);
     FindFirst ('*.sig', Archive, SR);
     while DosError = 0 do begin
           Write (SR.Name, ' - ');
           if TestSig (SR.Name) then begin
              GetMem (P, FileRecord^.HR.CodeSize);
              Assign (f, S);
              ReSet (f, 1);
              Seek (f, SizeOf (TFileRecord));
              BlockRead (f, P^, FileRecord^.HR.CodeSize, CR);
              if (FileRecord^.HR.CodeSize <> CR) or (CR = 0) then begin
                 WriteLn ('файл испорчен');
                 FreeMem (P, FileRecord^.HR.CodeSize);
              end else begin
                 WriteLn ('подключен');
                 Write ('Стартует "', FileRecord^.DR.Signature.SigName, '" - ');
                 @ExternFunc := Addr (P^);
                 ExternFunc (Environment, FileRecord);
                 WriteLn ('выполнен');
              end;
              Close (f);
              FreeMem (P, FileRecord^.HR.CodeSize);
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
END.
