                       Program ASM_Swapper;
(*-----------------------------------------------------------------*)
(*   (C) by TechnoRat "Tool for NextHarrier" 18-Jan-1997y Ver: 1.0 *)
(*                                           03-Feb-1997y Ver: 1.1 *)
(*                                           14-Mar-1997y Ver: 1.2 *)
(*                  "Tool for 95-th Harrier" 11-Aug-1997y Ver: 1.3 *)
(*-----------------------------------------------------------------*)
(*$I+,R-*)(*$M 16384,0,655360*)

(*-----------------------------------------------------------------*)
(*                      E X C E P T I O N                          *)
(*-----------------------------------------------------------------*)
Const StdFault='Unknown failure';
Type Resources=(rOutputFile, rMemory, rInputFile);
Var Status:Set Of Resources;
    InFile,OutFile:Text; Heap:Pointer;
    InFileName,OutFileName:String;
    PossibleFault:String;
    OldExit:Pointer;

(*-----------------------------------------------------------------*)
(*$I-*)
Procedure ExceptionProc;Far;
Begin
 If ErrorAddr<>Nil Then Begin
  WriteLn(#10#13'Error(',ExitCode,'): ',PossibleFault,'!');
  ErrorAddr:=Nil;
 End Else If ExitCode=255 Then Begin
  WriteLn('Ctrl-Break passed!');
 End;

 If rMemory In Status Then Release(Heap);
 If rOutputFile In Status Then Erase(OutFile);
 If rInputFile In Status Then Close(InFile);
End;
(*$I+*)

(*-----------------------------------------------------------------*)
Procedure Fault(S:String);
Begin
 PossibleFault:=S; RunError;
End;

(*-----------------------------------------------------------------*)
Function UpStr(S:String):String;
Var I:Integer;
Begin
 For I:=1 To Length(S) Do S[I]:=UpCase(S[I]);
 UpStr:=S;
End;

(*-----------------------------------------------------------------*)
(*                       M A I N   E N T R Y                       *)
(*-----------------------------------------------------------------*)
Const cmStartC=';STARTCODE'; cmStopC=';STOPCODE';
      cmLongLineC=';DEFCODELINE'; cmBreakC=';BREAKCODELINE';
      cmStartD=';STARTDATA'; cmStopD=';STOPDATA';
      cmLongLineD=';DEFDATALINE'; cmBreakD=';BREAKDATALINE';

      cmSeparatorC=';SEPARATOR='; cmSeparatorD=';'#0#0#0;

Type
 PLine=^TLine;
 TLine=Record L:String[91]; Next:PLine; End;
 PSource=^TSource;
 TSource=Record D:PLine; S:String[7]; N:LongInt; End;
Const MaxLines=5000;

Var cmStart,cmStop,cmLongLine,cmBreak,cmSeparator:String[20];
Var Source:Array[1..MaxLines] Of PSource; CodeWorkMode:Boolean;

(*-----------------------------------------------------------------*)
Var I,J,Lines,SLine,FromL,ToL:LongInt; S,Prefix,Separator:String;
    P,PP:PLine; Flg:Boolean; Mem1,Mem2:LongInt; P2S:PSource;
    FirstSeparator:String;
Begin
 Status:=[]; Mark(Heap); PossibleFault:=StdFault;
 OldExit:=ExitProc; ExitProc:=@ExceptionProc;

 WriteLn('(C) 11-Aug-1997y by TechnoRat "ASM Swapper Tool" v1.3');
 WriteLn('                              ~~~~~~~~~~~~~~~~~~     ');
 If ParamCount<3 Then Begin
  If ParamStr(1)='/?' Then Begin
   WriteLn('Welcome to .ASM sources scrambler. Inside the .ASM sources');
   WriteLn('You can use the following commands:');
   WriteLn('Code work mode:');
   WriteLn(cmStartC:15,' -open processing block (global context)');
   WriteLn(cmStopC:15,' -close processing block (global context)');
   WriteLn(cmLongLineC:15,' -define some long line');
   WriteLn(cmBreakC:15,' -break long line definition.');
   WriteLn(cmSeparatorC:15,' -define new separator.');
   WriteLn('Data work mode:');
   WriteLn(cmStartD:15,' -open processing block (global context)');
   WriteLn(cmStopD:15,' -close processing block (global context)');
   WriteLn(cmLongLineD:15,' -define some long line');
   WriteLn(cmBreakD:15,' -break long line definition.');
   WriteLn('Long lines must be  declared only  inside  the  processing');
   WriteLn('block,  nested  commands is improper. Mixing code and data');
   WriteLn('blocks is not recommended.');
   WriteLn('   Commands must  be  written from the position 1 of line.');
   WriteLn('Spaces  and tabstops are  not allowed. Maximal line length');
   WriteLn('is 91 chars. Maximal separator length is 7 chars.');
   WriteLn;
   WriteLn('Seek And Destroy!                                TechnoRat');
   Exit;
  End;
  WriteLn('Usage: ASMSWAP.EXE /?');
  WriteLn('       - Show brief help message.');
  WriteLn('       ASMSWAP.EXE Prefix InFile OutFile');
  WriteLn('       - Scramble InFile to OutFile with Prefix.');
  WriteLn('       ASMSWAP.EXE /Data InFile OutFile');
  WriteLn('       - Scramble InFile to OutFile in DATA work mode.');
  Exit;
 End;

 InFileName:=ParamStr(2); OutFileName:=ParamStr(3); Prefix:=ParamStr(1);
 Assign(InFile,InFileName);
 PossibleFault:='Unable to open input file';
 Reset(InFile); Status:=Status+[rInputFile];

 CodeWorkMode:=(UpStr(ParamStr(1))<>'/DATA');
 Separator:='Jmp'; FirstSeparator:='';
 If CodeWorkMode Then Begin
  cmStart:=cmStartC; cmStop:=cmStopC;
  cmLongLine:=cmLongLineC; cmBreak:=cmBreakC;
  cmSeparator:=cmSeparatorC;
 End Else Begin
  cmStart:=cmStartD; cmStop:=cmStopD;
  cmLongLine:=cmLongLineD; cmBreak:=cmBreakD;
  cmSeparator:=cmSeparatorD;
 End;

(*-----------------------------------------------------------------*)
 Mem1:=MemAvail; Status:=Status+[rMemory];
 Lines:=0; SLine:=0; FromL:=0; ToL:=0; Flg:=False;
 PossibleFault:='Disk reading error or memory overflow';
 While Not(Eof(InFile)) Do Begin
  ReadLn(InFile,S); If S='' Then Continue; (*Skip Blank Lines*)

  If (Length(S)>1) And (S[1]=';') Then Begin (*Pre-Processing commands*)
   If UpStr(Copy(S,1,Length(cmSeparator)))=cmSeparator Then Begin
    If Not(CodeWorkMode) Then Fault('Illegal use '+cmSeparator+' command');
    (* reserved for future ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ *)
    If (FromL=0) Or (ToL<>0)
     Then Fault('Unexpected '+cmSeparator+' command');
    If Flg Then Fault('Nested '+cmSeparator+' command');
    Separator:=Copy(S,Length(cmSeparator)+1,Length(S)-Length(cmSeparator));
    Continue; (*Next Cycle*)
   End;
  End; If FirstSeparator='' Then FirstSeparator:=Separator;

  New(P); P^.L:=S; P^.Next:=Nil;                       (*Processing*)
  Inc(SLine); Write(' Reading line ',SLine,' . . .'#13);
  If Not(Flg) Then Begin
   Inc(Lines); If Lines>MaxLines Then Fault('Handlers array overflow');
   New(Source[Lines]); Source[Lines]^.D:=P; PP:=P;
   Source[Lines]^.S:=Copy(Separator,1,7);
   Source[Lines]^.N:=Lines;
  End Else Begin
   PP^.Next:=P; PP:=P;
  End;

  If (Length(S)>1) And (S[1]=';') Then Begin (*Post-Processing commands*)
   S:=UpStr(S); If S=cmStart Then Begin
    If FromL<>0 Then Fault('Nested '+cmStart+' command');
    FromL:=Lines+1;
   End Else If S=cmStop Then Begin
    If FromL=0 Then Fault('Unexpected '+cmStop+' command');
    If ToL<>0 Then Fault('Nested '+cmStop+' command');
    ToL:=Lines-1;
   End Else If S=cmLongLine Then Begin
    If (FromL=0) Or (ToL<>0)
     Then Fault('Unexpected '+cmLongLine+' command');
    If Flg Then Fault('Nested '+cmLongLine+' command');
    Flg:=True;
   End Else If S=cmBreak Then Begin
    If Not(Flg) Then Fault('Unexpected '+cmBreak+' command');
    Flg:=False;
   End;
  End;
 End;
 If Flg Then Fault('Still opened '+cmLongLine+' command');
 If (FromL=0) And (ToL=0) Then Begin
  FromL:=1; ToL:=Lines;
 End Else If ToL=0 Then Fault('Expected '+cmStop+' command');
 Close(InFile); Status:=Status-[rInputFile];
 Mem2:=Mem1-MemAvail;

(*-----------------------------------------------------------------*)
 Randomize; PossibleFault:=StdFault;
 For I:=FromL To ToL Do Begin
  Write(' Processing string ',I,' . . .'#13);
  J:=Random(ToL-FromL+1)+FromL; P2S:=Source[J];
  Source[J]:=Source[I]; Source[I]:=P2S;
 End;

 Assign(OutFile,OutFileName);
 PossibleFault:='Unable to create output file';
 Rewrite(OutFile); Status:=Status+[rOutputFile];

(*-----------------------------------------------------------------*)
 PossibleFault:='Disk writing error or no room on disk';
 For I:=1 To Lines Do Begin
  Write(' Writing target string ',I,' . . .'#13);
  If CodeWorkMode Then Begin
   If I=FromL Then WriteLn(OutFile,FirstSeparator,' ',Prefix,FromL);
   If (I>=FromL) And (I<=ToL) Then
    WriteLn(OutFile,Prefix,Source[I]^.N,':');
  End;
  P:=Source[I]^.D; Repeat
   WriteLn(OutFile,P^.L);
   P:=P^.Next;
  Until P=Nil;
  If CodeWorkMode Then Begin
   If (I>=FromL) And (I<=ToL) Then
    WriteLn(OutFile,Source[I]^.S,' ',Prefix,Source[I]^.N+1);
   If I=ToL Then WriteLn(OutFile,Prefix,ToL+1,':');
  End;
 End; Close(OutFile); Release(Heap);
 Status:=Status-[rMemory,rOutputFile];

(*-----------------------------------------------------------------*)
 WriteLn('Total loaded ',SLine,' lines.  Processed ',Lines,' strings.');
 WriteLn('Available memory ',Mem1,' bytes.  Memory used ',Mem2,' bytes.');
 WriteLn;
End.
