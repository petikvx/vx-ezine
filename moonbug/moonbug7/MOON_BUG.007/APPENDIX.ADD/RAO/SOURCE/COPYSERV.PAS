UNIT COPYSERV;

INTERFACE

USES CRT, DOS;

type
  PList = ^TList;
  TList = record
    Name : String[12];
    Next : Plist;
    end;

var
   MoveFlag : Boolean;
   AlwaysFlag : Byte;
  SR : SearchRec;
  S : String;
  P1 : String;
  P2 : String;
  T : Text;
   Dir : DirStr;
   Nam : NameStr;
   Ext : ExtStr;
   Ch : Char;
   Count : LongInt;

PROCEDURE CopyFile (Name : String);

IMPLEMENTATION

function UpStr (S : String) : String;
var
   i : byte;
begin
     for i := 1 to length (S) do S [i] := upcase (S [i]);
     UpStr := S;
end;

PROCEDURE NewName (VAR SN : String);
VAR
   F : File;
   I : Word;
   S1 : String [4];
   Dir : DirStr;
   Nam : NameStr;
   Ext : ExtStr;
   Flag : Boolean;
   S2 : Char;
BEGIN
     FSplit (SN, Dir, Nam, Ext);
     Flag := False;
     FileMode := 0;
     REPEAT
         FOR I := 0 TO 999 DO BEGIN
             Str (I, S1);
             WHILE Length (S1) < 3 DO S1 := '0'+S1;
             S1 := '.'+S1;
             Assign (F, P2 + '\' + Nam + S1);
             {$I-}
             ReSet (F);
             {$I+}
             IF IOResult <> 0 THEN BEGIN
                Flag := True;
                Break;
             END;
             Close (F);
         END;
         IF not Flag THEN BEGIN
            S2 := Chr (33 + Random (223));
            IF Length (Nam) < 8 THEN Nam := Nam + S2 ELSE BEGIN
               Dec ( Byte (Nam [0]) );
               Nam := Nam + S2;
            END;
         END;
     UNTIL Flag;
     SN := Nam + S1;
     WriteLn (SN);
END;

PROCEDURE CopyFile (Name : String);
VAR
   F1, F2 : File;
   P : Pointer;
   S : Word;
   ER, EW : Word;
   Attr : Word;
   FTime : LongInt;
   I : LongInt;
   D_ : DirStr;
   SN : String [12];
BEGIN
     FSplit (Name, D_, Nam, Ext);
     IF MoveFlag THEN BEGIN
        Assign (F1, Name);
        {$I-}
        Rename (F1, P2 + '\' + Nam+Ext);
        {$I+}
        IF IOResult = 0 THEN BEGIN
           Inc (Count);
           WriteLn (Count, ' ' + Nam+Ext+' - moving');
           Exit;
        END
     END;
     Inc (Count);
     Write (Count, ' ' + Nam+Ext + ' - ');
     Assign (F1, Name);
     GetFAttr (F1, Attr);
     {$I-}
     ReSet (F1, 1);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        WriteLn ('read error. Skip to file');
        WriteLn (T, Name + ' - ' + 'read error. Skip to file');
        Exit;
     END;
     GetFTime (F1, FTime);
     SN := Nam + Ext;
     REPEAT
          Assign (F2, P2 + '\' + SN);
          {$I-}
          ReSet (F2, 1);
          {$I+}
          IF IOResult = 0 THEN BEGIN
             Write ('file already coping. Overwrite [Y/N/R/Q]? ');
             IF AlwaysFlag = 0 THEN BEGIN
                REPEAT
                REPEAT UNTIL KeyPressed;
                WHILE KEYPRESSED DO Ch := ReadKey;
                UNTIL UpCase (Ch) in ['Y','N','R','Q'];
             END ELSE BEGIN
                 CASE AlwaysFlag OF
                 1 : Ch := 'Y';
                 2 : Ch := 'N';
                 3 : Ch := 'R';
                 END;
             END;
             CASE UpCase (Ch) OF
             'Y' : BEGIN
                   WriteLn ('Y ');
                   Write (Count, ' ' + SN + ' - ');
                   Close (F2);
                   SetFAttr (F2, Archive);
                   Erase (F2);
                   WriteLn (T, Name + ' - ' + 'file already coping. OverWrite to file');
                   Break;
                   END;
             'N' : BEGIN
                     Close (F2);
                     Close (F1);
                     WriteLn (T, Name + ' - ' + 'file already coping. Skip to file');
                     WriteLn ('N');
                     Write (Count, ' ' + SN + ' - ');
                     WriteLn ('skip to file');
                     Exit;
                   END;
             'R' : BEGIN
                      Close (F2);
                      WriteLn ('R');
                      Write ('Enter new name: ');
                      IF AlwaysFlag = 3 THEN NewName (SN)
                      ELSE ReadLn (SN);
                      SN := UpStr (SN);
                      IF SN = '' THEN SN := 'ERROR.VIR';
                      Write (Count, ' ' + SN + ' - ');
                      WriteLn (T, Name + ' - ' + 'file already coping. Rename file to '+SN);
                   END;
             'Q' : BEGIN
                     Close (F2);
                     Close (F1);
                     WriteLn (T, Name + ' - ' + 'file already coping. Break from user');
                     Close (T);
                     WriteLn ('Q');
                     Write (Count, ' ' + SN + ' - ');
                     WriteLn ('Exit to DOS');
                     {$I-}
                     ChDir (Dir);
                     {$I+}
                     IF IOResult <> 0 THEN BEGIN
                        WriteLn ('Change path to '+DIR+'\ error');
                        Halt;
                     END;
                     Halt (3);
                   END;
             END;
          END ELSE Break;
     UNTIL False;

     {$I-}
     ReWrite (F2, 1);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        Close (F1);
        WriteLn ('error writing');
        WriteLn (T, Name + ' - ' + 'error writing');
        Close (T);
        {$I-}
        ChDir (Dir);
        {$I+}
        IF IOResult <> 0 THEN BEGIN
           WriteLn ('Change path to '+DIR+'\ error');
           Exit;
        END;
        Halt (1);
     END;
     I := FileSize (F1);
     GetMem (P, 65535);
     REPEAT
           BlockRead (F1, P^, 65535, ER);
           BlockWrite (F2, P^, ER, EW);
           IF ER <> EW THEN BEGIN
              WriteLn ('Input/Output error');
              FreeMem (P, 65535);
              Close (F1);
              Close (F2);
              WriteLn (T, Name + ' - ' +  'Input/Output error');
              Close (T);
              {$I-}
              ChDir (Dir);
              {$I+}
              IF IOResult <> 0 THEN BEGIN
                 WriteLn ('Change path to '+DIR+'\ error');
                 Halt;
              END;
              Halt (2);
           END;
           IF EW <> 65535 THEN Break;
     UNTIL False;
     FreeMem (P, 65535);
     Close (F1);
     SetFTime (F2, FTime);
     Close (F2);
     SetFAttr (F2, Attr);
     Write (I);
     IF MoveFlag THEN Erase (F1);
     WriteLn;
END;

BEGIN
     Count := 0;
END.
