
include                 consts.inc

callW                   macro   x
                        extrn   x:proc
                        call    x
                        endm

                        p386
                        model   flat
                        locals  __
                        jumps

                        .data

pubfile                 db      'KEY\TEST\public.rsa',0
secfile                 db      'KEY\TEST\secret.rsa',0

keyid                   dd      ?               ; used to support
keylen                  dd      KEYLEN          ; RSACRYPT format
numlen                  dd      KEYLEN/8        ; ...

pubkey                  db      PUBKEYSIZE dup (?)
seckey                  db      SECKEYSIZE dup (?)

rndbuf                  db      RNDBUFSIZE dup (?)

x1                      db      'fuck',KEYLEN/8*8-4 dup (0)
x2                      db      KEYLEN/8*8 dup (?)
x3                      db      KEYLEN/8*8 dup (?)

                        .code
start:
                        call    dump_msg
                        db      'RSA KEYGEN (ASM) -- (x) 2000',13,10,0

                        lea     edx, pubfile
                        call    fgetattr
                        jnc     fileexists
                        lea     edx, secfile
                        call    fgetattr
                        jnc     fileexists

                        call    initrndbuf

                        call    dump_msg
                        db      'þ generating ',0
                        mov     eax, KEYLEN
                        call    dump_dec
                        call    dump_msg
                        db      '-bit key...',13,10,0

                        push    offset pubkey
                        push    offset seckey
                        push    offset rndbuf
                        call    keygen

                        call    dump_msg
                        db      'þ testing...',13,10,0

                        push    offset x2               ; x
                        push    offset x1               ; a
                        push    offset pubkey+KEYLEN/8  ; e
                        push    offset pubkey           ; m
                        push    10                      ; e_len
                        call    modexp

                        push    offset x3               ; x
                        push    offset x2               ; a
                        push    offset seckey+KEYLEN/8  ; d
                        push    offset seckey           ; m
                        push    KEYLEN                  ; d_len
                        call    modexp

                        mov     eax, dword ptr x1
                        cmp     eax, dword ptr x3
                        jne     error

                        lea     edx, pubfile
                        lea     esi, pubkey
                        call    savekey

                        lea     edx, secfile
                        lea     esi, seckey
                        call    savekey

quit:                   push    -1
                        callW   ExitProcess

; both PUB/SEC keys are written in RSACRYPT-compatible format,
; BUT secret key contains only m/d, i.e. there is no extra (p,q,...) info

savekey:                pusha
                        call    dump_msg
                        db      'þ writing ',0
                        call    dump_asciiz_edx
                        call    dump_crlf
                        popa

                        call    fcreate
                        xchg    ebx, eax

                        mov     ecx, KEYLEN/32          ; calc keyhash --
                        xor     eax, eax                ; dwordxored m[]
__xor:                  xor     eax, [esi+ecx*4-4]
                        loop    __xor
                        mov     keyid, eax

                        lea     edx, keyid
                        mov     ecx, 4+4+4
                        call    fwrite
                        mov     edx, esi
                        mov     ecx, KEYLEN/8
                        call    fwrite
                        lea     edx, numlen
                        mov     ecx, 4
                        call    fwrite
                        lea     edx, [esi+KEYLEN/8]
                        mov     ecx, KEYLEN/8
                        call    fwrite
                        call    fclose
                        retn

error:                  call    dump_msg
                        db      '***ERROR***',13,10,0

                        lea     edx, x1
                        call    dump_asciiz_edx
                        call    dump_crlf

                        lea     edx, x2
                        call    dump_asciiz_edx
                        call    dump_crlf

                        lea     edx, x3
                        call    dump_asciiz_edx
                        call    dump_crlf

                        jmp     quit

fileexists:             call    dump_msg
                        db      '***ERROR***: ',0
                        call    dump_asciiz_edx
                        call    dump_msg
                        db      ' alredy exists -- remove old keys first',13,10,0
                        jmp     quit

initrndbuf:             pusha

                        call    dump_msg
                        db      'þ type random sequence...',13,10,0

                        call    initconsole

                        lea     edi, rndbuf
                        mov     ecx, RNDBUFSIZE

__cycle:                mov     eax, ecx
                        call    dump_dec
                        call    dump_msg
                        db      ' ',13,0

                        call    GetRndByte
                        aam     16
                        xor     al, ah
                        shl     al, 4
                        mov     dl, al

                        call    GetRndByte
                        aam     16
                        xor     al, ah
                        or      al, dl

                        stosb

                        loop    __cycle

                        popa
                        retn

getconsoleinputhandle:  push    -10             ; STD_INPUT_HANDLE
                        callW   GetStdHandle
                        xchg    ebx, eax
                        retn

initconsole:            pusha
                        call    getconsoleinputhandle
                        push    ebx
                        callW   FlushConsoleInputBuffer
                        push    1               ; flags: ctrl+c and alike
                        push    ebx
                        callW   SetConsoleMode
                        popa
                        retn

GetRndByte:             pusha
                        call    getconsoleinputhandle

                        callW   GetTickCount
                        xchg    esi, eax

                        lea     eax, [esp].popa_eax
                        push    0
                        push    esp
                        push    1
                        push    esp     ; eax
                        push    ebx
                        callW   ReadConsoleA

                        callW   GetTickCount
                        sub     eax, esi
                        xor     al, ah
                        xor     byte ptr [esp].popa_eax, al

                        popa
                        retn

include                 fioexlow.inc
include                 console.inc

c:
include                 rsalib4.inc
c_size                  equ     $-c

db 13,10
db '-------------------------',13,10
db 'RSALIB used '
db c_size/1000 mod 10 + '0'
db c_size/ 100 mod 10 + '0'
db c_size/  10 mod 10 + '0'
db c_size/   1 mod 10 + '0'
db ' bytes',13,10
db '-------------------------',13,10,13,10

                        end     start
