PROGRAM FindFile;

{$I-}

USES DOS, FIND, CRT, Working;

procedure Info;
begin
     WriteLn ('USAGE: findfile.exe SourceDir TargetDir FileName Key');
     WriteLn ('       SourceDir - каталог для поиска файлов');
     WriteLn ('       TargetDir - каталог для накопления файлов');
     WriteLn ('       FileName  - имя файла со списком искомых файлов');
     WriteLn ('       Key:');
     WriteLn ('              /C - копирование найденных файлов в TargetDir');
     WriteLn ('              /M - перемещение найденных файлов в TargetDir');
     WriteLn;
     Halt;
end;

procedure WriteHeader;
begin
     TextAttr := Black * 16 + LightGray;
     ClrScr;
     WriteLn;
     WriteLn ('FindFile (c) 1999 by RedArc');
     WriteLn;
end;

BEGIN
     WriteHeader;
     if ParamCount <> 4 then Info;
     SDir := ParamStr (1);
     TDir := ParamStr (2);
     if SDir [Length (SDir)] = '\' then Dec (Byte (SDir[0]));
     if TDir [Length (TDir)] = '\' then Dec (Byte (TDir[0]));
     GetDir (0, Home);
     ChDir (SDir);
     if IOResult <> 0 then begin
        WriteLn ('Cannot find directory ' + SDir);
        ChDir (Home);
        Exit;
     end;
     ChDir (TDir);
     if IOResult <> 0 then begin
        WriteLn ('Cannot find directory ', TDir);
        ChDir (Home);
        Exit;
     end;
     ChDir (Home);
     FileName := ParamStr (3);
     Assign (T, FileName);
     ReSet (T);
     if IOResult <> 0 then begin
        WriteLn ('File ', FileName, ' not found');
        Exit;
     end;
     AF := 0;
     while not eof (T) do begin
           ReadLn (T, S);
           inc (AF);
     end;
     Close (T);
     Regime := False;
     if (ParamStr (4) = '/m') or (ParamStr (4) = '/M') then Regime := True;
     if Regime then S := 'Moving' else S := 'Copying';
     Assign (TP, 'findfile.rpt');
     Append (TP);
     if IOResult <> 0 then ReWrite (TP);
     if IOResult <> 0 then Flag := False else Flag := True;
     WriteLn ('Source: ', SDir);
     WriteLn ('Target: ', TDir);
     WriteLn ('Thread: ', FileName);
     WriteLn ('Regime: ', S);
     WriteLn;
     if Flag then begin
        WriteLn (TP, 'FindFile (c) 1999 by RedArc');
        WriteLn (TP, '');
        WriteLn (TP, 'Source: ', SDir);
        WriteLn (TP, 'Target: ', TDir);
        WriteLn (TP, 'Thread: ', FileName);
        WriteLn (TP, 'Regime: ', S);
        WriteLn (TP, '');
     end;
     ScanDir (SDir);
     WriteHeader;
     WriteLn ('.Finished');
     if Flag then begin
        WriteLn (TP, '.Finished');
        Close (TP);
     end;
END.
