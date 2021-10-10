.model tiny
.code
	org 100h
main:	mov si,80h
	lodsb
	cmp al,0
	jz NoPack
	add si,ax
	mov byte ptr ds:[si],0
	mov ax,3d00h
	mov dx,82h
	int 21h
	xchg ax,bx
	mov ah,3fh
	mov dx,offset free
	mov cx,0FC00h
	int 21h
	push ax
	mov ah,3eh
	int 21h
	pop cx

	mov si,dx
	xor di,di

	mov ax,ds
	add ax,1000h
	mov es,ax

	push di
	Call RLEP
	mov ah,3ch
	xor cx,cx
	mov dx,offset OutF
	int 21h
	xchg ax,bx

	push es
	pop  ds

	xor si,si
	mov dx,si
	lodsw
	xchg ax,cx
	mov ah,40h
	int 21h
	mov ah,3eh
	int 21h
NoPack:	int 20h
OutF	db	'fout.!!!',0
include	rlep.inc
Free:
end	main