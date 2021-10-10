{
                          1997 (c) by RedArc // TAVC
}
UNIT RepCheck;

INTERFACE

USES DOS, Global, Service, WinHarry, CRT;

PROCEDURE ReadRep;

IMPLEMENTATION

PROCEDURE DivDirName;
VAR
   I, J : Word;
BEGIN
     WITH FileInfo DO BEGIN
          CASE FlagCheck (FileInfo) OF
               1,2 : begin
                   Inc (DirCount);
                   DirName [DirCount] := VirusName [1];
                   IF (FlagCheck (FileInfo) = 1) AND (Length (VirusName) > 1) THEN BEGIN
                      Inc (DirCount);
                      DirName [DirCount] :=  VirusName [1] + VirusName [2];
                   END;
                   J := 1;
                   REPEAT
                        Inc (DirCount);
                        DirName [DirCount] := '';
                        WHILE Pos (VirusName [J], NamePr) = 0 DO BEGIN
                              DirName [DirCount] := DirName [DirCount] + VirusName [J];
                              Inc (J);
                              IF J > Length (VirusName) THEN Break;
                              IF Length (DirName [DirCount]) = 8 THEN BEGIN
                                 WHILE Pos (VirusName [J], NamePr) = 0 DO BEGIN
                                       IF J > Length (VirusName) THEN Break;
                                       Inc (J);
                                 END;
                                 Break;
                              END;
                        END;
                        Inc (J);
                   UNTIL J > Length (VirusName);
                   IF (UpStr(DivNameFlag) = 'NO') AND ((Length(DirName [DirCount]) < 4) AND (DirCount > 3)) THEN BEGIN
                      DirName [DirCount-1] := DirName [DirCount-1] + '.' + DirName [DirCount];
                      Dec (DirCount);
                   END ELSE
                   IF (Length(DirName [DirCount-1]) = 1) AND (DirCount > 3) THEN BEGIN
                      DirName [DirCount-1] := DirName [DirCount];
                      Dec (DirCount);
                   END;
                   end;
               3 : begin
                   Inc (DirCount, 2);
                   DirName [DirCount] := '';
                   FOR I := 1 TO 10 DO
                       IF POS (AntiInfo. CodeAnal [I], UpStr(VirusName)) <> 0
                          THEN DirName [DirCount] := DirName [DirCount] + AntiInfo. CodeAnal [I] [1];
                   DirName [DirCount-1] := 'V_' + DirName [DirCount] [1];
                   IF Length (DirName [DirCount]) > 8 THEN BEGIN
                      Insert ('.', DirName [DirCount], 9);
                   END;
                   end;
          END;
     END;
END;

PROCEDURE MoveFileToDir;
VAR
   I : Byte;
   HOME : PathStr;
   N : NameStr;
   E : ExtStr;
   S, S1, S2 : String;
   T : Text;
   Attr : Word;
   PPP : PathStr;
BEGIN
     PPP := PathFileVirusDestion;
     IF PPP = '' THEN BEGIN
        FSplit (ParamStr (0), Home, N, E);
        IF Home [Length (Home)] = '\' THEN
           Delete (Home, Length (Home), 1);
        ChDir (Home);
        PPP := Home;
     END;
        IF PrioryPath = 'YES' THEN BEGIN
           GetDir (0, S1);
           FSplit (ParamStr (0), Home, N, E);
           IF Home [Length (Home)] = '\' THEN
              Delete (Home, Length (Home), 1);
           ChDir (Home);
           {$I-}
           ChDir (PPP);
           {$I+}
           IF IOResult <> 0 THEN BEGIN
              MkDir (PPP);
              ChDir (PPP);
           END;
           IF Home [Length (S1)] = '\' THEN
              Delete (S1, Length (S1), 1);
           ChDir (S1);
           PPP := PPP + '\' + AVKatalog;
        END;
     S := PPP + '\';
     FOR I := 1 TO FileInfo. DirCount DO
         S := S + FileInfo. DirName [I] + '\';
     S2 := S;
     Delete (S, GetColNum-5, Length (S));
     GotoXY (23, 5); ClrEOL; Write (S2);
     S := S + FileInfo. FileName;
     S1 := PathFileInfected + '\' + FileInfo. FileName;
     FileMode := 0;
     Assign (F, S1);
     {$I-}
     ReSet (F,1);
     {$I+}
     IF IOResult <> 0 THEN Exit;
     Close (F);
     {$I-}
     ChDir (PPP);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        MkDir (PPP);
        ChDir (PPP);
     END;
     FOR I := 1 TO FileInfo. DirCount DO BEGIN
         IF Pos ('/', FileInfo. DirName [I]) <> 0 THEN
            FileInfo. DirName [I] [Pos ('/', FileInfo. DirName [I])] := '_';
         IF Pos ('?', FileInfo. DirName [I]) <> 0 THEN
            FileInfo. DirName [I] [Pos ('?', FileInfo. DirName [I])] := '_';
         IF Pos ('*', FileInfo. DirName [I]) <> 0 THEN
            FileInfo. DirName [I] [Pos ('*', FileInfo. DirName [I])] := '_';
         {$I-}
         ChDir (FileInfo. DirName [I]);
         {$I+}
         IF IOResult <> 0 THEN BEGIN
            MkDir (FileInfo. DirName [I]);
            ChDir (FileInfo. DirName [I]);
         END;
     END;
     FSplit (ParamStr (0), Home, N, E);
     IF Home [Length (Home)] = '\' THEN
        Delete (Home, Length (Home), 1);
     ChDir (Home);
     Assign (F, S);
     {$I-}
     ReSet (F,1);
     {$I+}
     IF IOResult = 0 THEN BEGIN
        Close (F);
        Assign (F, S1);
        GetFAttr (F, Attr);
        SetFAttr (F, Archive);
        {$I-}
        Rename (F, PPP + '\' + FileInfo. FileName);
        {$I+}
        IF IOResult = 0 THEN
           SetFAttr (F, Attr)
        ELSE BEGIN
        SetFAttr (F, Archive);
        {$I-}
        Erase (F);
        {$I+}
        END;
        Exit;
     END;
     Assign (F, S1);
     GetFAttr (F, Attr);
     SetFAttr (F, Archive);
     IF (PPP = AVKatalog) AND (S [2] <> ':') THEN
        S := Home + '\' + S;
     Rename (F, S);
     SetFAttr (F, Attr);
     IF (ModifyInsertFlag = 'YES') AND (FileInfo. DirName [1] = ModPath) THEN BEGIN
         Assign (T, PathFileVirlist1);
         {$I-}
         ReSet (T);
         {$I+}
         IF IOResult <> 0 THEN BEGIN
            ReWrite (T);
            WriteLn (T, FileInfo. VirusName);
            Inc (AllRecord);
            Close (T)
         END ELSE BEGIN
             WHILE not EOF (T) DO BEGIN
                   ReadLn (T, S);
                   IF S = FileInfo. VirusName THEN BEGIN
                      Close (T);
                      Exit;
                   END;
             END;
             Close (T);
             Append (T);
             WriteLn (T, FileInfo. VirusName + '~');
             Inc (AllRecord);
             Close (T);
        END;
     END;
     IF FileInfo. DirName [1] <> InfPath THEN Exit;
     Assign (T, PathFileVirlist1);
     {$I-}
     ReSet (T);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        ReWrite (T);
        WriteLn (T, FileInfo. VirusName);
        Inc (AllRecord);
        Close (T)
     END ELSE BEGIN
          WHILE not EOF (T) DO BEGIN
                ReadLn (T, S);
                IF S = FileInfo. VirusName THEN BEGIN
                   Close (T);
                   Exit;
                END;
          END;
          Close (T);
          Append (T);
          WriteLn (T, FileInfo. VirusName);
          Inc (AllRecord);
          Close (T);
     END;
     GotoXY (23, 7); Write (AllRecord);
END;

PROCEDURE ReadRep;
VAR
   I : Byte;
   S, S1, S2 : String;
   Dir : DirStr;
   Nam : NameStr;
   Ext : ExtStr;
BEGIN
     Assign (T, PathFileReport + '\' + AVRName);
     {$I-}
          ReSet (T);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        WriteLn ('File ', PathFileReport + '\' + AVRName, ' not found');
        Exit;
     END;
     WHILE not EOF (T) DO BEGIN
           {$I-}
           ReadLn (T, S);
           {$I+}
           IF IOResult <> 0 THEN BEGIN
              WriteLn ('File ',PathFileReport + '\' + AVRName,' is corrupt');
              Close (T);
              Exit;
           END;

           {Teledisk}
           if Pos ('/Boot Sector', S) <> 0 then
              Delete (S, Pos ('/Boot Sector', S), Length ('/Boot Sector'));

           WHILE S [1] = #16 DO Delete (S, 1, 1);
           IF (S [2] <> ':') OR (S [3] <> '\') THEN Continue;
           S1 := '';
           WHILE (S [1] <> ' ') AND (S [1] <> #9) DO BEGIN
                 S1 := S1 + S[1];
                 if (S[1] = 'Z') or (S[1] = 'z') then
                    Delay (0);
                 Delete (S, 1, 1);
                 if Length (S) = 0 then begin
                    S := '- Ok';
                    Break;
                 end;
           END;

           {Archivers}
           S2 := S1;
           Delete (S2, 1, Length (PathFileInfected)+1);
           if (Pos ('/', S2) <> 0) or (Pos ('\', S2) <> 0) then begin
              if (Pos ('/', S2) <> 0) then Delete (S2, Pos ('/', S2), Length (S2));
              if (Pos ('\', S2) <> 0) then Delete (S2, Pos ('\', S2), Length (S2));
              Delete (S1, Length (PathFileInfected)+2, Length (S1));
              S1 := S1 + S2;
           end;

           {Multipariti}
           S2 := S;
           While (Pos (' ',S2) <> 0) or (Pos (#9,S2) <> 0) do
                 Delete (S2, 1, 1);
           if (Pos ('/', S2) <> 0) or (Pos ('\', S2) <> 0) then begin
              while (Pos ('/', S2) <> 0) do
                    S2[Pos ('/', S2)] := FileInfo.NamePr[1];
              while (Pos ('\', S2) <> 0) do
                    S2[Pos ('\', S2)] := FileInfo.NamePr[1];
              Delete (S, Length (S)-Length (S2), Length (S2)+1);
              S := S + ' ' + S2;
           end;

           FSplit (S1, Dir, Nam, Ext);
           GotoXY (23, 2); ClrEOL; Write (Nam + Ext);
           S2 := S;
           Delete (S, GetColNum-5, Length (S));
           GotoXY (23, 3); ClrEOL; Write (S2);
           GotoXY (23, 5); ClrEOL;
           DelLeftSpace (S);
           FlagOff (FileInfo);
           FOR I := 1 TO 3 DO BEGIN
               IF Pos (AntiInfo. IF_Flags [I], S) = 1 THEN
                  FileInfo. Flag_I := True;
               IF Pos (AntiInfo. MF_Flags [I], S) = 1 THEN
                  FileInfo. Flag_M := True;
               IF Pos (AntiInfo. SF_Flags [I], S) = 1 THEN
                  FileInfo. Flag_S := True;
               IF Pos (AntiInfo. OF_Flags [I], S) = 1 THEN
                  FileInfo. Flag_O := True;
           END;
           FOR I := 1 TO 6 DO BEGIN
               IF Pos (AntiInfo. EF_Flags [I], S) = 1 THEN
                  FileInfo. Flag_E := True;
           END;
           IF FlagCheck (FileInfo) > 0 THEN BEGIN
              FileInfo. FileName := Nam + EXT;
              GotoXY (23, 4); ClrEOL;
              CASE FlagCheck (FileInfo) OF
              1 : Write ('Infected');
              2 : Write ('Modify');
              3 : Write ('Unknown');
              4 : Write ('Not infected');
              5 : Write ('Error');
              END;
           END ELSE Continue;

                    WHILE Pos (' ', S) <> 0 DO Delete (S, 1, 1);

           FileInfo. VirusName := S;
           CASE FlagCheck (FileInfo) OF
                1 : FileInfo. DirName [1] := InfPath;
                2 : FileInfo. DirName [1] := ModPath;
                3 : FileInfo. DirName [1] := UnkPath;
                4 : begin
                    FileInfo. DirName [1] := ClePath;
                    FileInfo. VirusName := '';
                    end;
                5 : FileInfo. DirName [1] := ErrPath;
           END;
           IF Pos ('/', FileInfo. VirusName ) <> 0 THEN
              FileInfo. VirusName [Pos ('/', FileInfo. VirusName)] := '_';
           IF Pos ('?', FileInfo. VirusName) <> 0 THEN
              FileInfo. VirusName [Pos ('?', FileInfo. VirusName )] := '_';
           IF Pos ('*', FileInfo. VirusName) <> 0 THEN
              FileInfo. VirusName [Pos ('*', FileInfo. VirusName )] := '_';
           GotoXY (23, 6); ClrEOL; Write (FileInfo. VirusName);
           FileInfo. DirCount := 1;
           IF FlagCheck (FileInfo) < 4 THEN DivDirName;
           MoveFileToDir;
     END;
     Close (T);
END;

END.
