                 Program Include_Binary_In_File;
(*-----------------------------------------------------------------*)
(*  (C) by TechnoRat "IncludeBinaryInFile"  04-Sep-1997y Ver: 1.0  *)
(*-----------------------------------------------------------------*)
(*$R-,I-,Q+*)(*$M 4096,0,0*)

(*-----------------------------------------------------------------*)
(*                       E X C E P T I O N                         *)
(*-----------------------------------------------------------------*)
Procedure Error(Err:Byte; S:String);
Begin
 WriteLn('Error: ',S,'!');
 Halt(Err);
End;

(*-----------------------------------------------------------------*)
(*                           T O O L S                             *)
(*-----------------------------------------------------------------*)
Function UpStr(S:String):String;
Var I:Integer;
Begin
 For I:=1 To Length(S) Do S[I]:=UpCase(S[I]);
 UpStr:=S;
End;

(*-----------------------------------------------------------------*)
Function CutName(N:String):String;
Var I:Byte;
Begin
 For I:=Length(N) DownTo 1 Do Begin
  If N[I]='\' Then Begin
   CutName:=Copy(N,I+1,Length(N)-I);
   Exit;
  End;
 End; CutName:=N;
End;

(*-----------------------------------------------------------------*)
Function Equ(P1,P2:Pointer; Sz:Word):Boolean;Assembler;
Asm
 Mov    Dx,Ds
 Les    Di,P1
 Lds    Si,P2
 Mov    Cx,Sz
 Cld
 Repe   CmpsB
 Mov    Al,False
 Jne    @Done
 Mov    Al,True
@Done:
 Mov    Ds,Dx
End;

(*-----------------------------------------------------------------*)
(*                      M A I N   E N T R Y                        *)
(*-----------------------------------------------------------------*)
Const BufSize=16384; BBufSize=16384;
Var BFileName,TFileName:String; BFile,TFile:File;
    Buf:Array[1..BufSize] Of Byte;
    BBuf:Array[1..BBufSize] Of Byte;
    L,P,L1,P1,I:LongInt; W,W1,J,LL:Word;
    SLabel:String;
Begin
 WriteLn('(C) 4-Sep-1997y by TechnoRat "Include Bin Into File" V1.0');
 WriteLn('                             ~~~~~~~~~~~~~~~~~~~~~~~');
 If ParamCount<2 Then Begin
  WriteLn('Usage: INCFILE.EXE BinFile TargetFile');
  WriteLn(' -to include some BinFile in TargetFile at position');
  WriteLn('  BinFileName into TargetFile');
  Exit;
 End; BFileName:=UpStr(ParamStr(1)); TFileName:=UpStr(ParamStr(2));
 SLabel:=CutName(BFileName); LL:=Length(SLabel);
 If LL=0 Then Error(1,'Binary file name required');
 Assign(TFile,TFileName); Reset(TFile,1);
 If IOResult<>0 Then Error(1,'Opening target file '+TFileName+' failure');
 P:=0; L:=FileSize(TFile); While P<L Do Begin
  If (L-P)>BufSize Then W:=BufSize Else W:=L-P;
  Seek(TFile,P); BlockRead(TFile,Buf,W);
  If IOResult<>0 Then Error(1,'Reading target file failure');
  For J:=1 To W Do Buf[J]:=Ord(UpCase(Char(Buf[J])));
  If W>=LL Then Begin
   I:=1; J:=W-LL+1; While I<=J Do Begin
    If Equ(@SLabel[1],@Buf[I],LL) Then Begin
     Write(SLabel,' founded at position ',P+I-1,'; ');
     Seek(TFile,P+I-1); Assign(BFile,BFileName); Reset(BFile,1);
     If IOResult<>0 Then Error(1,'Opening binary file '+BFileName+' failure');
     P1:=0; L1:=FileSize(BFile); While P1<L1 Do Begin
      If (L1-P1)>=BBufSize Then W1:=BBufSize Else W1:=L1-P1;
      BlockRead(BFile,BBuf,W1); BlockWrite(TFile,BBuf,W1);
      If IOResult<>0 Then Error(2,'Fatal transferring failure. File'+
       ' can be processed incorrectly');
      Inc(P1,W1);
     End; Close(BFile); Inc(I,L1);
     WriteLn('included ',L1,' bytes OK.');
    End Else Inc(I);
   End; Inc(P,I-1);
  End Else Inc(P,W);
 End; WriteLn('File was processed OK.');
End.
(*-----------------------------------------------------------------*)
