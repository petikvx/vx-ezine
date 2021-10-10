PROGRAM AVP_BAD;

USES CRT, DOS;

{$I-}

const
     AVP_TXT = 'avp_bad.txt';
     AVP_BAK = 'avp_bad.bak';
     DRW_TXT = 'drw_bad.txt';
     DRW_BAK = 'drw_bad.bak';

VAR
    T, T1, T2, T_source, T_target : Text;
    S : String;
    I, J : Integer;
    V_TXT, V_BAK : String [12];

function UpStr (S : String) : String;
var
   k : integer;
   S1 : String;
begin
     S1 := '';
     if Length (S) > 0 then begin
        for k := 1 to Length (S) do
            S1 := S1 + UpCase (S [k]);
     end;
     UpStr := S1;
end;

procedure Info;
begin
      ClrScr;
      WriteLn;
      WriteLn ('Antiviral_BAD (c) 1999 by RedArc');
      WriteLn ('USAGE: AVP_BAD.EXE [key]');
      WriteLn ('       key:');
      WriteLn ('            /AVP - for Antiviral toolkit Pro');
      WriteLn ('            /DRW - for Doctor Web ');
      WriteLn;
end;

BEGIN
      if ParamCount <> 1 then begin
         Info;
         Exit;
      end;
      J := 0;
      if UpStr (ParamStr (1)) = '/AVP' then begin
         V_TXT := AVP_TXT;
         V_BAK := AVP_BAK;
         J := 56;
      end;
      if UpStr (ParamStr (1)) = '/DRW' then begin
         V_TXT := DRW_TXT;
         V_BAK := DRW_BAK;
         J := 17;
      end;
      if J = 0 then begin
         Info;
         Exit;
      end;
      Assign (T_source, 'tester.txt');
      ReSet  (T_source);
      if IOResult <> 0 then begin
         WriteLn ('File TESTER.TXT not found');
         Exit;
      end;
      Assign (T_target, V_TXT);
      ReSet  (T_target);
      if IOResult = 0 then begin
         Assign (T, V_BAK);
         ReSet  (T);
         if IOResult = 0 then begin
            SetFAttr (T, Archive);
            Erase (T);
         end;
         Rename (T_target, V_BAK);
      end;
      Assign (T, 'v_bad.ok');
      ReWrite (T);
      Assign (T1, 'v_bad.unk');
      ReWrite (T1);
      Assign (T2, 'v_bad.mod');
      ReWrite (T2);
      while not EOF (T_source) do begin
            ReadLn (T_source, S);
            if Length (S) <> 93 then Continue;
            if S [1] <> 'º' then Continue;
            case S [J] of
                 'O' : WriteLn (T, S);
                 'U' : WriteLn (T1, S);
                 'M' : WriteLn (T2, S);
            end;
      end;
      Close (T2);
      Close (T1);
      Close (T);
      ReSet  (T_source);
      Assign (T_target, V_TXT);
      ReWrite  (T_target);
      for I := 1 to 7 do begin
          ReadLn (T_source, S);
          WriteLn (T_target, S);
      end;
      Close (T_source);
      ReSet (T);
      while not EOF (T) do begin
          ReadLn (T, S);
          WriteLn (T_target, S);
      end;
      Close (T);
      Erase (T);
      ReSet (T1);
      while not EOF (T1) do begin
          ReadLn (T1, S);
          WriteLn (T_target, S);
      end;
      Close (T1);
      Erase (T1);
      ReSet (T2);
      while not EOF (T2) do begin
          ReadLn (T2, S);
          WriteLn (T_target, S);
      end;
      Close (T2);
      Erase (T2);
      Close (T_target);
      WriteLn ('.Finished');
END.
