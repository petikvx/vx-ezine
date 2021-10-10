UNIT CompUtil;

INTERFACE

USES DOS, CRT, Win, WinHarry;

TYPE
    String80 = String [80];
    Link = ^FileNameType;
    FileNameType = Record
             Name  : String [12];
             Size  : LongInt;
             Fater : Link;
             Next  : Link;
    End;

    PList = ^TList;
    TList = record
      Name : String[12];
      Next : Plist;
      end;

    ButtomType = Record
               X1, Y1, Xlen : Integer; {размеры кнопки}
               Active : Boolean;       {признак активности}
               Pressed: Boolean;       {признак состояния}
               Name   : String80;      {надпись на кнопке}
               Fone   : Byte;          {фон под кнопкой}
               HotNum : Byte;          {номер горячей клавиши}
               WIN    : WinState;      {информация о состоянии окна}
    End;
    PButtom = ^ButtomType;

CONST
     ButtomShade = Black;  {Цвет тени под кнопкой}
     ButtomColor = Green;  {Цвет фона кнопки}
     ButtomCText = Black;  {Цвет обычного текста на кнопке}
     ButtomHText = White;  {Цвет выделенного текста на кнопке (при активности)}
     ButtomHKeys = Yellow; {Цвет горячих клавиш текста}
     Ident1         = 'FileCompare (c) 1998 by RedArc // TAVC';
     Ident2         = 'Thanks for Kravchenko Eugene';
     Autors         = 'Дикшев Игорь Владиславович';
     LOG            = 'filecomp.log';
     BAT            = 'filecomp.bat';

VAR
   T1, T2 : Text;
   Home : PathStr;
   Path : PathStr;
   CouDir, CouFile, CouEqu : LongInt;
   Bool : Boolean;
   Header  : Link;
   Current : Link;
   SR : SearchRec;
   I, J : LongInt;
   Nam : String [12];
   Siz : LongInt;
   FlagOk : Boolean;

procedure FindConcat (Path : String);
procedure ScanDir(stdir:PathStr);
PROCEDURE NewRecord;  {Создание заголовка списка}
PROCEDURE AddFirst; {создание первого объекта в списке}
PROCEDURE Adding (VAR A : LINK);  {Добавление записи, после объекта A}
PROCEDURE DelFirst (VAR A : LINK); {Удаление первого объекта из списка}
PROCEDURE Killer (VAR A : LINK);  {Удаление объекта из списка}
PROCEDURE DoneRecord;  {Удаление заголовка списка}
PROCEDURE Up (X1, Y1, X2, Y2 : Integer; TA : Byte);
FUNCTION YesNoCancel (M1, M2 : String) : Byte;
procedure Help (i : byte);
procedure Report;

IMPLEMENTATION

procedure Help (i : byte);
begin
     WriteLn;
     WriteLn (Ident1);
     WriteLn (Ident2);
     WriteLn;
     case i of
     0 : WriteLn ('Uses: filecomp.exe path');
     1 : WriteLn ('Example: filecomp.exe c:\zoopark\infected');
     2 : WriteLn ('ERROR: Path ', Path, ' not found!');
     3 : WriteLn ('ERROR: Path ', Home, ' not found!');
     4 : WriteLn ('Input/Output Error');
     end;
     WriteLn;
end;

procedure Report;
begin
     WriteLn ('Tested ', CouDir : 10, ' directory');
     WriteLn ('Tested ', CouFile : 10, ' files');
     WriteLn ('Finded ', CouEqu : 10, ' concatenated');
     WriteLn (T1, 'Tested ', CouDir : 10, ' directory');
     WriteLn (T1, 'Tested ', CouFile : 10, ' files');
     WriteLn (T1, 'Finded ', CouEqu : 10, ' concatenated');

     Close (T2);
     Close (T1);
end;

PROCEDURE Up (X1, Y1, X2, Y2 : Integer; TA : Byte);
VAR
  R : REGISTERS ;
BEGIN
  R.AH := 6 ;
  R.AL := 1 ;
  R.BH := TA;
  R.Ch := Y1;
  R.CL := X1;
  R.DH := Y2;
  R.DL := X2;
  INTR ($10, R) ;
END ;

procedure Info (S : String);
begin
    TextAttr := Blue * 16 + LightGray;
    if S [1] = 'E' then
       TextAttr := Blue * 16 + Yellow;
    if S [1] = '■' then
       TextAttr := Blue * 16 + LightRed;
    Up (1, 1, 78, 17, Blue * 16 + Yellow);
    GotoXY (1, 17);
    Write (S);
    if S [1] = 'E' then begin
       Sound (1000);
       Delay (1000);
       NoSound;
    end;
    if KeyPressed then begin
       while keypressed do readkey;
       if YesNoCancel ('Are you sure?', 'Прервать работу программы?') = 1 then begin
          CloseWin (WW [1]);
          SetN;
          ChDir (Home);
          if IOResult <> 0 then begin
             Help (3);
             Exit;
          end;
         Help (255);
         WriteLn (T1);
         WriteLn (T1, '*** User aborted ***');
         WriteLn (T1);
         Report;
         Halt (1);
       end;
    end;
end;

procedure FindConcat (Path : String);
var
   sr : SearchRec;
   f1, f2 : File;
   Count : Word;
   p : pointer;
   a, b : array [1..1024] of byte;
   c, d : word;
   Flag : Boolean;
   S : String [12];
   L, M : Link;
Label
     Lab1;

(*
procedure VisTemp (B : Boolean);
begin
     if B then begin
     OpenWin(10,10,70,13, '', Red * 16 + Yellow,
     Red * 16 + Yellow, 2, WW [2]);
     TextAttr := Red * 16 + Yellow;
     ClrScr;
     GotoXY (1, 1); Write ('   Sorted');
     end else begin
     CloseWin (WW [2]);
     end;
{     M := Current;
     Current := Header^.Next;
     for i := 1 to Count do begin
         GotoXY (1,i); Write (Current^.Name);
         GotoXY (14,i); Write (Current^.Size);
         Current := Current^.Next;
     end;
     Current := M;
     readkey;}
end;
*)

begin
    Mark (p);
    Count := 0;
    NewRecord;
    FindFirst (Path, AnyFile, sr);
    while DosError = 0 do begin
          if (SR.Attr and VolumeID=0) and (SR.Attr and Directory=0) then begin
              if HEADER^.NEXT = Header then begin
                 AddFirst;
                 Current := Header^.Next;
              end else begin
                 Adding (Current);
                 Current := Current^.Next;
              end;
              Current^.Name := sr.Name;
              Current^.Size := sr.Size;
              Inc (Count);
              Inc (CouFile);
              TextAttr := Blue * 16 + LightGreen;
              GotoXY (23, 22); Write (CouFile);
          end;
          FindNext (sr);
    end;
    Current := Header^.Next;
    Delete (Path, Length (Path)-2, 3);
    WriteLn (T1, ' ├─' + Path);
    Info (' ├─' + Path);
    repeat
        if Count > 0 then begin
           if Count = 1 then begin
              WriteLn (T1, ' │ └──' +  Current^.Name);
              Info (' │ └──' +  Current^.Name);
              DelFirst (Current);
              Break;
           end;
           {Сортировка}
           I := 0;
           J := 0;
           Current := Header^.Next;
           L := Current;
           M := Current;
           for I := 1 to Count-1 do begin
               for J := I to Count do begin
                   if Current^.Size < M^.Size then M := Current;
                   Current := Current^.Next;
               end;
               if M <> L then begin
                  Current := M;
                  Nam := M^.Name;
                  Siz := M^.Size;
                  Current^.Name := L^.Name;
                  Current^.Size := L^.Size;
                  Current := L;
                  Current^.Name := Nam;
                  Current^.Size := Siz;
               end;
               Current := L^.Next;
               L := Current;
               M := Current;
           end;
           {}
           repeat
                Current := Header^.Next;
                if Count < 2 then begin
                   if Count = 1 then
                      DelFirst (Current);
                   Break;
                end;
                L := Current;
                M := Current^.Next;
                if M^.Next <> Header then begin
                   WriteLn (T1, ' │  ├──' +  L^.Name);
                   Info (' │  ├──' +  L^.Name);
                end else begin
                   WriteLn (T1, ' │  └──' +  L^.Name);
                   Info (' │  └──' +  L^.Name);
                end;
Lab1:
                if M = Header then begin
                   DelFirst (Current);
                   Dec (Count);
                   Continue;
                end;
                TextAttr := Blue * 16 + LightCyan;
                GotoXY (1, 19); Write ('                      ');
                GotoXY (1, 19);
                Write ('Файл: ' + L^.Name);
                GotoXY (1, 20); Write ('                      ');
                GotoXY (1, 20);
                Write ('Файл: ' + M^.Name);

                if L^.Size <> M^.Size then begin
                   if Count > 2 then begin
                      Info (' │  │  └──' + M^.Name);
                      if FlagOk then
                      WriteLn (T1, ' │  │  └──' + M^.Name)
                   end else begin
                      Info (' │     └──' + M^.Name);
                      if FlagOk then
                      WriteLn (T1, ' │     └──' + M^.Name)
                   end;
                   DelFirst (Current);
                   Dec (Count);
                   Continue;
                end;

                Flag := True;
                TextAttr := Blue * 16 + Cyan;
                GotoXY (23, 20);
                for i := 1 to 56 do
                    Write ('░');
                GotoXY (23, 19);
                for i := 1 to 56 do
                    Write ('░');

                Assign (f1, Path + L^.Name);
                ReSet (f1, 1);
                Assign (f2, Path + M^.Name);
                ReSet (f2, 1);

                repeat
                   BlockRead (f1, a, 1024, c);

                   TextAttr := Blue * 16 + LightGray;
                   GotoXY (23, 19);
                   j := Round(56 / L^.Size * FilePos (f1));
                   for i := 1 to j do Write ('▒');

                   BlockRead (f2, b, 1024, d);

                   TextAttr := Blue * 16 + LightRed;
                   GotoXY (23, 20);
                   j := Round(56 / M^.Size * FilePos (f2));
                   for i := 1 to j do Write ('▒');

                   if c <> d then begin
                      Flag := False;
                      Break;
                   end;

                   for i := 1 to c do
                       if a [i] <> b [i] then begin
                          Flag := False;
                          break;
                       end;

                   if not Flag then Break;

                until (c<>d) or (c = 0);

                Close (f2);
                Close (f1);

                if Flag then begin
                   if Count > 2 then begin
                      WriteLn (T1, '■│  │  └──' + M^.Name);
                      Info ('■│  │  └──' + M^.Name)
                   end else begin
                      WriteLn (T1, '■│     └──' + M^.Name);
                      Info ('■│     └──' + M^.Name);
                   end;

                   WriteLn (T2, '@DEL ' + Path + M^.Name);
                   Inc (CouEqu);

                   TextAttr := Blue * 16 + LightGreen;
                   GotoXY (23, 23); Write (CouEqu);

                   Current := M;
                   Killer (Current);
                   Dec (Count);
                   Current := L;
                   M := Current^.Next;

                end else begin
                   if Count > 2 then begin
                      Info (' │  │  └──' + Current^.Next^.Name);
                      if FlagOk then
                      WriteLn (T1, ' │  │  └──' + Current^.Next^.Name)
                   end else begin
                       Info (' │     └──' + Current^.Next^.Name);
                       if FlagOk then
                       WriteLn (T1, ' │     └──' + Current^.Next^.Name);
                   end;
                   M := M^.Next;
                end;
                goto Lab1;
           until False;
        end;
    until True;

    DoneRecord;
    Header := nil;
    Release (p);
end;

procedure ScanDir(stdir:PathStr);
  var
    n,L : PList;
    m : PathStr;
{    St : string[79];
    ch : char;
    DIR : DirStr;
    NAM : NameStr;
    EXT : EXTSTR;}
begin
  FileMode := 0;
  L := nil;
  if stdir[Length(stdir)] <> '\' then
    stdir:=stdir+'\';
  m := stdir+'*.*';
  FindFirst(m,AnyFile, SR);
  while dosError=0 do begin
    if ((SR.Attr and Directory) <> 0) and ((SR.Name<>'.') and
      (SR.Name<>'..')) then begin
      New(n);
      N^.Next := L;
      N^.Name := SR.Name;
      L := N;
      end;
{    else}
(*
      if (SR.Attr and VolumeID=0) and (SR.Attr and Directory=0) then begin
       {Здесь мы нашли файл}
       {stdir+S.Name - путь к файлу}
        S := m;
        Delete (S, Length (m)-2, 3);
        S := S + SR.Name;
        CopyFile (S);
        end;
*)
      if SR.Name = '..' then begin
         FindConcat (m);
         inc (CouDir);
         TextAttr := Blue * 16 + LightGreen;
         GotoXY (23, 21); Write (CouDir);
      end;
    FindNext(sR);
    end;
  while L<> nil do begin
    m := Stdir+L^.Name;
    ChDir(m);
    n := L;
    L := L^.next;
    Dispose(n);
    m := m+'\';
    ScanDir(m);
    m := stdir;
    if m[length(m)-1] <> ':' then
      m[0] := chr(length(stdir)-1);
    ChDir(m);
    end;
end;

PROCEDURE NewRecord;  {Создание заголовка списка}
BEGIN
  NEW (HEADER);             {размещаем заголовок списка в куче}
  HEADER^.FATER := HEADER;  {нет предка}
  HEADER^.NEXT  := HEADER;  {нет наследника}
END;

PROCEDURE AddFirst; {создание первого объекта в списке}
VAR
  A : LINK;
BEGIN
  NEW (A);  {создаем новый объект}
  A^.FATER := Header; {Для него предком является Header}
  A^.NEXT := Header^.NEXT; {Теперь наследником является наследник Header}
  Header^.NEXT^.FATER := A;
  Header^.NEXT := A;  {объект A становится наследником объекта Header}
END;

PROCEDURE Adding (VAR A : LINK);  {Добавление записи, после объекта A}
VAR
  P : LINK;
BEGIN
  NEW (P); {создан новый объект}
  P^.FATER := A;       {для него предком является объект A}
  P^.NEXT := A^.NEXT;  {наследник берется из объекта A}
  A^.NEXT^.FATER := P;
  A^.NEXT := P;        {а сам становится наследником объекта A}
END;

PROCEDURE DelFirst (VAR A : LINK); {Удаление первого объекта из списка}
BEGIN
  Header^.NEXT := A^.NEXT; {он становится наследником заголовка}
  A^.NEXT^.FATER := Header; {предком для него становится сам заголовок}
  DISPOSE (A); {уничтожение объекта A из кучи}
END;


PROCEDURE Killer (VAR A : LINK);  {Удаление объекта из списка}
BEGIN
  A^.FATER^.NEXT := A^.NEXT;
  A^.NEXT^.FATER := A^.FATER;
  DISPOSE (A);
END;

PROCEDURE DoneRecord;  {Удаление заголовка списка}
BEGIN
  DISPOSE (HEADER);             {размещаем заголовок списка в куче}
END;

PROCEDURE InitButtom (VAR B : ButtomType);
VAR
   I : Byte;
BEGIN
     WITH B DO BEGIN
          SaveWin(WIN);
          Xlen := Length (Name) + 2;
          TextAttr := Fone * 16 + Black;
          GotoXY (X1 + Xlen, Y1);
          Write ('▄');
          GotoXY (x1 + 1, Y1 + 1);
          FOR I := 1 TO Xlen DO
              Write ('▀');
          TextAttr := 16 * ButtomColor + ButtomCText;
          GotoXY (X1, Y1);
          Write (' ' + Name + ' ');
          IF HotNum > 0 THEN BEGIN
             TextAttr := 16 * ButtomColor + ButtomHKeys;
             GotoXY (X1 + HotNum, Y1);
             Write (Name [HotNum]);
          END;
          Active := False;
          Pressed:= False;
     END;
END;

PROCEDURE PressButtom (VAR B : ButtomType);
VAR
   C1, C2 : Char;
BEGIN
     WITH B DO BEGIN
          RestoreWin(WIN);
          TextAttr := Fone * 16 + Fone;
          GotoXY (X1, Y1);
          Write  (' ');
          GotoXY (X1, Y1+1);
          Write  (' ' + Name + '  ');
          GotoXY (X1+1, Y1{+1});
          IF Active THEN BEGIN
             C1 := #17;
             C2 := #16;
             TextAttr := 16 * ButtomColor + ButtomHText;
          END ELSE BEGIN
             C1 := ' ';
             C2 := ' ';
             TextAttr := 16 * ButtomColor + ButtomCText;
          END;
          Write (C1 + Name + C2);
          IF HotNum > 0 THEN BEGIN
             TextAttr := 16 * ButtomColor + ButtomHKeys;
             GotoXY (X1 + HotNum + 1, Y1 {+ 1});
             Write (Name [HotNum]);
          END;
          Pressed := True;
     END;
END;

PROCEDURE UnPressButtom (VAR B : ButtomType);
VAR
   C1, C2 : Char;
   I : Byte;
BEGIN
     WITH B DO BEGIN
          RestoreWin(WIN);
          TextAttr := Fone * 16 + Black;
          GotoXY (X1 + Xlen, Y1);
          Write ('▄');
          GotoXY (x1 + 1, Y1 + 1);
          FOR I := 1 TO Xlen DO
              Write ('▀');
          TextAttr := 16 * ButtomColor + ButtomCText;
          GotoXY (X1, Y1);
          IF Active THEN BEGIN
             C1 := #17;
             C2 := #16;
             TextAttr := 16 * ButtomColor + ButtomHText;
          END ELSE BEGIN
             C1 := ' ';
             C2 := ' ';
             TextAttr := 16 * ButtomColor + ButtomCText;
          END;
          Write (C1 + Name + C2);
          IF HotNum > 0 THEN BEGIN
             TextAttr := 16 * ButtomColor + ButtomHKeys;
             GotoXY (X1 + HotNum, Y1);
             Write (Name [HotNum]);
          END;
          Pressed := False;
     END;
END;

PROCEDURE UnActivateButtom (VAR B : ButtomType);
CONST
     C1 = ' ';
     C2 = ' ';
BEGIN
     WITH B DO BEGIN
          IF Pressed THEN UnPressButtom (B);
          RestoreWin(WIN);
          Active := False;
          GotoXY (X1, Y1);
          TextAttr := 16 * ButtomColor + ButtomCText;
          Write (C1 + Name + C2);
          IF HotNum > 0 THEN BEGIN
             TextAttr := 16 * ButtomColor + ButtomHKeys;
             GotoXY (X1 + HotNum, Y1);
             Write (Name [HotNum]);
          END;
     END;
END;

PROCEDURE DoneButtom (VAR B : ButtomType);
VAR
   I : Byte;
BEGIN
     WITH B DO BEGIN
          IF Active THEN UnActivateButtom (B);
          IF Pressed THEN UnPressButtom (B);
          RestoreWin(WIN);
          TextAttr := Fone * 16 + Fone;
          GotoXY (X1, Y1);
          FOR I := 1 TO Xlen+1 DO
              Write (' ');
          GotoXY (X1, Y1+1);
          FOR I := 1 TO Xlen+1 DO
              Write (' ');
          Active := False;
     END;
END;

PROCEDURE ActivateButtom (VAR B : ButtomType);
CONST
     C1 = #17;
     C2 = #16;
BEGIN
     WITH B DO BEGIN
          IF Pressed THEN UnPressButtom (B);
          RestoreWin(WIN);
          Active := True;
          GotoXY (X1, Y1);
          TextAttr := 16 * ButtomColor + ButtomHText;
          Write (C1 + Name + C2);
          IF HotNum > 0 THEN BEGIN
             TextAttr := 16 * ButtomColor + ButtomHKeys;
             GotoXY (X1 + HotNum, Y1);
             Write (Name [HotNum]);
          END;
     END;
END;

FUNCTION YesNoCancel (M1, M2 : String) : Byte;
CONST
     X1 = 20;
     Y1 = 9;
     X2 = 58;
     Y2 = Y1 + 7;
VAR
   WIN : WinState;
   WT  : WindowType;
   But : Array [1..3] OF PButtom;
   I : Byte;
   Ch : Char;

BEGIN
     SaveWin(WIN);
     SaveCurrentScreenOnDisk ('YNCPanel.$$$');
     OpenWin(X1, Y1, X2, Y2, '', Red * 16 + Yellow, Red * 16 + Yellow, 2, WT);
     TextAttr := Red * 16 + Yellow;
     ClrScr;
     GotoXY (1,1);
     Write (M1);
     GotoXY (1,2);
     Write (M2);
     New (But [1]);
     WITH But [1]^ DO BEGIN
          X1 := 4;
          Y1 := 5;
          Name := ' Yes ';
          HotNum := 1;
          Fone := Red;
     END;
     InitButtom (But [1]^);
     New (But [2]);
     WITH But [2]^ DO BEGIN
          X1 := But [1]^. X1 + But [1]^. Xlen + 3;
          Y1 := 5;
          Name := ' No ';
          HotNum := 1;
          Fone := Red;
     END;
     InitButtom (But [2]^);
     New (But [3]);
     WITH But [3]^ DO BEGIN
          X1 := But [2]^. X1 + But [2]^. Xlen + 3;
          Y1 := 5;
          Name := ' Cancel ';
          HotNum := 1;
          Fone := Red;
     END;
     InitButtom (But [3]^);
     SetO;
     I := 1;
     REPEAT
           ActivateButtom (But [I]^);
           REPEAT
           UNTIL KeyPressed;
           UnActivateButtom (But [I]^);
           Ch := ReadKey;
           CASE ORD (Ch) OF
                13 : BEGIN
                          ActivateButtom (But [I]^);
                          PressButtom (But [I]^);
                          Delay (500);
                          while  keypressed do begin
                                 Delay (10);
                                 readkey;
                          end;
                          YesNoCancel := I;
                          Break;
                     END;
                27 : BEGIN
                          ActivateButtom (But [3]^);
                          PressButtom (But [3]^);
                          I := 3;
                          Delay (500);
                          while keypressed do begin
                                Delay (10);
                                readkey
                          end;
                          YesNoCancel := 3;
                          Break;
                     END;
                9  : BEGIN
                          IF I < 3 THEN Inc (I) ELSE I := 1;
                     END;
                0  : BEGIN
                     Ch := ReadKey;
                     CASE ORD (Ch) OF
                          75 : IF I > 1 THEN Dec (I) ELSE I := 3;
                          77 : IF I < 3 THEN Inc (I) ELSE I := 1;
                     END;
                     END;
           END;
     UNTIL False;
     UnPressButtom (But [I]^);
     Delay (300);
     DoneButtom (But [3]^);
     DoneButtom (But [2]^);
     DoneButtom (But [1]^);
     Dispose (But [3]);
     Dispose (But [2]);
     Dispose (But [1]);
     CloseWin (WT);
     LoadScreenFromDisk ('YNCPanel.$$$');
     RestoreWin(WIN);
     SetN;
END;

BEGIN
     CouDir  := 0;
     CouFile := 0;
     CouEqu  := 0;
     FlagOk  := False;
END.
