PROGRAM CopyExch;

USES CRT, DOS, WinHarry;

CONST
     INI            = 'COPYEXCH.CFG';
     RPT            = 'COPYEXCH.RPT';
     Ident1         = 'COPYEXCH (c) 1997 by RedArc // TAVC';
     Ident2         = '     Build: 230698   freeware';

VAR
   T, TW : Text;
   IniSou, PatSou, PatDest : String;
   NamePr : String;
   AndModify : String [3];
   DivName   : String [3];
   InfPath   : String;
   ModPath   : String;
   I, J, K : LongInt;
   S, S1, S2 : String;
   DirCount  : Byte;
   DirName   : Array [1..20] OF String [12];
   Dir : DirStr;
   Nam : NameStr;
   Ext : ExtStr;
   NameP : String;
   X_Cur, Y_Cur : Byte;
   Cur_Rec, All_Rec : LongInt;
   Comments : String [5];
   CL : Byte;

function UpStr (S : String) : String;
var
   i : byte;
begin
     for i := 1 to length (S) do S [i] := upcase (S [i]);
     UpStr := S;
end;

procedure DelLeftSpace (VAR S : String);
begin
     while (S [1] = ' ') or (S [1] = ',') or (S [1] = #9) do delete (S, 1, 1)
end;

procedure StringCheck (VAR S, SS, Path : String);
begin
    Delete (S, 1, Pos (SS, S) + Length (SS));
    DelLeftSpace (S);
    Path := S;
    IF Path [Length (Path)] = '\' THEN
       Dec (Byte (Path[0]));
end;

procedure Copy_File (S, D : String);
var
  FromF, ToF: file;
  NumRead, NumWritten: Word;
  Buf: array[1..2048] of Char;
begin
  Assign(FromF, S); { Open input file }
  Reset(FromF, 1);  { Record size = 1 }
  Assign(ToF, D);   { Open output file }
  Rewrite(ToF, 1);  { Record size = 1 }
  repeat
    BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
    BlockWrite(ToF, Buf, NumRead, NumWritten);
  until (NumRead = 0) or (NumWritten <> NumRead);
  Close(FromF);
  Close(ToF);
end;


procedure CopyFile;
var
   sr : searchrec;
   f  : file;
begin
     FindFirst ('*.*', AnyFile, sr);
     while doserror = 0 do begin
           if sr.name[1] <> '.' then begin
           Assign (f, sr.name);
           {$I-}
           reset (f,1);
           {$I+}
           if ioresult <> 0 then break;
           close (f);
           Copy_File (sr.name, PatDest+'\'+sr.name);
           end;
           FindNext (sr);
     end;
end;

PROCEDURE DivDirName (CL : Byte; S : String);
VAR
   I, J : Word;
BEGIN
     Inc (DirCount);
     DirName [DirCount] := S [1];
     IF (CL = 1) AND (Length (S) > 1) THEN BEGIN
        Inc (DirCount);
        DirName [DirCount] :=  S [1] + S [2];
     END;
     J := 1;
     REPEAT
          Inc (DirCount);
          DirName [DirCount] := '';
          WHILE Pos (S [J], NamePr) = 0 DO BEGIN
                DirName [DirCount] := DirName [DirCount] + S [J];
                Inc (J);
                IF J > Length (S) THEN Break;
                IF Length (DirName [DirCount]) = 8 THEN BEGIN
                   WHILE Pos (S [J], NamePr) = 0 DO BEGIN
                         IF J > Length (S) THEN Break;
                         Inc (J);
                   END;
                   Break;
                END;
          END;
          Inc (J);
     UNTIL J > Length (S);
     IF (UpStr(DivName) = 'NO') AND ((Length(DirName [DirCount]) < 4) AND (DirCount > 3)) THEN BEGIN
        DirName [DirCount-1] := DirName [DirCount-1] + '.' + DirName [DirCount];
        Dec (DirCount);
     END ELSE
     IF (Length(DirName [DirCount-1]) = 1) AND (DirCount > 3) THEN BEGIN
        DirName [DirCount-1] := DirName [DirCount];
        Dec (DirCount);
     END;
END;

BEGIN
     FSPlit (ParamStr (0), Dir, Nam, Ext);
     IF Dir [Length (Dir)] = '\' THEN Delete (Dir, Length (Dir), 1);
     WriteLn;
     WriteLn (Ident1);
     WriteLn (Ident2);
     WriteLn;
     Assign (T, INI);
     {$I-}
     ReSet (T);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        WriteLn ('File '+INI+' not found');
        Halt;
     END;
     IniSou := '';
     PatSou := '';
     PatDest := '';
     NamePr := '';
     AndModify := '';
     DivName := '';
     InfPath := '';
     ModPath := '';
     {$I-}
     ReadLn (T, Comments);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        WriteLn ('File '+INI+' is corrupt');
        Close (T);
        Exit;
     END;
     WHILE not EOF (T) DO BEGIN
           {$I-}
           ReadLn (T, S);
           {$I+}
           IF IOResult <> 0 THEN BEGIN
              WriteLn ('File '+INI+' is corrupt');
              Close (T);
              Exit;
           END;
           IF (S = '') OR (Pos (Comments, S)<>0) THEN Continue;
           IF S [1] <> '&' THEN BEGIN
              WriteLn ('File '+INI+' is corrupt');
              Close (T);
              Exit;
           END;
           S1 := '&CV,';
           IF Pos (S1, S) > 0 THEN
              StringCheck (S, S1, IniSou);
           S1 := '&PV,';
           IF Pos (S1, S) > 0 THEN
              StringCheck (S, S1, PatSou);
           S1 := '&PC,';
           IF Pos (S1, S) > 0 THEN
              StringCheck (S, S1, PatDest);
           S1 := '&DN,';
           IF Pos (S1, S) > 0 THEN
              StringCheck (S, S1, NamePr);
           S1 := '&AM,';
           IF Pos (S1, S) > 0 THEN
              StringCheck (S, S1, AndModify);
           S1 := '&DF,';
           IF Pos (S1, S) > 0 THEN
              StringCheck (S, S1, DivName);
           S1 := '&IP,';
           IF Pos (S1, S) > 0 THEN
              StringCheck (S, S1, InfPath);
           S1 := '&MP,';
           IF Pos (S1, S) > 0 THEN
              StringCheck (S, S1, ModPath);
     END;
     Close (T);
     IF IniSou = '' THEN BEGIN
        WriteLn ('Не задан файл со списком вирусов');
        Exit;
     END;
     IF PatSou = '' THEN BEGIN
        WriteLn ('Не задан путь расположения коллекции');
        Exit;
     END;
     IF PatDest = '' THEN BEGIN
        WriteLn ('Не указан конечный каталог копирования');
        Exit;
     END;
     IF NamePr = '' THEN BEGIN
        WriteLn ('Не заданы разделители в названиях вирусов');
        Exit;
     END;
     IF AndModify = '' THEN BEGIN
        WriteLn ('Не выставлен флаг реакции на тильду в конце названия вирусов');
        Exit;
     END;
     IF DivName = '' THEN BEGIN
        WriteLn ('Не выставлен флаг обработки названий вирусов DF');
        Exit;
     END;
     IF InfPath = '' THEN BEGIN
        WriteLn ('Не задан путь с инфицированными файлами');
        Exit;
     END;
     IF ModPath = '' THEN BEGIN
        WriteLn ('Не задан путь с возможными модификациями');
        Exit;
     END;

     Assign (T, IniSou);
     {$I-}
     ReSet (T);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        WriteLn ('File '+IniSou+' not found');
        Exit;
     END;

     All_Rec := 0;
     WHILE not EOF (T) DO BEGIN
           {$I-}
           ReadLn (T, S);
           {$I+}
           IF IOResult <> 0 THEN BEGIN
              Close (T);
              WriteLn ('File '+IniSou+' is corrupt');
              Exit;
           END;
           Inc (All_REc);
     END;
     Close (T);
     ReSet (T);

     SetO;
     X_Cur := WhereX;
     Y_Cur := WhereY;
     {$I-}
     ChDir (Dir);
     {$I+}
     SaveCurrentScreenOnDisk ('COPYEXCH.SCR');
     TenWin(1,1,GetColNum,GetRowNum, Black * 16 + DarkGray);
     OpenWin(1,3,GetColNum,11, ' COPYEXCH (c) 1997 by RedArc // TAVC ', Cyan*16+LightCyan, LightGray * 16 + White,
	               	2, WW[1]);
     TextAttr :=LightGray * 16 + White;
     ClrScr;
     TextAttr :=LightGray * 16 + Yellow;
     GotoXY (1,1); Write ('Прогресс: '); Write ('░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░');
     TextAttr :=LightGray * 16 + White;
     Cur_Rec := 0;
     Assign (TW, RPT);
     ReWrite (TW);
     WriteLn (TW, '.Started.');
     WHILE not EOF (T) DO BEGIN
           {$I-}
           ReadLn (T, S);
           {$I+}
           Write (TW, S + ' - ');
           IF IOResult <> 0 THEN BEGIN
              {$I-}
              ChDir (Dir);
              {$I+}
              CloseWin (WW [1]);
              LoadScreenFromDisk ('COPYEXCH.SCR');
              TextAttr := Black * 16 + LightGray;
              GotoXY (X_Cur, Y_Cur);
              WriteLn;
              SetN;
              Close (T);
              WriteLn ('File '+IniSou+' is corrupt');
              WriteLn (TW, 'File '+IniSou+' is corrupt');
              Close (TW);
              Exit;
           END;
           IF (Pos (Comments, S) <> 0) OR (S = '') THEN BEGIN
              WriteLn (TW, 'is comment');
              Continue;
           END;
           IF (S [Length (S)] = '~') AND (UpStr(AndModify) = 'NO') THEN BEGIN
              WriteLn (TW, 'flag AndModify not check');
              Continue;
           END;
           TextAttr :=LightGray * 16 + White;
           GotoXY (1,2); DelLine;
           GotoXY (1,7); Write (S);
           TextAttr :=LightGray * 16 + Yellow;
           GotoXY (11, 1);
           Inc (Cur_Rec);
           FOR K := 1 TO Round((60 / All_Rec)*Cur_Rec) DO
               Write ('█');

              DirCount := 1;
             IF S [Length (S)] <> '~' THEN BEGIN
              DirName [DirCount] := InfPath;
              CL := 1;
              END ELSE BEGIN
              DirName [DirCount] := ModPath;
              CL := 2;
              END;
              Inc (DirCount);
              DirName [DirCount] := S [1];
              IF (Length (S) > 1) AND (S [Length (S)] <> '~') THEN BEGIN
                 Inc (DirCount);
                 DirName [DirCount] :=  S [1] + S [2];
              END;
              IF S [Length (S)] = '~' THEN Dec (Byte(S[0]));
              J := 1;
{              REPEAT
                   Inc (DirCount);
                   DirName [DirCount] := '';
                   WHILE Pos (S [J], NamePr) = 0 DO BEGIN
                         DirName [DirCount] := DirName [DirCount] + S [J];
                         Inc (J);
                         IF J > Length (S) THEN Break;
                         IF Length (DirName [DirCount]) = 8 THEN BEGIN
                            WHILE Pos (S [J], NamePr) = 0 DO BEGIN
                                  IF J > Length (S) THEN Break;
                                  Inc (J);
                            END;
                            Break;
                         END;
                   END;
                   Inc (J);
              UNTIL J > Length (S);}

           case CL of
           1 : DirName [1] := InfPath;
           2 : DirName [1] := ModPath;
           end;

           IF Pos ('/', S ) <> 0 THEN
              S [Pos ('/', S)] := '_';
           IF Pos ('?', S) <> 0 THEN
              S [Pos ('?', S )] := '_';
           IF Pos ('*', S) <> 0 THEN
              S [Pos ('*', S )] := '_';
           DirCount := 1;
           DivDirName (CL, S);


              IF (UpStr(DivName) = 'NO') AND ((Length(DirName [DirCount]) < 4) AND (DirCount > 3)) THEN BEGIN
                 DirName [DirCount-1] := DirName [DirCount-1] + '.' + DirName [DirCount];
                 Dec (DirCount);
              END ELSE
              IF (Length(DirName [DirCount-1]) = 1) AND (DirCount > 3) THEN BEGIN
                 DirName [DirCount-1] := DirName [DirCount];
                 Dec (DirCount);
              END;
           {$I-}
           ChDir (PatDest);
           {$I+}
           IF IOResult <> 0 THEN BEGIN
              MkDir (PatDest);
              ChDir (PatDest);
           END;
           ChDir (Dir);
           {$I-}
           ChDir (PatSou);
           {$I+}
           IF IOResult <> 0 THEN BEGIN
              {$I-}
              ChDir (Dir);
              {$I+}
{              CloseWin (WW [1]);
              LoadScreenFromDisk ('COPYEXCH.SCR');
              TextAttr := Black * 16 + LightGray;
              GotoXY (X_Cur, Y_Cur);
              WriteLn;
              SetN;
              Close (T);
              WriteLn ('Path '+PatSou+' not found');
              Exit;}
              WriteLn (TW, 'Path '+PatSou+' not found');
              Continue;
           END;
           FOR I := 1 TO DirCount DO BEGIN
               {$I-}
               ChDir (DirName [I]);
               {$I+}
               IF IOResult <> 0 THEN BEGIN
                  {$I-}
                  ChDir (Dir);
                  {$I+}
{                  CloseWin (WW [1]);
                  LoadScreenFromDisk ('COPYEXCH.SCR');
                  TextAttr := Black * 16 + LightGray;
                  GotoXY (X_Cur, Y_Cur);
                  WriteLn;
                  SetN;
                  Close (T);
                  Write ('Path '+PatSou+'\');
                  FOR J := 1 TO I DO
                      Write (DirName [J] + '\');
                  WriteLn (' not found');
                  Exit;}
                  Write (TW, 'Path '+PatSou+'\');
                  FOR J := 1 TO I DO
                      Write (TW, DirName [J] + '\');
                  WriteLn (TW, ' not found');
                  Continue;
               END;
           END;
           CopyFile;
           WriteLn (TW, 'Ok');
{           SwapVectors;
           Exec (GetEnv ('COMSPEC'), '/c copy *.* '+PatDest+'\'+'*.* > nul');
           SwapVectors; }
           {$I-}
           ChDir (Dir);
           {$I+}
           IF IOResult <> 0 THEN BEGIN
                  {$I-}
                  ChDir (Dir);
                  {$I+}
              CloseWin (WW [1]);
              LoadScreenFromDisk ('COPYEXCH.SCR');
              TextAttr := Black * 16 + LightGray;
              GotoXY (X_Cur, Y_Cur);
              WriteLn;
              SetN;
              WriteLn ('Change Directory to '+Dir+' error');
              WriteLn (TW, 'Change Directory to '+Dir+' error');
              Close (TW);
              Close (T);
              Exit;
           END;
     END;
     Close (T);
     {$I-}
     ChDir (Dir);
     {$I+}
     WriteLn (TW, '.Finished.');
     Write (TW, 'Alle records: ');
     WriteLn (TW, All_Rec);
     Write (TW, 'Write records: ');
     WriteLn (TW, Cur_Rec);
     Close (TW);
     CloseWin (WW [1]);
     LoadScreenFromDisk ('COPYEXCH.SCR');
     TextAttr := Black * 16 + LightGray;
     GotoXY (X_Cur, Y_Cur);
     WriteLn;
     SetN;
END.
