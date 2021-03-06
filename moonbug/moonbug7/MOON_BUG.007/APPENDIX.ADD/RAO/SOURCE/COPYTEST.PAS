PROGRAM COPYTEST;

USES CRT, DOS, FIND, COPYSERV;

CONST
     Ident1         = '  COPYTEST (c) 1997 by RedArc // TAVC';
     Ident11        = '�⨫�� ��� ����஢���� 䠩��� ������樨';
     Ident12        = '            � ���� ��⠫��';
     Ident2         = '       Source: MooN BuG issue 4';

BEGIN
     WriteLn;
     WriteLn (Ident1);
     WriteLn (Ident2);
     IF (ParamCount < 2) OR (ParamCount > 4) THEN BEGIN
        WriteLn ('USAGE: COPYTEST.EXE SourcePath DestionPath [/m][/y:/n:/r]');
        WriteLn ('SourcePath - ��⠫��, ��㤠 �롨��� 䠩��');
        WriteLn ('DestionPath - ��⠫��, �㤠 ᪫��뢠�� 䠩��');
        WriteLn ('/m - 㤠���� 䠩�� ��᫥ ����஢����');
        WriteLn ('����� ������ ���� �� ᫥����� ���祩:');
        WriteLn ('/y - �⢥��� �� �� ������ ������⥫쭮');
        WriteLn ('/n - �⢥��� �� �� ������ ����⥫쭮');
        WriteLn ('/r - ��⮬���᪨  �������� ����� ��� 䠩���');
        WriteLn;
        WriteLn ('Example: COPYTEST.EXE C:\ZOOPARK\ C:\TEST\ /M /Y');
        WriteLn;
        Exit;
     END;
     P1 := ParamStr (1);
     IF P1 [Length (P1)] = '\' THEN Dec (Byte (P1 [0]));
     P2 := ParamStr (2);
     IF P2 [Length (P2)] = '\' THEN Dec (Byte (P2 [0]));
     FSplit (ParamStr (0), Dir, Nam, Ext);
     MoveFlag := False;
     AlwaysFlag := 0;
     IF ParamCount >= 3 THEN Begin
        IF (ParamStr (3) = '/m') OR (ParamStr (3) = '/M') THEN
           MoveFlag := True;
        IF (ParamStr (3) = '/y') OR (ParamStr (3) = '/Y') THEN
           AlwaysFlag := 1;
        IF (ParamStr (3) = '/n') OR (ParamStr (3) = '/N') THEN
           AlwaysFlag := 2;
        IF (ParamStr (3) = '/r') OR (ParamStr (3) = '/r') THEN
           AlwaysFlag := 3;
     END;
     IF ParamCount = 4 THEN Begin
        IF (ParamStr (4) = '/m') OR (ParamStr (4) = '/M') THEN
           MoveFlag := True;
        IF (ParamStr (4) = '/y') OR (ParamStr (4) = '/Y') THEN
           AlwaysFlag := 1;
        IF (ParamStr (4) = '/n') OR (ParamStr (4) = '/N') THEN
           AlwaysFlag := 2;
        IF (ParamStr (4) = '/r') OR (ParamStr (4) = '/R') THEN
           AlwaysFlag := 3;
     END;
     IF Dir [Length (Dir)] = '\' THEN Dec (Byte (Dir[0]));
     {$I-}
     ChDir (P1);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        WriteLn ('Path '+P1+'\'+' not found');
        Exit;
     END;
     {$I-}
     ChDir (Dir);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        WriteLn ('Change path to '+DIR+'\ error');
        Exit;
     END;
     {$I-}
     ChDir (P2);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        WriteLn ('Path '+P2+'\'+' not found');
        WriteLn ('���� Create path '+P2+'\ ۲��');
        MkDir (P2);
        ChDir (P2);
     END;
     {$I-}
     ChDir (Dir);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        WriteLn ('Change path to '+DIR+'\ error');
        Exit;
     END;

     Assign (T, 'COPYTEST.RPT');
     ReWrite (T);

     ScanDir(P1);

     Close (T);

     {$I-}
     ChDir (Dir);
     {$I+}
     IF IOResult <> 0 THEN BEGIN
        WriteLn ('Change path to '+DIR+'\ error');
        Exit;
     END;

     WriteLn ('.Finished.');
END.