;Оказывается ненормальный Долбаггер сохраняет IP в PSP трассируемой программы
;и можно его перехватить и определить...

.model tiny
.code
org 100h
start:
       mov bx,ds:[0fff8h]
       cmp bx,100h
       jne norm
       mov  dx,offset trase
       jmp  short exit
norm:
       mov  dx,offset notrase
exit:
       mov  ah,9
       int  21h
       mov  ax,4c00h                 
       int  21h
  trase   db 'Run Debugger',0ah,0dh,'$'
  notrase db 'Normal exit',0ah,0dh,'$'         
end start
