PROGRAM Prepare;
VAR
   F1, F2 : File;
   P : Pointer;
   I,J : Word;
   K : LongInt;
BEGIN
     if ParamCount <> 2 then begin
        WriteLn ('USAGE: PREPARE.EXE LOAD.EXE ARJSFX.EXE');
        Exit;
     end;
     Assign (F1, ParamStr (1));
     Assign (F2, ParamStr (2));
     ReSet (F1, 1);
     K := FileSize (F1);
     ReSet (F2, 1);
     FileMode := 2;
     GetMem (P, 1024 * 5);
     BlockRead (F2, P^, K, I);
     Seek (F2, FileSize (F2));
     BlockWrite (F2, P^, I, J);
     Seek (F2, 0);
     BlockRead (F1, P^, K, I);
     BlockWrite (F2, P^, I, J);
     FreeMem (P, 1024 * 5);
     Close (F2);
     Close (F1);
END.
