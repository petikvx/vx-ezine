{
                          1997 (c) by RedArc // TAVC
}
UNIT CFGRead;

INTERFACE

USES Global, CRT;

FUNCTION ReadConfig : Boolean;
FUNCTION ReadAVConfig : Boolean;

IMPLEMENTATION

procedure StringCheck (VAR S, SS, Path : String);
begin
    Delete (S, 1, Pos (SS, S) + Length (SS));
    DelLeftSpace (S);
    Path := S;
    IF Path [Length (Path)] = '\' THEN
       Dec (Byte (Path[0]));
    Path := UpStr (PATH);
end;

procedure InitGlobal;
begin
     PathFileInfected := DefaultPFI;
     PathFileReport   := DefaultPFR;
     PathFileVirlist  := DefaultPFV;
     CountAVInform    := 0;
     CountAVInfo      := 0;
     AntiVirusInform  := '';
     AVName           := '';
     AVRName          := '';
     AVKatalog        := '';
end;

FUNCTION ReadConfig : Boolean;
VAR
   S, S1 : String [100];
   EC : Integer;
BEGIN
     InitGlobal;
     Assign (CFG, CFGFileName);
     {$I-}
     ReSet (CFG);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        ReadConfig := False;
        WriteLn ('File not found ',CFGFileName);
        Exit
     END;
     {$I-}
     ReadLn (CFG, Comments); {Считываем идентификатор комментария}
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        ReadConfig := False;
        WriteLn ('File ', CFGFileName,' is corrupt');
        Close (CFG);
        Exit
     END;
     WHILE NOT Eof (CFG) DO BEGIN
           {$I-}
           ReadLn (CFG, S);
           {$I+}
           IF IOResult <> 0 THEN BEGIN
              ReadConfig := False;
              WriteLn ('File ', CFGFileName,' is corrupt');
              Close (CFG);
              Exit
           END;
           IF (Pos (Comments, S) = 0) AND (S <> '') THEN BEGIN
              S := UpStr (S);
              S1 := '&IF,';
              IF Pos (S1, S) > 0 THEN
                 StringCheck (S, S1, PathFileInfected);
              S1 := '&FR,';
              IF Pos (S1, S) > 0 THEN
                 StringCheck (S, S1, PathFileReport);
              S1 := '&VL,';
              IF Pos (S1, S) > 0 THEN
                 StringCheck (S, S1, PathFileVirlist);
              S1 := '&AN,';
              IF Pos (S1, S) > 0 THEN BEGIN
                 StringCheck (S, S1, S1);
                 Val (S1, CountAVInform, EC);
              END;
              S1 := '&HF,';
              IF Pos (S1, S) > 0 THEN
                 StringCheck (S, S1, PathFileHeaderList);
              S1 := '&VP,';
              IF Pos (S1, S) > 0 THEN
                 StringCheck (S, S1, PathFileVirusDestion);
              S1 := '&CM,';
              IF Pos (S1, S) > 0 THEN
                 StringCheck (S, S1, ModifyInsertFlag);
              S1 := '&DF,';
              IF Pos (S1, S) > 0 THEN
                 StringCheck (S, S1, DivNameFlag);

              S1 := '&@I,';
              IF Pos (S1, S) > 0 THEN
                 StringCheck (S, S1, InfPath);
              S1 := '&@M,';
              IF Pos (S1, S) > 0 THEN
                 StringCheck (S, S1, ModPath);
              S1 := '&@U,';
              IF Pos (S1, S) > 0 THEN
                 StringCheck (S, S1, UnkPath);
              S1 := '&@C,';
              IF Pos (S1, S) > 0 THEN
                 StringCheck (S, S1, ClePath);
              S1 := '&PP,';
              IF Pos (S1, S) > 0 THEN
                 StringCheck (S, S1, PrioryPath);
              S1 := '&@E,';
              IF Pos (S1, S) > 0 THEN
                 StringCheck (S, S1, ErrPath);
           END;
     END;
     Close (CFG);
     IF CountAVInform = 0 THEN ReadConfig := False
        ELSE ReadConfig := True;
     ModifyInsertFlag := UpStr (ModifyInsertFlag);
END;

PROCEDURE ReturnString (VAR S, S1 : String);
BEGIN
     S1 := '';
     WHILE (S [1] <> ',') AND (S [1] <> ' ') DO BEGIN
           S1 := S1 + S [1];
           Delete (S, 1, 1);
           IF S = '' THEN Break;
     END;
     DelLeftSpace (S);
END;

FUNCTION ReadAVConfig : Boolean;
VAR
   S : String;
   I, J : Word;
   Flag1, Flag2, Flag3, Flag4, Flag5 : Boolean;
BEGIN
     Inc (CountAVInfo);
     Assign (CFG, CFGFileName);
     {$I-}
     ReSet (CFG);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        ReadAVConfig := False;
        WriteLn ('File not found ',CFGFileName);
        Exit
     END;
     REPEAT
           IF EOF (CFG) THEN BEGIN
              ReadAVConfig := False;
              WriteLn ('File ',CFGFileName,' is corrupt');
              Close (CFG);
              Exit;
           END;
           {$I-}
           ReadLn (CFG, S);
           {$I+}
           IF IOResult <> 0 THEN BEGIN
              ReadAVConfig := False;
              WriteLn ('File ',CFGFileName,' is corrupt');
              Close (CFG);
              Exit;
           END;
           IF Pos (Comments, S) <> 0 THEN Continue;
           IF S = '' THEN Continue;
           IF Pos ('&AN,', S) = 0 THEN Continue;
           Break;
     UNTIL False;
     {$I-}
     ReadLn (CFG, S);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        ReadAVConfig := False;
        WriteLn ('File ',CFGFileName,' is corrupt');
        Close (CFG);
        Exit;
     END;
     I := 0;
     REPEAT
           {$I-}
           ReadLn (CFG, S);
           {$I+}
           IF IOResult <> 0 THEN BEGIN
              ReadAVConfig := False;
              WriteLn ('File ',CFGFileName,' is corrupt');
              Close (CFG);
              Exit;
           END;
           IF Pos (Comments, S) <> 0 THEN Continue;
           IF S = '' THEN Continue;
           Inc (I);
     UNTIL I = CountAVInfo;
     Close (CFG);
     ReturnString (S, AVName);
     ReturnString (S, AVRName);
     GotoXY (23, 1); ClrEOL; Write (AVRName);
     ReturnString (S, AVKatalog);
     ReturnString (S, AVConfig);
     Assign (CFG, PathFileReport + '\' + AVConfig);
     {$I-}
     ReSet (CFG);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        ReadAVConfig := False;
        WriteLn ('File not found ',PathFileReport + '\' + AVConfig);
        Exit
     END;
     IF EOF (CFG) THEN BEGIN
        ReadAVConfig := False;
        WriteLn ('File ',PathFileReport + '\' + AVConfig,' is corrupt');
        Close (CFG);
        Exit
     END;
     WITH AntiInfo DO BEGIN
          FOR I := 1 TO 3 DO BEGIN
              IF_Flags [I] := '';
              SF_Flags [I] := '';
              MF_Flags [I] := '';
              OF_Flags [I] := '';
          END;
          FOR I := 1 TO 6 DO BEGIN
              CodeAnal [I] := 'ДуБ';
              EF_Flags [I] := '';
          END;

          Flag1 := False;
          Flag2 := False;
          Flag3 := False;
          Flag4 := False;
          Flag5 := False;
          FileInfo. NamePr := '';
{          FileInfo. SomePr := #0;}
          REPEAT
                IF EOF (CFG) THEN Break;
                {$I-}
                ReadLn (CFG, S);
                {$I+}
                IF IOResult <> 0 THEN BEGIN
                   ReadAVConfig := False;
                   WriteLn ('File ',PathFileReport + '\' + AVConfig,' is corrupt');
                   Close (CFG);
                   Exit
                END;
                IF S = '' THEN Continue;
                IF Pos (Comments, S) <> 0 THEN Continue;
                DelLeftSpace (S);
                IF S [1] <> '&' THEN BEGIN
                   ReadAVConfig := False;
                   WriteLn ('File ',PathFileReport + '\' + AVConfig,' is corrupt');
                   Close (CFG);
                   Exit
                END;
                IF S [2] = '#' THEN BEGIN
                   Delete (S, 1, 3);
                   FileInfo. NamePr := S;
{                   FileInfo. SomePr := S [5];}
                   Continue
                END;
                IF S [2] = '$' THEN BEGIN
                   Delete (S, 1, 3);
                   DelLeftSpace (S);
                   I := 1;
                   WHILE S <> '' DO BEGIN
                         J := 1;
                         WHILE (S [1] <> ',') AND (S <> '') DO BEGIN
                               CodeAnal [I] [J] := UpCase (S [1]);
                               Delete (S, 1, 1);
                               Inc (J);
                         END;
                         Inc (I);
                         IF I > 10 THEN Break;
                         DelLeftSpace (S)
                   END;
                   Continue
                END;
                IF UpCase(S [3]) <> 'F' THEN BEGIN
                   ReadAVConfig := False;
                   WriteLn ('File ',PathFileReport + '\' + AVConfig,' is corrupt');
                   Close (CFG);
                   Exit
                END;
                Delete (S, 1, 1);
                CASE UpCase(S [1]) OF
                     'I' : begin
                                Delete (S, 1, 2);
                                DelLeftSpace (S);
                                Delete (S, 1, 1);
                                FOR I := 1 TO 3 DO BEGIN
                                    WHILE S [1] <> #39 DO BEGIN
                                          IF_Flags [I] := IF_Flags [I] + S [1];
                                          Delete (S, 1, 1);
                                    END;
                                    Delete (S, 1, 1);
                                    DelLeftSpace (S);
                                END;
                                Flag1 := True;
                           end;
                     'S' : begin
                                Delete (S, 1, 2);
                                DelLeftSpace (S);
                                Delete (S, 1, 1);
                                FOR I := 1 TO 3 DO BEGIN
                                    WHILE S [1] <> #39 DO BEGIN
                                          SF_Flags [I] := SF_Flags [I] + S [1];
                                          Delete (S, 1, 1);
                                    END;
                                    Delete (S, 1, 1);
                                    DelLeftSpace (S);
                                END;
                                Flag2 := True;
                           end;
                     'M' : begin
                                Delete (S, 1, 2);
                                DelLeftSpace (S);
                                Delete (S, 1, 1);
                                FOR I := 1 TO 3 DO BEGIN
                                    WHILE S [1] <> #39 DO BEGIN
                                          MF_Flags [I] := MF_Flags [I] + S [1];
                                          Delete (S, 1, 1);
                                    END;
                                    Delete (S, 1, 1);
                                    DelLeftSpace (S);
                                END;
                                Flag3 := True;
                           end;
                     'O' : begin
                                Delete (S, 1, 2);
                                DelLeftSpace (S);
                                Delete (S, 1, 1);
                                FOR I := 1 TO 3 DO BEGIN
                                    WHILE S [1] <> #39 DO BEGIN
                                          OF_Flags [I] := OF_Flags [I] + S [1];
                                          Delete (S, 1, 1);
                                    END;
                                    Delete (S, 1, 1);
                                    DelLeftSpace (S);
                                END;
                                Flag4 := True;
                           end;
                     'E' : begin
                                Delete (S, 1, 2);
                                DelLeftSpace (S);
                                Delete (S, 1, 1);
                                FOR I := 1 TO 6 DO BEGIN
                                    WHILE S [1] <> #39 DO BEGIN
                                          EF_Flags [I] := EF_Flags [I] + S [1];
                                          Delete (S, 1, 1);
                                    END;
                                    Delete (S, 1, 1);
                                    DelLeftSpace (S);
                                END;
                                Flag5 := True;
                           end;
                ELSE
                    ReadAVConfig := False;
                    WriteLn ('File ',PathFileReport + '\' + AVConfig,' is corrupt');
                    Close (CFG);
                    Exit
                END;
          UNTIL False;
     END;
     Close (CFG);
     ReadAVConfig := True;
END;

END.
