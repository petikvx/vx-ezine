{$A-,B-,D-,E-,F-,G+,I-,L-,N+,O-,P-,Q-,R-,S-,T-,V-,X+,Y-}
{$M 65520,200000,655360}

{
(****************************************************************************)
(*****                     PASAV (c) 2000 by RedArc                     *****)
(*****     ��⨢���᭠� �ணࠬ�� �� �몥 Borland Pascal Version 7.0   *****)
(*****       ᯥ樠�쭮 ��� �����஭���� ��ୠ�� "���᪨� ���蠫"       *****)
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
     {������祭�� ����ᥩ � ���ଠ樥� � ������}
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
