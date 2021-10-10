UNIT FileUtil;

INTERFACE

USES DOS;

CONST
{$i header.inc}

FUNCTION RandomName : String;
FUNCTION CopyFile (Sou, Dest : String; Mode : Boolean) : Boolean;
PROCEDURE ProgramExecute (FileName, FileParam : String);

IMPLEMENTATION

PROCEDURE ProgramExecute (FileName, FileParam : String);
BEGIN
     SwapVectors;
     Exec (FileName, FileParam);
     SwapVectors;
END;

FUNCTION RandomName : String;
VAR
   S    : String;
   I, J : Integer;
BEGIN
     S := '';
     for I := 1 to 8 do begin
         J := 65 + Random (25);
         S := S + Chr (J);
     end;
     S := S + '.EXE';
     RandomName := S;
END;

FUNCTION CopyFile (Sou, Dest : String; Mode : Boolean) : Boolean;
VAR
   Fs, Ft : File;
   P      : Pointer;
   Cr, Cw : Word;
   FilA : Word;
   FilT : LongInt;
BEGIN
     Assign (Fs, Sou);
     GetFAttr (Fs, FilA);
     SetFAttr (Fs, Archive);
     ReSet (Fs, 1);
     if IOResult <> 0 then begin
        CopyFile := True;
        Exit;
     end;
     GetFTime (Fs, FilT);
     Assign (Ft, Dest);
     ReWrite (Ft, 1);
     if IOResult <> 0 then begin
        Close (Fs);
        CopyFile := True;
        Exit;
     end;
     GetMem (P, 1024 * 5);
     repeat
           BlockRead (Fs, P^, 1024 * 5, Cr);
           BlockWrite (Ft, P^, Cr, Cw);
     until (Cr <> Cw) or (Cr <> 1024 * 5);
     FreeMem (P, 1024 * 5);
     SetFTime (Ft, FilT);
     Close (Ft);
     SetFAttr (Ft, FilA);
     Close (Fs);
     SetFAttr (Fs, FilA);
     if Mode then begin
        SetFAttr (Fs, Archive);
        Erase (Fs);
     end;
     CopyFile := False;
END;

BEGIN
     Randomize;
END.
