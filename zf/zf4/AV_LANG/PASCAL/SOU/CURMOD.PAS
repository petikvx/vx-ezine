UNIT CurMod;

INTERFACE

{$I-}

Uses CRT, DOS, GlobVar, VirBase, CureLib;

procedure CopyFile (S : String);
procedure Beenden;

IMPLEMENTATION

function FindSign (FName : String) : Boolean;
var
   f : File;
   A : Integer;
   B, C, D : Word;
   P, PB : Pointer;
   Flag, Flag1, Flag2 : Boolean;
   RC   : Word;
   i    : Integer;
begin
     FlagError := False;
     Assign (f, S);
     SetFAttr (f, Archive);
     ReSet (f, 1);
     A := IOResult;
     if A <> 0 then begin
        Inc (CouErrorFile);
        GotoXY (1, WhereY);
        ClrEol;
        WriteLn ('File ', S, ' open error: ', A);
        if TextMode then
           WriteLn (tProt, 'File ', S, ' open error: ', A);
        FindSign := False;
        FlagError := True;
        Exit;
     end;
     FileMode := 2;
     B := FileSize(f);
     if B > 65535 then begin
        Inc (CouErrorFile);
        Close (f);
        GotoXY (1, WhereY);
        ClrEol;
        WriteLn ('File ', S, ' too long');
        if TextMode then
           WriteLn (tProt, 'File ', S, ' too long');
        FindSign := False;
        FlagError := True;
        Exit;
     end;
     C := SR.Size;
     if (C <> B) then begin
        Inc (CouErrorFile);
        Close (f);
        GotoXY (1, WhereY);
        ClrEol;
        WriteLn ('FileSize ', S, ' was changed! ', C, '/', B);
        if TextMode then
           WriteLn (tProt, 'FileSize ', S, ' was changed! ', C, '/', B);
        FindSign := False;
        FlagError := True;
        Exit;
     end;
     GetMem (P, B);
     BlockRead (f, P^, B, RC);
     if RC <> B then begin
        Inc (CouErrorFile);
        FreeMem (P, B);
        Close (f);
        GotoXY (1, WhereY);
        ClrEol;
        WriteLn ('File ', S, ' open error');
        if TextMode then
           WriteLn (tProt, 'File ', S, ' open error');
        FindSign := False;
        FlagError := True;
        Exit;
     end;
     Flag := False;
     for i := 1 to CouRecords do begin
         PB := Addr(Signature[i].Sig1Info.SigArray[1]);
         Flag1 := BlockPresent (P^, PB^, B, Signature[i].Sig1Info.SigLength);
         if Flag1 then
            Signature[i].Sig1Info.SigOffset := BlockOffs (P^, PB^, B,
                                            Signature[i].Sig1Info.SigLength);
         PB := Addr(Signature[i].Sig2Info.SigArray[1]);
         Flag2 := BlockPresent (P^, PB^, B, Signature[i].Sig2Info.SigLength);
         if Flag2 then
            D := BlockOffs (P^, PB^, B, Signature[i].Sig2Info.SigLength);
         if (not Flag1) or (not Flag2) then Continue;
         D := D - Signature[i].Sig1Info.SigOffset;
         if D <> Signature[i].Sig2Info.SigOffset then Continue;
         Flag := True;
         Inc (Signature[i].CouFind);
         NumOfRecord := i;
         Break;
     end;
     FreeMem (P, B);
     Close (f);
     FindSign := Flag;
end;

procedure CopyFile (S : String);
var
   Dir : DirStr;
   Nam : NameStr;
   Ext : ExtStr;
   A   : Integer;
   Rea : String;
   f : File;
   Ch : Char;
begin
     GotoXY (1, WhereY);
     ClrEol;
     if KeyPressed then begin
        while KeyPressed do Ch := ReadKey;
        if Ord (Ch) = 27 then begin
           WriteLn;
           WriteLn ('*User break*');
           if TextMode then begin
              WriteLn (tProt);
              WriteLn (tProt, '*User break*');
           end;
           Beenden;
           Halt (1);
        end;
     end;
     A := IOResult;
     if A <> 0 then begin
        Inc (CouErrorFile);
        WriteLn ('File ', S, ' open error: ', A);
        if TextMode then
           WriteLn (tProt, 'File ', S, ' open error: ', A);
        Exit;
     end;
     FSplit (S, Dir, Nam, Ext);
     GotoXY (1, WhereY);
     ClrEol;
     Write (Dir);
     if Pos('COM', UpStr(Ext)) = 0 then Exit;
     Inc (CouFileFound);
     if (not FindSign (S)) then begin
        if FlagError then Exit;
        if OkMode then begin
           WriteLn (Nam, Ext, ' - Ok');
           if TextMode then
              WriteLn (tProt, S, ' - Ok');
        end;
        Exit;
     end;
     GotoXY (1, WhereY);
     ClrEol;
     Rea := S + ' - infected ' + Signature[NumOfRecord].VirName;
     Inc (CouFileInfect);
     if CureMode then begin
        case Signature[NumOfRecord].Desinfect of
             DisinfNo :  begin
                           Assign (f, S);
                           SetFAttr (f, Archive);
                           Inc (CouFileErased);
                           Rea := Rea + ' - killed';
                           Erase (f);
                         end;
             DisinfYes : begin
                           case Signature[NumOfRecord].TypeWrt of
                                TypeBeg : FromBegOfFile (S, Rea);
                                TypeMov : None (Rea);
                                TypeAdd : None (Rea);
                                TypeIns : None (Rea);
                                TypeEnd : FromEndOfFile (S, Rea);
                                TypeOvr : begin
                                            Assign (f, S);
                                            SetFAttr (f, Archive);
                                            Inc (CouFileErased);
                                            Rea := Rea + ' - killed';
                                            Erase (f);
                                          end;
                                TypeSat : None (Rea);
                                TypeUep : None (Rea);
                           end;
                         end;
        end;
     end;
     A := IOResult;
     WriteLn (Rea);
     if TextMode then
        WriteLn (tProt, Rea);
end;

procedure TestMode;
var
   i : integer;
   S : String;
   Dir : DirStr;
   Nam : NameStr;
   Ext : ExtStr;
begin
     S := '';
     for i := 1 to ParamCount do
         S := S + ' ' + UpStr (ParamStr (i));
     if Pos ('/O', S) > 0 then OkMode   := True;
     if Pos ('/C', S) > 0 then CureMode := True;
     if Pos ('/P', S) > 0 then TextMode := True;
     FSplit (ParamStr (0), Dir, Nam, Ext);
     if Dir[Length(Dir)] = '\' then Dec(Byte(Dir[0]));
     HomeDir := Dir;
     if TextMode then begin
        with StartTime do begin
             GetDate(Year,Month,Day, y);
             GetTime (Hour, Min, Sec, y);
        end;
        Assign (tProt, HomeDir + '\PASAV.RPT');
        Append (tProt);
        if IOResult <> 0 then
           ReWrite (tProt)
        else begin
             WriteLn (tProt);
             WriteLn (tProt);
             WriteLn (tProt);
             WriteLn (tProt);
             WriteLn (tProt);
        end;
        WriteLn (tProt, 'Example for ZF (c) 2000 by RedArc');
        WriteLn (tProt);
        WriteLn (tProt, ParamStr (0), S);
        with StartTime do
             WriteLn (tProt, 'Date: ', Year, '/', Month, '/', Day);
        WriteLn (tProt);
     end;
end;

procedure Beenden;
begin
      ChDir (HomeDir);
      GotoXY (1, WhereY);
      ClrEol;
      WriteLn;
      with EndTime do begin
           GetDate(Year,Month,Day, y);
           GetTime (Hour, Min, Sec, y);
      end;
      PackTime (StartTime, STime);
      PackTime (EndTime, ETime);
      ETime := ETime - STime;
      UnpackTime (ETime, EndTime);
      for STime := 1 to CouRecords do
          if Signature [STime].CouFind > 0 then Inc (CouVirusFind);
     if TextMode then begin
        WriteLn (tProt, '-----');
        WriteLn (tProt, 'Known viruses     - ', CouRecords);
        WriteLn (tProt, 'Files found       - ', CouFileFound);
        WriteLn (tProt, 'Infected files    - ', CouFileInfect);
        WriteLn (tProt, 'Desinfected files - ', CouFileDesinf);
        WriteLn (tProt, 'Erased files      - ', CouFileErased);
        WriteLn (tProt, 'Viruses finded    - ', CouVirusFind);
        WriteLn (tProt, 'Skiped viruses    - ', CouVirusSkip);
        WriteLn (tProt, 'Errors in files   - ', CouErrorFile);
        WriteLn (tProt, '*****');
        for STime := 1 to CouRecords do
            if Signature [STime].CouFind > 0 then begin
               WriteLn (tProt, Signature [STime].VirName, ' - ',
                        Signature [STime].CouFind, ' viruses found');
            end;
        WriteLn (tProt, '*****');
        with EndTime do
             WriteLn (tProt, 'Search time: ', Hour, ':', Min, ':', Sec);
        Close (tProt);
     end;
     WriteLn ('-----');
     WriteLn ('Known viruses     - ', CouRecords);
     WriteLn ('Files found       - ', CouFileFound);
     WriteLn ('Infected files    - ', CouFileInfect);
     WriteLn ('Desinfected files - ', CouFileDesinf);
     WriteLn ('Erased files      - ', CouFileErased);
     WriteLn ('Viruses finded    - ', CouVirusFind);
     WriteLn ('Skiped viruses    - ', CouVirusSkip);
     WriteLn ('Errors in files   - ', CouErrorFile);
     WriteLn ('*****');
     for STime := 1 to CouRecords do
         if Signature [STime].CouFind > 0 then begin
            WriteLn (Signature [STime].VirName, ' - ',
                     Signature [STime].CouFind, ' viruses found');
         end;
     WriteLn ('*****');
     with EndTime do
          WriteLn ('Search time: ', Hour, ':', Min, ':', Sec);
end;

BEGIN
     TestMode;
END.
