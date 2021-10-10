PROGRAM WebPrepar;

USES CRT, DOS;

{$I-}

CONST
     Ident1         = 'DrWeb report prepare (c) 1998 by RedArc // TAVC';
     Ident2         = '           Source: MooN BuG issue 7';
     Autors         = 'Дикшев Игорь Владиславович';
     BAK            = '.bak';

VAR
   T, T1 : Text;
   Dir : DirStr;
   Nam : NameStr;
   Ext : ExtStr;
   S, S1 : String;
   S2 : String [79];
   I, J : Byte;

procedure Info;
begin
     WriteLn;
     WriteLn (Ident1);
     WriteLn (Ident2);
     WriteLn;
     WriteLn ('Usage: webprepar.exe report.dwb');
     WriteLn;
end;

BEGIN
     if (ParamCount <> 1) or (Pos ('?', ParamStr (1)) <> 0) then begin
        Info;
        Exit;
     end;
     Assign (T, ParamStr (1));
     ReSet (T);
     if IOResult <> 0 then begin
        Info;
        WriteLn ('File ', ParamStr (1), ' not open');
        WriteLn;
        Exit;
     end;
     Close (T);
     FSplit (ParamStr (1), Dir, Nam, Ext);
     Assign (T1, Nam + BAK);
     ReSet (T1);
     if IOResult = 0 then begin
        Close (T1);
        Erase (T1);
        if IOResult <> 0 then begin
           Info;
           WriteLn ('File ', Nam + BAK, ' erase error');
           WriteLn;
           Exit;
        end;
     end;
     Rename (T, Nam + BAK);
     if IOResult <> 0 then begin
        Info;
        WriteLn ('File ', Nam + BAK, ' create error');
        WriteLn;
        Exit;
     end;
     ReSet (T1);
     Assign (T, ParamStr (1));
     ReWrite (T);
     ClrEOL;
     repeat
           ReadLn (T1, S1);
           if IOResult <> 0 then begin
              Info;
              WriteLn ('File ', Nam + BAK, ' read error');
              WriteLn;
              Exit;
           end;
           if S1 [1] = '' then Break;
           if S1 [2] <> ':' then
              WriteLn (T, S1);
              S2 := S1;
              if Byte (S2 [0]) > 79 then Byte (S2 [0]) := 79;
              GotoXY (1, 25);
              ClrEOL;
              Write (S2);
     until S1 [2] = ':';
     if S1 [1] = '' then begin
        while S1 [1] = '' do begin
              Delete (S1, 1, 1);
        end;
        if Pos ('.', S1) <> 0 then begin
           I := Pos ('.', S1);
           while (S1 [I] <> '\') and (S1 [I] <> ' ') do Inc (I);
           if S1 [I] <> ' ' then begin
              J := I;
              while S1 [J] <> ' ' do Inc (J);
              Delete (S1, I, J - I);
           end;
           J := I;
           while S1 [J] = ' ' do Inc (J);
           Delete (S1, I, J - I - 1);
        end;
     end;
     while not EOF (T1) do begin
           repeat
                ReadLn (T1, S);
                if S [1] = '' then begin
                   while S [1] = '' do begin
                         Delete (S, 1, 1);
                   end;
                   if Pos ('.', S) <> 0 then begin
                      I := Pos ('.', S);
                      while (S [I] <> '\') and (S [I] <> ' ') do Inc (I);
                      if S [I] <> ' ' then begin
                         J := I;
                         while S [J] <> ' ' do Inc (J);
                         Delete (S, I, J - I);
                      end;
                      J := I;
                      while S [J] = ' ' do Inc (J);
                      Delete (S, I, J - I - 1);
                   end;
                end;

                if S = S1 then Continue;

                if S [2] <> ':' then begin
                   if Pos (':', S) <> 0 then Break;
                   S1 := S1 + S;
                   Continue;
                end;
                Break;
           until False;
           WriteLn (T, S1);
           S2 := S1;
           if Byte (S2 [0]) > 79 then Byte (S2 [0]) := 79;
           GotoXY (1, 25);
           ClrEOL;
           Write (S2);
           S1 := S;
           if S1 [2] <> ':' then Break;
     end;
     WriteLn (T, S1);
     while not EOF (T1) do begin
           ReadLn (T1, S1);
           WriteLn (T, S1);
           S2 := S1;
           if Byte (S2 [0]) > 79 then Byte (S2 [0]) := 79;
           GotoXY (1, 25);
           ClrEOL;
           Write (S2);
     end;
     Close (T);
     Close (T1);
END.
