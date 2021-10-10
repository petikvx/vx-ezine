UNIT Sorted;

INTERFACE

USES Global, CRT;

PROCEDURE SortedVirList;

IMPLEMENTATION

PROCEDURE SortedVirList;
VAR
   S1, S2, S3 : String;
   I, J, K : Word;
   T1 : Text;
   Count : Word;
BEGIN
     Assign (CFG, PathFileVirlist1);
     {$I-}
     ReSet (CFG);
     {$I+}
     IF IOResult <> 0 THEN Exit;
     I := 0;
     WHILE not EOF (CFG) DO BEGIN
           ReadLn (CFG, S1);
           Inc (I);
     END;
     ReSet (CFG);

     Assign (T, 'SORTED.VIR');
     ReWrite (T);
     Close (T);

     Assign (T1, 'SORTED.$$$');
     ReWrite (T1);
     ReSet (CFG);
     WHILE not EOF (CFG) DO BEGIN
           ReadLn (CFG, S3);
           IF Pos (Comments, S3) <> 0 THEN Continue;
           WriteLn (T1, S3);
     END;
     Close (T1);
     Close (CFG);
     Erase (CFG);
     Rename (T1, PathFileVirlist1);
     Assign (CFG, PathFileVirlist1);
     J := 1;
     REPEAT
           ReSet (CFG);
           ReadLn (CFG, S1);
           WHILE not EOF (CFG) DO BEGIN
                 ReadLn (CFG, S2);
                 IF S2 < S1 THEN S1 := S2
           END;
           ReSet (CFG);
           Append (T);
           WriteLn (T, S1);
           Close (T);
           Assign (T1, 'SORTED.$$$');
           ReWrite (T1);
           WHILE not EOF (CFG) DO BEGIN
                 ReadLn (CFG, S3);
                 IF Pos (Comments, S3) <> 0 THEN Continue;
                 IF S3 <> S1 THEN
                    WriteLn (T1, S3);
           END;
           Close (T1);
           Close (CFG);
           Erase (CFG);
           Rename (T1, PathFileVirlist1);
           Assign (CFG, PathFileVirlist1);
           Inc (J);
           TextAttr :=LightGray * 16 + White;
           GotoXY (1,2); DelLine;
           GotoXY (1,7); Write (S1);
           TextAttr :=LightGray * 16 + Yellow;
           GotoXY (13, 1);
           FOR K := 1 TO Round((50/I)*J) DO
               Write ('€');
     UNTIL J > I;
     Assign (T, PathFileVirlist1);
     {$I-}
     ReSet (T);
     {$I+}
     IF IOResult = 0 THEN BEGIN
        Close (T);
        Erase (T);
     END;
     Assign (T, 'SORTED.$$$');
     {$I-}
     ReSet (T);
     {$I+}
     IF IOResult = 0 THEN BEGIN
        Close (T);
        Erase (T);
     END;
     Assign (T, 'SORTED.VIR');
     Rename (T, PathFileVirlist1);
(**)
     TextAttr :=LightGray * 16 + Yellow;
     ClrScr;
     Assign (CFG, PathFileVirlist);
     {$I-}
     ReSet (CFG);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        Assign (CFG, PathFileVirlist);
        ReWrite (CFG);
        Assign (T1, PathFileHeaderList);
        {$I-}
        ReSet (T1);
        {$I+}
        IF IOResult <> 0 THEN BEGIN
           WriteLn (CFG, Comments+' '+Ident1);
           WriteLn (CFG, Comments+' '+Ident2);
        END ELSE BEGIN
            WHILE not EOF (T1) DO BEGIN
                  ReadLn (T1, S1);
                  IF Pos (Comments, S1) = 0 THEN S1 := Comments+' '+S1;
                  WriteLn (CFG, S1);
            END;
            Close (T1);
        END;
        Assign (T1, PathFileVirlist1);
        ReSet (T1);
        I := 0;
        WHILE not EOF (T1) DO BEGIN
              ReadLn (T1, S1);
              IF (Pos (Comments,S1) = 0) AND (S1 <> '') THEN Inc (I);
        END;
        WriteLn (CFG, Comments+' äÆ´®Á•·‚¢Æ ¢®‡„·Æ¢ ¢ ¢®‡´®·‚• - ', I);
        WriteLn (CFG);
        ReSet (T1);
        TextAttr :=LightGray * 16 + Yellow;
        GotoXY (1,7);
        WHILE not EOF (T1) DO BEGIN
              ReadLn (T1, S1);
              IF (Pos (Comments,S1) = 0) AND (S1 <> '') THEN BEGIN
                 WriteLn (CFG, S1);
                 WriteLn (S1);
              END;
        END;
        Close (T1);
        Close (CFG);
        Assign (T, PathFileVirlist1);
        {$I-}
        ReSet (T);
        {$I+}
        IF IOResult = 0 THEN BEGIN
           Close (T);
           Erase (T);
        END;
     END ELSE BEGIN
         Close (CFG);
         Assign (T, PathFileVirlist1);
         ReSet (T);
         Assign (T1, PathFileVirlist);
         ReSet (T1);
         Assign (CFG, 'SORTED.VIR');
         ReWrite (CFG);
  {       WHILE not EOF (T1) DO BEGIN
               ReadLn (T1, S2);
               IF (S2 = '') OR (Pos (Comments, S2) <> 0) THEN
                  WriteLn (CFG, S2)
               ELSE Break;
         END;
         ReSet (T1);
         WriteLn (CFG, '// ÑÆ°†¢´•≠Æ ¢®‡„·Æ¢ - ', I);}
         S1 := Autors;
         S2 := Autors;
         TextAttr :=LightGray * 16 + Yellow;
         GotoXY (1, 7);
         REPEAT
               IF (S1 = Autors) AND (EOF (T) = False) THEN
                  ReadLn (T, S1);
               IF (S2 = Autors) AND (EOF (T1) = False) THEN
                  ReadLn (T1, S2);
               IF (S1 = Autors) AND (S1 = S2) THEN Break;
               IF S2 <> Autors THEN BEGIN
                  IF (Pos (Comments, S2) <> 0) OR (S2 = '') THEN BEGIN
                     S2 := Autors;
                     Continue
                  END;
               END;
               IF (S1 = Autors) AND (S2 <> Autors) THEN BEGIN
                  WriteLn (S2);
                  WriteLn (CFG, S2);
                  S2 := Autors;
                  Continue;
               END;
               IF (S1 <> Autors) AND (S2 = Autors) THEN BEGIN
                  WriteLn (S1);
                  WriteLn (CFG, S1);
                  S1 := Autors;
                  Continue;
               END;
               IF S1 = S2 THEN BEGIN
                  WriteLn (S1);
                  WriteLn (CFG, S1);
                  S1 := Autors;
                  S2 := Autors;
                  Continue;
               END;
               IF S1 < S2 THEN BEGIN
                  WriteLn (S1);
                  WriteLn (CFG, S1);
                  S1 := Autors;
               END ELSE BEGIN
                  WriteLn (S2);
                  WriteLn (CFG, S2);
                  S2 := Autors;
               END;
         UNTIL False;
         Close (T);
         Close (T1);
         Erase (T1);
         Close (CFG);
         Rename (CFG, PathFileVirlist);
         Assign (T1, 'News.TXT');
         {$I-}
         ReSet (T1);
         {$I+}
         IF IOResult = 0 THEN BEGIN
              Close (T1);
              Erase (T1);
         END;
         Rename (T, 'News.TXT');
         Assign (CFG, 'SORTED.VIR');
         ReWrite (CFG);
         Assign (T1, PathFileHeaderList);
         {$I-}
         ReSet (T1);
         {$I+}
        IF IOResult <> 0 THEN BEGIN
           WriteLn (CFG, Comments+' '+Ident1);
           WriteLn (CFG, Comments+' '+Ident2);
        END ELSE BEGIN
            WHILE not EOF (T1) DO BEGIN
                  ReadLn (T1, S1);
                  IF Pos (Comments, S1) = 0 THEN S1 := Comments+' '+S1;
                  WriteLn (CFG, S1);
            END;
            Close (T1);
        END;
        Assign (T1, PathFileVirlist);
        ReSet (T1);
        I := 0;
        WHILE not EOF (T1) DO BEGIN
              ReadLn (T1, S1);
              IF (Pos (Comments, S1) = 0) AND (S1 <> '') THEN Inc (I);
        END;
        WriteLn (CFG, Comments+' äÆ´®Á•·‚¢Æ ¢®‡„·Æ¢ ¢ ¢®‡´®·‚• - ', I);
        WriteLn (CFG);
        ReSet (T1);
        TextAttr :=LightGray * 16 + White;
        ClrScr;
        TextAttr :=LightGray * 16 + Yellow;
        GotoXY (1,1); Write ('è•‡•ß†Ø®·Ï: '); Write ('∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞');
        TextAttr :=LightGray * 16 + White;
        GotoXY (1,7);
        J := 0;
        WHILE not EOF (T1) DO BEGIN
              ReadLn (T1, S1);
              IF (Pos (Comments,S1) = 0) AND (S1 <> '') THEN BEGIN
                 WriteLn (CFG, S1);
                 TextAttr :=LightGray * 16 + White;
                 Inc (J);
                 GotoXY (1,2); DelLine;
                 GotoXY (1,7); Write (S1);
                 TextAttr :=LightGray * 16 + Yellow;
                 GotoXY (13, 1);
                 FOR K := 1 TO Round((50/I)*J) DO
                     Write ('€');
              END;
        END;
        Close (T1);
        Close (CFG);
        Erase (T1);
        Rename (CFG, PathFileVirlist);
     END;
END;

END.