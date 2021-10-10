{
                          1997 (c) by RedArc // TAVC
}
PROGRAM EXCHANGE;

     {$I-}

USES DOS, CRT, WinHarry;

CONST
     Ident1         = 'EXCHANGE (c) 1997 by RedArc // TAVC';
     Ident2         = '     Build: 200698  freeware';
     Autors         = 'Igor V. Dikchew // Uni Tula';
     CFG_T          = 'EXCHANGE.CFG';
     XCHG_Extension = '.chg';
     MaxInd         = 64;

VAR
   NameSource1, NameSource2, NameTarget1, NameTarget2 : String [12];
   CFG, Sou1, Sou2, Tar1, Tar2 : Text;
   Dir : DirStr;
   Nam : NameStr;
   Ext : ExtStr;
   Comment, CommentS, CommentT : String [5];
   S1, S2 : String;
   N1, N2 : String [80];
   ErrorCode : Integer;
   X_Cur, Y_Cur : Byte;
   Ch : Char;
   Reader, Writer, Sou1Cou, Sou2Cou, MaxCou : LongInt;
   Cou1S, Cou2S, Cou1T, Cou2T : LongInt;

PROCEDURE Help;
BEGIN
        WriteLn;
        WriteLn (Ident1);
        WriteLn (Ident2);
        WriteLn;
        WriteLn ('Usage: EXCHANGE.EXE FileName1 FileName2');
        WriteLn ('   FileName1 - ¨áå®¤­ë© ¢¨à«¨áâ');
        WriteLn ('   FileName2 - áà ¢­¨¢ ¥¬ë© ¢¨à«¨áâ');
END;

FUNCTION ExistsFile (S : String) : Byte;
VAR
   Result : Byte;
BEGIN
     WriteLn ('File '+S+' already exists');
     WriteLn ('[Q] - return to DOS');
     WriteLn ('[O] - overwriting a file');
     WriteLn ('[A] - append to file');
     Result := 0;
     REPEAT
           REPEAT UNTIL KeyPressed;
           While KeyPressed Do Ch := ReadKey;
           CASE UpCase (Ch) OF
           'Q' : BEGIN
                  Result := 1;
                  Break;
                 END;
           'O' : BEGIN
                  Result := 2;
                  Break;
                 END;
           'A' : BEGIN
                  Result := 3;
                  Break;
                 END;
           ELSE
               Sound (1000);
               Delay (100);
               NoSound;
           END;
     UNTIL False;
     ExistsFile := Result;
END;

FUNCTION UpStr (S : String) : String;
VAR
   i : byte;
BEGIN
     for i := 1 to Length (S) do
         s [i] := UpCase (s [i]);
     UpStr := s;
END;

PROCEDURE Indicat;
VAR
   I, J : Byte;
   S_1, S_2 : String [80 - 2 - 24 - 1];
BEGIN
     TextAttr := White + 16 * LightGray;
     GotoXY (15,1);
     J := Round ((Reader * MaxInd) / MaxCou);
     for i := 1 to j do Write ('Û');
     TextAttr := White + 16 * LightGray;
     GotoXY (15,2);
     J := Round ((Writer * MaxInd) / MaxCou);
     for i := 1 to j do Write ('Û');
     TextAttr := LightBlue + 16 * LightGray;
     GotoXY (15,3);
     J := Round ((Cou1S * MaxInd) / Sou1Cou);
     for i := 1 to j do Write ('Û');
     TextAttr := LightBlue + 16 * LightGray;
     GotoXY (15,4);
     J := Round ((Cou2S * MaxInd) / Sou2Cou);
     for i := 1 to j do Write ('Û');
     TextAttr := LightRed + 16 * LightGray;
     GotoXY (15,5);
     J := Round ((Cou1T * MaxInd) / Sou1Cou);
     for i := 1 to j do Write ('Û');
     TextAttr := LightRed + 16 * LightGray;
     GotoXY (15,6);
     J := Round ((Cou2T * MaxInd) / Sou2Cou);
     for i := 1 to j do Write ('Û');

     TextAttr := Green + 16 * LightGray;
     S_1 := S1;
     GotoXY (24,7); ClrEOL; Write (S_1);
     S_2 := S2;
     GotoXY (24,8); ClrEOL; Write (S_2);
END;

BEGIN
     if (ParamCount <> 0) and (ParamCount <> 2) then begin
        Help;
        Halt (1);
     end;
     Assign (CFG, CFG_T);
     Reset (CFG);
     IF IOResult <> 0 THEN BEGIN
        Help;
        WriteLn ('File '+CFG_T+' not found');
        Halt (2);
     END;
     ReadLn (CFG, Comment);
     WHILE not EOF (CFG) DO BEGIN
           ReadLn (CFG, S1);
           if S1 = '' then Continue;
           if Pos (Comment, S1) <> 0 then Continue;
           if Pos ('&IVL', S1) <> 0 then begin
              while Pos (' ', S1) <> 0 do Delete (S1, 1, 1);
              N1 := S1;
              Continue;
           end;
           if Pos ('&SVL', S1) <> 0 then begin
              while Pos (' ', S1) <> 0 do Delete (S1, 1, 1);
              N2 := S1;
              Continue;
           end;
           if Pos ('&IVC', S1) <> 0 then begin
              while Pos (' ', S1) <> 0 do Delete (S1, 1, 1);
              CommentS := S1;
              Continue;
           end;
           if Pos ('&SVC', S1) <> 0 then begin
              while Pos (' ', S1) <> 0 do Delete (S1, 1, 1);
              CommentT := S1;
           end;
     END;
     Close (CFG);
     NameSource1 := N1;
     NameSource2 := N2;
     if ParamCount = 2 then begin {for old style}
        NameSource1 := ParamStr (1);
        NameSource2 := ParamStr (2);
     end;
     FSplit (NameSource1, Dir, Nam, Ext);
     NameTarget1 := Nam + XCHG_Extension;
     FSplit (NameSource2, Dir, Nam, Ext);
     NameTarget2 := Nam + XCHG_Extension;
     Assign (Sou1, NameSource1);
     Assign (Sou2, NameSource2);
     Assign (Tar1, NameTarget1);
     Assign (Tar2, NameTarget2);
     ReSet (Sou1);
     IF IOResult <> 0 THEN BEGIN
        Help;
        WriteLn ('File '+NameSource1+' not found');
        Halt (3);
     END;
     ReSet (Sou2);
     IF IOResult <> 0 THEN BEGIN
        Close (Sou1);
        Help;
        WriteLn ('File '+NameSource2+' not found');
        Halt (4);
     END;
     ReSet (Tar1);
     IF IOResult = 0 THEN BEGIN
        ErrorCode := ExistsFile (NameTarget1);
        CASE ErrorCode OF
             0 : BEGIN
                 Close (Tar1);
                 Help;
                 WriteLn ('°±²Û Fatal Error Û²±°');
                 Halt (5);
                 END;
             1 : BEGIN
                 Close (Tar1);
                 Close (Sou2);
                 Close (Sou1);
                 Halt (6);
                 END;
             2 : BEGIN
                 Close (Tar1);
                 ReWrite (Tar1);
                 Close (Tar1);
                 END;
             3 : BEGIN
                 Close (Tar1);
                 END;
        END;
     END ELSE BEGIN
         ReWrite (Tar1);
         Close (Tar1);
     END;
     ReSet (Tar2);
     IF IOResult = 0 THEN BEGIN
        ErrorCode := ExistsFile (NameTarget2);
        CASE ErrorCode OF
             0 : BEGIN
                 Close (Tar2);
                 Help;
                 WriteLn ('°±²Û Fatal Error Û²±°');
                 Halt (5);
                 END;
             1 : BEGIN
                 Close (Tar2);
                 Close (Sou2);
                 Close (Sou1);
                 Halt (6);
                 END;
             2 : BEGIN
                 Close (Tar2);
                 ReWrite (Tar2);
                 Close (Tar2);
                 END;
             3 : BEGIN
                 Close (Tar2);
                 END;
        END;
     END ELSE BEGIN
         ReWrite (Tar2);
         Close (Tar2);
     END;
{Window}
     SetO;
     X_Cur := WhereX;
     Y_Cur := WhereY;
     SaveCurrentScreenOnDisk ('EXCHANGE.SCR');
     TenWin(1,1,GetColNum,GetRowNum, Black * 16 + DarkGray);
     OpenWin(1,3,GetColNum,12, ' EXCHANGE (c) 1997 by RedArc // TAVC ', Cyan*16+LightCyan, LightGray * 16 + White,
                        2, WW[1]);
     TextAttr :=LightGray * 16 + White;
     ClrScr;
{Window}
     Append (Tar1);
     Append (Tar2);
     Reader := 0;
     Writer := 0;
     Sou1Cou := 0;
     Sou2Cou := 0;
     Cou1S := 0;
     Cou2S := 0;
     Cou1T := 0;
     Cou2T := 0;
     WHILE not EOF (Sou1) DO BEGIN
           ReadLn (Sou1, S1);
           Sou1Cou := Sou1Cou + 1;
     END;
     WHILE not EOF (Sou2) DO BEGIN
           ReadLn (Sou2, S2);
           Sou2Cou := Sou2Cou + 1;
     END;
     MaxCou := Sou1Cou + Sou2Cou;
     Close (Sou2);
     ReSet (Sou2);
     Close (Sou1);
     ReSet (Sou1);
     S1 := Autors;
     S2 := S1;
{Visual}
     TextAttr := White + 16 * LightGray;
     GotoXY (15,1); Write ('°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°');
     GotoXY (15,2); Write ('°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°');
     TextAttr := LightBlue + 16 * LightGray;
     GotoXY (15,3); Write ('°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°');
     GotoXY (15,4); Write ('°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°');
     TextAttr := LightRed + 16 * LightGray;
     GotoXY (15,5); Write ('°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°');
     GotoXY (15,6); Write ('°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°');
     TextAttr := Black + 16 * LightGray;
     GotoXY (1,1); Write ('        Read:');
     GotoXY (1,2); Write ('       Write:');
     while Length (NameSource1) < 12 do NameSource1 := ' ' + NameSource1;
     while Length (NameSource2) < 12 do NameSource2 := ' ' + NameSource2;
     while Length (NameTarget1) < 12 do NameTarget1 := ' ' + NameTarget1;
     while Length (NameTarget2) < 12 do NameTarget2 := ' ' + NameTarget2;
     GotoXY (1,3); Write (UpStr(NameSource1) + ': ');
     GotoXY (1,4); Write (UpStr(NameSource2) + ': ');
     GotoXY (1,5); Write (UpStr(NameTarget1) + ': ');
     GotoXY (1,6); Write (UpStr(NameTarget2) + ': ');
     GotoXY (1,7); Write ('Word from ' + UpStr(NameSource1));
     GotoXY (1,8); Write ('Word from ' + UpStr(NameSource2));
{Visual}
     ReadLn (Sou1, S1);
     Inc (Cou1S);
     Inc (Reader);
     ReadLn (Sou2, S2);
     Inc (Cou2S);
     Inc (Reader);
     REPEAT
        Indicat;
        IF (Pos (CommentS, S1) <> 0) or (S1 = '') THEN BEGIN
           IF not EOF (Sou1) THEN BEGIN
              ReadLn (Sou1, S1);
              Inc (Reader);
              Inc (Cou1S);
              Continue;
           END ELSE BEGIN
               WHILE not EOF (Sou2) DO BEGIN
                     Indicat;
                     ReadLn  (Sou2, S2);
                     Inc (Reader);
                     Inc (Cou2S);
                     IF (Pos (CommentT, S2) = 0) and (S2 <> '') THEN BEGIN
                        WriteLn (Tar2, S2);
                        Inc (Writer);
                        Inc (Cou2T);
                     END;
               END;
               Break;
           END;
        END;
        IF (Pos (CommentT, S2) <> 0) or (S2 = '') THEN BEGIN
           IF not EOF (Sou2) THEN BEGIN
              ReadLn (Sou2, S2);
              Inc (Reader);
              Inc (Cou2S);
              Continue;
           END ELSE BEGIN
               WHILE not EOF (Sou1) DO BEGIN
                     Indicat;
                     ReadLn  (Sou1, S1);
                     Inc (Reader);
                     Inc (Cou1S);
                     IF (Pos (CommentS, S1) = 0) and (S1 <> '') THEN BEGIN
                        WriteLn (Tar1, S1);
                        Inc (Writer);
                        Inc (Cou1T);
                     END;
               END;
               Break;
           END;
        END;
        IF EOF (Sou1) THEN BEGIN
           WHILE not EOF (Sou2) DO BEGIN
                 Indicat;
                 ReadLn  (Sou2, S2);
                 Inc (Reader);
                 Inc (Cou2S);
                 IF (Pos (CommentT, S2) = 0) and (S2 <> '') THEN BEGIN
                    WriteLn (Tar2, S2);
                    Inc (Writer);
                    Inc (Cou2T);
                 END;
           END;
           Break;
        END;
        IF EOF (Sou2) THEN BEGIN
           WHILE not EOF (Sou1) DO BEGIN
                 Indicat;
                 ReadLn  (Sou1, S1);
                 Inc (Reader);
                 Inc (Cou1S);
                 IF (Pos (CommentS, S1) = 0) and (S1 <> '') THEN BEGIN
                    WriteLn (Tar1, S1);
                    Inc (Writer);
                    Inc (Cou1T);
                 END;
           END;
           Break;
        END;
        IF S1 = S2 THEN BEGIN
           ReadLn (Sou1, S1);
           Inc (Reader);
           Inc (Cou1S);
           ReadLn (Sou2, S2);
           Inc (Reader);
           Inc (Cou2S);
           Continue;
        END;
        IF S1 < S2 THEN BEGIN
           WriteLn (Tar1, S1);
           Inc (Writer);
           Inc (Cou1T);
           IF not EOF (Sou1) THEN BEGIN
              ReadLn  (Sou1, S1);
              Inc (Reader);
              Inc (Cou1S);
              Continue;
           END ELSE BEGIN
               WHILE not EOF (Sou2) DO BEGIN
                     Indicat;
                     ReadLn  (Sou2, S2);
                     Inc (Reader);
                     Inc (Cou2S);
                     IF (Pos (CommentT, S2) = 0) and (S2 <> '') THEN BEGIN
                        WriteLn (Tar2, S2);
                        Inc (Writer);
                        Inc (Cou2T);
                     END;
               END;
               Break;
           END;
        END;
        IF S1 > S2 THEN BEGIN
           WriteLn (Tar2, S2);
           Inc (Writer);
           Inc (Cou2T);
           IF not EOF (Sou2) THEN BEGIN
              ReadLn  (Sou2, S2);
              Inc (Reader);
              Inc (Cou2S);
              Continue;
           END ELSE BEGIN
               WHILE not EOF (Sou1) DO BEGIN
                     Indicat;
                     ReadLn  (Sou1, S1);
                     Inc (Reader);
                     Inc (Cou1S);
                     IF (Pos (CommentS, S1) = 0) and (S1 <> '') THEN BEGIN
                        WriteLn (Tar1, S1);
                        Inc (Writer);
                        Inc (Cou1T);
                     END;
               END;
               Break;
           END;
        END;
     UNTIL False;
     Close (Tar2);
     Close (Tar1);
     Close (Sou2);
     Close (Sou1);
     CloseWin (WW [1]);
     LoadScreenFromDisk ('EXCHANGE.SCR');
     TextAttr := Black * 16 + LightGray;
     GotoXY (X_Cur, Y_Cur);
     WriteLn;
     SetN;
     WriteLn ('.Completed.');
     Writeln;
     WriteLn ('Read strings:');
     WriteLn (NameSource1 + ' - ',Sou1Cou);
     WriteLn (NameSource2 + ' - ',Sou2Cou);
     WriteLn ('Write strings:');
     WriteLn (NameTarget1 + ' - ', Cou1T);
     WriteLn (NameTarget2 + ' - ', Cou2T);
END.
