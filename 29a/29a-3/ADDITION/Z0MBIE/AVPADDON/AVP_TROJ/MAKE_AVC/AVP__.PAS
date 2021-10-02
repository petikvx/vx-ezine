unit avp__;

interface

(*
   формат .avc

   00h  DBx40H  kami_copyriht
   40H  DBx40H  author_copyright

   80H  DBx46H  avc_header

   xxx  suxЫ (заголовки для данных), 36 байт каждый

   yyy  данные

*)

type
  Tavc_header = record  { 46H байт }
    id        : array[1..4] of char;  { EK.8 }    { 00 01 02 03 }
    ver       : word;                 { 3 }       { 04 05 }

    bits      : byte;                             { 06 }
    (* 1й бит: 0 - изготовлено в Ками    ;)  *)
    (*         1 - изготовлено НЕ В КАМИ ;(  *)

    _1        : array[$07..$0B] of byte;

    filesize  : longint;                          { 0C 0D 0E 0F }

    sux_offs  : longint;                          { 10 11 12 13 }
    sux_count : word;                             { 14 15 }

    _2        : array[$16..$3D] of byte;

   authcpr_cs : longint;                          { 3E 3F 40 41 }
    hdr_cs    : longint;                          { 42 43 44 45 }
  end;

  Tsux = record { 36 байт }
    id          : word;         { 00 01 }    { 0/1/2 / 100H/101H/102H }

    unk_word    : word;         { 02 03 }

    data_offs   : longint;      { 04 05 06 07 }
    data_size   : longint;      { 08 09 0A 0B }
    { очевидно, размер распакованных данных }
    real_size   : longint;      { 0C 0D 0E 0F }

    _1 : array[$10..$17] of byte;

    data_cs     : longint;      { 18 19 1A 1B }

    _2 : array[$1C..$23] of byte;  { нули? }

  end;

function calc_checksum(var data_ptr; data_size : word) : longint;

implementation

function calc_checksum(var data_ptr; data_size : word) : longint; assembler;
  const
    word_0_7663 : word = 0;
  var
    word_0_3DDA, word_0_3DDC : word;
  asm
                xor     si, si
                mov     word_0_3DDA, si
                mov     word_0_3DDC, si

                les     bx, data_ptr
                mov     cx, data_size

@@loc_0_1878:
                mov     ax, word_0_3DDA
                mov     dx, word_0_3DDC
                cmp     word_0_7663, 0
                jnz     @@loc_0_18AA
                cmp     si, 4
                jnb     @@loc_0_18AA
                shl     ax, 1
                rcl     dx, 1
                shl     ax, 1
                rcl     dx, 1
                shl     ax, 1
                rcl     dx, 1
                shl     ax, 1
                rcl     dx, 1
                shl     ax, 1
                rcl     dx, 1
                shl     ax, 1
                rcl     dx, 1
                shl     ax, 1
                rcl     dx, 1

@@loc_0_18AA:
                shl     ax, 1
                rcl     dx, 1
                xor     word_0_3DDA, ax
                xor     word_0_3DDC, dx
                mov     al, es:[si+bx]
                xor     byte ptr word_0_3DDA, al
                inc     si
                jnz     @@loc_0_18C9

                mov     word_0_7663, 1

@@loc_0_18C9:   cmp     si, cx
                jnz     @@loc_0_1878
                mov     ax, word_0_3DDA
                mov     dx, word_0_3DDC
                {mov     word_0_7661, si}


  end;

begin
end.
