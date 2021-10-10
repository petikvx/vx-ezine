PROGRAM FileComp;

USES CRT, DOS, WinHarry, CompUtil;

{$I-}

BEGIN
     if ParamCount <> 1 then begin
        Help (0);
        Exit;
     end;
     if pos ('?', ParamStr(1)) <> 0 then begin
       Help (1);
       Exit;
     end;
     GetDir (0, Home);
     Path := ParamStr (1);
     if Path [Length(Path)] = '\' then Dec (Byte (Path [0]));
     ChDir (Path);
     if IOResult <> 0 then begin
        Help (2);
        Exit;
     end;
     ChDir (Home);
     if IOResult <> 0 then begin
        Help (3);
        Exit;
     end;
     Assign (T1, 'OK');
     ReSet (T1);
     if IOResult = 0 then begin
        Close (T1);
        FlagOk := True;
     end;
     Assign (T1, LOG);
     ReWrite (T1);
     if IOResult <> 0 then begin
        Help (4);
        Exit;
     end;
     Assign (T2, BAT);
     ReWrite (T2);
     if IOResult <> 0 then begin
        Close (T1);
        Help (4);
        Exit;
     end;
     WriteLn (T2, '@ECHO ON');
     SetO;
     OpenWin(1,1,80,25, ' FileComp (c) 1998 by RedArc // TAVC ', Blue * 16 + White,
     Blue * 16 + White, 2, WW [1]);
     TextAttr := Blue * 16 + White;
     ClrScr;
     GotoXY (1, 21); Write ('à®¢¥à¥­® ¤¨à¥ªâ®à¨©: 0');
     GotoXY (1, 22); Write ('à®¢¥à¥­® ä ©«®¢:     0');
     GotoXY (1, 23); Write ('‘®¢¯ ¤¥­¨©:           0');
     GotoXY (1, 18);
     Write ('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
     TextAttr := Blue * 16 + Cyan;
     GotoXY (23, 20);
     for i := 1 to 56 do
         Write ('°');
     GotoXY (23, 19);
     for i := 1 to 56 do
         Write ('°');
     while keypressed do readkey;
     ScanDir(Path);
     CloseWin (WW [1]);
     SetN;
     ChDir (Home);
     if IOResult <> 0 then begin
        Help (3);
        Exit;
     end;
    Help (255);
    Report;
END.
