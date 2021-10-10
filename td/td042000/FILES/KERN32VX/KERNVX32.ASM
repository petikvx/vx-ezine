.386p
.model flat
include exeption.inc
.DATA
include dinav2.inc
db '(c) Voodoo//SMF 31.03.2000'
extrn   MessageBeep:PROC  ; Только лишь для того чтобы прога запускалась.
                          ; Без импoртов прога не запускаетя и тд32 глючит.
;-----------------------------------------------------------------------------
MyCode:
; Сюда передаёт управление DINA v2.0
; Код работает в стеке.
           call @MyCodeL1
@Hello:      db 'Hello from stack !!!',0
@MyCodeL1:   pop ebx
call GetKernelHahdlerA ; Получаем  в EDI=KernelHahdler
                       ; для инициализации VX кернела
call Kern32VxInit      ; Инициализация VX кернела
; Получим  User32Hahdler
          call LpL
@UserName    db 'USER32.dll',0
LpL:         push zGetModuleHandleA ; Вызов GetModuleHandleA
             EXEPTION              ; в стеке offset на USER32.DLL
             mov edi,eax
             add eax,[eax+3ch] ; eax=offset 2 PE
             mov esi,[eax+78h] ; esi=Export Table RVA 2 USER32.dll
             ;-------------
             xor eax,eax
             pop dword ptr  fs:[eax]
             pop eax
             ;-------------
            call Kern32VxInit ; Инициализация VX кернела но для User32.dll
            push 0
            push ebx
            push ebx
            push 0
            push zMessageBoxA
            EXEPTION
             ;-------------
             xor eax,eax
             pop dword ptr  fs:[eax]
             pop eax
             ;-------------
             call GetKernelHahdlerA
             call Kern32VxInit   ; Инициализация VX кернела для KERNEL32.dll
             push 0             ; Выход из проги.
             push zExitProcess   ;
             EXEPTION           ;
include kern32vx.inc
;-----------------------------------------------------------------------------
EndMyCode:
.data?
buffer db 1024 dup(?)
.CODE
MyCodeSize equ offset EndMyCode- offset MyCode
KernVX32:
mov eax,MyCodeSize
call GetKernelHahdlerA ; Получаем
                       ; в EDI=KernelHahdler
                       ; в ESI=Export Table RVA
                       ; для инициализации VX кернела
call Kern32VxInit      ; Инициализация VX кернела
   ;--------------------
   ; Делаем Randomaze
    push offset buffer
    push zGetSystemTime  ; Вызов GetSystemTime
    EXEPTION            ;
    mov RandSeed,eax
   ;-----------------
   ; Выделяем память для генерации кода
    push MyCodeSize*10 ; K<=10
    push 0
    push zGlobalAlloc
    EXEPTION
    push eax
    push zGlobalLock
    EXEPTION
    ;-------------------
    mov edi,eax            ;edi=Смещение на наш буфер
    mov esi,offset MyCode  ;esi=Наш код каторый мы "полиморфим"
    mov ecx,MyCodeSize     ;ecx=Его размер
    call MakePolyImg       ;На выходе eax=Размер сгенерированного кода
    ;--------------------
    xor eax,eax  ; Анинсталим VX кернел
    pop dword ptr fs:[eax] ;
    pop eax      ;
    jmp edi      ; Отдаем управление сгенерированному коду.
                 ;
    push 0
    push zExitProcess
    EXEPTION
exit_:
Ends
End KernVX32

