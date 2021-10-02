
type
  long = longint;

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

function HexByte(B : Byte) : String; assembler;
  asm
    LES DI, @RESULT
    CLD
    MOV AL, 2
    STOSB
    MOV AL, B
    CALL Hex
    STOSW
  end;

function HexWord(W : Word) : String; assembler;
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

function HexLong(L : Long) : String; assembler;
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

type
  Theader = record
    avc_id              : array[1..4] of char;
    avc_ver             : word;
    avc_bits            : byte;
    avc_unk1            : array[1..5] of byte;
    avc_filesize        : long;
    avc_sux_offs        : long;
    avc_sux_count       : word;
    avc_unk2            : word;
    avc_unk3            : array[1..32] of byte;
    avc_unk4            : array[1..6] of byte;
    avc_author_cs       : long;
    avc_header_cs       : long;
  end;

  Tsux = record
    sux_id              : word;
    sux_id2             : word;
    sux_dataoffs        : long;
    sux_datasize        : long;
    sux_realsize        : long;
    sux_unk2            : word;
    sux_recsize         : word;
    sux_recnum          : long;
    sux_data_cs         : long;
    sux_unk3            : array[1..8] of byte;
  end;

var
  f : file;
  o : text;
  x : array[1..1024] of byte;
  i, xsize : word;

  sux : Tsux absolute x;
  h   : theader absolute x;
  a   : array[1..64] of char absolute x;

procedure dump_header;
  begin
    writeln(o, '; HEADER');
    writeln(o);
    writeln(o, '0000   avc_id          dword ',h.avc_id);
    writeln(o, '0004   avc_ver          word ',h.avc_ver);
    writeln(o, '0006   avc_bits         byte ',h.avc_bits);

    write  (o, '0007   avc_unk1       5xBYTE ');
    for i := 1 to 5 do
      write(o,hexbyte(h.avc_unk1[i]),' ');
    writeln(o);

    writeln(o, '000C   avc_filesize    dword ',h.avc_filesize);
    writeln(o, '0010   avc_sux_offs    dword ',hexlong(h.avc_sux_offs),' h');
    writeln(o, '0014   avc_sux_count    word ',h.avc_sux_count);
    writeln(o, '0016   avc_unk2         word ',h.avc_unk2);

    for i := 1 to 32 do
    begin
      if i = 1 then write  (o, '0018   avc_unk3      32xBYTE ');
      write(o,hexbyte(h.avc_unk3[i]));
      if i in [8,24] then write(o,'-') else write(o,' ');
      if i in [16] then write(o,#13#10'                             ');
    end;
    writeln(o);

    write  (o, '0038   avc_unk4       6xBYTE ');
    for i := 1 to 6 do
      write(o,hexbyte(h.avc_unk4[i]),' ');
    writeln(o);

    writeln(o, '003E   avc_author_cs   dword ',hexlong(h.avc_author_cs),' h');
    writeln(o, '0042   avc_header_cs   dword ',hexlong(h.avc_header_cs),' h');
  end;

procedure dump_sux;
  begin
    writeln(o, '; SUX');
    writeln(o);
    writeln(o, '0000   sux_id           word ',hexword(sux.sux_id ),' h');
    writeln(o, '0002   sux_id2          word ',hexword(sux.sux_id2),' h');
    writeln(o, '0004   sux_dataoffs    dword ',sux.sux_dataoffs);
    writeln(o, '0008   sux_datasize    dword ',sux.sux_datasize);
    writeln(o, '000C   sux_realsize    dword ',sux.sux_realsize);

    writeln(o, '0010   sux_unk2         word ',hexword(sux.sux_unk2),' h');
    writeln(o, '0010   sux_recsize      word ',hexword(sux.sux_recsize),' h');
    writeln(o, '0010   sux_recnum      dword ',sux.sux_recnum);

    writeln(o, '0018   sux_data_cs     dword ', hexlong(sux.sux_data_cs),' h');

    write  (o, '001C   sux_unused     8xBYTE ');
    for i := 1 to 8 do
      write(o, hexbyte(sux.sux_unk3[i]),' ');
    writeln(o);

  end;

begin
  if paramcount <> 2 then halt;

  assign(f, paramstr(1));
  reset(f,1);
  blockread(f, x, sizeof(x), xsize);

  assign(o, paramstr(2));
  rewrite(o);

  if filesize(f) = 64              then write(a);

  if filesize(f) = sizeof(Tsux)    then dump_sux;
  if filesize(f) = sizeof(Theader) then dump_header;

  close(f);

  close(o);
end.
