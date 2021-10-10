 .model tiny
 .code
  org 100h
Start:
  xor ax,ax
  mov es,ax
  mov [save_ss],ss
  mov [save_sp],sp
  mov ss,ax           ; !!!!!
  mov sp,0ah
  mov ss,[save_ss]
  mov sp,[save_sp]
  mov dx,offset debugger
  mov ah,9
  int 21h
  int 20h
debugger db 'Program RUNZ successfully :)',0dh,0ah,'$'
save_ss dw ?
save_sp dw ?
End Start
