;Это старый прикол определения трассировки по флагу
.model tiny
.code
org 100h
start:
       push cs
;       push cs
;       pop  ds
       pop  ss
       pushf
       pop  ax
       test ah,1
       jz   norm
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
