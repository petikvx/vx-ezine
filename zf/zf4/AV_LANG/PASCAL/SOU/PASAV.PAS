{$A-,B-,D-,E-,F-,G+,I-,L-,N+,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
{$M 65520,200000,655360}

{
(****************************************************************************)
(*****                     PASAV (c) 2000 by RedArc                     *****)
(*****     Антивирусная программа на языке Borland Pascal Version 7.0   *****)
(*****       специально для электронного журнала "Земский Фершал"       *****)
(****************************************************************************)
}

Program PasAV;

Uses CRT, DOS, GlobVar, VirBase, CurMod, FIND;
{$I-}
begin
     with StartTime do begin
          GetDate(Year,Month,Day, y);
          GetTime (Hour, Min, Sec, y);
     end;
     {Подключение записей с информацией о вирусах}
     InitRecords;
     {}
     Path := ParamStr (1);
      if (Path <> '*') and (Path <> '+') and (Path <> '-')
      and (Path[1] <> '/') then begin
         ChDrive (Ord(UpCase(Path[1]))-65);
         Path := UpStr (Path);
         ScanDir(Path);
         ChDrive (Ord(UpCase(HomeDir[1]))-65);
         ChDir(HomeDir);
      end else begin
          TestDrives (HD);
          for Ch := 'A' to 'Z' do
              if Ch in HD then begin
                 if (ParamStr(1) = '+') then
                    if (Ch < 'C') then Continue;
                 if (ParamStr(1) = '-') then
                    if (Ch > 'B') then Break;
                 Path := Ch + ':';
                 ChDrive (Ord(UpCase(Path[1]))-65);
                 ScanDir(Path);
              end;
      end;
      Beenden;
end.
