                      Program v_95th_Scanner;
(*-----------------------------------------------------------------*)
(*  (C) by TechnoRat "95-th Harrier Scanner"    13-Sep-1997y v1.0  *)
(*-----------------------------------------------------------------*)
Uses Crt,Dos;
(*$R-,I-*)
(*$M 32768,0,0*)

(*-----------------------------------------------------------------*)
Var TotalScanFiles,LocalScanFiles,
    TotalScanPaths,LocalScanPaths:LongInt;

(*-----------------------------------------------------------------*)
Function Path(S:String):String;       (* Make the path from string *)
Begin
 If S<>'' Then If Copy(S,Length(S),1)<>'\' Then S:=S+'\';
 Path:=S;
End;

(*-----------------------------------------------------------------*)
Function Infected(Name:String):Byte;
Var F:File; L:LongInt; I,W,W1:Word;
    S:String[8];
Begin Infected:=1;
 Assign(F,Name); Reset(F,1); If IOResult<>0 Then Exit;
 If FileSize(F)<$40 Then Begin Infected:=0; Close(F); Exit; End;
 W:=0; W1:=0; L:=0; BlockRead(F,W,SizeOf(W));
 Seek(F,$18); BlockRead(F,W1,SizeOf(W1));
 Seek(F,$3C); BlockRead(F,L,SizeOf(L));
 If IOResult<>0 Then Begin Close(F); Exit; End;
 If ((W<>$4D5A) And (W<>$5A4D)) Or (W1<$40) Then Begin
  Infected:=0; Close(F); Exit;
 End;
 Seek(F,L); BlockRead(F,L,SizeOf(L));
 Seek(F,FilePos(F)+2); BlockRead(F,W,SizeOf(W));
 Seek(F,FilePos(F)+12); BlockRead(F,W1,SizeOf(W1));
 Seek(F,FilePos(F)+W1+2);
 If (IOResult<>0) Or (L<>$4550) Then Begin
  Infected:=0; Close(F); Exit;
 End;
 For I:=1 To W Do Begin
  FillChar(S,SizeOf(S),0); S[0]:=#8; BlockRead(F,S[1],8);
  If S='.TEXT'#0#0#0 Then Begin
   Infected:=2; Close(F); Exit;
  End; Seek(F,FilePos(F)+32);
 End;
 If IOResult=0 Then Infected:=0;
 Close(F);
End;

(*-----------------------------------------------------------------*)
Procedure ScanPath(S:String);
Const Msg:Array[1..2] Of String[10]=('IO error','Infected');
Var SR:SearchRec; M:Byte;
Begin Inc(LocalScanPaths);
 FindFirst(S+'*.*',AnyFile-VolumeID,SR);
 If DosError=0 Then Repeat
  If SR.Name[1]<>'.' Then Begin
   If (SR.Attr And Directory)<>0 Then ScanPath(S+SR.Name+'\')
   Else Begin
    Write(#13); ClrEol; Write(S,SR.Name);
    Inc(LocalScanFiles); M:=Infected(S+SR.Name);
    If M<>0 Then WriteLn(' - ',Msg[M],'!');
   End;
  End; FindNext(SR);
 Until DosError<>0;
End;

(*-----------------------------------------------------------------*)
Var I:Integer;
Begin FileMode:=0;
 WriteLn('(C) 13-Sep-1997y by TechnoRat "95th Harrier Scanner" v1.0');
 WriteLn('                              ~~~~~~~~~~~~~~~~~~~~~~');
 If ParamCount=0 Then Begin
  WriteLn('Usage: 95SCAN.EXE Path4Scan1 Path4Scan2 . . .');
  WriteLn('       - for scanning on 95-th Harrier Infection');
  Exit;
 End; TotalScanFiles:=0; TotalScanPaths:=0;
 For I:=1 To ParamCount Do Begin
  WriteLn('Scanning path - ',ParamStr(I));
  LocalScanFiles:=0; LocalScanPaths:=0;
  ScanPath(Path(ParamStr(I)));
  Write(#13); ClrEol;
  WriteLn('Scanned ',LocalScanPaths,' path(s), contained ',
          LocalScanFiles,' file(s).'); WriteLn;
  Inc(TotalScanFiles,LocalScanFiles);
  Inc(TotalScanPaths,LocalScanPaths);
 End;
 WriteLn('Total scanned: ',TotalScanPaths,' path(s), contained ',
         TotalScanFiles,' file(s).');
End.
(*-----------------------------------------------------------------*)
