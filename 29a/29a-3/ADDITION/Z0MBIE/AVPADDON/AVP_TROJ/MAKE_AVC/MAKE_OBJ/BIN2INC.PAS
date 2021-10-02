program BIN2INC;

{$A+,B-,D+,E-,F-,G+,I-,L+,N+,O-,P-,Q-,R-,S-,T-,V+,X+}
{$M 16384,0,0}

uses Dos;

const
  DefEXT = '.INC';
  err_1 = 'Incompatible options';

function FStr(L : Longint) : String;
  var
    S : String;
  begin
    Str(L:0, S);
    FStr := S;
  end;

type

  Long = Longint;

const
  hexchar : array[0..15] of char = '0123456789ABCDEF';

function F(L : Long; Base,Len:Integer) : String;
  var
    i : integer;
    s : string;
    ch : char;
  begin
    s := '';
    repeat
      asm
        DB 66H; MOV AX, word ptr L
        DB 66H; XOR DX, DX
        DB 66H; XOR BX, BX
        MOV BX, base
        DB 66H; DIV BX
        DB 66H; MOV word ptr L, AX
        XCHG DX, BX
        MOV AL, byte ptr hexchar[BX]
        MOV &ch, AL
      end;
      s := ch + s;
      dec(len);
    until (len <= 0) and (l = 0);
    F := s;
  end;

function F_s(L : Long; Base,Len:Integer) : String;
  var
    i : integer;
    s : string;
    ch : char;
    c : string[1];
  begin
    s := '';
    c := '';
    if l < 0 then
    begin
      l := -l;
      c := '-';
    end;
    repeat
      asm
        DB 66H; MOV AX, word ptr L
        DB 66H; XOR DX, DX
        DB 66H; XOR BX, BX
        MOV BX, base
        DB 66H; DIV BX
        DB 66H; MOV word ptr L, AX
        XCHG DX, BX
        MOV AL, byte ptr hexchar[BX]
        MOV &ch, AL
      end;
      s := ch + s;
      dec(len);
    until (len <= 0) and (l = 0);
    F_s := c + s;
  end;

function HexByte(B: Byte) : String; begin HexByte := F(B,16, 2); end;
function HexWord(W: Word) : String; begin HexWord := F(W,16, 4); end;
function HexLong(L: Long) : String; begin HexLong := F(L,16, 8); end;

function DecByte(B: Longint) : String; begin DecByte := F(B,10, 0); end;
function DecWord(W: Longint) : String; begin DecWord := F(W,10, 0); end;
function DecLong(L: Long) : String; begin DecLong := F(L,10, 0); end;

function OctByte(B: Byte) : String; begin OctByte := F(B, 8, 0); end;
function OctWord(W: Word) : String; begin OctWord := F(W, 8, 0); end;
function OctLong(L: Long) : String; begin OctLong := F(L, 8, 0); end;

function BinByte(B: Byte) : String; begin BinByte := F(B, 2, 8); end;
function BinWord(W: Word) : String; begin BinWord := F(W, 2,16); end;
function BinLong(L: Long) : String; begin BinLong := F(L, 2,32); end;

procedure Error(ErrMsg : String);
  begin
    writeln(ErrMsg);
    Halt(1);
  end;

procedure STOP;
  begin
    Error('Эта опция ещё не запрограммирована :(');
  end;

function UpCaseChar(C : Char) : Char; assembler;
  asm
    MOV AL, C
    CMP AL, 'a'
    JB @@1
    CMP AL, 'z'
    JA @@1
    SUB AL, 32
@@1:
  end;

function UpCaseStr(S : String) : String; assembler;
  asm
    PUSH DS
    LES DI, @RESULT
    LDS SI, S
    CLD
    LODSB
    STOSB
    XOR AH, AH
    XCHG CX, AX
    JCXZ @@1
@@2:LODSB
    PUSH AX
    CALL UpCaseChar
    STOSB
    LOOP @@2
@@1:POP DS
  end;

function AddExt(FileName, Ext : String; X : Boolean) : String;
  var
    D : DirStr;
    N : NameStr;
    E : ExtStr;
  begin
    FSplit(FExpand(FileName), D,N,E);
    if X or (E = '') then E := Ext;
    AddExt := D+N+E;
  end;

const
  arrayname : string = 'abc';

  Lang    : (lAsm, lPas)                             = lAsm;
  AsmType : (aByte, aWord, aDWord, aQWord, aTByte)   = aByte;
  PasType : (pByte, pWord, pShortInt, pInteger,
             pLongInt, pChar)                        = pByte;

  Base    : (bHex, bDec, bOct, bBin)                 = bHex;

  n       : Byte = 1;

  AsmTypeChar : array[0..6] of Char = 'BWDQT';

  PasTypeStr  : array[0..6] of string[20] =
    ('byte','word','shortint','integer','longint','char','string');

const
  maxinsize = 16384;

var
  insize : word;
  inptr  : longint;
  inbuf   : array[1..maxinsize+256] of byte;
  outsize : word;
  outbuf  : array[1..32768] of byte;

  linesize : word;
  linesnum : longint;

  _b,_b2 : byte;
  _w,_w2 : word;
  _l,_l2 : longint;

  _wl : array[1..2] of word absolute _l;

procedure go(infile, outfile : string);
  var
    i,o : file;

  procedure Flush;
    begin
      blockwrite(o, outbuf, outsize);
      outsize := 0;
    end;

  procedure OutChar(C : Char);
    begin
      inc(outsize);
      outbuf[outsize] := ord(C);

      if C = #10 then linesize := 0 else inc(linesize);

      if outsize >= sizeof(outbuf) then Flush;
    end;

  procedure OutString(S : String);
    var
      i : Integer;
    begin
      for i := 1 to Length(S) do
        outChar(S[i]);
    end;

  procedure AddX;
    begin
      case Base of
        bHex: OutChar('H');
        bOct: OutChar('o');
        bBin: OutChar('B');
      end;
    end;

  var
    s2, s  : word;
    st : string;

  function getbyte : byte;
    begin
      if (insize = 0) or (inptr > insize) then
      begin
        fillchar(inbuf, sizeof(inbuf), 0);
        blockread(i, inbuf, maxinsize, insize);
        inptr := 1;
      end;

      _b := inbuf[inptr];
      inc(inptr);

      getbyte := _b;
    end;

  function GetWord : word;
    begin
      _w := (getbyte shl 8) or getbyte;
      getword := _w;
    end;

  function GetLong : long;
    begin
      _wl[1] := getword;
      _wl[2] := getword;
      getlong := _l;
    end;

  procedure LineStart;
    begin
      if Lang = lAsm then outString('D'+AsmTypeChar[byte(asmType)]+' ');
      if Lang = lPas then outString(#9);
    end;

  procedure LineEnd;
    begin
      outString(#13#10);
      inc(LinesNum);
    end;

  function eof : boolean;
    begin
      eof := system.eof(i) and (inptr > insize);
    end;

  begin
    assign(i, infile);
    filemode := 0;
    reset(i,1);
    filemode := 2;
    if IOResult <> 0 then error('Can not open file '+infile);

    s := filesize(i);

    linesnum := 0;

    case Lang of
      lPas: case PasType of
              pWord, pInteger: s := (s + 1) div 2;
              pLongInt: s := (s + 3) div 4;
            end;
      lAsm: case AsmType of
              aByte:  s2 := s;
              aWord:  s2 := (s + 1) div 2;
              aDWord: s2 := (s + 3) div 4;
              aQWord: s2 := (s + 7) div 8;
              aTByte: s2 := (s + 9) div 10;
            end;
    end;

    assign(o, outfile);
    rewrite(o, 1);
    if IOResult <> 0 then error('Can not create file '+outfile);

    inptr := -1;
    insize  := 0;
    outsize := 0;
    linesize := 0;

    if Lang = lAsm then
    begin
      outString(arrayname+'_size'#9'EQU '+fstr(s)+#9#9'; size in bytes'#13#10);
      outString(arrayname+'_num '#9'EQU '+fstr(s2)+#9#9'; size in elements'#13#10);
      outString(arrayname+' ');
    end;

    if Lang = lPas then
    begin
      outString(#13#10+
                'const'#13#10+
                '  '+arrayname+'_num = '+FStr(s)+';   { size in elements! }'#13#10+
                #13#10+
                '  '+arrayname+' : array['+fstr(n)+'..'+arrayname+'_num');
      if n = 0 then outString('-1');
      outString('] of ');
      outString(PasTypeStr[byte(PasType)]);
      outString(' ='#13#10);
      outString('    ('#13#10);
    end;

    LineStart;

    while not eof do
    begin

      if lang = lAsm then
      begin
        case AsmType of
          aByte:  begin
                    getByte;

                    case Base of
                      bDec: outString(DecByte(_b));
                      bHex: outString('0'+HexByte(_b));
                      bOct: outString(OctByte(_b));
                      bBin: outString(BinByte(_b));
                    end;

                    AddX;

                    if (linesize < 75) and (not eof) then
                      outChar(',')
                    else begin
                      LineEnd;
                      if not eof then LineStart;
                    end;

                  end;
          aWord:  begin
                    getWord;

                    case Base of
                      bDec: outString(DecWord(_w));
                      bHex: outString('0'+HexWord(_w));
                      bOct: outString(OctWord(_w));
                      bBin: outString(BinWord(_w));
                    end;

                    AddX;

                    if (linesize < 75) and (not eof) then
                      outChar(',')
                    else begin
                      LineEnd;
                      if not eof then LineStart;
                    end;

                  end;

          aDWord: begin
                    getLong;

                    case Base of
                      bDec: outString(DecLong(_l));
                      bHex: outString('0'+HexLong(_l));
                      bOct: outString(OctLong(_l));
                      bBin: outString(BinLong(_l));
                    end;

                    AddX;

                    if (linesize < 75) and (not eof) then
                      outChar(',')
                    else begin
                      LineEnd;
                      if not eof then LineStart;
                    end;

                  end;

          aQWord: begin
                    getLong;
                    _l2 := _l;
                    getLong;
                    case Base of
                      bDec, bOct: error(err_1);
                      bHex: outString('0'+HexLong(_l));
                      bBin: outString(BinLong(_l));
                    end;
                    case Base of
                      bHex: outString(HexLong(_l2));
                      bBin: outString(BinLong(_l2));
                    end;

                    AddX;

                    if (linesize < 75) and (not eof) then
                      outChar(',')
                    else begin
                      LineEnd;
                      if not eof then LineStart;
                    end;

                  end;

          aTByte: begin
                    getWord;
                    _w2 := _w;
                    getLong;
                    _l2 := _l;
                    getLong;
                    case Base of
                      bDec, bOct: error(err_1);
                      bHex: outString('0'+HexLong(_l));
                      bBin: outString(BinLong(_l));
                    end;
                    case Base of
                      bHex: outString(HexLong(_l2));
                      bBin: outString(BinLong(_l2));
                    end;
                    case Base of
                      bHex: outString(HexWord(_w2));
                      bBin: outString(BinWord(_w2));
                    end;

                    AddX;

                    if (linesize < 75) and (not eof) then
                      outChar(',')
                    else begin
                      LineEnd;
                      if not eof then LineStart;
                    end;

                  end;

          else    STOP;
        end;
      end;

      if lang = lPas then begin

        if Base in [bOct,bBin] then error(err_1);

        case PasType of
          pByte, pShortInt, pChar:
                 begin
                   getByte;
                   if PasType = pChar then outChar('#');
                   case Base of
                     bDec: case PasType of
                             pByte, pChar: outString(DecByte(_b));
                             pShortInt:    outString(F_s(_b,10,0));
                           end;
                     bHex: outString('$'+HexByte(_b));
                   end;
                   if PasType <> pChar then
                     if not eof then
                       outChar(',');
                   if linesize >= 60 then
                   begin
                     if PasType = pChar then outString('+');
                     LineEnd;
                     LineStart;
                   end;
                 end;
          pWord, pInteger:
                 begin
                   getWord;
                   case Base of
                     bDec: case PasType of
                             pWord:    outString(DecWord(_w));
                             pInteger: outString(F_s(_w,10,0));
                           end;
                     bHex: outString('$'+HexWord(_w));
                   end;
                   if not eof then outChar(',');
                   if linesize >= 60 then
                   begin
                      LineEnd;
                      LineStart;
                    end;
                 end;
          pLongInt:
                 begin
                   getLong;
                   case Base of
                     bDec: outString(F_s(_l,10,0));
                     bHex: outString('$'+HexLong(_l));
                   end;
                   if not eof then outChar(',');
                   if linesize >= 60 then
                   begin
                     LineEnd;
                     LineStart;
                   end;
                 end;
        end;

      end;

    end;

    LineEnd;

    if Lang = lPas then
    begin
      outString('    );'#13#10+
                #13#10);
    end;

    Flush;

    close(i);

    close(o);

    writeln('BIN2INC: ',LinesNum, ' line(s) generated');
  end;

procedure Help;
  begin
    writeln('syntax:');
    writeln('         BIN2INC [options] [@arrayname] infile [outfile[.INC]]');
    writeln;
    writeln('options: /a,/asm  (default)');
    writeln('         /p,/pas');
    writeln;
    writeln('         ASSEMBLER              PASCAL');
    writeln('     /b, /byte     (default)    /byte          (default)');
    writeln('     /w, /word                  /word');
    writeln('     /d, /dword                 /shortint');
    writeln('     /q, /qword (hex,bin)       /integer');
    writeln('         /tbyte (hex,bin)       /longint');
    writeln('                                /char');
    writeln;
    writeln('         /16       (default)    /16            (default)');
    writeln('         /10                    /10');
    writeln('         /8');
    writeln('         /2                     /0   array[0.. (default 1)');
    halt;
  end;

var
  i, j : integer;
  s, t : string;
  c : integer;
  p : array[1..2] of string;

begin
  if paramcount = 0 then Help;

  c := 0;

  for i := 1 to paramcount do
  begin
    s := paramstr(i);

    if (s = '/?') or (s = '-?') or (upcasestr(s) = '/H') or (upcasestr(s) = '-H') or
    (upcasestr(s) = '/HELP') or (upcasestr(s) = '-HELP') or (s = '?') then Help;

    if s[1] = '@' then begin

      if s <> '@' then
      begin
        arrayname := copy(s,2,255);
        s := '';
      end;

    end else

    if s[1] = '/' then begin

      t := UpCaseStr(s);

      if (t = '/A') or (t = '/ASM') then begin Lang := lAsm; s := ''; end;
      if (t = '/P') or (t = '/PAS') then begin Lang := lPas; s := ''; end;

      if t = '/16' then begin s := ''; Base := bHex; end;
      if t = '/10' then begin s := ''; Base := bDec; end;
      if t = '/8'  then begin s := ''; Base := bOct; end;
      if t = '/2'  then begin s := ''; Base := bBin; end;

      if t = '/0'  then begin s := ''; n := 0; end;

      if (t = '/BYTE') or (t = '/B') then begin s := ''; AsmType := aByte; PasType := pByte; end;
      if (t = '/WORD') or (t = '/W') then begin s := ''; AsmType := aWord; PasType := pWord; end;

      if (t = '/DWORD') or (t = '/D') then begin s := ''; AsmType := aDWord; end;
      if (t = '/QWORD') or (t = '/Q') then begin s := ''; AsmType := aQWord; end;
      if t = '/TBYTE' then begin s := ''; AsmType := aTByte; end;

      if t = '/SHORTINT' then begin s := ''; PasType := pShortInt; end;
      if t = '/INTEGER'  then begin s := ''; PasType := pInteger;  end;
      if t = '/LONGINT'  then begin s := ''; PasType := pLongInt;  end;
      if t = '/CHAR'     then begin s := ''; PasType := pChar;     end;

    end else

    if c < 2 then begin

      inc(c);
      p[c] := s;
      s := '';

    end;

    if s <> '' then
      Error('Unknown parameter: '+s);

  end;

  case c of
    0: Error('File name required');
    1: go(FExpand(p[1]), addExt(p[1], DefEXT, True));
    2: go(FExpand(p[1]), addExt(p[2], DefEXT, False));
  end;

end.
