;(c) RedArc
;Простенькая демка по калькуляции адресов переходов
Model Tiny
.code
org 100h
start:
       lea si,MetkaDown
       lea di,JumpMetkaDown
       mov bx,100h
       call CalcJump
       jmp JumpMetkaDown
       db 10 dup (90h)
MetkaUp:
       ret
JumpMetkaDown:
       db 0e9h
       dw 01234h
       db 100 dup (90h)
MetkaDown:
       lea si,MetkaUp
       lea di,JumpMetkaUp
       mov bx,100h
       call CalcJump
       jmp JumpMetkaUp
       db 10 dup (90h)
JumpMetkaUp:
       db 0e9h
       dw 01234h

;--- Калькуляция перехода
;Input:  si - адрес метки для перехода
;        di - адрес команды перехода
;        bx - адрес начала буфера
;Output: none
CalcJump:
         push ax cx dx
         mov ax,di
         mov dx,si
         sub ax,bx
         sub dx,bx
         cmp ax,dx
         jl JumpDown
JumpUp:
         mov cx,0ffffh
         sub ax,dx
         sub cx,ax
         sub cx,2
         xchg dx,cx
         jmp FormJump
JumpDown:
         add ax,3
         sub dx,ax
FormJump:
         mov word ptr ds:[di+1],dx
         pop dx cx ax
         ret
end start
