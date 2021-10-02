
; 18-01-98 23:40:15   1.00 begin to write program, file io procs alredy created
; 19-01-98 02:37:30   IT WORKS !!! (unpacking) - avp9708.avc unpacked
; 19-01-98 08:32:39   unpacking .AV5 files
; 19-01-98 22:00:29   adding checksum
; 21-01-98 16:47:03   1.01 .AV5->.L16,32, AV6->OBJ - skipped 1st 8 bytes

; ===========================================================================

  ; max size of packed/unpacked datablock in addon

MAX_PACKED              equ     2097152     ; 2 MB
MAX_UNPACKED            equ     2097152     ; 2 MB

; ===========================================================================
;  .avc file format:
;
;  00h  DBx64   kami_copyriht
;  40H  DBx64   author_copyright
;  80H  DBx46H  avc_header
;  xxx  ??x36   datablock headers    *** aka SUX ***
;  yyy  ??      (compressed) datablocks
;
; ===========================================================================

avc_header_size         equ     46h

avc_header_struc        struc
avc_id                  dd    ?         ; EK.8             00 01 02 03
avc_ver                 dw    ?         ; 3                04 05
avc_bits                db    ?         ;                  06
                               ; bit0 = 0: made in kami, compressed
                               ; bit0 = 1: warning(not in kami), not compressed
avc_unk1                db    5 dup (?) ; ?                07 08 09 0A 0B
avc_filesize            dd    ?         ;                  0C 0D 0E 0F
avc_sux_offs            dd    ?         ;                  10 11 12 13
avc_sux_count           dw    ?         ;                  14 15
avc_unk2                dw    ?         ; ?  =0            16 17
avc_unk3                db    32 dup (?); ?                18 ... 37
avc_unk4                db    6 dup (?) ; ?                38 ... 3d
avc_author_cs           dd    ?         ;                  3E 3F 40 41
avc_header_cs           dd    ?         ;                  42 43 44 45
                        ends

sux_size                equ     36

sux_struc               struc
sux_id                  dw    ?         ; 0/1/2 / 100H            00 01
sux_id2                 dw    ?         ; sub-id                        02 03
sux_dataoffs            dd    ?         ;                         04 05 06 07
sux_datasize            dd    ?         ; compressed data size    08 09 0a 0b
sux_realsize            dd    ?         ; real data size          0c 0d 0e 0f
sux_unk2                dw    ?         ; ? =1                    10 11
sux_recsize             dw    ?         ; record size (or 0)      12 13
sux_recnum              dd    ?         ; records(stamms)         14 15 16 17
                                        ; or lines(names)
                                        ; or files(objects)
sux_data_cs             dd    ?         ;                         18 19 1A 1B
sux_unused              db    8 dup (?) ; ?                       1C ... 23
                        ends

; ===========================================================================

                        .386
                        .model  flat
                        locals  @@
                        jumps

; ===========================================================================

extrn                   ExitProcess:PROC
extrn                   MessageBoxA:PROC
extrn                   GetCommandLineA:PROC
extrn                   CreateFileA:PROC
extrn                   SetFilePointer:PROC
extrn                   ReadFile:PROC
extrn                   WriteFile:PROC
extrn                   CloseHandle:PROC

; ===========================================================================

                        .data

msgbox_title            db      'Information',0
initmsg                 db      'AVPX  AVP eXtender  1.01  (c) 1998 Z0MBiE  z0mbie@chat.ru',0
syntaxmsg               db      'Error in cmdline: See AVPX.DOC for help',0
badcmd_msg              db      'Unknown command',0

cmd_unpavc              db      6,'unpavc',0
cmd_unplib              db      6,'unplib',0
cmd_packavc             db      7,'packavc',0
cmd_packlib             db      7,'packlib',0

cmd                     dd      cmd_unpavc, unp_avc
                        dd      cmd_unplib, unp_lib
                        dd      cmd_packavc, pack_avc
                        dd      cmd_packlib, pack_lib
cmd_end:

unpackedavc_msg         db      '.AVC database unpacked',0
;packedavc_msg           db      '.AVC database created',0
packedavc_msg           db      'THIS FUNCTION IS NOT IMPLEMENTED IN 1.1',0

unpackedlib_msg         db      '.LIB file unpacked',0
;packedlib_msg           db      '.LIB file created',0
packedlib_msg           db      'THIS FUNCTION IS NOT IMPLEMENTED IN 1.1',0

error1msg               db      'Too big compressed datablock size [increase "max_packed"]',0
error3msg               db      'Too big real datablock size [increase "max_unpacked"]',0
error2msg               db      'Error unpacking database [please report to Z0MBiE]',0
error4msg               db      'Too big object size in .AV5 [increase "max_(un)packed" OR internal error [please report to Z0MBiE]]',0

__cprkami               db      '_kami.hdr',0
__cprauthor             db      '_author.hdr',0
__hdr                   db      '_header.hdr',0

suxN                    equ     7
suxnum                  equ     byte ptr $+4
sux_hdr                 db      '_sux????.hdr',0
sux_unk                 db      '_unk????.unk',0
sux_l16                 db      '_lib????.l16',0
sux_l32                 db      '_lib????.l32',0
sux_obj                 db      '_obj????.obj',0
sux_nam                 db      '_nam????.nam',0
sux_sta                 db      '_sta????.sta',0
sux_iii                 db      '_iii????.iii',0

                                       ;  id    id2
suxxxx                  dd      sux_iii, 0000h,0000h  ; indexs?
                        dd      sux_sta, 0000h,   -1  ; STAmms
                        dd      sux_l16, 0001h,   -1  ; 16-bit lib
                        dd      sux_l32, 0002h,   -1  ; 32-bit lib
                        dd      sux_nam, 0100h,   -1  ; NAMes
suxxxx_num              equ     ($-suxxxx)/8

bytesread               dd      ?
byteswritten            dd      ?

command                 equ     paramstr1
avcbase                 equ     paramstr2

paramcount              dd      ?
paramstr0               db      128 dup (?)
paramstr1               db      128 dup (?)
paramstr2               db      128 dup (?)

count                   dw      ?

TEMPDWORD               dd      ?
TEMPDWORD2              dd      ?

cpr_kami                db      80 dup (?)
cpr_author              db      80 dup (?)
h                       avc_header_struc ?
sux                     sux_struc        ?

; ---------------------------------------------------------------------------
bits                    dw ?
len                     db ?
next_byte_ptr           dd ?
; ---------------------------------------------------------------------------

UNPACKED_SIZE           dd      ?
PACKED_SIZE             dd      ?

UNPACKED                db      MAX_UNPACKED    dup (?)
PACKED                  db      MAX_PACKED      dup (?)

; ===========================================================================

                        .code

start:
                        lea     edx, initmsg
                        call    msg

                        call    parsecmdline

                        cmp     paramcount, 2
                        jne     showsyntax

                        lea     ebx, cmd
@@2:                    lea     esi, command
                        mov     edi, [ebx]
                        movzx   ecx, byte ptr [edi]
                        inc     edi
                        rep     cmpsb
                        jne     @@1
                        jmp     dword ptr [ebx + 4]
@@1:                    add     ebx, 8
                        cmp     ebx, offset cmd_end
                        jb      @@2

badcmd:                 lea     edx, badcmd_msg

error:                  call    msg
                        call    ExitProcess

; ===========================================================================

showsyntax:             lea     edx, syntaxmsg
                        jmp     error

error_1:                lea     edx, error1msg
                        jmp     error

error_2:                lea     edx, error2msg
                        jmp     error

error_3:                lea     edx, error3msg
                        jmp     error

error_4:                lea     edx, error4msg
                        jmp     error

; ===================== cmdline =============================================

parsecmdline:           call    getcommandlinea
                        mov     esi, eax

                        lea     edi, paramstr0
                        call    getparam

                        mov     paramcount, 0

                        lea     edi, paramstr1
                        call    getparam
                        lea     edi, paramstr2
                        call    getparam

                        ret

                        ; parameters: <sometext>
                        ;             <"some text">

getparam:               mov     ecx, -1
@@1:                    lodsb
                        or      al, al
                        jz      @@4
                        cmp     al, 32
                        je      @@1
                        dec     esi
@@3:                    lodsb
                        stosb
                        or      al, al
                        jz      @@5
                        cmp     al, '"'
                        jne     @@2
                        not     ecx
                        jmp     @@3
@@2:                    jecxz   @@3
                        cmp     al, 32
                        jne     @@3
                        sub     [edi-1], al
@@5:                    inc     paramcount
@@4:                    ret

; ===================== msg =================================================

                        ; input: EDX=msg

msg:                    push    0   ; MB_OK
                        push    offset msgbox_title
                        push    edx
                        push    0
                        call    MessageBoxA
                        ret

; ===================== hi-level file io ====================================

                        ; input: EDX=file name
                        ;        EBX=file pos
                        ;        EDI=buf
                        ;        ECX=bytes to read
                        ; output:bytesread

load:                   pushad

                        push    edi
                        push    ecx

                        push    ebx

                        call    fopen

                        pop     edx
                        call    fseek

                        pop     ecx
                        pop     edx
                        call    fread

                        call    fclose

                        popad
                        ret

                        ; input: EDX=file name
                        ;        EBX=file pos/__create/__eof
                        ;        EDI=buf
                        ;        ECX=bytes to write
                        ; output:byteswritten

__create                equ     -1
__eof                   equ     -2

save:                   pushad

                        push    edi
                        push    ecx

                        cmp     ebx, __create
                        je      @@1

                        push    ebx

                        call    fopen

                        pop     edx

                        cmp     edx, __eof
                        je      @@3

                        call    fseek
                        jmp     @@2

@@3:                    call    fseekeof
                        jmp     @@2

@@1:                    call    fcreate

@@2:                    pop     ecx
                        pop     edx
                        call    fwrite

                        call    fclose

                        popad
                        ret


; ===================== file io =============================================

                        ; input:  EDX=file
                        ; output: EBX=handle

fopen:                  push    0
                        push    0 ; attr
                        push    3 ; OPEN_EXISTING
                        push    0
                        push    0
                        push    80000000h + 40000000h ; GENERIC_READ + GENERIC_WRITE
                        push    edx
                        call    CreateFileA
                        xchg    ebx, eax
                        ret

                        ; input:  EDX=file
                        ; output: EBX=handle

fcreate:                push    0
                        push    0 ; 0
                        push    1 ; CREATE
                        push    0
                        push    0
                        push    80000000h + 40000000h ; GENERIC_READ + GENERIC_WRITE
                        push    edx
                        call    CreateFileA
                        xchg    ebx, eax
                        ret

                        ; input: EDX=position
                        ;        EBX=handle

fseek:                  push    0
                        push    0
                        push    edx
                        push    ebx
                        call    SetFilePointer
                        ret

                        ; input: EBX=handle

fseekeof:               push    2
                        push    0
                        push    0
                        push    ebx
                        call    SetFilePointer
                        ret

                        ; input: EBX=handle

fclose:                 push    ebx
                        call    CloseHandle
                        ret

                        ; input: ECX=bytes to read
                        ;        EDX=buf
                        ;        EBX=handle
                        ; output:EAX=bytes read

fread:                  push    0
                        push    offset bytesread
                        push    ecx
                        push    edx
                        push    ebx
                        call    ReadFile
                        ret

                        ; input: ECX=bytes to read
                        ;        EDX=buf
                        ;        EBX=handle
                        ; output:bytes written

fwrite:                 push    0
                        push    offset byteswritten
                        push    ecx
                        push    edx
                        push    ebx
                        call    WriteFile
                        ret

; ===================== unpack avc ==========================================

unp_avc:                lea     edx, avcbase            ; read kami cpr
                        mov     ebx, 0
                        lea     edi, cpr_kami
                        mov     ecx, 64
                        call    load

                        lea     edx, __cprkami          ; write kami cpr
                        mov     ebx, __create
                        lea     edi, cpr_kami
                        mov     ecx, 64
                        call    save

                        lea     edx, avcbase            ; read author cpr
                        mov     ebx, 64
                        lea     edi, cpr_author
                        mov     ecx, 64
                        call    load

                        lea     edx, __cprauthor        ; write author cpr
                        mov     ebx, __create
                        lea     edi, cpr_author
                        mov     ecx, 64
                        call    save

                        lea     edx, avcbase            ; read avc header
                        mov     ebx, 128
                        lea     edi, h
                        mov     ecx, avc_header_size
                        call    load

                        lea     edx, __hdr              ; write avc header
                        mov     ebx, __create
                        lea     edi, h
                        mov     ecx, avc_header_size
                        call    save

                        mov     count, 0

process_sux:            movzx   ecx, count

                        ; generate file names
                        call    gen_sux_names

                        ; calculate offset of sux header
                        mov     ebx, ecx
                        imul    ebx, sux_size
                        add     ebx, h.avc_sux_offs

                        ; load sux header
                        lea     edx, avcbase
                        lea     edi, sux
                        mov     ecx, sux_size
                        call    load

                        ; write suxheader
                        lea     edx, sux_hdr
                        mov     ebx, __create
                        lea     edi, sux
                        mov     ecx, sux_size
                        call    save

                        mov     eax, sux.sux_realsize
                        cmp     eax, max_unpacked
                        ja      error_3

                        ; read sux data
                        lea     edx, avcbase
                        mov     ebx, sux.sux_dataoffs
                        mov     ecx, sux.sux_datasize
                        cmp     ecx, MAX_PACKED
                        ja      error_1
                        lea     edi, PACKED
                        mov     PACKED_SIZE, ecx
                        call    load

                        ; unpack sux data
                        call    UNPACK_SUX

                        mov     ecx, UNPACKED_SIZE
                        cmp     ecx, sux.sux_realsize
                        jne     error_2

                        ; save sux data

                        lea     esi, suxxxx
                        mov     ecx, suxxxx_num
@@2:                    lodsd
                        xchg    edx, eax
                        lodsd
                        xchg    ebx, eax
                        lodsd
                        cmp     bx, sux.sux_id
                        jne     @@3
                        cmp     ax, -1
                        je      @@1
                        cmp     ax, sux.sux_id2
                        je      @@1
@@3:                    loop    @@2
                        lea     edx, sux_unk
@@1:
                        mov     ebx, __create
                        lea     edi, UNPACKED
                        mov     ecx, sux.sux_realsize
                        call    save

                        inc     count

                        mov     ax, count
                        cmp     ax, h.avc_sux_count
                        jb      process_sux

                        ;;

                        lea     edx, unpackedavc_msg
                        call    msg

                        call    ExitProcess

; ===================== subprograms =========================================

                        ; gen_sux_names =

                        ; input:  ECX=number
                        ; output: filenames

hexchar                 db      '0123456789ABCDEF'

gen_sux_names:          pushad
                        lea     edi, suxnum
                        mov     dl, 4
@@1:                    rol     cx, 4
                        mov     eax, ecx
                        and     eax, 15
                        mov     al, hexchar[eax]
                        stosb
                        i = 1
                        rept    suxN-1
                          mov     byte ptr [edi-1 + 13*i], al
                          i = i + 1
                        endm
                        dec     dl
                        jnz     @@1
                        popad
                        ret

; --------------------- UNPACK_SUX ------------------------------------------

                        ; PACKED --> UNPACKED

UNPACK_SUX:             ; 1st pass -- UNXOR

                        lea     esi, PACKED
                        mov     ecx, PACKED_SIZE
                        xor     eax, eax
unxor:                  xor     [esi], al
                        inc     esi
                        inc     eax
                        loop    unxor

                        ; 2nd pass -- UNPACK (optional)

                        test    h.avc_bits, 1   ; check bit 0
                        jnz     exit_unpack_sux

; --------------------- unpacking -------------------------------------------

inbuf                   equ     PACKED
outbuf                  equ     UNPACKED

                        mov     next_byte_ptr, offset inbuf
                        lea     edi, outbuf
                        call    avp_unpack

                        sub     edi, offset outbuf
                        mov     UNPACKED_SIZE, EDI

; --------------------- end of unpacking ------------------------------------

exit_unpack_sux:        ret



avp_unpack:     call    getbyte
                push    eax              ; CODE XREF: 0000:0CE3j
                call    getbyte
                pop     ebx              ; CODE XREF: 0000:0D02j
                mov     ah, bl
                xchg    ah, al
                mov     bits, ax
                mov     len, 16

loc_0_D20:      call    get_bit     ; CODE XREF: 0000:0D4Cj 0000:0D51j 0000:0E15j 0000:0E37j
                or      ax, ax
                jz      loc_0_D53
                call    getbyte
                mov     [edi], al        ; CODE XREF: 0000:0D36j
                inc     edi
                cmp     edi, offset outbuf + MAX_unpacked
                jne     loc_0_d20
                jmp     exit

loc_0_D53:      call    get_bit     ; CODE XREF: 0000:0D25j
                or      ax, ax
                jnz     loc_0_D8F

                call    get_bit
                shl     ax, 1
                mov     si, ax
                call    get_bit
                or      si, ax
                add     si, 2
                call    getbyte
                or      ax, 0FF00h      ; CODE XREF: 0000:0D78j
                mov     dx, ax

                jmp     loc_0_E19

loc_0_D8F:      call    getbyte

loc_0_DAD:      mov     ah, 0           ; CODE XREF: 0000:0D9Ej
                mov     dx, ax
                call    getbyte

                mov     ah, 0           ; CODE XREF: 0000:0DC0j
                mov     si, ax
                and     ax, 0FFF8h
                mov     cl, 5
                shl     ax, cl
                or      ax, 0E000h
                or      dx, ax
                and     si, 7
                add     si, 2
                cmp     si, 2
                jnz     loc_0_E19
                call    getbyte

loc_0_E08:      mov     ah, 0           ; CODE XREF: 0000:0DF9j
                mov     si, ax
                or      si, si
                jz      exit
                cmp     si, 1
                jnz     loc_0_E18
                jmp     loc_0_D20

loc_0_E18:      inc     si              ; CODE XREF: 0000:0E13j

loc_0_E19:      ; CODE XREF: 0000:0D8Cj 0000:0DE8j
                MOVsX   EDX, DX
                add     edx, edi
                jmp     loc_0_E33

loc_0_E21:      mov     ebx, edx          ; CODE XREF: 0000:0E35j
                mov     al, [ebx]
                mov     [edi], al
                inc     edi
                dec     si
                inc     edx
                cmp     edi, offset outbuf + MAX_unpacked
                ja      exit

loc_0_E33:      or      si, si          ; CODE XREF: 0000:0E1Fj 0000:0E2Ej
                jg      loc_0_E21
                jmp     loc_0_D20

exit:           ret




getbyte:        push    ebx
                mov     ebx, next_byte_ptr; CODE XREF: 0000:0C8Cj
                mov     al, [ebx]        ; CODE XREF: 0000:0CDEj
                pop     ebx
                inc     next_byte_ptr
                ret

get_bit:        mov     dx, bits; CODE XREF: 0000:0D20p 0000:0D53p 0000:0D5Ap 0000:0D61p
                and     dx, 1
                mov     al, len
                add     al, -1
                mov     len, al
                jnz     shr_XXX

                call    getbyte
                push    ax              ; CODE XREF: 0000:0E66j
                call    getbyte
                pop     bx              ; CODE XREF: 0000:0E85j
                mov     ah, bl
                xchg    ah, al
                mov     bits, ax
                mov     len, 16
                jmp     c1

shr_XXX:        shr     bits, 1 ; CODE XREF: 0000:0E55j

c1:             mov     ax, dx          ; CODE XREF: 0000:0EA3j
                ret

; ===================== pack avc ============================================

pack_avc:               ;; not implemented

                        lea     edx, packedavc_msg
                        call    msg

                        call    ExitProcess

; ===================== unpack lib =========================================

unp_lib:                xor     ebp, ebp
                        mov     count, 0

@@1:                    lea     edx, avcbase    ; .av5
                        lea     edi, TEMPDWORD
                        mov     ecx, 8
                        mov     ebx, ebp
                        call    load

                        cmp     bytesread, 0
                        je      @@exit

                        add     ebp, 8
                        sub     TEMPDWORD, 8

                        lea     edx, avcbase
                        lea     edi, PACKED
                        mov     ecx, TEMPDWORD
                        cmp     ecx, MAX_PACKED+MAX_UNPACKED
                        ja      error_4
                        mov     ebx, ebp
                        call    load

                        inc     count
                        movzx   ecx, word ptr count

                        call    gen_sux_names

                        lea     edx, sux_obj
                        lea     edi, PACKED
                        mov     ecx, TEMPDWORD
                        mov     ebx, __create
                        call    save

                        add     ebp, TEMPDWORD

                        jmp     @@1

@@exit:                 lea     edx, unpackedlib_msg
                        call    msg

                        call    ExitProcess

; ===================== pack lib =========================================

pack_lib:               ; not implemented

                        lea     edx, packedlib_msg
                        call    msg

                        call    ExitProcess

                        end     start

