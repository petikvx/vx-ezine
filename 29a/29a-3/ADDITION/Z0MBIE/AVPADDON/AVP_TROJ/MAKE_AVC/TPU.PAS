unit TPU;

interface

function FStr(L : Longint) : String;

procedure error(msg : string);

procedure load(fname : string; ofs : longint; var buf; size : word; realsize : pointer);
procedure save(fname : string; ofs : longint; var buf; size : word);

function fsize(fname : string) : longint;

function HexByte(B : Byte) : string;
function HexWord(W : Word) : string;
function HexPointer(P : Pointer) : string;
function HexLong(L : Longint) : string;

implementation

uses Dos;

function fsize(fname : string) : longint;
  var
    r : searchrec;
  begin
    findfirst(fname, anyfile, r);
    fsize := r.size;
  end;

function FStr;
  var
    S : String;
  begin
    Str(L:0, S);
    FStr := S;
  end;

procedure error;
  begin
    writeln(msg);
    halt;
  end;

function Hex : Word; assembler;
  asm
    AAM 16
    ADD AL, 90H
    DAA
    ADC AL, 40H
    DAA
    XCHG AL, AH
    ADD AL, 90H
    DAA
    ADC AL, 40H
    DAA
  end;

function HexByte; assembler;
  asm
    LES DI, @RESULT
    CLD
    MOV AL, 2
    STOSB
    MOV AL, B
    CALL Hex
    STOSW
  end;

function HexWord; assembler;
  asm
    LES DI, @RESULT
    CLD
    MOV AL, 4
    STOSB
    MOV AL, BYTE PTR W + 1
    CALL Hex
    STOSW
    MOV AL, BYTE PTR W + 0
    CALL Hex
    STOSW
  end;

function HexPointer; assembler;
  asm
    LES DI, @RESULT
    CLD
    MOV AL, 9
    STOSB
    MOV AL, BYTE PTR P + 3
    CALL Hex
    STOSW
    MOV AL, BYTE PTR P + 2
    CALL Hex
    STOSW
    MOV AL, ':'
    STOSB
    MOV AL, BYTE PTR P + 1
    CALL Hex
    STOSW
    MOV AL, BYTE PTR P + 0
    CALL Hex
    STOSW
  end;

function HexLong; assembler;
  asm
    LES DI, @RESULT
    CLD
    MOV AL, 8
    STOSB
    MOV AL, L.BYTE[3]
    CALL Hex
    STOSW
    MOV AL, L.BYTE[2]
    CALL Hex
    STOSW
    MOV AL, L.BYTE[1]
    CALL Hex
    STOSW
    MOV AL, L.BYTE[0]
    CALL Hex
    STOSW
  end;

procedure load;
  var
    f : file;
    w : word;
  begin
    assign(f, fname);
    {$I-}
    reset(f,1);
    if IOResult <> 0 then
    begin
      writeln('file not found: ',fname);
      halt(1);
    end;
    seek(f, ofs);
    blockread(f, buf, size, w);
    if realsize <> nil then word(realsize^) := w;
    close(f);
  end;

procedure save;
  var
    f : file;
  begin
    assign(f, fname);
    if ofs = -1 then
      rewrite(f,1)
    else begin
      reset(f,1);
      if ofs = -2 then
        seek(f, filesize(f))
      else
        seek(f, ofs);
    end;
    if size = 0 then
      truncate(f)
    else
      blockwrite(f, buf, size);
    close(f);
  end;

end.
