; Переход в нулевое кольцо под Win9x 
; Метод: Модификация контекста с использованием Win API

.586p
.model flat

callW           macro   x
                extern  x:PROC
                call    x
                endm

.data

;===== переменные ==============================================================
thread1_finished        db      0

thread1_handle          dd      ?
thread1_id              dd      ?

thread1_context:
c_contextflags          dd      -1
c_dr0                   dd      ?
c_dr1                   dd      ?
c_dr2                   dd      ?
c_dr3                   dd      ?
c_dr6                   dd      ?
c_dr7                   dd      ?
c_fpu_controlword       dd      ?
c_fpu_statusword        dd      ?
c_fpu_tagword           dd      ?
c_fpu_erroroffset       dd      ?
c_fpu_errorselector     dd      ?
c_fpu_dataoffset        dd      ?
c_fpu_dataselector      dd      ?
c_fpu_registerarea      db      80 dup (?)
c_fpu_cr0npxstate       dd      ?
c_gs                    dd      ?
c_fs                    dd      ?
c_es                    dd      ?
c_ds                    dd      ?
c_edi                   dd      ?
c_esi                   dd      ?
c_ebx                   dd      ?
c_edx                   dd      ?
c_ecx                   dd      ?
c_eax                   dd      ?
c_ebp                   dd      ?
c_eip                   dd      ?
c_cs                    dd      ?
c_eflags                dd      ?
c_esp                   dd      ?
c_ss                    dd      ?
;===============================================================================

_Start:

; создаём новую нитку
                push    offset thread1_id       ; угазатель на ID нитки
                push    0                       ; флаги
                push    0                       ; мутота
                push    offset thread1_r3_code  ; точка входа в нитку
                push    0                       ; размер стэка
                push    0                       ; атрибута
                callW   CreateThread            ; создать новую нить
                mov     thread1_handle, EAX

; получаем контекст(регистры) нити
                push    offset thread1_context  ; указатель на контекст
                push    thread1_handle          ; хендл нитки
                callW   GetThreadContext        ; получаем контекст

; изменяем контекст - установливаем CS:EIP на наш код нулевого кольца
                mov     c_cs, 28h
                mov     c_eip, offset ring0_proc

; применяем измененный контекст
                push    offset thread1_context  ; указатель на контекст
                push    thread1_handle          ; хендл нитки
                callW   SetThreadContext        ; применяем контекст

; дожедаемся окончания работы нитки
__waitcycle:    cmp     thread1_finished, 1
                jne     __waitcycle

; выходим из нитки
__exit:         jmp     exit
                

; начальный код нити третьего кольца
thread1_r3_code:
__cycle:        push    1
                callW   Sleep
                jmp     __cycle

; код в нулевом кольце!
ring0_proc:                             ; r0 start
                push    ss ss
                pop     ds es
                pushad

; Ждем нажатия Esc
WaitESC:                                
                in      AL, 60h
                cmp     AL, 1         
                jne     WaitESC

                popad
                mov     thread1_finished, 1 ; устанавливаем флаг завершённости
                jmp     $

.code

start:
                call        _Start
exit:
                push        00000000h
                callW       ExitProcess
end start