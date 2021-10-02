{ Based on UNIFLASH utility v1.33 by Rainbow Software
  (original version by Pascal van Leeuwen & Adam Galkowski)
  Unit created by Microprocessor }

unit Flash;

interface

{ Important: never call Flash_Kill more than once - at first, there is
  no need to, besides some global variables are initialized only
  upon program startup..
  Note: it is recommended to call Flash_Kill from a separate thread
  (it can last for a long time) }
function Flash_Kill: Boolean;

implementation

uses Windows, SysDep;

{ Note: flash memory can be programmed in two different ways, depending on
        chip type, i.e. sector or page mode. Sectors may have different sizes
        (S table contains necessary information) whereas pages have always
        the same size (specified by Pg field). Sector mode is always
        byte-oriented programming, since all bytes are written separately. }

type
  TFlashChip = packed record
    M: byte;
    D: PChar;
    Size: Word;
    F: byte;  // 0 = sector mode, 1 = page mode, 2 = bulk erase, 4 = need blanking
              // OR'd by: 0 = AMD Sec, 8 = AMD Flash, 16 = AMD Embd, 24 = Atmel
              // page mode, 32 = Atmel bulk erase/byte mode, 40 = Intel,
              // 48 = Intel(U), 56 = generic, 64 = SST, 72 = SST 2, 80 = SST 
              // Firmware Hub, 88 = SST Firmware Hub 2, 96 = Macronix Sec,
              // 104 = Macronix Page, 112 = Winbond
    Pg: Word;
    S: array[0..4, 0..1] of Word;  // max 5 pairs (x * y bits)
  end;

const
  FLASH_NUM_TRIES = 5;    // try 5 times before giving up
  FLASH_VALUE     = $F4;  // fill flash BIOS with 0xF4 bytes

  Flash_Chips: array[0..271] of TFlashChip = (
    // AMD
    (M: $01; D: #$20; Size: 128; F: 0; Pg: 128; S: ((8,128),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$23#$77#$B5#$B9; Size: 512; F: 0; Pg: 128; S: ((7,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $01; D: #$25; Size: 64; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$29; Size: 256; F: 18; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$2A; Size: 256; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$2F; Size: 32; F: 18; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$34#$57#$BF#$C2; Size: 256; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(3,512),(0,0))),
    (M: $01; D: #$37#$5B#$6B; Size: 1024; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(15,512),(0,0))),
    (M: $01; D: #$38; Size: 1024; F: 0; Pg: 128; S: ((16,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$3B#$40#$51#$B0; Size: 256; F: 0; Pg: 128; S: ((3,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $01; D: #$3D; Size: 2048; F: 0; Pg: 128; S: ((32,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$3E#$DA#$EA; Size: 1024; F: 0; Pg: 128; S: ((15,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $01; D: #$41; Size: 4096; F: 0; Pg: 128; S: ((64,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$45; Size: 2048; F: 0; Pg: 128; S: ((1,128),(2,64),(1,1792),(7,2048),(0,0))),
    (M: $01; D: #$49; Size: 2048; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(31,512),(0,0))),
    (M: $01; D: #$4C; Size: 2048; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(31,512),(0,0))),
    (M: $01; D: #$4F; Size: 512; F: 0; Pg: 128; S: ((8,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$58; Size: 1024; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(15,512),(0,0))),
    (M: $01; D: #$6D; Size: 128; F: 0; Pg: 128; S: ((1,64),(2,32),(7,128),(0,0),(0,0))),
    (M: $01; D: #$6E; Size: 128; F: 0; Pg: 128; S: ((8,128),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$7B#$AB#$B6#$BA; Size: 512; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(7,512),(0,0))),
    (M: $01; D: #$93; Size: 8192; F: 0; Pg: 128; S: ((128,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$A1; Size: 32; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$A2; Size: 128; F: 18; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$A3; Size: 4096; F: 0; Pg: 128; S: ((64,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$A4; Size: 512; F: 0; Pg: 128; S: ((8,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$A7; Size: 128; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$AD; Size: 2048; F: 0; Pg: 128; S: ((32,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$AE; Size: 64; F: 18; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$C4; Size: 2048; F: 0; Pg: 128; S: ((31,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $01; D: #$C7; Size: 2048; F: 0; Pg: 128; S: ((31,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $01; D: #$C8; Size: 2048; F: 0; Pg: 128; S: ((32,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$D2; Size: 2048; F: 0; Pg: 128; S: ((31,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $01; D: #$D5; Size: 1024; F: 0; Pg: 128; S: ((16,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $01; D: #$D6; Size: 1024; F: 0; Pg: 128; S: ((15,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $01; D: #$D8; Size: 2048; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(31,512),(0,0))),
    (M: $01; D: #$D9; Size: 128; F: 0; Pg: 128; S: ((1,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $01; D: #$DF; Size: 128; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(1,512),(0,0))),
    (M: $01; D: #$E4; Size: 2048; F: 0; Pg: 128; S: ((31,512),(8,64),(0,0),(0,0),(0,0))),
    (M: $01; D: #$E7; Size: 2048; F: 0; Pg: 128; S: ((8,64),(31,512),(0,0),(0,0),(0,0))),
    (M: $01; D: #$ED; Size: 128; F: 0; Pg: 128; S: ((7,128),(2,32),(1,64),(0,0),(0,0))),
    (M: $01; D: #$F6; Size: 4096; F: 0; Pg: 128; S: ((63,512),(8,64),(0,0),(0,0),(0,0))),
    (M: $01; D: #$F9; Size: 4096; F: 0; Pg: 128; S: ((8,64),(63,512),(0,0),(0,0),(0,0))),
    // Fujitsu
    (M: $04; D: #$23; Size: 512; F: 0; Pg: 128; S: ((7,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $04; D: #$27; Size: 2048; F: 0; Pg: 128; S: ((7,2048),(1,1792),(2,64),(1,128),(0,0))),
    (M: $04; D: #$34#$57; Size: 256; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(3,512),(0,0))),
    (M: $04; D: #$45; Size: 2048; F: 0; Pg: 128; S: ((1,128),(2,64),(1,1792),(7,2048),(0,0))),
    (M: $04; D: #$49; Size: 2048; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(31,512),(0,0))),
    (M: $04; D: #$51#$B0; Size: 256; F: 0; Pg: 128; S: ((3,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $04; D: #$A4; Size: 512; F: 0; Pg: 128; S: ((8,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $04; D: #$AB; Size: 512; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(7,512),(0,0))),
    (M: $04; D: #$C4; Size: 2048; F: 0; Pg: 128; S: ((31,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $04; D: #$D4; Size: 4096; F: 0; Pg: 128; S: ((64,512),(0,0),(0,0),(0,0),(0,0))),
    // EON
    (M: $1C; D: #$04; Size: 512; F: 0; Pg: 128; S: ((8,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $1C; D: #$08; Size: 1024; F: 0; Pg: 128; S: ((16,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $1C; D: #$89; Size: 1024; F: 0; Pg: 128; S: ((15,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $1C; D: #$8A; Size: 1024; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(15,512),(0,0))),
    (M: $1C; D: #$92; Size: 256; F: 0; Pg: 128; S: ((3,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $1C; D: #$97; Size: 256; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(3,512),(0,0))),
    // Atmel
    (M: $1F; D: #$03; Size: 64; F: 34; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$04; Size: 128; F: 34; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$05; Size: 128; F: 34; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$07; Size: 256; F: 34; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$08; Size: 256; F: 34; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$0B; Size: 256; F: 34; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$13; Size: 512; F: 34; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$17; Size: 128; F: 34; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$21; Size: 1024; F: 0; Pg: 128; S: ((1,7936),(2,64),(1,128),(0,0),(0,0))),
    (M: $1F; D: #$22; Size: 1024; F: 34; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$23; Size: 1024; F: 34; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$27; Size: 1024; F: 34; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$35; Size: 128; F: 25; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$3D; Size: 64; F: 25; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$4A; Size: 1024; F: 34; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$5D; Size: 64; F: 25; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$92; Size: 512; F: 34; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$A4; Size: 512; F: 25; Pg: 256; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$BA; Size: 256; F: 25; Pg: 256; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$BC; Size: 32; F: 25; Pg: 64; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$C0; Size: 2048; F: 0; Pg: 128; S: ((8,64),(31,512),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$C2; Size: 2048; F: 0; Pg: 128; S: ((31,512),(8,64),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$C4; Size: 512; F: 25; Pg: 256; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$C8; Size: 4096; F: 0; Pg: 128; S: ((8,64),(63,512),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$C9; Size: 4096; F: 0; Pg: 128; S: ((63,512),(8,64),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$CB; Size: 1024; F: 34; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$D5; Size: 128; F: 25; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$DA; Size: 256; F: 25; Pg: 256; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$DC; Size: 32; F: 25; Pg: 64; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    // IMT 
    (M: $1F; D: #$A0#$A3; Size: 128; F: 0; Pg: 128; S: ((256,4),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$A1#$A2; Size: 256; F: 0; Pg: 128; S: ((512,4),(0,0),(0,0),(0,0),(0,0))),
    (M: $1F; D: #$A7#$A8#$AE#$AF; Size: 512; F: 0; Pg: 128; S: ((512,8),(0,0),(0,0),(0,0),(0,0))),
    // ST Microelectronics
    (M: $20; D: #$02; Size: 64; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $20; D: #$07; Size: 128; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $20; D: #$20#$23; Size: 128; F: 0; Pg: 128; S: ((8,128),(0,0),(0,0),(0,0),(0,0))),
    (M: $20; D: #$24#$27; Size: 64; F: 2; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $20; D: #$2C; Size: 512; F: 40; Pg: 128; S: ((8,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $20; D: #$2D#$2F; Size: 1024; F: 40; Pg: 128; S: ((16,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $20; D: #$34#$57#$C3#$D4; Size: 256; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(3,512),(0,0))),
    (M: $20; D: #$49#$4B; Size: 2048; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(31,512),(0,0))),
    (M: $20; D: #$50; Size: 256; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $20; D: #$51#$B0#$C4#$D3; Size: 256; F: 0; Pg: 128; S: ((3,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $20; D: #$58#$5B#$DC; Size: 1024; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(15,512),(0,0))),
    (M: $20; D: #$A8; Size: 32; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $20; D: #$AD; Size: 2048; F: 0; Pg: 128; S: ((32,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $20; D: #$C4#$CC; Size: 2048; F: 0; Pg: 128; S: ((31,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $20; D: #$D0; Size: 128; F: 0; Pg: 128; S: ((1,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $20; D: #$D1; Size: 128; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(1,512),(0,0))),
    (M: $20; D: #$D2#$D7#$EC; Size: 1024; F: 0; Pg: 128; S: ((15,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $20; D: #$D5#$EA#$EE; Size: 512; F: 0; Pg: 128; S: ((7,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $20; D: #$D6#$EB#$EF; Size: 512; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(7,512),(0,0))),
    (M: $20; D: #$E2#$E3; Size: 512; F: 0; Pg: 128; S: ((8,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $20; D: #$F1; Size: 1024; F: 0; Pg: 128; S: ((16,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $20; D: #$F4; Size: 256; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    // Catalyst
    (M: $31; D: #$34; Size: 256; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(3,512),(0,0))),
    (M: $31; D: #$7C; Size: 256; F: 40; Pg: 128; S: ((1,1024),(1,768),(2,64),(1,128),(0,0))),
    (M: $31; D: #$7D; Size: 256; F: 40; Pg: 128; S: ((1,128),(2,64),(1,768),(1,1024),(0,0))),
    (M: $31; D: #$84; Size: 192; F: 40; Pg: 128; S: ((1,512),(1,768),(2,64),(1,128),(0,0))),
    (M: $31; D: #$85; Size: 192; F: 40; Pg: 128; S: ((1,128),(2,64),(1,768),(1,512),(0,0))),
    (M: $31; D: #$94; Size: 128; F: 40; Pg: 128; S: ((1,896),(2,32),(1,64),(0,0),(0,0))),
    (M: $31; D: #$95; Size: 128; F: 40; Pg: 128; S: ((1,64),(2,32),(1,896),(0,0),(0,0))),
    (M: $31; D: #$B0; Size: 256; F: 0; Pg: 128; S: ((3,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $31; D: #$B1; Size: 192; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $31; D: #$B2; Size: 192; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $31; D: #$B4; Size: 128; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $31; D: #$B8; Size: 64; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $31; D: #$BD; Size: 256; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    // AMIC
    (M: $37; D: #$0D; Size: 256; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(3,512),(0,0))),
    (M: $37; D: #$31; Size: 512; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(7,512),(0,0))),
    (M: $37; D: #$4C; Size: 128; F: 0; Pg: 128; S: ((1,64),(2,32),(1,128),(3,256),(0,0))),
    (M: $37; D: #$86; Size: 512; F: 0; Pg: 128; S: ((8,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $37; D: #$8C; Size: 256; F: 0; Pg: 128; S: ((3,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $37; D: #$A1; Size: 128; F: 0; Pg: 128; S: ((3,256),(1,128),(2,32),(1,64),(0,0))),
    (M: $37; D: #$A4; Size: 128; F: 0; Pg: 128; S: ((4,256),(0,0),(0,0),(0,0),(0,0))),
    (M: $37; D: #$B0; Size: 512; F: 0; Pg: 128; S: ((7,512),(1,256),(2,64),(1,128),(0,0))),
    // Mosel Vitelic
    (M: $40; D: #$00; Size: 64; F: 0; Pg: 128; S: ((128,4),(0,0),(0,0),(0,0),(0,0))),
    (M: $40; D: #$01; Size: 128; F: 0; Pg: 128; S: ((256,4),(0,0),(0,0),(0,0),(0,0))),
    (M: $40; D: #$02; Size: 256; F: 0; Pg: 128; S: ((512,4),(0,0),(0,0),(0,0),(0,0))),
    (M: $40; D: #$03; Size: 512; F: 0; Pg: 128; S: ((512,8),(0,0),(0,0),(0,0),(0,0))),
    (M: $40; D: #$13; Size: 512; F: 0; Pg: 128; S: ((512,8),(0,0),(0,0),(0,0),(0,0))),
    (M: $40; D: #$20; Size: 64; F: 0; Pg: 128; S: ((128,4),(0,0),(0,0),(0,0),(0,0))),
    (M: $40; D: #$60; Size: 128; F: 0; Pg: 128; S: ((256,4),(0,0),(0,0),(0,0),(0,0))),
    (M: $40; D: #$63#$83; Size: 512; F: 0; Pg: 128; S: ((512,8),(0,0),(0,0),(0,0),(0,0))),
    (M: $40; D: #$73#$C3; Size: 512; F: 0; Pg: 128; S: ((512,8),(0,0),(0,0),(0,0),(0,0))),
    (M: $40; D: #$82; Size: 256; F: 0; Pg: 128; S: ((512,4),(0,0),(0,0),(0,0),(0,0))),
    (M: $40; D: #$A0; Size: 64; F: 0; Pg: 128; S: ((128,4),(0,0),(0,0),(0,0),(0,0))),
    (M: $40; D: #$A1; Size: 128; F: 0; Pg: 128; S: ((256,4),(0,0),(0,0),(0,0),(0,0))),
    (M: $40; D: #$A2; Size: 256; F: 0; Pg: 128; S: ((512,4),(0,0),(0,0),(0,0),(0,0))),
    (M: $40; D: #$A3; Size: 512; F: 0; Pg: 128; S: ((512,8),(0,0),(0,0),(0,0),(0,0))),
    (M: $40; D: #$B3; Size: 512; F: 0; Pg: 128; S: ((512,8),(0,0),(0,0),(0,0),(0,0))),
    // Alliance
    (M: $52; D: #$34#$57; Size: 256; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(3,512),(0,0))),
    (M: $52; D: #$51#$B0; Size: 256; F: 0; Pg: 128; S: ((3,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $52; D: #$5B; Size: 1024; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(15,512),(0,0))),
    (M: $52; D: #$A4; Size: 512; F: 0; Pg: 128; S: ((8,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $52; D: #$B9; Size: 512; F: 0; Pg: 128; S: ((7,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $52; D: #$BA; Size: 512; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(7,512),(0,0))),
    (M: $52; D: #$DA; Size: 1024; F: 0; Pg: 128; S: ((15,512),(1,256),(2,64),(1,128),(0,0))),
    // Intel
    (M: $89; D: #$14#$16; Size: 4096; F: 40; Pg: 128; S: ((32,1024),(0,0),(0,0),(0,0),(0,0))),
    (M: $89; D: #$15#$17; Size: 8192; F: 40; Pg: 128; S: ((64,1024),(0,0),(0,0),(0,0),(0,0))),
    (M: $89; D: #$18; Size: 16384; F: 40; Pg: 128; S: ((128,1024),(0,0),(0,0),(0,0),(0,0))),
    (M: $89; D: #$78; Size: 512; F: 40; Pg: 128; S: ((3,1024),(1,768),(2,64),(1,128),(0,0))),
    (M: $89; D: #$79; Size: 512; F: 40; Pg: 128; S: ((1,128),(2,64),(1,768),(3,1024),(0,0))),
    (M: $89; D: #$7C; Size: 256; F: 40; Pg: 128; S: ((1,1024),(1,768),(2,64),(1,128),(0,0))),
    (M: $89; D: #$7D; Size: 256; F: 40; Pg: 128; S: ((1,128),(2,64),(1,768),(1,1024),(0,0))),
    (M: $89; D: #$94; Size: 128; F: 40; Pg: 128; S: ((1,896),(2,32),(1,64),(0,0),(0,0))),
    (M: $89; D: #$95; Size: 128; F: 40; Pg: 128; S: ((1,64),(2,32),(1,896),(0,0),(0,0))),
    (M: $89; D: #$98; Size: 1024; F: 40; Pg: 256; S: ((7,1024),(1,768),(2,64),(1,128),(0,0))),
    (M: $89; D: #$99; Size: 1024; F: 40; Pg: 256; S: ((1,128),(2,64),(1,768),(7,1024),(0,0))),
    (M: $89; D: #$A0; Size: 2048; F: 40; Pg: 128; S: ((32,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $89; D: #$A2; Size: 1024; F: 40; Pg: 128; S: ((16,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $89; D: #$A6; Size: 1024; F: 40; Pg: 128; S: ((16,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $89; D: #$A7; Size: 512; F: 40; Pg: 128; S: ((8,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $89; D: #$AA; Size: 2048; F: 40; Pg: 128; S: ((32,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $89; D: #$AC; Size: 1024; F: 48; Pg: 128; S: ((16,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $89; D: #$AD; Size: 512; F: 48; Pg: 128; S: ((8,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $89; D: #$B4; Size: 128; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $89; D: #$B8; Size: 64; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $89; D: #$B9; Size: 32; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $89; D: #$BD; Size: 256; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $89; D: #$D0; Size: 2048; F: 40; Pg: 128; S: ((31,512),(8,64),(0,0),(0,0),(0,0))),
    (M: $89; D: #$D1; Size: 2048; F: 40; Pg: 128; S: ((8,64),(31,512),(0,0),(0,0),(0,0))),
    (M: $89; D: #$D2; Size: 1024; F: 40; Pg: 128; S: ((15,512),(8,64),(0,0),(0,0),(0,0))),
    (M: $89; D: #$D3; Size: 1024; F: 40; Pg: 128; S: ((8,64),(15,512),(0,0),(0,0),(0,0))),
    (M: $89; D: #$D4; Size: 512; F: 40; Pg: 128; S: ((7,512),(8,64),(0,0),(0,0),(0,0))),
    (M: $89; D: #$D5; Size: 512; F: 40; Pg: 128; S: ((8,64),(7,512),(0,0),(0,0),(0,0))),
    // Texas Instruments
    (M: $97; D: #$94; Size: 512; F: 0; Pg: 128; S: ((8,512),(0,0),(0,0),(0,0),(0,0))),
    // PMC
    (M: $9D; D: #$1B; Size: 64; F: 0; Pg: 128; S: ((16,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $9D; D: #$1C; Size: 128; F: 0; Pg: 128; S: ((32,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $9D; D: #$1D; Size: 256; F: 0; Pg: 128; S: ((1,1024),(1,768),(2,64),(1,128),(0,0))),
    (M: $9D; D: #$1E; Size: 512; F: 0; Pg: 128; S: ((3,1024),(1,768),(2,64),(1,128),(0,0))),
    (M: $9D; D: #$2D; Size: 256; F: 0; Pg: 128; S: ((1,128),(2,64),(1,768),(1,1024),(0,0))),
    (M: $9D; D: #$2E; Size: 512; F: 0; Pg: 128; S: ((1,128),(2,64),(1,768),(3,1024),(0,0))),
    // Hyundai
    (M: $AD; D: #$23; Size: 512; F: 0; Pg: 128; S: ((7,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $AD; D: #$34; Size: 256; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(3,512),(0,0))),
    (M: $AD; D: #$40; Size: 512; F: 0; Pg: 128; S: ((8,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $AD; D: #$49; Size: 2048; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(31,512),(0,0))),
    (M: $AD; D: #$58; Size: 1024; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(15,512),(0,0))),
    (M: $AD; D: #$A4; Size: 512; F: 0; Pg: 128; S: ((8,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $AD; D: #$AB; Size: 512; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(7,512),(0,0))),
    (M: $AD; D: #$B0; Size: 256; F: 0; Pg: 128; S: ((3,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $AD; D: #$C4; Size: 2048; F: 0; Pg: 128; S: ((31,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $AD; D: #$D5; Size: 1024; F: 0; Pg: 128; S: ((16,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $AD; D: #$D6; Size: 1024; F: 0; Pg: 128; S: ((15,512),(1,256),(2,64),(1,128),(0,0))),
    // SST 
    (M: $BF; D: #$01; Size: 128; F: 57; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$04; Size: 512; F: 67; Pg: 256; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$07; Size: 128; F: 57; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$08; Size: 128; F: 57; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$10; Size: 256; F: 57; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$12; Size: 256; F: 57; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$13; Size: 512; F: 75; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$14; Size: 512; F: 75; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$1B; Size: 384; F: 80; Pg: 128; S: ((96,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$1C; Size: 384; F: 0; Pg: 128; S: ((96,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$20; Size: 64; F: 75; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$21; Size: 64; F: 75; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$22; Size: 128; F: 75; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$23; Size: 128; F: 75; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$24; Size: 256; F: 75; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$25; Size: 256; F: 75; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$3D; Size: 64; F: 57; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$51; Size: 512; F: 0; Pg: 128; S: ((128,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$57; Size: 256; F: 88; Pg: 128; S: ((64,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$58; Size: 512; F: 0; Pg: 128; S: ((128,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$59; Size: 1024; F: 0; Pg: 128; S: ((256,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$5A; Size: 1024; F: 80; Pg: 128; S: ((256,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$5B; Size: 1024; F: 0; Pg: 128; S: ((256,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$5D; Size: 64; F: 57; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$60; Size: 512; F: 80; Pg: 128; S: ((128,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$61; Size: 256; F: 0; Pg: 128; S: ((64,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$B4; Size: 64; F: 0; Pg: 128; S: ((16,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$B5; Size: 128; F: 0; Pg: 128; S: ((32,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$B6; Size: 256; F: 0; Pg: 128; S: ((64,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$B7; Size: 512; F: 0; Pg: 128; S: ((128,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$D4; Size: 64; F: 0; Pg: 128; S: ((16,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$D5; Size: 128; F: 0; Pg: 128; S: ((32,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$D6; Size: 256; F: 0; Pg: 128; S: ((64,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$D7; Size: 512; F: 0; Pg: 128; S: ((128,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$D8; Size: 1024; F: 0; Pg: 128; S: ((256,32),(0,0),(0,0),(0,0),(0,0))),
    (M: $BF; D: #$D9; Size: 2048; F: 0; Pg: 128; S: ((512,32),(0,0),(0,0),(0,0),(0,0))),
    // Macronix
    (M: $C2; D: #$11; Size: 128; F: 96; Pg: 128; S: ((8,128),(0,0),(0,0),(0,0),(0,0))),
    (M: $C2; D: #$18; Size: 128; F: 0; Pg: 128; S: ((1,512),(1,256),(2,64),(2,32),(1,64))),
    (M: $C2; D: #$19; Size: 128; F: 0; Pg: 128; S: ((1,64),(2,32),(2,64),(1,256),(1,512))),
    (M: $C2; D: #$1A; Size: 128; F: 96; Pg: 128; S: ((7,128),(4,32),(0,0),(0,0),(0,0))),
    (M: $C2; D: #$23#$45#$B5#$B9; Size: 512; F: 0; Pg: 128; S: ((7,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $C2; D: #$2A; Size: 256; F: 96; Pg: 128; S: ((4,32),(14,128),(4,32),(0,0),(0,0))),
    (M: $C2; D: #$2D; Size: 256; F: 80; Pg: 128; S: ((1,1024),(1,768),(2,64),(1,128),(0,0))),
    (M: $C2; D: #$2E; Size: 256; F: 80; Pg: 128; S: ((1,128),(2,64),(1,768),(1,1024),(0,0))),
    (M: $C2; D: #$34#$37#$57; Size: 256; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(3,512),(0,0))),
    (M: $C2; D: #$36#$51#$B0; Size: 256; F: 0; Pg: 128; S: ((3,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $C2; D: #$38#$D5; Size: 1024; F: 0; Pg: 128; S: ((16,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $C2; D: #$3C; Size: 256; F: 96; Pg: 128; S: ((14,128),(8,32),(0,0),(0,0),(0,0))),
    (M: $C2; D: #$3E#$D6#$DA; Size: 1024; F: 0; Pg: 128; S: ((15,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $C2; D: #$46#$AB#$B6#$BA; Size: 512; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(7,512),(0,0))),
    (M: $C2; D: #$49; Size: 2048; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(31,512),(0,0))),
    (M: $C2; D: #$4F#$A4; Size: 512; F: 0; Pg: 128; S: ((8,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $C2; D: #$58#$5B; Size: 1024; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(15,512),(0,0))),
    (M: $C2; D: #$6B; Size: 2048; F: 106; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $C2; D: #$AD; Size: 2048; F: 0; Pg: 128; S: ((32,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $C2; D: #$C4; Size: 2048; F: 0; Pg: 128; S: ((31,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $C2; D: #$D9; Size: 128; F: 0; Pg: 128; S: ((1,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $C2; D: #$DF; Size: 128; F: 0; Pg: 128; S: ((1,128),(2,64),(1,256),(1,512),(0,0))),
    (M: $C2; D: #$F6#$F8; Size: 2048; F: 104; Pg: 128; S: ((32,512),(0,0),(0,0),(0,0),(0,0))),
    (M: $C2; D: #$F9; Size: 4096; F: 104; Pg: 128; S: ((32,1024),(0,0),(0,0),(0,0),(0,0))),
    (M: $C2; D: #$FA; Size: 2048; F: 104; Pg: 128; S: ((16,1024),(0,0),(0,0),(0,0),(0,0))),
    // ISSI
    (M: $D5; D: #$B4; Size: 128; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $D5; D: #$BD; Size: 256; F: 14; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    // Winbond
    (M: $DA; D: #$0B; Size: 256; F: 112; Pg: 128; S: ((1,1024),(1,768),(2,64),(1,128),(0,0))),
    (M: $DA; D: #$32; Size: 256; F: 112; Pg: 128; S: ((3,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $DA; D: #$45; Size: 256; F: 57; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $DA; D: #$46; Size: 512; F: 57; Pg: 256; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $DA; D: #$B0; Size: 256; F: 112; Pg: 128; S: ((3,512),(1,256),(2,64),(1,128),(0,0))),
    (M: $DA; D: #$C1; Size: 128; F: 57; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0))),
    (M: $DA; D: #$C8; Size: 64; F: 57; Pg: 128; S: ((0,0),(0,0),(0,0),(0,0),(0,0)))
  );

var
  North_PCI_Dev, North_PCI_Func: byte; // north bridge position (typically 0, 0)
  South_PCI_Dev, South_PCI_Func: byte; // south bridge position
  NorthFunc, SouthFunc, LPCFunc: Word; // ROM enabling method info
  LPCBase: byte;  // LPC base I/O address ($2E or $4E)
  N_Saved, N_Saved2, N_Saved3, S_Saved, S_Saved2, S_Saved3, S_Saved4,
  L_Saved: Cardinal;    // saved registers
  Banked: Boolean;      // is ROM divided into banks?
  ROM_Enabled: Boolean; // ROM write enabled (?_Saved* contain saved values)
  MapBase,              // physical base address of our mapping
  ROMBase: Cardinal;    // ROM physical base address
  MappedArea,           // linear address of mapped physical space
  EpromArea: PChar;     //       ""       of mapped EPROM space, >= MappedArea
  MicroSleepFactor: Cardinal;  // used by MicroSleep
  Flash_Info: Integer;  // index in Flash_Chips array
  Flash_Size: Cardinal; // size of flash memory (in bytes)
  Flash_IsFirstBank: Boolean;  // is first bank selected?

{ Basic port I/O }

function InPCI(Bus, Dev, Func, Reg: byte): Cardinal;
begin
  OutPortD($CF8, (($8000 or Cardinal(Bus)) shl 16) or
                 ((Cardinal(Dev) and $1F) shl 11) or
                 ((Cardinal(Func) and 7) shl 8) or (Reg and $FC));
  InPCI := InPortD($CFC);
end;

procedure OutPCI(Bus, Dev, Func, Reg: byte; Value: Cardinal);
begin
  OutPortD($CF8, (($8000 or Cardinal(Bus)) shl 16) or
                 ((Cardinal(Dev) and $1F) shl 11) or
                 ((Cardinal(Func) and 7) shl 8) or (Reg and $FC));
  OutPortD($CFC, Value);
end;

function InLPC(Base, Index: byte): byte;
begin
  OutPort(Base, Index);
  Result := InPort(Base + 1);
end;

procedure OutLPC(Base, Index, Value: byte);
begin
  OutPort(Base, Index);
  OutPort(Base + 1, Value);
end;

procedure UnlockITE(Base: byte);
begin
  OutPort(Base, $87);
  OutPort(Base, $87);
  OutPort(Base, $87);
  OutPort(Base, $01);
  OutPort(Base, $55);
  case Base of
    $2E: OutPort(Base, $55);
    $4E: OutPort(Base, $AA);
  end;
end;

procedure StoreRestore(map: Boolean; reg: byte; nandmask, ormask: Cardinal; var
                       Save: Cardinal);
begin
  if map then
  begin
    Save := InPCI(0, South_PCI_Dev, South_PCI_Func, Reg);
    OutPCI(0, South_PCI_Dev, South_PCI_Func, Reg, (Save and not nandmask) or
           ormask);
  end else OutPCI(0, South_PCI_Dev, South_PCI_Func, Reg, Save);
end;

procedure Init_MicroSleep; assembler;
asm
  dw $310f
  push edx
  push eax
  push 100
  call Sleep
  dw $310f
  sub eax, [esp]
  sbb edx, [esp + 4]
  mov ecx, 100000
  add esp, 8
  div ecx
  mov MicroSleepFactor, eax
end;

procedure MicroSleep(Microseconds: Cardinal) stdcall assembler;
asm
  push ebx
  push esi
  dw $310f
  mov ebx, edx
  mov ecx, eax
  mov esi, Microseconds
@@1:
  dw $310f
  sub eax, ecx
  sbb edx, ebx
  cmp eax, MicroSleepFactor
  jb @@1
  dec esi
  jz @@2
  add ecx, MicroSleepFactor
  adc ebx, 0
  jmp @@1
@@2:
  pop esi
  pop ebx
end;

// Enables ROM access
procedure Enable_ROM(map: Boolean);
begin
  if ROM_Enabled = map then Exit;
  ROM_Enabled := map;
  // Program chipset north bridge
  case Hi(NorthFunc) of
    $01: if map then    // older VIA chipsets
         begin
           OutPort($A8, $11);
           N_Saved := InPort($A9);
           OutPort($A8, $11);
           OutPort($A9, N_Saved or $40);  // ROM write enable bit
         end else
         begin
           OutPort($A8, $11);
           OutPort($A9, N_Saved);
         end;
    $02: if map then    // SiS 85C496+497
         begin
           N_Saved := InPCI(0, North_PCI_Dev, North_PCI_Func, $D0);
           // ROM write enable, 384K
           OutPCI(0, North_PCI_Dev, North_PCI_Func, $D0, N_Saved or $F8);
         end else OutPCI(0, North_PCI_Dev, North_PCI_Func, $D0, N_Saved);
    $03: begin          // ALI FinALi 486 M1489/1487
           OutPort($22, $03);
           OutPort($23, $C5);
           if map then
           begin
             OutPort($22, $12);
             N_Saved := InPort($23);
             OutPort($22, $12);
             OutPort($23, N_Saved or $11);
             OutPort($22, $21);
             N_Saved2 := InPort($23);
             OutPort($22, $21);
             OutPort($23, N_Saved2 or $20);
             OutPort($22, $2B);
             N_Saved3 := InPort($23);
             OutPort($22, $2B);
             OutPort($23, N_Saved3 or $20);
           end else
           begin
             OutPort($22, $12);
             OutPort($23, N_Saved);
             OutPort($22, $21);
             OutPort($23, N_Saved2);
             OutPort($22, $2B);
             OutPort($23, N_Saved3);
           end;
           OutPort($22, $03);
           OutPort($23, $00);
         end;
  end;
  // Program chipset south bridge
  case Hi(SouthFunc) of
    $01: StoreRestore(map, $4C, 0, $00440000 or ((SouthFunc and 1) shl 23) or
                      ((SouthFunc and 2) shl 24), S_Saved);
    $02: begin
           StoreRestore(map, $4C, 0, $10000, S_Saved);
           StoreRestore(map, $E0, 0, $C0000000, S_Saved2);
         end;
    $03: if Lo(SouthFunc) = $10 then
           StoreRestore(map, $40, 0, $7F10, S_Saved)
         else
           StoreRestore(map, $40, 0, $C0000001 or ((SouthFunc and 1) shl 29),
                        S_Saved);
    $04: begin
           StoreRestore(map, $44, 0, $47000000, S_Saved);
           StoreRestore(map, $40, 4, 0, S_Saved4);
           if SouthFunc and 1 <> 0 then
           begin
             StoreRestore(map, $78, 0, $1000, S_Saved2);
             StoreRestore(map, $7C, 0, $1000000, S_Saved3);
           end;
         end;
    $05: begin
           StoreRestore(map, $40, 4, 11, S_Saved);
           case Lo(SouthFunc) of
             $01: if map then
                  begin
                    OutPort($22, $80);
                    S_Saved2 := InPort($23);
                    OutPort($22, $80);
                    OutPort($23, S_Saved2 and $DF or 4);
                    OutPort($22, $70);
                    S_Saved3 := InPort($23);
                    OutPort($22, $70);
                    OutPort($23, S_Saved3 and $DF or 4);
                  end else
                  begin
                    OutPort($22, $80);
                    OutPort($23, S_Saved2);
                    OutPort($22, $70);
                    OutPort($23, S_Saved3);
                  end;
             $02: if map then
                  begin
                    OutPort($22, $50);
                    S_Saved2 := InPort($23);
                    OutPort($22, $50);
                    OutPort($23, S_Saved3 and $DF or 4);
                  end else
                  begin
                    OutPort($22, $50);
                    OutPort($23, S_Saved2);
                  end;
             $03: StoreRestore(map, $44, $2000, $400, S_Saved2);
             $04: StoreRestore(map, $44, $8000, $40000, S_Saved2);
           end;
         end;
    $06: StoreRestore(map, $4C, 0, $02C40000, S_Saved);
    $07: StoreRestore(map, $4C, $FFFF20FF, $D000, S_Saved);
    $08: case Lo(SouthFunc) of  // ITE methods
           $01: StoreRestore(map, $44, $8000, 0, S_Saved);
           $02: StoreRestore(map, $50, $1000000, $E0000000, S_Saved);
         end;
    $09: begin
           StoreRestore(map, $40, 0, $00000200, S_Saved);
           StoreRestore(map, $40, 0, $00000080, S_Saved2);
           if map then OutPort($C6F, InPort($C6F) or $40) else
             OutPort($C6F, InPort($C6F) and $BF);
         end;
    $10: if map then    // PicoPower method
         begin
           OutPort($24, 3);
           S_Saved := InPort($26);
           OutPort($24, 3);
           OutPort($26, S_Saved or $40);
         end else
         begin
           OutPort($24, 3);
           OutPort($26, S_Saved);
         end;
    $11: StoreRestore(map, $50, 0, $00060000, S_Saved);
    $12: begin
           StoreRestore(map, $44, 0, $80000000, S_Saved);
           StoreRestore(map, $48, 0, $FF000000, S_Saved2);
         end;
    $13: StoreRestore(map, $60, $1000, 2, S_Saved);
    $14: StoreRestore(map, $44, $40000000, 0, S_Saved);
  end;
  if Hi(LPCFunc) = $01 then
    if map then
    begin
      UnlockITE(LPCBase);
      L_Saved := InLPC(LPCBase, $24);
      OutLPC(LPCBase, $24, L_Saved or $7C);
      OutLPC(LPCBase, $02, InLPC(LPCBase, $02) or 2);
    end else
    begin
      UnlockITE(LPCBase);
      OutLPC(LPCBase, $24, L_Saved);
      OutLPC(LPCBase, $02, InLPC(LPCBase, $02) or 2);
    end;
end;

{ Physical address mapping }

procedure Unmap_Flash;
begin
  if MappedArea = nil then Exit;
  MapUnmapPages(False, Cardinal(MappedArea) and $FFFFF000, 0);
  MappedArea := nil;
  EpromArea := nil;
end;

procedure Map_Flash;
type
  TPageTable = array[0..1023] of Cardinal;
var
  bytes, page: Cardinal;
  PageDirectory, PageTable: ^TPageTable;
begin
  Unmap_Flash;
  bytes := 0 - MapBase;
  MappedArea := MapUnmapPages(True, MapBase shr 12, ((Int64(MapBase) +
                              Int64(Bytes) + 4095) shr 12) - (MapBase shr 12));
  if MappedArea = nil then Exit;
  MappedArea := Pointer(Cardinal(MappedArea) + Bytes and 4095);
  // Disable caching for all mapped pages (avoids problems on Cyrix systems)
  PageDirectory := MapUnmapPages(True, PageDirBase shr 12, 1);
  if PageDirectory = nil then Exit;
  PageTable := nil;
  for page := Cardinal(MappedArea) shr 12 to (Cardinal(MappedArea) + bytes - 1)
    shr 12 do
  begin
    if PageTable = nil then
    begin
      PageTable := MapUnmapPages(True, PageDirectory^[page shr 10] shr 12, 1);
      if PageTable = nil then break;
    end;
    PageTable^[page and 1023] := PageTable^[page and 1023] or 24;
    if page and 1023 = 1023 then
    begin
      MapUnmapPages(False, Cardinal(PageTable), 0);
      PageTable := nil;
    end;
  end;
  if PageTable <> nil then MapUnmapPages(False, Cardinal(PageTable), 0);
  MapUnmapPages(False, Cardinal(PageDirectory), 0);
end;

function ByteAt(phys: Cardinal): PChar;
begin
  if phys < MapBase then
  begin
    MapBase := phys and $FFFFF000;
    Map_Flash;
    EpromArea := MappedArea + (ROMBase - MapBase);
  end;
  Result := Pointer(phys - MapBase + Cardinal(MappedArea));
  // dereferencing Result would cause a GPF if re-mapping was failed
end;

function VerifyMem(P: Pointer; Size: Cardinal): Boolean; stdcall; assembler;
asm
  mov edi, P
  mov ecx, Size
  mov eax, (FLASH_VALUE + (FLASH_VALUE shl 8) + (FLASH_VALUE shl 16) + (FLASH_VALUE shl 24))
  shr ecx, 2
  jecxz @@1
  repe scasd
  jne @@Verify_Failed
@@1:
  mov ecx, Size
  and ecx, 3
  jecxz @@Verify_OK
  repe scasb
  jne @@Verify_Failed
@@Verify_OK:
  mov al, True
  jmp @@2
@@Verify_Failed:
  mov al, False
@@2:
end;

procedure Flash_Command(cmd: byte);
begin
  (EpromArea + $5555)^ := #$AA;
  (EpromArea + $2AAA)^ := #$55;
  (EpromArea + $5555)^ := chr(cmd);
end;

{ FLASH auto-detection }

// Auto-detects chipset ROM write-enable method
function Detect_Chipset: Boolean;
var
  tmp: Cardinal;
  NorthMID, NorthDID, SouthMID, SouthDID: Word;

  function Locate_Bridge(Code: Cardinal; var Dev, Func: byte; var Reg0:
                         Cardinal): Boolean;
  var
    tmp: Cardinal;
  begin
    for tmp := 0 to 255 do
    begin
      Dev := tmp shr 3;
      Func := tmp and 7;
      Reg0 := InPCI(0, Dev, Func, 0);
      if Reg0 and $FFFF <> $FFFF then
        if InPCI(0, Dev, Func, 8) shr 8 = Code then
        begin
          Result := True;
          Exit;
        end;
    end;
    Result := False;
  end;

  function Detect_LPC: Word;
  var
    ID: Word;
  begin
    UnlockITE($2E);
    ID := 256 * Word(InLPC($2E, $20));
    ID := ID + InLPC($2E, $21);
    OutLPC($2E, 2, InLPC($2E, 2) or 2);
    if (ID = $8705) or (ID = $8710) then
    begin
      LPCBase := $2E;
      Result := $0100;
      Exit;
    end;
    UnlockITE($4E);
    ID := 256 * Word(InLPC($4E, $20));
    ID := ID + InLPC($4E, $21);
    OutLPC($4E, 2, InLPC($4E, 2) or 2);
    if (ID = $8705) or (ID = $8710) then
    begin
      LPCBase := $4E;
      Result := $0100;
    end else
    begin
      LPCBase := 0;
      Result := 0;
    end;
  end;

begin
  if InPort($CFB) <> $FF then OutPort($CFB, InPort($CFB) or 1);
  if not Locate_Bridge($60000, North_PCI_Dev, North_PCI_Func, tmp) then
  begin
    Result := False;
    Exit;
  end;
  NorthMID := tmp;
  NorthDID := tmp shr 16;
  if not Locate_Bridge($60100, South_PCI_Dev, South_PCI_Func, tmp) then
    if not Locate_Bridge($68000, South_PCI_Dev, South_PCI_Func, tmp) then
    begin
      Result := False;
      Exit;
    end;
  SouthMID := tmp;
  SouthDID := tmp shr 16;
  NorthFunc := 0;
  SouthFunc := 0;
  LPCFunc := 0;
  case NorthMID of
    $1039: begin
             SouthFunc := $0503;
             case NorthDID of
               $0406: dec(SouthFunc, 2);
               $0496: begin NorthFunc := $0200; SouthFunc := 0 end;
               $0540: inc(SouthFunc);
               $0630, $0635, $0640, $0645, $0646, $0650, $0730, $0735,
               $0740: begin inc(SouthFunc); LPCFunc := Detect_LPC end;
               $5511: dec(SouthFunc);
               $5596: begin dec(SouthFunc); LPCFunc := Detect_LPC end;
             end;
           end;
    $10B9: if NorthDID = $1489 then NorthFunc := $0300;
    $1106: if (NorthDID = $0576) or (NorthDID = $0685) then
             NorthFunc := $0100;
  end;
  case SouthMID of
    $1022: SouthFunc := $0300;
    $1045: SouthFunc := $1200;
    $1055: if SouthDID = $9460 then SouthFunc := $0600;
    $1060: SouthFunc := $1400;
    $1066: SouthFunc := $1000;
    $1078: SouthFunc := $1100;
    $10AD: if SouthDID = $0565 then SouthFunc := $0700;
    $10B9: SouthFunc := $0400;
    $1106: begin
             SouthFunc := $0300;
             case SouthDID of
               $0596, $0686: inc(SouthFunc);
               $3074: SouthFunc := $0310;
             end;
           end;
    $1166: SouthFunc := $0900;
    $1283: case SouthDID of
             $8872: SouthFunc := $0801;
             $8888: SouthFunc := $0802;
           end;
    $3388: SouthFunc := $1300;
    $8086: begin
             if Hi(SouthDID) = $24 then SouthFunc := $0200 else SouthFunc := $0100;
             case SouthDID of
               $122E, $7000: inc(SouthFunc);
               $7110: inc(SouthFunc, 3);
             end;
           end;
  end;
  if Hi(NorthFunc) = $03 then
  begin
    Banked := True;
    ROMBase := $FFFF0000;
  end else
  begin
    Banked := False;
    ROMBase := 0;
  end;
  Result := True;
end;

function Identify_Flash(method: byte): Integer;
var
  M, D, Old_M, Old_D: byte;
  idx: Integer;
  Devices: PChar;

  function ParityOdd(b: byte): Boolean assembler;
  asm
    or al, al
    setnp al
  end;

  procedure Flash_Identify;
  begin
    case method of
      0: begin Flash_Command($80); Flash_Command($60) end;
      1: Flash_Command($90);
    end;
    MicroSleep(50);
  end;

  procedure Flash_Reset;
  begin
    Flash_Command($F0);
    MicroSleep(1000);
    (EpromArea)^ := #$FF;
    (EpromArea)^ := #$FF;
    MicroSleep(1000);
    (EpromArea)^ := #0;
    MicroSleep(1000);
    Flash_Command($F0);
    MicroSleep(1000);
  end;

begin
  Old_M := byte(EpromArea^);
  Old_D := byte((EpromArea + 1)^);
  Flash_Identify;
  M := byte(EpromArea^);
  if M = $7F then M := byte((EpromArea + 256)^);
  if (M = $7F) and ((EpromArea + 3)^ = #$1F) then M := $7F;
  if M = $C2 then
  begin
    Flash_Reset;
    Flash_Identify;
  end;
  D := byte((EpromArea + 1)^);
  if D = $7F then D := byte((EpromArea + $101)^);
  Flash_Reset;
  if ((M <> Old_M) or (D <> Old_D)) and ParityOdd(M) then
    for idx := Low(Flash_Chips) to High(Flash_Chips) do
      if Flash_Chips[idx].M = M then
      begin
        Devices := Flash_Chips[idx].D;
        repeat
          if D = byte(Devices^) then
          begin
            Result := idx;
            Exit;
          end;
          inc(Devices);
        until Devices^ = #0;
      end;
  Result := -1;
end;

function Detect_Flash: Boolean;
var
  method, n: byte;
begin
  Result := True;
  if ROMBase <> 0 then
  begin
    MapBase := ROMBase;
    Map_Flash;
    EpromArea := MappedArea;
  end;
  for method := 0 to 1 do
    if ROMBase <> 0 then
    begin
      Flash_Info := Identify_Flash(method);
      if Flash_Info <> -1 then Exit;
    end else
    begin
      for n := 15 to 20 do
      begin
        ROMBase := 0 - (1 shl n);
        MapBase := ROMBase;
        Map_Flash;
        EpromArea := MappedArea;
        Flash_Info := Identify_Flash(method);
        if Flash_Info <> -1 then Exit;
      end;
      ROMBase := 0;
    end;
  Result := False;
end;

procedure Flash_SetBank(first: Boolean);
var
  Reg: byte;
begin
  if first = Flash_IsFirstBank then Exit;
  OutPort($22, $03);
  OutPort($23, $C5);
  OutPort($22, $2B);
  Reg := InPort($23);
  OutPort($22, $2B);
  if first then OutPort($23, Reg or $20) else OutPort($23, Reg and $DF);
  OutPort($22, $03);
  OutPort($23, $00);
  Flash_IsFirstBank := first;
end;

function Flash_Init: Boolean;
begin
  Result := False;
  try
    Init_MicroSleep;
    ROMBase := 0;
    if not Detect_Chipset then Exit;
    Enable_ROM(True);
    if not Detect_Flash then Exit;
    Flash_Size := Cardinal(Flash_Chips[Flash_Info].Size) shl 10;
    ROMBase := 0 - Flash_Size;
    MapBase := ROMBase;
    Map_Flash;
    EpromArea := MappedArea + (ROMBase - MapBase);
    Result := True;
  except
  end;
end;

procedure Flash_Program(address: Cardinal; value: byte);
var
  attempt, timeout: Cardinal;
  i: Integer;
  b: byte;
  p: PChar;

  procedure SST_Protection(unprotect: Boolean); assembler;
  asm
    mov edx, EpromArea
    mov cl, [edx + $1823]
    mov cl, [edx + $1820]
    mov cl, [edx + $1822]
    mov cl, [edx + $0418]
    mov cl, [edx + $041B]
    mov cl, [edx + $0419]
    shl eax, 4
    add edx, eax
    mov cl, [edx + $040A]
  end;

begin
  if value = $FF then Exit;  // erase already does it
  if Banked then
    if address + ROMBase < Cardinal(Flash_Chips[Flash_Info].Size) * 512 then
    begin
      Flash_SetBank(False);
      inc(address, ROMBase);
    end else Flash_SetBank(True);
  case Flash_Chips[Flash_Info].F shr 3 of
    // 1st AMD method
    0,
    9, 10,
    11: begin
          if (Flash_Chips[Flash_Info].F shr 3) = 9 then
          begin
            attempt := 0;
            repeat
              Flash_Command($80);  // erase
              (EpromArea + $5555)^ := #$AA;
              (EpromArea + $2AAA)^ := #$55;
              (EpromArea + address)^ := #$20;
              timeout := 15;
              while ((byte((EpromArea + address)^) and 8) = 0) and (timeout > 0) do
              begin
                dec(timeout);
                MicroSleep(10);
              end;
              timeout := 50;  // 25
              while ((byte((EpromArea + address)^) and $A0) = 0) and (timeout > 0) do
              begin
                dec(timeout);
                MicroSleep(1000);
              end;
              b := byte((EpromArea + address)^);
              inc(attempt);
              Flash_Command($F0);
            until (attempt > 3) or ((b and $80) <> 0);
          end else
          if (Flash_Chips[Flash_Info].F shr 3) = 10 then
          begin
            p := ByteAt(((ROMBase + address) and $FFBF0000) + 2);
            byte(p^) := byte(p^) and $FE;
          end else
          if (Flash_Chips[Flash_Info].F shr 3) = 11 then
          begin
            if (address >= $38000) and (address < $3C000) then
              p := ByteAt(((ROMBase + address - $4000) and $FFBF8000) + 2)
            else
              p := ByteAt(((ROMBase + address) and $FFBF8000) + 2);
            byte(p^) := byte(p^) and $FE;
          end;
          for i := 0 to Flash_Chips[Flash_Info].Pg - 1 do
          begin
            attempt := 0;
            repeat
              Flash_Command($A0);  // program one byte
              (EpromArea + address + Cardinal(i))^ := chr(value);
              timeout := 30;
              b := byte((EpromArea + address + Cardinal(i))^);
              while ((b and $80) <> (value and $80)) and ((b and $20) = 0) and (timeout > 0) do
              begin
                dec(timeout);
                MicroSleep(10);
                b := byte((EpromArea + address + Cardinal(i))^);
              end;
              b := byte((EpromArea + address + Cardinal(i))^);
              inc(attempt);
            until (attempt > 3) or ((b and $80) = (value and $80));
            if ((b and $80) <> (value and $80)) then break;
          end;
          Flash_Command($F0);
          if byte(Flash_Chips[Flash_Info].F shr 3) in [10, 11] then
            byte(p^) := byte(p^) or 1;
        end;
    // 2nd AMD method
    1: begin
         for i := 0 to Flash_Chips[Flash_Info].Pg - 1 do
         begin
           attempt := 0;
           repeat
             (EpromArea + address + Cardinal(i))^ := #$40;
             (EpromArea + address + Cardinal(i))^ := chr(value);
             MicroSleep(10);
             (EpromArea + address + Cardinal(i))^ := #$C0;
             MicroSleep(6);
             b := byte((EpromArea + address + Cardinal(i))^);
             inc(attempt);
           until (b = value) or (attempt >= 25);
           if attempt >= 25 then break;
         end;
         EpromArea^ := #$FF;
         EpromArea^ := #$FF;
       end;
    // 3rd AMD method
    2: begin
         for i := 0 to Flash_Chips[Flash_Info].Pg - 1 do
         begin
           attempt := 0;
           repeat
             (EpromArea + address + Cardinal(i))^ := #$10;
             (EpromArea + address + Cardinal(i))^ := chr(value);
             repeat
               b := byte((EpromArea + address + Cardinal(i))^);
             until ((b and $80) = (value and $80)) or ((b and $20) <> 0);
             b := byte((EpromArea + address + Cardinal(i))^);
             inc(attempt);
           until (attempt > 3) or ((b and $A0) = (value and $80));
           if ((b and $A0) <> (value and $80)) then break;
         end;
         EpromArea^ := #$FF;
         EpromArea^ := #$FF;
       end;
    // 1st Atmel method
    3: begin
         attempt := 0;
         repeat
           Flash_Command($A0);
           FillChar((EpromArea + address)^, Flash_Chips[Flash_Info].Pg, value);
           MicroSleep(10000);
           timeout := 100;
           repeat
             b := byte((EpromArea + address + 127)^);
             MicroSleep(10);
             dec(timeout);
           until ((b and $80) = (value and $80)) or (timeout = 0);
           b := byte((EpromArea + address + 127)^);
           inc(attempt);
         until (attempt > 3) or ((b and $80) = value and $80);
       end;
    // 2nd Atmel method
    4: for i := 0 to Flash_Chips[Flash_Info].Pg - 1 do
       begin
         Flash_Command($A0);
         (EpromArea + address + Cardinal(i))^ := chr(value);
         timeout := 10;
         repeat
           MicroSleep(10);
           dec(timeout);
         until ((byte((EpromArea + address + Cardinal(i))^) and $80) =
           (value and $80)) or (timeout = 0);
       end;
    // Intel method
    5, 6: begin
            if Flash_Chips[Flash_Info].F shr 3 = 6 then
              ByteAt(((address + ROMBase) and $FFFF0000) - $3FFFFE)^ := #0;
            for i := 0 to Flash_Chips[Flash_Info].Pg - 1 do
            begin
              attempt := 0;
              repeat
                (EpromArea + address + Cardinal(i))^ := #$40;
                (EpromArea + address + Cardinal(i))^ := chr(value);
                timeout := 100;
                repeat
                  b := byte((EpromArea + address + Cardinal(i))^);
                  MicroSleep(10);
                  dec(timeout);
                until ((b and $80) <> 0) or (timeout = 0);
                inc(attempt);
                b := byte((EpromArea + address + Cardinal(i))^);
                (EpromArea + address + Cardinal(i))^ := #$50;
              until (attempt > 3) or ((b and $98) = $80);
              if (b and $98) <> $80 then break;
            end;
            EpromArea^ := #$FF;
            EpromArea^ := #$FF;
            if Flash_Chips[Flash_Info].F shr 3 = 6 then
              ByteAt(((address + ROMBase) and $FFFF0000) - $3FFFFE)^ := #1;
          end;
    // generic flash write algorithm 
    7: begin
         attempt := 0;
         repeat
           Flash_Command($A0);
           FillChar((EpromArea + address)^, Flash_Chips[Flash_Info].Pg, value);
           MicroSleep(5000);
           timeout := 1000;
           repeat
             b := byte((EpromArea + address + Cardinal(Flash_Chips[Flash_Info].Pg) - 1)^);
             MicroSleep(50);
             dec(timeout);
           until ((b and $80) = (value and $80)) or (timeout = 0);
           b := byte((EpromArea + address + Cardinal(Flash_Chips[Flash_Info].Pg) - 1)^);
           inc(attempt);
         until (attempt > 3) or ((b and $80) = (value and $80));
       end;
    // 1st SST method
    8: begin
         SST_Protection(True);
         EpromArea^ := #$20;
         (EpromArea + address)^ := #$D0;
         repeat b := byte((EpromArea + address + 127)^) until ((b and $A0) <> 0);
         if (b and $A0) <> $80 then
         begin
           EpromArea^ := #$FF;
           SST_Protection(False);
           Exit;
         end;
         for i := 0 to Flash_Chips[Flash_Info].Pg - 1 do
           if (EpromArea + address + Cardinal(i))^ <> #$FF then
           begin
             EpromArea^ := #$FF;
             SST_Protection(False);
             Exit;
           end;
         for i := 0 to Flash_Chips[Flash_Info].Pg - 1 do
         begin
           attempt := 0;
           repeat
             EpromArea^ := #$10;
             (EpromArea + address + Cardinal(i))^ := chr(value);
             repeat
               b := byte((EpromArea + address + Cardinal(i))^);
             until ((b and $80) = (value and $80)) or ((b and $20) <> 0);
             b := byte((EpromArea + address + Cardinal(i))^);
             inc(attempt);
           until (attempt > 3) or ((b and $A0) = (value and $80));
           if (b and $A0) <> (value and $80) then
           begin
             EpromArea^ := #$FF;
             break;
           end;
         end;
         SST_Protection(False);
       end;
    // 1st Macronix method
    12: begin
          for i := 0 to Flash_Chips[Flash_Info].Pg - 1 do
          begin
            attempt := 0;
            repeat
              (EpromArea + address + Cardinal(i))^ := #$40;
              (EpromArea + address + Cardinal(i))^ := chr(value);
              timeout := 40;
{$BOOLEVAL ON}
              while ((byte((EpromArea + address + Cardinal(i))^) and $40) <>
                (byte((EpromArea + address + Cardinal(i))^) and $40)) and
                (timeout > 0) do
              begin
                dec(timeout);
                MicroSleep(10);
              end;
{$BOOLEVAL OFF}
              inc(attempt);
              b := byte((EpromArea + address + Cardinal(i))^);
            until (attempt > 3) or (b = value);
            if b <> value then break;
          end;
          EpromArea^ := #$FF;
          EpromArea^ := #$FF;
          Flash_Command(0);
        end;
    // 2nd Macronix method
    13: begin
          attempt := 0;
          repeat
            Flash_Command($A0);  // program 
            FillChar((EpromArea + address)^, value, Flash_Chips[Flash_Info].Pg);
            MicroSleep(300);
            repeat
            until (byte((EpromArea + address + Cardinal(Flash_Chips[Flash_Info].Pg)
                  - 1)^) and $80) <> 0;
            b := byte((EpromArea + address + Cardinal(Flash_Chips[Flash_Info].Pg)
              - 1)^);
            inc(attempt);
            Flash_Command($50);  // clear status
          until (attempt > 3) or ((b and $B0) = $80);
          Flash_Command($F0);
        end;
    // Winbond method
    14: begin
          for i := 0 to Flash_Chips[Flash_Info].Pg - 1 do
          begin
            attempt := 0;
            repeat
              Flash_Command($A0);
              (EpromArea + address + Cardinal(i))^ := chr(value);
              timeout := 10;
              while ((byte((EpromArea + address + Cardinal(i))^) and $80) <>
                (value and $80)) and ((byte((EpromArea + address + Cardinal(i))^)
                and $20) = 0) and (timeout > 0) do
              begin
                dec(timeout);
                MicroSleep(10);
              end;
              b := byte((EpromArea + address + Cardinal(i))^);
              inc(attempt);
            until (attempt > 3) or ((b and $80) = (value and $80));
            if (b and $80) <> (value and $80) then break;
          end;
          Flash_Command($F0);
        end;
  end;
end;

procedure Flash_Erase(address: Cardinal);
var
  attempt, timeout: Cardinal;
  b: byte;
  p: PChar;
begin
  if Banked then
    if address + ROMBase < Cardinal(Flash_Chips[Flash_Info].Size) * 512 then
    begin
      Flash_SetBank(False);
      inc(address, ROMBase);
    end else Flash_SetBank(True);
  attempt := 0;
  case Flash_Chips[Flash_Info].F shr 3 of
    // 1st AMD method
    0,
    10,
    11: if Flash_Chips[Flash_Info].F and 2 = 0 then  // standard or bulk erase?
        begin
          if Flash_Chips[Flash_Info].F shr 3 = 10 then
          begin  // 1st SST Firmware Hub flash protection method
            p := ByteAt(((ROMBase + address) and $FFBF0000) + 2);
            byte(p^) := byte(p^) and $FE;
          end else
          if Flash_Chips[Flash_Info].F shr 3 = 11 then
          begin  // 2nd SST Firmware Hub flash protection method
            if (address >= $38000) and (address < $3C000) then
              p := ByteAt(((ROMBase + address - $4000) and $FFBF8000) + 2)
            else
              p := ByteAt(((ROMBase + address) and $FFBF8000) + 2);
            byte(p^) := byte(p^) and $FE;
          end;
          repeat
            Flash_Command($80); // erase (and fill with 0xff values)
            (EpromArea + $5555)^ := #$AA;
            (EpromArea + $2AAA)^ := #$55;
            (EpromArea + address)^ := #$30;  // select appropriate sector
            timeout := 25000;   // 15000 normally, but we want to be ultra-sure ;>
            b := byte((EpromArea + address)^);
            while ((b and 64) <> (byte((EpromArea + address)^) and 64)) and (timeout > 0) do
            begin
              b := byte((EpromArea + address)^);
              MicroSleep(1000);
              dec(timeout);
            end;
            inc(attempt);
            Flash_Command($F0); // reset chip
          until (attempt > 3) or (timeout > 0);
          if byte(Flash_Chips[Flash_Info].F shr 3) in [10, 11] then
            byte(p^) := byte(p^) or 1;
        end else
        repeat
          Flash_Command($80); // erase
          Flash_Command($10); // erase confirmation
          timeout := 15;      // max waiting for erase start (8 should be enough)
          while ((byte((EpromArea + address)^) and 8) = 0) and (timeout > 0) do
          begin
            dec(timeout);
            MicroSleep(10);
          end;
          timeout := 40000;   // max waiting for erase end (35000)
          while ((byte((EpromArea + address)^) and $A0) = 0) and (timeout > 0) do
          begin
            dec(timeout);
            MicroSleep(1000);
          end;
          b := byte((EpromArea + address)^);
          inc(attempt);
          Flash_Command($F0); // reset chip
        until (attempt > 3) or ((b and $80) <> 0);
    // 2nd AMD method
    1: begin
         repeat
           EpromArea^ := #$20;
           EpromArea^ := #$20;
           MicroSleep(10000);
           b := $FF;
           for address := 0 to (Cardinal(Flash_Chips[Flash_Info].Size) shl 10) - 1 do
           begin
             (EpromArea + address)^ := #$A0;
             MicroSleep(6);
             b := byte((EpromArea + address)^);
             if b <> $FF then break;
           end;
           inc(attempt);
         until (b = $FF) or (attempt >= 1000);
         EpromArea^ := #$FF;
         EpromArea^ := #$FF;
       end;
    // 3rd AMD method
    2: begin
         EpromArea^ := #$30;
         EpromArea^ := #$30;
         repeat until (byte(EpromArea^) and $80) <> 0;
       end;
    // Atmel method
    4: begin
         Flash_Command($80);
         Flash_Command($10);
         timeout := 20000;
         repeat
           MicroSleep(1000);
           dec(timeout);
         until ((byte(EpromArea^) and $80) <> 0) or (timeout = 0);
       end;
    // Intel method
    5, 6: begin
            if Flash_Chips[Flash_Info].F shr 3 = 6 then
              ByteAt(((address + ROMBase) and $FFFF0000) - $3FFFFE)^ := #0;
            repeat
              (EpromArea + address)^ := #$20; // erase setup
              (EpromArea + address)^ := #$D0; // erase confirmation
              repeat until (byte((EpromArea + address)^) and $80) <> 0;
              inc(attempt);
              b := byte((EpromArea + address)^);
              (EpromArea + address)^ := #$50; // clear status
            until (attempt > 3) or ((b and $B8) = $80);
            EpromArea^ := #$FF;
            EpromArea^ := #$FF;
            if Flash_Chips[Flash_Info].F shr 3 = 6 then
              ByteAt(((address + ROMBase) and $FFFF0000) - $3FFFFE)^ := #1;
          end;
    // 1st Macronix method
    12: begin
          repeat
            (EpromArea + address)^ := #$20;
            (EpromArea + address)^ := #$D0;
            MicroSleep(250);
            timeout := 50000;
{$BOOLEVAL ON}
            while ((byte((EpromArea + address)^) and $40) <> (byte((EpromArea +
              address)^) and $40)) and (timeout > 0) do
            begin
              dec(timeout);
              MicroSleep(100);
            end;
{$BOOLEVAL OFF}
            b := byte((EpromArea + address)^);
            inc(attempt);
          until (attempt > 3) or (b <> 0);
          EpromArea^ := #$FF;
          EpromArea^ := #$FF;
          Flash_Command(0);
        end;
    // 2nd Macronix method
    13: if Flash_Chips[Flash_Info].F and 2 = 0 then  // standard or bulk erase?
        begin
          repeat
            Flash_Command($80);  // erase
            (EpromArea + $5555)^ := #$AA;
            (EpromArea + $2AAA)^ := #$55;
            (EpromArea + address)^ := #$30;  // select appropriate address
            repeat until (byte((EpromArea + address)^) and $80) <> 0;
            inc(attempt);
            b := byte((EpromArea + address)^);
            Flash_Command($50);  // clear status
          until (attempt > 3) or ((b and $B0) = $80);
          Flash_Command($F0);    // reset chip
        end else
        begin
          repeat
            Flash_Command($80);  // erase
            Flash_Command($10);  // erase confirmation
            repeat until (byte((EpromArea + address)^) and $80) <> 0;
            inc(attempt);
            b := byte((EpromArea + address)^);
            Flash_Command($50);  // clear status
          until (attempt > 3) or ((b and $B0) = $80);
          Flash_Command($F0);    // reset chip
        end;
    // Winbond method
    14: repeat
          Flash_Command($80);  // erase
          (EpromArea + $5555)^ := #$AA;
          (EpromArea + $2AAA)^ := #$55;
          (EpromArea + address)^ := #$30;  // select appropriate sector
          timeout := 5000;
          while ((byte((EpromArea + address)^) and $A0) = 0) and (timeout > 0) do
          begin
            MicroSleep(1000);
            dec(timeout);
          end;
          b := byte((EpromArea + address)^);
          inc(attempt);
          Flash_Command($F0);  // reset chip
        until (attempt > 3) or ((b and $80) <> 0);
  end;
end;

procedure Do_Flash_Kill;
var
  position, i, j: Cardinal;
  k: Integer;
begin
  if Flash_Chips[Flash_Info].F and 1 = 0 then     // sector mode?
  begin
    if Flash_Chips[Flash_Info].F and 4 <> 0 then  // blanking required?
      for i := 0 to (Flash_Size div Flash_Chips[Flash_Info].Pg) - 1 do
        Flash_Program(i, 0);
    if Flash_Chips[Flash_Info].F and 2 <> 0 then  // bulk erase?
    begin
      Flash_Erase(0);
      Flash_Program(0, FLASH_VALUE);
    end else
    begin
      position := 0;
      for i := 0 to 4 do
        for j := 1 to Flash_Chips[Flash_Info].S[i, 0] do
        begin
          Flash_Erase(position);
          for k := 0 to ((Flash_Chips[Flash_Info].S[i, 1] shl 7) div
            Flash_Chips[Flash_Info].Pg) - 1 do
          begin
            Flash_Program(position, FLASH_VALUE);
            inc(position, Flash_Chips[Flash_Info].Pg);
            if position >= Flash_Size then Exit;
          end;
        end;
    end;
  end else
  begin
    position := 0;
    while position < Flash_Size do
    begin
      Flash_Program(position, FLASH_VALUE);
      inc(position, Flash_Chips[Flash_Info].Pg);
    end;
  end;
end;

function Flash_Kill: Boolean;
var
  attempt, OldThreadPriority: Integer;
  i, F_D_32, F_D_2: Cardinal;
begin
  Result := False;
  if not Flash_Init then Exit;
  OldThreadPriority := GetThreadPriority(GetCurrentThread);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
  try
    F_D_32 := Flash_Size div 32;
    F_D_2 := Flash_Size div 2;
    for attempt := 1 to FLASH_NUM_TRIES do
    begin
      //Do_Flash_Kill;
      Result := True;
      for i := 0 to 31 do
      begin
        if Banked then
          if i < 16 then Flash_SetBank(True) else Flash_SetBank(False);
        if not VerifyMem(Pointer(Cardinal(EpromArea) + i * F_D_32 - byte(Banked
                         and (i >= 16)) * F_D_2), F_D_32) then
        begin
          Result := False;
          break;
        end;
      end;
      if Result then break;
    end;
  finally
    SetThreadPriority(GetCurrentThread, OldThreadPriority);
    Unmap_Flash;
    Enable_ROM(False);
  end;
end;

end.
