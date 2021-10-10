UNIT Working;

INTERFACE

{$I-}

USES DOS, CRT, TFunc;

TYPE
    PList = ^TList;
    TList = record
      Name : String[12];
      Next : Plist;
      end;

var
   SR         : SearchRec;
   S          : String;
   SDir, TDir : PathStr;
   Regime     : Boolean;
   Home       : String;
   T, TP      : Text;
   Fs, Ft     : File;
   FileName   : String;
   Flag       : Boolean;
   Pa         : PathStr;
   Na         : NameStr;
   Ex         : ExtStr;
   AF         : LongInt;
   CF         : LongInt;

procedure CopyFile (S1 : String);

IMPLEMENTATION

function RandomName : String;
var
   I, J : integer;
   S    : String [12];
begin
     S := '';
     for I := 1 to 8 do begin
         J := 65 + Random (26);
         S := S + Chr (J);
     end;
     S := S + '.';
     for I := 1 to 3 do begin
         J := 65 + Random (26);
         S := S + Chr (J);
     end;
     RandomName := S;
end;

procedure CopMovFil (S1 : String);
var
   S2, S3, S4 : String;
   P : Pointer;
   NR, NW : Word;
begin
     Assign (Fs, S1);
     ReSet (Fs, 1);
     if IOResult <> 0 then begin
        TextAttr := 16 * Black + LightRed;
        GotoXY (1, 10);
        InsLine;
        GotoXY (1, 11);
        Write ('File ', S1, ' ioerror');
        if Flag then WriteLn (TP, 'File ', S1, ' ioerror');
        Exit;
     end;
     S2 := TDir;
     if S2 [Length (S2)] <> '\' then S2 := S2 + '\';
     S3 := S2 + Na + Ex;
     Assign (Ft, S3);
     ReSet (Ft, 1);
     while IOResult = 0 do begin
           Close (Ft);
           S3 := S2 + RandomName;
           Assign (Ft, S3);
           ReSet (Ft, 1);
     end;
     ReWrite (Ft, 1);
     if IOResult <> 0 then begin
        TextAttr := 16 * Black + LightRed;
        GotoXY (1, 10);
        InsLine;
        GotoXY (1, 11);
        Write ('File ', S3, ' create error');
        if Flag then WriteLn (TP, 'File ', S3, ' create error');
        Exit;
     end;
     TextAttr := 16 * Black + Cyan;
     GotoXY (1, 10);
     InsLine;
     GotoXY (1, 11);
     S4 := Na + Ex;
     while Length (S4) < 16 do S4 := S4 + ' ';
     Write (S4, '-> ', S3);
     if Flag then Write (TP, S4, '-> ', S3);
     GetMem (P, 65535);
     repeat
           BlockRead (Fs, P^, 65535, NR);
           BlockWrite (Ft, P^, NR, NW);
           if NR <> NW then begin
              GotoXY (1, WhereY);
              ClrEOL;
              TextAttr := 16 * Black + Red;
              Write ('IOError');
              if Flag then Write (TP, ' IOError');
              Break;
           end;
           if NR < 65535 then Break;
     until False;
     if (NR = NW) then begin
        inc (CF);
        GotoXY (1, 8);
        ClrEOL;
        TextAttr := 16 * Black + Yellow;
        Write ('File ', CF, ' from ', AF);
     end;
     if Flag then WriteLn (TP, '');
     FreeMem (P, 65535);
     Close (Ft);
     Close (Fs);
     if Regime then begin
        SetFAttr (Fs, Archive);
        Erase (Fs);
     end;
     if IOResult <> 0 then Exit;
end;

procedure CopyFile (S1 : String);
var
   X : Integer;
   Y : Integer;
   S2 : String;
begin
     Assign (T, Home + '\' + FileName);
     ReSet (T);
     if IOResult <> 0 then Exit;
     FSplit (S1, Pa, Na, Ex);
     GotoXY (1, 9);
     TextAttr := Black * 16 + White;
     ClrEOL;
     Write (Pa);
     S2 := Na + Ex;
     GotoXY (1, 10);
     ClrEOL;
     Write (S2, '    ');
     X := WhereX;
     Y := WhereY;
     while not eof (T) do begin
           ReadLn (T, S);
           GotoXY (X, Y);
           TextAttr := Black * 16 + LightCyan;
           Write (S);
           ClrEOL;
           if UpStr (S) = UpStr (S2) then CopMovFil (S1);
     end;
     Close (T);
end;

BEGIN
     Randomize;
END.
