PROGRAM NewInf;

TYPE
    TInfo = Record
          VirName  : String [12];
          GoatName : String [12];
          ArjName  : String [12];
          LZEName  : String [12];
          BegName  : String [12];
          BadName  : String [12];
    End;

VAR
   FI    : File Of TInfo;
   Info  : TInfo;

BEGIN
     with Info do begin
          VirName  := 'HLLA_VIR.EXE';
          GoatName := 'STARWAY.EXE';
          ArjName  := 'RAR.EXE';
          LZEName  := 'LZEXE.EXE';
          BegName  := 'LOAD.EXE';
          BadName  := 'FILE_ID.DIZ';
     end;
     Assign (FI, 'HLLA_VIR.INF');
     ReWrite (FI);
     Write (FI, Info);
     Close (FI);
END.
