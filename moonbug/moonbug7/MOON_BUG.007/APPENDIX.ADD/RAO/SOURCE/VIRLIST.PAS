{
                          1997 (c) by RedArc // TAVC
}
PROGRAM VIRLIST;

USES CFGRead, Global, Service, RepCheck, WinHarry, CRT, Sorted;

BEGIN
     SetO;
     X_Cur := WhereX;
     Y_Cur := WhereY;
     GlobalFlag := 1;
     IF not ReadConfig THEN BEGIN
        WriteLn ('Program aborted!');
        SetN;
        Halt (0);
     END;
     SaveCurrentScreenOnDisk ('VIRLIST.SCR');
     TenWin(1,1,GetColNum,GetRowNum, Black * 16 + DarkGray);
     OpenWin(1,3,GetColNum,11, ' VIRLIST (c) 1997 by RedArc // TAVC ', Cyan*16+LightCyan, Blue * 16 + White,
	               	2, WW[1]);
     TextAttr :=Blue * 16 + Yellow;
     ClrScr;
     TextAttr := Black * 16 + LightGray;
     GotoXY (1,1); ClrEOL;
     GotoXY (1,2); ClrEOL;
     GotoXY (1,3); ClrEOL;
     GotoXY (1,4); ClrEOL;
     GotoXY (1,5); ClrEOL;
     GotoXY (1,6); ClrEOL;
     GotoXY (1,7); ClrEOL;
     TextAttr :=Blue * 16 + Yellow;
     GotoXY (1,1); Write ('Обрабатываемый отчет: ');
     GotoXY (1,2); Write ('Тестируемый файл:     ');
     GotoXY (1,3); Write ('Реакция антивируса:   ');
     GotoXY (1,4); Write ('Выставленный флаг:    ');
     GotoXY (1,5); Write ('Копируется в каталог: ');
     GotoXY (1,6); Write ('Название вируса:      ');
     GotoXY (1,7); Write ('Записей в вирлисте:   ');
     TextAttr := Black * 16 + LightGray;
     Clon := PrioryPath;
     REPEAT
           CountAVInfo := 0;
           REPEAT
                 IF not ReadAVConfig THEN BEGIN
                    CloseWin (WW [1]);
                    LoadScreenFromDisk ('VIRLIST.SCR');
                    TextAttr := Black * 16 + LightGray;
                    GotoXY (X_Cur, Y_Cur);
                    WriteLn;
                    WriteLn ('Program aborted!');
                    SetN;
                    Halt (0);
                 END;
                 ReadRep;
           UNTIL CountAVInform = CountAVInfo;
           PrioryPath := Clon;
           Inc (GlobalFlag);
     UNTIL GlobalFlag = 6;
     CloseWin (WW [1]);
     OpenWin(1,3,GetColNum,11, ' VIRLIST (c) 1997 by RedArc // TAVC ', Cyan*16+LightCyan, LightGray * 16 + White,
	               	2, WW[1]);
     TextAttr :=LightGray * 16 + White;
     ClrScr;
     TextAttr :=LightGray * 16 + Yellow;
     GotoXY (1,1); Write ('Сортировка: '); Write ('░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░');
     TextAttr :=LightGray * 16 + White;
     SortedVirList;
     CloseWin (WW [1]);
     LoadScreenFromDisk ('VIRLIST.SCR');
     TextAttr := Black * 16 + LightGray;
     GotoXY (X_Cur, Y_Cur);
     WriteLn;
     SetN;
     WriteLn ('.Finished.');
END.
