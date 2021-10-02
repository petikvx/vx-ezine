                  Program Define_File_Parameters;
(*-----------------------------------------------------------------*)
(*  (C) by TechnoRat "DefineFileParameters" 04-Sep-1997y Ver: 1.0  *)
(*-----------------------------------------------------------------*)
(*$R-,I-*)
Var K,N:String; F:File; Sz:LongInt;
Begin
 If ParamCount<2 Then Begin
  WriteLn('(C) 4-Sep-1997y by TechnoRat "Define the File Parameters" V1.0');
  WriteLn('                             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  WriteLn('Usage: DEFFILE.EXE KeyName FileName -to define some .Asm key');
  Exit;
 End; K:=ParamStr(1); N:=ParamStr(2);
 Assign(F,N); Reset(F,1); If IOResult<>0 Then Begin
  WriteLn('File ',N,' not found or error opening file!');
  Halt(1);
 End; Sz:=FileSize(F); Close(F);
 WriteLn(K,'_Sz'#9#9'Equ'#9,Sz);
End.
(*-----------------------------------------------------------------*)
