; Распаковка Lz78 файлов

.model tiny
.386
.code
	org 100h
Main:	cld
	mov si,80h
	lodsb
	cmp al,0
	jnz zOk
	ret
zOk:	add si,ax
	mov [si],ah
	mov ax,3D00h
	mov dx,82h
	int 21h
	xchg ax,bx

	mov ax,cs
	add ax,1000h
	mov es,ax
	mov ds,ax

	mov ah,3fh
	mov dx,Free
	mov cx,Dest
	int 21h

	mov ah,3eh
	int 21h

	mov si,Free
	mov di,Dest
	Call Lz78u
	push cx es cs
	pop  ds
	mov ah,3ch
	xor cx,cx
	mov dx,offset OutName
	int 21h
	pop  ds
	xchg ax,bx
	mov ah,40h
	mov dx,Dest
	pop cx
	int 21h
	mov ah,3eh
	int 21h
	ret
OutName	db	'unk.lz',0
Free	=	0
Dest	=	32000
include	lz78.inc
End	main