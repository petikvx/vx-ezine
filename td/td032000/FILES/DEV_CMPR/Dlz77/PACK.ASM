
.model tiny
.386
.code
	org 100h
Main:	mov si,80h			; ���������� ��ப�
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

	mov ah,3fh
	mov dx,offset Free
	mov cx,Dest
	int 21h
	push ax
	mov ah,3eh
	int 21h
	pop  cx
	mov si,offset Free		; ���⨥
	mov di,Dest
	Call DLz77c
	push cx ds cs
	pop  ds
	mov ah,3ch
	xor cx,cx
	mov dx,offset OutName
	int 21h
	pop  ds
	xchg ax,bx
	mov ah,40h
	mov dx,offset Dest
	pop cx
	int 21h
	mov ah,3eh
	int 21h
	ret
OutName	db	'out.lz7',0
include	dlz77.inc
Free	equ	$+2000
Dest	=	32000
End	main